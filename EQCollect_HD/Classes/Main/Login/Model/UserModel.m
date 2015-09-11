//
//  UserModel.m
//  EQCollect_HD
//
//  Created by shi on 15/9/11.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_jobid forKey:@"_jobid"];
    [aCoder encodeObject:_groupid forKey:@"_groupid"];
    [aCoder encodeObject:_roleid forKey:@"_roleid"];
    [aCoder encodeObject:_userccount forKey:@"_userccount"];
    [aCoder encodeObject:_username forKey:@"_username"];
    [aCoder encodeObject:_userpwd forKey:@"_userpwd"];
    [aCoder encodeObject:_useraddress forKey:@"_useraddress"];
    [aCoder encodeObject:_userstatus forKey:@"_userstatus"];
    [aCoder encodeObject:_userlon forKey:@"_userlon"];
    [aCoder encodeObject:_userlat forKey:@"_userlat"];
    [aCoder encodeObject:_usertel forKey:@"_usertel"];
    [aCoder encodeObject:_jobname forKey:@"_jobname"];
    [aCoder encodeObject:_groupname forKey:@"_groupname"];
}

//解码
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self == [super init])
    {
        _jobid = [aDecoder decodeObjectForKey:@"_jobid"];
        _groupid = [aDecoder decodeObjectForKey:@"_groupid"];
        _roleid = [aDecoder decodeObjectForKey:@"_roleid"];
        _userccount = [aDecoder decodeObjectForKey:@"_userccount"];
        _username = [aDecoder decodeObjectForKey:@"_username"];
        _userpwd = [aDecoder decodeObjectForKey:@"_userpwd"];
        _useraddress = [aDecoder decodeObjectForKey:@"_useraddress"];
        _userstatus = [aDecoder decodeObjectForKey:@"_userstatus"];
        _userlon = [aDecoder decodeObjectForKey:@"_userlon"];
        _userlat = [aDecoder decodeObjectForKey:@"_userlat"];
        _usertel = [aDecoder decodeObjectForKey:@"_usertel"];
        _jobname = [aDecoder decodeObjectForKey:@"_jobname"];
        _groupname = [aDecoder decodeObjectForKey:@"_groupname"];
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    UserModel *vo = [[[self class] allocWithZone:zone] init];
    vo.jobid = [self.jobid copyWithZone:zone];
    vo.groupid = [self.groupid copyWithZone:zone];
    vo.roleid = [self.roleid copyWithZone:zone];
    vo.userccount = [self.userccount copyWithZone:zone];
    vo.username = [self.username copyWithZone:zone];
    vo.userpwd = [self.userpwd copyWithZone:zone];
    vo.useraddress = [self.useraddress copyWithZone:zone];
    vo.userstatus = [self.userstatus copyWithZone:zone];
    vo.userlon = [self.userlon copyWithZone:zone];
    vo.userlat = [self.userlat copyWithZone:zone];
    vo.usertel = [self.usertel copyWithZone:zone];
    vo.useraddress = [self.useraddress copyWithZone:zone];
    vo.jobname = [self.jobname copyWithZone:zone];
    vo.groupname = [self.groupname copyWithZone:zone];
    return vo;
}
@end
