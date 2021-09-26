//
//  NSDate+Format.m
//  ZLGitHubClient
//
//  Created by 朱猛 on 2019/8/25.
//  Copyright © 2019 ZM. All rights reserved.
//

#import "NSDate+Format.h"

@implementation NSDate (Format)



- (NSString *) dateStrForYYYYMMdd
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    
    return [dateFormatter stringFromDate:self];
}


- (NSString *) dateStrForYYYYMMDDTHHMMSSZForTimeZone0
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return [dateFormatter stringFromDate:self];
}

- (NSString *) dateStrForYYYYMMDDTHHMMSSZForTimeZoneCurrent
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    return [dateFormatter stringFromDate:self];
}





@end
