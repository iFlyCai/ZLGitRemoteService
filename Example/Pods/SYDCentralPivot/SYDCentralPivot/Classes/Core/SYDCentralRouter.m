//
//  SYDCentralRouter.m
//  SYDServiceSDK
//
//  Created by zhumeng on 2019/1/7.
//  Copyright © 2019年 zhumeng. All rights reserved.
//

#import "SYDCentralRouter.h"
#import "SYDCentralFactory.h"
#import "SYDCentralRouterModel.h"
#import <objc/runtime.h>

@interface SYDCentralRouter()

@end


@implementation SYDCentralRouter

+ (instancetype) sharedInstance{
    
    static SYDCentralRouter * centeralRouter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        centeralRouter = [[SYDCentralRouter alloc] init];
    });
    
    return centeralRouter;
}


- (instancetype) init{
    if(self = [super init]){
        _centralFactory = [SYDCentralFactory sharedInstance];
    }
    return self;
}

- (void) addConfigWithFilePath:(NSString *) filePath withBundle:(NSBundle *)bundle{
    [self.centralFactory addConfigWithFilePath:filePath withBundle:bundle];
}

- (void) addConfig:(NSArray<SYDCentralRouterModel *> *)configs {
    [self.centralFactory addConfig:configs];
}



- (id) sendMessage:(NSString *) message
            toBean:(NSString *) modelkey
          withPara:(NSArray *) paramArray
 isInstanceMessage:(BOOL) isInstanceMessage{
    
    SYDLog(@"SYDCentralRouter_sendMessageToBean: modelkey[%@] message[%@] paramArray[%@] isInstanceMessage[%d]",modelkey, message ,paramArray,isInstanceMessage);
    
    if(message == nil || modelkey == nil){
        return nil;
    }
    
    NSInvocation * invocation = nil;
    
    if(isInstanceMessage){
        id bean = [self.centralFactory getCommonBean:modelkey];
        if(!bean){
            SYDLog(@"SYDCentralRouter_sendMessageToBean: bean for [%@] not exist",modelkey);
            return nil;
        }
        SEL sel = NSSelectorFromString(message);
        if(![bean respondsToSelector:sel]){
            SYDLog(@"SYDCentralRouter_sendMessageToBean: bean [%@] can not respondsToInstanceSelector[%@]",modelkey,message);
            return nil;
        }
        invocation =  [SYDCentralRouter injectArguments:paramArray withSelector:sel withReceiver:bean];
        [invocation invoke];
        return [SYDCentralRouter getReturnValue:invocation];
    }
    else{
        
        id beanClass = [self.centralFactory getBeanClass:modelkey];
        if(!beanClass){
            SYDLog(@"SYDCentralRouter_sendMessageToBean: beanClass for [%@] not exist",modelkey);
            return nil;
        }
        SEL sel = NSSelectorFromString(message);
        if(![beanClass respondsToSelector:sel]){
            SYDLog(@"SYDCentralRouter_sendMessageToBean: beanClass [%@] can not respondsToClassSelector[%@]",modelkey,message);
            return nil;
        }
        invocation =  [SYDCentralRouter injectArguments:paramArray withSelector:sel withReceiver:beanClass];
        [invocation invoke];
        return [SYDCentralRouter getReturnValue:invocation];
    }
    
}


+ (NSInvocation *) injectArguments:(NSArray *) argumentArray
                      withSelector:(SEL) message
                      withReceiver:(id) receiver{
    
    NSMethodSignature * methodSignature = [receiver methodSignatureForSelector:message];
    NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setSelector:message];
    [invocation setTarget:receiver];
    
    for(uint index = 0; index < [argumentArray count]; index++)
    {
        id argument = [argumentArray objectAtIndex:index];
        char argumentType = *[methodSignature getArgumentTypeAtIndex:index + 2];
        
        switch(argumentType)
        {
            case _C_ID: //'@':
            {
                //An Object
                [invocation setArgument:&argument atIndex:index+2];
                break;
            }
            case _C_CLASS: //'#':
            {
                //A class object(Class)
                SYDLog(@"injectArguments::not support 'class object'");
                break;
            }
            case _C_SEL://':':
            {
                //A method selector(SEL)
                SYDLog(@"injectArguments::not support 'method selector'");
                break;
            }
            case _C_CHR://'c':
            {
                //A char
                char aArgument = [argument charValue];
                [invocation setArgument:&aArgument atIndex:index + 2];
                break;
            }
            case _C_UCHR://'C':
            {
                //A unsgined char
                unsigned char aArgument = [argument unsignedCharValue];
                [invocation setArgument:&aArgument atIndex:index + 2];
                break;
            }
            case _C_SHT://'s':
            {
                //A short
                short aArgument = [argument shortValue];
                [invocation setArgument:&aArgument atIndex:index + 2];
                break;
            }
            case _C_USHT://'S':
            {
                //A unsgined short
                unsigned short aArgument = [argument unsignedShortValue];
                [invocation setArgument:&aArgument atIndex:index + 2];
                break;
            }
            case _C_INT://'i':
            {
                //An int
                int aArgument = [argument intValue];
                [invocation setArgument:&aArgument atIndex:index + 2];
                break;
            }
            case _C_UINT://'I':
            {
                //An unsgined int
                unsigned int aArgument = [argument unsignedIntValue];
                [invocation setArgument:&aArgument atIndex:index + 2];
                break;
            }
            case _C_LNG://'l':
            {
                //A long
                long aArgument = [argument longValue];
                [invocation setArgument:&aArgument atIndex:index + 2];
                break;
            }
            case _C_ULNG://'L':
            {
                //A unsgined long
                unsigned long aArgument = [argument unsignedLongValue];
                [invocation setArgument:&aArgument atIndex:index + 2];
                break;
            }
            case _C_LNG_LNG://'q':
            {
                //A long long
                long long aArgument = [argument longLongValue];
                [invocation setArgument:&aArgument atIndex:index + 2];
                break;
            }
            case _C_ULNG_LNG://'Q':
            {
                //A unsgined long long
                unsigned long long aArgument = [argument unsignedLongLongValue];
                [invocation setArgument:&aArgument atIndex:index + 2];
                break;
            }
            case _C_FLT://'f':
            {
                //A float
                float aArgument = [argument floatValue];
                [invocation setArgument:&aArgument atIndex:index + 2];
                break;
            }
            case _C_DBL://'d':
            {
                //A double
                double aArgument = [argument doubleValue];
                [invocation setArgument:&aArgument atIndex:index + 2];
                break;
            }
            case _C_BFLD://'b':
            {
                //A bit field of num bits
                SYDLog(@"setNSInvocationArgument::not support 'bit field of num bits'");
                break;
            }
            case _C_BOOL://'B':
            {
                //A C++ bool or aC99 _Bool
                bool aArgument = [argument boolValue];
                [invocation setArgument:&aArgument atIndex:index + 2];
                break;
            }
            case _C_VOID://'v':
            {
                //A void
                SYDLog(@"setNSInvocationArgument::not support 'void'");
                break;
            }
            case _C_UNDEF://'?':
            {
                //A unknow type
                SYDLog(@"setNSInvocationArgument::not support 'unknow type'");
                break;
            }
            case _C_PTR://'^':
            {
                //A pointer to type
                SYDLog(@"setNSInvocationArgument::not support 'pointer to type'");
                break;
            }
            case _C_CHARPTR://'*':
            {
                //A character string(char *)
                SYDLog(@"setNSInvocationArgument::not support 'character string'");
                break;
            }
            case _C_ATOM://'%':
            {
                //A atom
                SYDLog(@"setNSInvocationArgument::not support 'atom'");
                break;
            }
            case _C_ARY_B://'[':
            {
                //A array begin
                SYDLog(@"setNSInvocationArgument::not support 'array begin'");
                break;
            }
            case _C_ARY_E://']':
            {
                //A array end
                SYDLog(@"setNSInvocationArgument::not support 'array end'");
                break;
            }
            case _C_UNION_B://'(':
            {
                //A union begin
                SYDLog(@"setNSInvocationArgument::not support 'union begin'");
                break;
            }
            case _C_UNION_E://')':
            {
                //A union end
                SYDLog(@"setNSInvocationArgument::not support 'union end'");
                break;
            }
            case _C_STRUCT_B://'{':
            {
                //A struct begin
                SYDLog(@"setNSInvocationArgument::not support 'struct begin'");
                break;
            }
            case _C_STRUCT_E://'}':
            {
                //A struct end
                SYDLog(@"setNSInvocationArgument::not support 'struct end'");
                break;
            }
            case _C_VECTOR://'!':
            {
                //A vector
                SYDLog(@"setNSInvocationArgument::not support 'vector'");
                break;
            }
            case _C_CONST://'r':
            {
                //A const
                SYDLog(@"setNSInvocationArgument::not support 'const'");
                break;
            }
            default:
            {
                break;
            }
        }
    }
    
    return invocation;
    
}



+ (id) getReturnValue:(NSInvocation *) invocation{
    
    NSMethodSignature * methodSignature = [invocation methodSignature];
    char returnType = *[methodSignature methodReturnType];
        
    __autoreleasing id returnValue = nil;
    
    switch(returnType)
    {
        case _C_ID: //'@':
        {
            [invocation getReturnValue:&returnValue];
            break;
        }
        case _C_CLASS: //'#':
        {
            break;
        }
        case _C_SEL://':':
        {
            break;
        }
        case _C_CHR://'c':
        {
            //A char
            char aReturnArgument = 0;
            [invocation getReturnValue:&aReturnArgument];
            returnValue = [NSNumber numberWithChar:aReturnArgument];
            break;
        }
        case _C_UCHR://'C':
        {
            //A unsgined char
            unsigned char aReturnArgument = 0;
            [invocation getReturnValue:&aReturnArgument];
            returnValue = [NSNumber numberWithUnsignedChar:aReturnArgument];
            break;
        }
        case _C_SHT://'s':
        {
            //A short
            short aReturnArgument = 0;
            [invocation getReturnValue:&aReturnArgument];
            returnValue = [NSNumber numberWithShort:aReturnArgument];
            break;
        }
        case _C_USHT://'S':
        {
            //A unsgined short
            unsigned short aReturnArgument = 0;
            [invocation getReturnValue:&aReturnArgument];
            returnValue = [NSNumber numberWithUnsignedShort:aReturnArgument];
            break;
        }
        case _C_INT://'i':
        {
            //An int
            int aReturnArgument = 0;
            [invocation getReturnValue:&aReturnArgument];
            returnValue = [NSNumber numberWithInt:aReturnArgument];
            break;
        }
        case _C_UINT://'I':
        {
            //An unsgined int
            unsigned int aReturnArgument = 0;
            [invocation getReturnValue:&aReturnArgument];
            returnValue = [NSNumber numberWithUnsignedInt:aReturnArgument];
            break;
        }
        case _C_LNG://'l':
        {
            //A long
            long aReturnArgument = 0;
            [invocation getReturnValue:&aReturnArgument];
            returnValue = [NSNumber numberWithLong:aReturnArgument];
            break;
        }
        case _C_ULNG://'L':
        {
            //A unsgined long
            unsigned long aReturnArgument = 0;
            [invocation getReturnValue:&aReturnArgument];
            returnValue = [NSNumber numberWithUnsignedLong:aReturnArgument];
            break;
        }
        case _C_LNG_LNG://'q':
        {
            //A long long
            long long aReturnArgument = 0;
            [invocation getReturnValue:&aReturnArgument];
            returnValue = [NSNumber numberWithLongLong:aReturnArgument];
            break;
        }
        case _C_ULNG_LNG://'Q':
        {
            //A unsgined long long
            unsigned long long aReturnArgument = 0;
            [invocation getReturnValue:&aReturnArgument];
            returnValue = [NSNumber numberWithUnsignedLongLong:aReturnArgument];
            break;
        }
        case _C_FLT://'f':
        {
            //A float
            float aReturnArgument = 0;
            [invocation getReturnValue:&aReturnArgument];
            returnValue = [NSNumber numberWithFloat:aReturnArgument];
            break;
        }
        case _C_DBL://'d':
        {
            //A double
            double aReturnArgument = 0;
            [invocation getReturnValue:&aReturnArgument];
            returnValue = [NSNumber numberWithDouble:aReturnArgument];
            break;
        }
        case _C_BFLD://'b':
        {
            //A bit field of num bits
            SYDLog(@"setNSInvocationArgument::not support 'bit field of num bits'");
            break;
        }
        case _C_BOOL://'B':
        {
            //A C++ bool or aC99 _Bool
            bool aReturnArgument = 0;
            [invocation getReturnValue:&aReturnArgument];
            returnValue = [NSNumber numberWithBool:aReturnArgument];
            break;
        }
        case _C_VOID://'v':
        {
            //A void
            SYDLog(@"setNSInvocationArgument::not support 'void'");
            break;
        }
        case _C_UNDEF://'?':
        {
            //A unknow type
            SYDLog(@"setNSInvocationArgument::not support 'unknow type'");
            break;
        }
        case _C_PTR://'^':
        {
            //A pointer to type
            SYDLog(@"setNSInvocationArgument::not support 'pointer to type'");
            break;
        }
        case _C_CHARPTR://'*':
        {
            //A character string(char *)
            SYDLog(@"setNSInvocationArgument::not support 'character string'");
            break;
        }
        case _C_ATOM://'%':
        {
            //A atom
            SYDLog(@"setNSInvocationArgument::not support 'atom'");
            break;
        }
        case _C_ARY_B://'[':
        {
            //A array begin
            SYDLog(@"setNSInvocationArgument::not support 'array begin'");
            break;
        }
        case _C_ARY_E://']':
        {
            //A array end
            SYDLog(@"setNSInvocationArgument::not support 'array end'");
            break;
        }
        case _C_UNION_B://'(':
        {
            //A union begin
            SYDLog(@"setNSInvocationArgument::not support 'union begin'");
            break;
        }
        case _C_UNION_E://')':
        {
            //A union end
            SYDLog(@"setNSInvocationArgument::not support 'union end'");
            break;
        }
        case _C_STRUCT_B://'{':
        {
            //A struct begin
            SYDLog(@"setNSInvocationArgument::not support 'struct begin'");
            break;
        }
        case _C_STRUCT_E://'}':
        {
            //A struct end
            SYDLog(@"setNSInvocationArgument::not support 'struct end'");
            break;
        }
        case _C_VECTOR://'!':
        {
            //A vector
            SYDLog(@"setNSInvocationArgument::not support 'vector'");
            break;
        }
        case _C_CONST://'r':
        {
            //A const
            SYDLog(@"setNSInvocationArgument::not support 'const'");
            break;
        }
        default:
        {
            break;
        }
    }
    return returnValue;
}

@end

