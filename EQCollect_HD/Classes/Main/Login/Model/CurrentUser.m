//
//  CurrentUser.m
//  EQCollect_HD
//
//  Created by shi on 15/12/24.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import "CurrentUser.h"

@implementation CurrentUser

+(instancetype)shareInstance
{
    static CurrentUser *user = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        user = [[CurrentUser alloc] init];
    });
    return user;
}

@end
