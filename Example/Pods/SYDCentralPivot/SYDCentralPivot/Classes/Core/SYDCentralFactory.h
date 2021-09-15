//
//  SYDCentralFactory.h
//  SYDServiceSDK
//
//  Created by zhumeng on 2019/1/9.
//  Copyright © 2019年 zhumeng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SYDCentralRouterModel.h"

@interface SYDCentralFactory : NSObject

@property(nonatomic,strong) NSMutableDictionary * _Nullable viewControllerModelMapCache;

@property(nonatomic,strong) NSMutableDictionary * _Nullable serviceModelMapCache;

@property(nonatomic,strong) NSMutableDictionary * _Nullable otherMapCache;


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

- (id _Nullable) getSingleton:(const NSString * _Nonnull) beanKey;

@end


