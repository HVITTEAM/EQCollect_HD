//
//  MessageModel.h
//  EQCollect_HD
//
//  Created by shi on 15/11/14.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageModel : NSObject
@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *phoneNum;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *pointid;
@property (nonatomic, copy) NSString *upload;
@end
