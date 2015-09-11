//
//  UserModel.m
//  EQCollect_HD
//
//  Created by shi on 15/9/11.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel
-(instancetype)initWithNSDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.userid = [dict[@"userid"] integerValue];
        self.jobid = dict[@"jobid"];
        self.groupid = dict[@"groupid"];
        self.roleid = dict[@"roleid"];
        self.userccount = dict[@"userccount"];
        self.username = dict[@"username"];
        self.userpwd = dict[@"userpwd"];
        self.useraddress = dict[@"useraddress"];
        self.userstatus = dict[@"userstatus"];
        self.userlon = dict[@"userlon"];
        self.userlat = dict[@"userlat"];
        self.usertel = dict[@"usertel"];
        self.jobname = dict[@"jobname"];
        self.groupname = dict[@"groupname"];
    }
    return self;
}
@end
