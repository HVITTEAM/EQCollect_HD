//
//  CurrentUser.h
//  EQCollect_HD
//
//  Created by shi on 15/12/24.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrentUser : NSObject

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *jobid;
@property (nonatomic, copy) NSString *groupid;
@property (nonatomic, copy) NSString *roleid;
@property (nonatomic, copy) NSString *userccount;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *userpwd;
@property (nonatomic, copy) NSString *useraddress;
@property (nonatomic, copy) NSString *userstatus;
@property (nonatomic, copy) NSString *userlon;
@property (nonatomic, copy) NSString *userlat;
@property (nonatomic, copy) NSString *usertel;
@property (nonatomic, copy) NSString *jobname;
@property (nonatomic, copy) NSString *groupname;
@property (nonatomic, copy) NSString *success;

@property (nonatomic, copy) NSString *pointgroup;
@property (nonatomic, copy) NSString *pointperson;

+(instancetype)shareInstance;

@end
