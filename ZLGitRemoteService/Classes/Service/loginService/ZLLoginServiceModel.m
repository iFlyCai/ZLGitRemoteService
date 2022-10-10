//
//  ZLLoginServiceModel.m
//  ZLGitHubClient
//
//  Created by 朱猛 on 2019/7/7.
//  Copyright © 2019 ZM. All rights reserved.
//

#import "ZLLoginServiceModel.h"

// network
#import "ZLGithubHttpClient.h"

//
#import "ZLSharedDataManager.h"

#import "ZLGitRemoteService-Swift.h"

@interface ZLLoginServiceModel()

@property(nonatomic,assign) NSString * currentLoginSerialNumber;

@end

@implementation ZLLoginServiceModel


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:ZLGithubTokenInvalid_Notification];
}

- (instancetype) init {
    
    if(self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGithubTokenInvalid) name:ZLGithubTokenInvalid_Notification object:nil];
    }
    return self;
}


+ (instancetype) sharedServiceModel {
    
    static ZLLoginServiceModel * serviceModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serviceModel = [[ZLLoginServiceModel alloc] init];
    });
    return serviceModel;
}

- (NSString *)accessToken {
    
    __block NSString *accessToken = nil;
    [ZLBaseServiceModel dispatchSyncInOperationQueue:^{
        accessToken = [ZLSharedDataManager sharedInstance].githubAccessToken;
    }];
    return accessToken;
}


#pragma mark - login action

/**
 * 注销登录
 *
 **/
- (void) logout:(NSString *) serialNumber
{
    [ZLBaseServiceModel dispatchSyncInOperationQueue:^{
        
        ZLLog_Info(@"ZLLogoutProcess: logout[%@]",serialNumber);
      
        [[ZLGithubHttpClient defaultClient] logout:nil serialNumber:serialNumber];
        
        [[ZLSharedDataManager sharedInstance] clearGithubTokenAndUserInfo];
                
        ZLMainThreadDispatch([self postNotification:ZLLogoutResult_Notification withParams:[NSNull null]];)
        
    }];
}

- (void) setAccessToken:(NSString *) token
           serialNumber:(NSString *) serialNumber {
    
    [ZLBaseServiceModel dispatchSyncInOperationQueue:^{
        
        ZLLog_Info(@"ZLLoginProcess: checkTokenIsValid[%@]",serialNumber);
     
        __weak typeof(self) weakSelf = self;
        GithubResponse response = ^(BOOL result, id model, NSString *serialNumber){
            
            ZLLog_Info(@"ZLLoginResult: result[%d]  serialNumber[%@]",result,serialNumber);
            
            ZLOperationResultModel *resultModel = [[ZLOperationResultModel alloc] init];
            resultModel.result = result;
            resultModel.data = model;
            resultModel.serialNumber = serialNumber;
        
            if(result) {
                [[ZLSharedDataManager sharedInstance] setGithubAccessToken:token];
            }
            
            ZLMainThreadDispatch([weakSelf postNotification:ZLLoginResult_Notification withParams:resultModel];)
        };
        
        [[ZLGithubHttpClient defaultClient] checkTokenIsValid:response
                                                        token:token
                                                 serialNumber:serialNumber];
        
    }];
}


#pragma mark -

- (void) onGithubTokenInvalid {

    ZLLog_Info(@"ZLLogoutProcess: onGithubTokenInvliad");
    
    [self logout:[NSString generateSerialNumber]];

}



@end
