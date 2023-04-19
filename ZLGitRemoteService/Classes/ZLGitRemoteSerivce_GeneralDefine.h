//
//  ZLGitRemoteSerivce_GeneralDefine.h
//  Pods
//
//  Created by 朱猛 on 2021/9/27.
//

#ifndef ZLGitRemoteSerivce_GeneralDefine_h
#define ZLGitRemoteSerivce_GeneralDefine_h

// 宏定义， 静态常量
#import "ZLLogModuleProtocol.h"
#import <SYDCentralPivot/SYDCentralFactory.h>

#define ZLMainThreadDispatch(a)     if([NSThread isMainThread]){ a }else{dispatch_async(dispatch_get_main_queue(), ^{ a });}

#define ZLLOGMODULE  [[SYDCentralFactory sharedInstance] getCommonBean:@"ZLLogModule"]


#pragma mark - 日志模块快速调用宏

#define ZLLog_Error(fmt, ...)    [ZLLOGMODULE  ZLLogError:__PRETTY_FUNCTION__ file:__FILE__ line:__LINE__ format:fmt, ##__VA_ARGS__];
#define ZLLog_Warning(fmt, ...)  [ZLLOGMODULE  ZLLogWarning:__PRETTY_FUNCTION__ file:__FILE__ line:__LINE__ format:fmt, ##__VA_ARGS__];
#define ZLLog_Info(fmt, ...)     [ZLLOGMODULE  ZLLogInfo:__PRETTY_FUNCTION__ file:__FILE__ line:__LINE__ format:fmt, ##__VA_ARGS__];
#define ZLLog_Debug(fmt, ...)    [ZLLOGMODULE  ZLLogDebug:__PRETTY_FUNCTION__ file:__FILE__ line:__LINE__ format:fmt, ##__VA_ARGS__];
#define ZLLog_Verbose(fmt, ...)  [ZLLOGMODULE  ZLLogVerbose:__PRETTY_FUNCTION__ file:__FILE__ line:__LINE__ format:fmt, ##__VA_ARGS__];


static const NSNotificationName ZLGithubTokenInvalid_Notification = @"ZLGithubTokenInvalid_Notification";

typedef void(^GithubResponse)(BOOL,id _Nullable ,NSString * _Nonnull);

#endif /* ZLGitRemoteSerivce_GeneralDefine_h */
