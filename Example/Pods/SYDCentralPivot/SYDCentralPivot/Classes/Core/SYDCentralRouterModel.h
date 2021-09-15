//
//  SYDCentralRouterModel.h
//  SYDServiceSDK
//
//  Created by zhumeng on 2019/1/7.
//  Copyright © 2019年 zhumeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark -

typedef NS_ENUM(NSInteger,SYDCentralRouterModelType){
    SYDCentralRouterModelType_UIViewController,
    SYDCentralRouterModelType_Service,
    SYDCentralRouterModelType_Other
};


@interface SYDCentralRouterModel : NSObject <NSCopying>

@property(nonatomic,strong) NSString * modelKey;

@property(nonatomic,assign) SYDCentralRouterModelType modelType;

@property(nonatomic,strong) Class cla;

@property(nonatomic,assign,getter=isSingle) BOOL single;                                      // 是否为单例类

@property(nonatomic,strong) NSString * singletonMethodStr;                      // 单例方法；仅当isSingle为YES有效

//@property(nonatomic,strong) id singleton;                                       // 单例；仅当isSingle为YES有效

@end







