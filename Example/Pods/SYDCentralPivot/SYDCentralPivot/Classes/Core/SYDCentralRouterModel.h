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

@property(nonatomic,copy) NSString* _Nullable modelKey;

@property(nonatomic,assign) SYDCentralRouterModelType modelType;

@property(nonatomic,copy) NSString* _Nullable claStr;

@property(nonatomic,copy) NSString* _Nullable moduleName;                                 // 支持Swift全限定类名

@property(nonatomic,assign,getter=isSingle) BOOL single;                                  // 是否为单例类

@property(nonatomic,strong) NSString* _Nullable singletonMethodStr;                      // 单例方法；仅当isSingle为YES有效



- (instancetype _Nonnull ) initWithModelKey:(NSString *_Nullable) modelKey
                                  modelType:(SYDCentralRouterModelType)modelType
                                     claStr:(NSString* _Nullable ) claStr
                                 moduleName:(NSString* _Nullable) moduleName
                                     single:(BOOL) single
                         singletonMethodStr:(NSString * _Nullable)singletonMethodStr;

@end







