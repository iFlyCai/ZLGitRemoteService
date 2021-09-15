//
//  SYDCentralRouter.h
//  SYDServiceSDK
//
//  Created by zhumeng on 2019/1/7.
//  Copyright © 2019年 zhumeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SYDCentralFactory.h"
#import "SYDCentralRouterModel.h"


@interface SYDCentralRouter : NSObject

@property(nonatomic,strong,readonly) SYDCentralFactory * _Nonnull centralFactory;

+ (instancetype _Nonnull) sharedInstance;

- (void) addConfig:(NSArray <SYDCentralRouterModel *>  * _Nonnull ) configs;

- (void) addConfigWithFilePath:(NSString * _Nonnull) filePath withBundle:(NSBundle * _Nullable) bundle;

@end


