
//
//  UIViewController+SYDRouter.m
//  SYDServiceSDK
//
//  Created by zhumeng on 2019/1/7.
//  Copyright © 2019年 zhumeng. All rights reserved.
//

#import "UIViewController+SYDRouter.h"
#import <objc/runtime.h>
#import "SYDCentralRouterViewControllerConfig.h"
#import "SYDCentralFactory.h"


@implementation UIViewController (SYDRouter)

- (void) setVCKey:(NSString *)VCKey {
    objc_setAssociatedObject(self, "VCKey", VCKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *) VCKey{
    NSString *key = objc_getAssociatedObject(self, "VCKey");
    if(!key){
        key = NSStringFromClass([self class]);
    }
    return key;
}



+ (void) enterViewControllerWithViewControllerConfig:(id) pConfig withParam:(NSDictionary *) paramDic
{
    SYDCentralRouterViewControllerConfig * config = pConfig;
    
    UIViewController * controller = [self getOneViewController];
    controller.hidesBottomBarWhenPushed = config.hidesBottomBarWhenPushed;
    
    /**
     *
     * 传递参数
     **/
    [paramDic enumerateKeysAndObjectsUsingBlock:^(id  key,id value,BOOL * stop)
     {
         NSString * tmpKey = key;
         @try
         {
             [controller setValue:value forKey:tmpKey];
         }
         @catch(NSException * exception)
         {
             SYDLog(@"enterViewControllerWithViewControllerConfig: value for key[%@] not exist,exception[%@]",key,exception);
         }
       
     }];
    
    if(config.isNavigated)
    {
        UINavigationController * navigationController = [config.sourceViewController navigationController];
        [navigationController pushViewController:controller animated:config.animated];
    }
    else
    {
        [config.sourceViewController presentViewController:controller animated:config.animated completion:nil];
    }
    
}


+ (UIViewController *) getOneViewController
{
    return [[self alloc] init];
}


@end


