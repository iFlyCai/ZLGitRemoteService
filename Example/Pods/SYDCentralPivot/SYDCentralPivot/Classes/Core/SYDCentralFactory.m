//
//  SYDCentralFactory.m
//  SYDServiceSDK
//
//  Created by zhumeng on 2019/1/9.
//  Copyright © 2019年 zhumeng. All rights reserved.
//

#import "SYDCentralFactory.h"

#import <objc/Runtime.h>
#import <objc/message.h>

@interface SYDCentralFactory()

@property(nonatomic,strong) NSMutableDictionary* sydCentralModelMap;

@property(nonatomic,strong) NSMutableDictionary* singletonCache;

@property(nonatomic,strong) dispatch_queue_t concurrentQueue;       // 私有并发队列保证线程安全

@end

@implementation SYDCentralFactory

#pragma mark - 单例

+ (instancetype) sharedInstance{
    
    static SYDCentralFactory * centralFactory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        centralFactory = [[SYDCentralFactory alloc] init];
    });
    
    return centralFactory;
}


- (instancetype) init{
    
    if(self = [super init]){
        self.sydCentralModelMap = [[NSMutableDictionary alloc] init];
        self.singletonCache = [[NSMutableDictionary alloc] init];
        self.concurrentQueue = dispatch_queue_create("SYDCentralFactoryQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}


- (void) addConfig:(NSArray <SYDCentralRouterModel *> *) configs {
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    for(SYDCentralRouterModel * model in configs) {
        if(model.modelKey == nil || model.cla == nil) {
            continue;
        }
        [dic setObject:model forKey:model.modelKey];
    }
    dispatch_barrier_sync(self.concurrentQueue, ^{
        [self.sydCentralModelMap addEntriesFromDictionary:dic];
    });
    
}


- (void) addConfigWithFilePath:(NSString *) filePath withBundle:(NSBundle *) bundle{
    
    NSDictionary * centralRouterConfig = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    
    if(centralRouterConfig){
        
        NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
        
        [centralRouterConfig enumerateKeysAndObjectsUsingBlock:^(id key,id value,BOOL * stop)
         {
            NSString * modelKey = key;
            NSDictionary * modelValue = value;
            
            NSString * classString = [modelValue objectForKey:@"class"];
            Class cla = NSClassFromString(classString);
            
            if(!cla){
                // 支持swift 创建的类
                NSBundle *tmpBundle = bundle;
                if(!tmpBundle){
                    tmpBundle = [NSBundle mainBundle];
                }
                NSString *moduleName = [tmpBundle objectForInfoDictionaryKey:@"CFBundleName"];
               // NSString *classStringName = [NSString stringWithFormat:@"_TtC%lu%@%lu%@", (unsigned long)moduleName.length, moduleName, (unsigned long)classString.length, classString];
                NSString *classStringName = [NSString stringWithFormat:@"%@.%@",  moduleName,classString];
                cla = NSClassFromString(classStringName);
            }
            
            if(cla)
            {
                SYDCentralRouterModelType type = (SYDCentralRouterModelType)((NSNumber *)[modelValue objectForKey:@"type"]).intValue;
                SYDCentralRouterModel * model = [[SYDCentralRouterModel alloc] init];
                
                [model setModelType:type];
                [model setModelKey:modelKey];
                [model setCla:cla];
                [model setSingle:[[modelValue objectForKey:@"isSingle"] boolValue]];
                [model setSingletonMethodStr:[modelValue objectForKey:@"singleMethod"]];
                [dic setObject:model forKey:modelKey];
                
            }
            else
            {
                NSLog(@"SYDCentralFactory_init: class for [%@] not exist",modelKey);
            }
        }];
        
        dispatch_barrier_sync(self.concurrentQueue, ^{
            [self.sydCentralModelMap addEntriesFromDictionary:dic];
        });
    }
    
    
}

- (SYDCentralRouterModel *) getCentralRouterModel:(const NSString *) beanKey{
    if(beanKey == nil){
        return nil;
    }
    __block SYDCentralRouterModel* model = nil;
    dispatch_sync(self.concurrentQueue, ^{
        model = [self.sydCentralModelMap objectForKey:beanKey];
    });
    return model;
}


- (Class) getBeanClass:(const NSString *) beanKey{
    SYDCentralRouterModel * model = [self getCentralRouterModel:beanKey];
    return model.cla;
}

- (id) getCommonBean:(const NSString *) beanKey{
    
    if(beanKey == nil){
        return nil;
    }
    
    SYDCentralRouterModel * model = [self getCentralRouterModel:beanKey];
    
    id commomBean = nil;
    
    if(model){
        if(model.isSingle){
            commomBean = [self getSingleton:beanKey];
            if(!commomBean){
                NSLog(@"SYDCentralFactory_getCommonBean: create singleton for [%@] failed",beanKey);
            }
        }
        else{
            commomBean = class_createInstance([model cla], 0);
        }
    }
    else{
        NSLog(@"SYDCentralFactory_getCommonBean: SYDCentralRouterModel for [%@] is not exist",beanKey);
    }
    
    return commomBean;
    
}


- (id) getCommonBean:(const NSString *) beanKey withInjectParam:(NSDictionary *) param{
    
    id commonBean = [self getCommonBean:beanKey];
    
    if(commonBean){
        [param enumerateKeysAndObjectsUsingBlock:^(id key,id value,BOOL * stop){
            NSString * tmpKey = key;
            
            @try{
                [commonBean setValue:value forKey:tmpKey];
            }
            @catch(NSException * exception){
                NSLog(@"SYDCentralFactory_getCommonBeanWithInjectParam: value for key[%@] not exist,exception[%@]",beanKey,exception);
            }
            
        }];
    }
    
    return commonBean;
}

- (id) getSingleton:(const NSString *) beanKey{
    
    if(beanKey == nil){
        return nil;
    }
    
    __block id singleton = nil;
    dispatch_sync(self.concurrentQueue, ^{
        singleton = [self.singletonCache objectForKey:beanKey];
    });
    if(singleton){
        return singleton;
    }
    
    SYDCentralRouterModel * model = [self getCentralRouterModel:beanKey];
    
    if(model){
        
        if(model.isSingle && model.singletonMethodStr){
            
            SEL singleMethodSel = NSSelectorFromString(model.singletonMethodStr);
            Method singletonMethod = class_getClassMethod(model.cla,singleMethodSel);
            id(*singletonMethodIMP)(id,SEL) = (id(*)(id,SEL))method_getImplementation(singletonMethod);
            
            if(singletonMethodIMP){
                singleton = singletonMethodIMP(model.cla,singleMethodSel);
                if(singleton){
                    dispatch_barrier_sync(self.concurrentQueue, ^{
                        [self.singletonCache setObject:singleton forKey:beanKey];
                    });
                }
            }
            else{
                NSLog(@"SYDCentralFactory_getSingleton: singleton method for [%@] not exist",beanKey);
            }
            
        }
        else{
            NSLog(@"SYDCentralFactory_getSingleton: SYDCentralRouterModel for [%@] is not singleton",beanKey);
        }
    }
    else{
        NSLog(@"SYDCentralFactory_getSingleton: SYDCentralRouterModel for [%@] is not exist",beanKey);
    }
    
    return singleton;
}


@end








