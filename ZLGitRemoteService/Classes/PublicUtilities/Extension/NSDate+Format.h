//
//  NSDate+Format.h
//  ZLGitHubClient
//
//  Created by 朱猛 on 2019/8/25.
//  Copyright © 2019 ZM. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Format)

- (NSString *) dateStrForYYYYMMdd;

- (NSString *) dateStrForYYYYMMDDTHHMMSSZForTimeZone0;

- (NSString *) dateStrForYYYYMMDDTHHMMSSZForTimeZoneCurrent;

@end

NS_ASSUME_NONNULL_END
