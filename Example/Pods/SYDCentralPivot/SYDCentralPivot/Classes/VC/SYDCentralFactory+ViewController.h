//
//  SYDCentralFactory.h
//  SYDServiceSDK
//
//  Created by zhumeng on 2019/1/9.
//  Copyright © 2019年 zhumeng. All rights reserved.
//

#import "SYDCentralFactory.h"

@interface SYDCentralFactory (ViewController)

#pragma mark - UI跳转

- (Class _Nullable) getViewControllerClass:(const NSString * _Nonnull) viewControllerKey;

- (UIViewController * _Nullable) getOneUIViewController:(const NSString * _Nonnull) viewControllerKey;

- (UIViewController * _Nullable) getOneUIViewController:(const NSString * _Nonnull) viewControllerKey withInjectParam:(NSDictionary * _Nonnull) param;


@end
