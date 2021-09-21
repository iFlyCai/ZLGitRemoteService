//
//  SYDCentralRouterModel.m
//  SYDServiceSDK
//
//  Created by zhumeng on 2019/1/7.
//  Copyright © 2019年 zhumeng. All rights reserved.
//

#import "SYDCentralRouterModel.h"

@implementation SYDCentralRouterModel

- (id)copyWithZone:(nullable NSZone *)zone{
    
    SYDCentralRouterModel* newModel = [[SYDCentralRouterModel allocWithZone:zone] init];
    
    newModel.modelKey = self.modelKey;
    newModel.claStr = self.claStr;
    newModel.modelType = self.modelType;
    newModel.single = self.isSingle;
    newModel.moduleName = self.moduleName;
    newModel.singletonMethodStr = self.singletonMethodStr;
    
    return newModel;
}

- (instancetype)initWithModelKey:(NSString *)modelKey
                       modelType:(SYDCentralRouterModelType)modelType
                          claStr:(NSString*)claStr
                      moduleName:(NSString * _Nullable)moduleName 
                          single:(BOOL)single
              singletonMethodStr:(NSString *)singletonMethodStr{
   
    if(self = [super init]){
        self.modelKey = modelKey;
        self.modelType = modelType;
        self.claStr = claStr;
        self.single = single;
        self.moduleName = moduleName;
        self.singletonMethodStr = singletonMethodStr;
    }
    return self;
    
}

@end






