//
//  ZLLoginServiceHeader.h
//  ZLGitHubClient
//
//  Created by 朱猛 on 2019/7/18.
//  Copyright © 2019 ZM. All rights reserved.
//

#ifndef ZLLoginServiceHeader_h
#define ZLLoginServiceHeader_h

#import "ZLBaseServiceModel.h"

static NSNotificationName const _Nonnull ZLLoginResult_Notification = @"ZLLoginResult_Notification";
static NSNotificationName const _Nonnull ZLLogoutResult_Notification = @"ZLLogoutResult_Notification";

@protocol ZLLoginServiceModuleProtocol <ZLBaseServiceModuleProtocol>


@property(nonatomic, nullable, readonly) NSString* accessToken;


#pragma mark - login action

/**
 * 注销登录
 *
 **/
- (void) logout:(NSString * _Nonnull) serialNumber;

/**
 * 检查access token是否有效
 */

- (void) setAccessToken:(NSString * _Nonnull) token
           serialNumber:(NSString * _Nonnull) serialNumber;


@end

#endif /* ZLLoginServiceHeader_h */
