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
    newModel.cla = self.cla;
    newModel.modelType = self.modelType;
    newModel.single = self.isSingle;
    newModel.singletonMethodStr = self.singletonMethodStr;
    
    return newModel;
}

@end






