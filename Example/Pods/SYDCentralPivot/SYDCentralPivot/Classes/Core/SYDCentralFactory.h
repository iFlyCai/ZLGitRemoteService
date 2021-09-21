//
//  SYDCentralFactory.h
//  SYDServiceSDK
//
//  Created by zhumeng on 2019/1/9.
//  Copyright © 2019年 zhumeng. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SYDLog(format,...) [[SYDCentralFactory sharedInstance] handleLog:[NSString stringWithFormat:format,##__VA_ARGS__]];

@class SYDCentralRouterModel;

@interface SYDCentralFactory : NSObject

#pragma mark - SYDCentralFactory 单例

+ (instancetype _Nonnull) sharedInstance;

- (void) addConfig:(NSArray <SYDCentralRouterModel *>  * _Nonnull ) configs;

- (void) addConfigWithFilePath:(NSString * _Nonnull) filePath withBundle:(NSBundle * _Nullable) bundle;

#pragma mark - 获取 SYDCentralRouterModel

- (SYDCentralRouterModel * _Nullable) getCentralRouterModel:(const NSString * _Nonnull) beanKey;

- (Class _Nullable) getBeanClass:(const NSString * _Nonnull) beanKey;

#pragma mark - 获取实例

- (id _Nullable) getCommonBean:(const NSString * _Nonnull) beanKey;

- (id _Nullable) getCommonBean:(const NSString * _Nonnull) beanKey withInjectParam:(NSDictionary * _Nonnull) param;

#pragma mark - 日志处理

//
- (void) addLogHandler:(void(^_Nonnull)(NSString *_Nonnull)) handler;

- (void) handleLog:(NSString * _Nonnull) message;

@end


