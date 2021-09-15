//
//  SYDCentralRouterViewControllerConfig.h
//  SYDServiceSDK
//
//  Created by zhumeng on 2019/1/7.
//  Copyright © 2019年 zhumeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYDCentralRouterViewControllerConfig : NSObject

@property(nonatomic,assign) BOOL isNavigated;

@property(nonatomic,strong) UIViewController * sourceViewController;

@property(nonatomic,assign) BOOL hidesBottomBarWhenPushed;

@property(nonatomic,assign) BOOL animated;

@end