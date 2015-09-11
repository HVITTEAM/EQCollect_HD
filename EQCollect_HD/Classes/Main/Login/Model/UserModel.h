//
//  UserModel.h
//  EQCollect_HD
//
//  Created by shi on 15/9/11.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <Foundation/Foundation.h>

//{"userid":1,"roleid":null,"userlat":null,"username":"管理员","jobname":null,"groupname":null,"userpwd":"$s0$e0801$HBCjcUcN0Am6pZfzA6CcdA==$Ssd5OpKOIdO+YsxZOci+bN10XKBmDNYLoFAI3Uje010=","userccount":"admin","jobid":null,"userlon":null,"groupid":null,"usertel":"88888888888","useraddress":null,"userstatus":"0"}


@interface UserModel : NSObject

@property (nonatomic, assign) NSInteger userid;
@property (nonatomic, retain) NSString *jobid;
@property (nonatomic, retain) NSString *groupid;
@property (nonatomic, retain) NSString *roleid;
@property (nonatomic, retain) NSString *userccount;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *userpwd;
@property (nonatomic, retain) NSString *useraddress;
@property (nonatomic, retain) NSString *userstatus;
@property (nonatomic, retain) NSString *userlon;
@property (nonatomic, retain) NSString *userlat;
@property (nonatomic, retain) NSString *usertel;
@property (nonatomic, retain) NSString *jobname;
@property (nonatomic, retain) NSString *groupname;

@end
