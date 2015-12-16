//
//  NoteModel.h
//  EQCollect_HD
//
//  Created by shi on 15/12/16.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoteModel : NSObject

@property (nonatomic, copy) NSString *resourceid;

@property (nonatomic, copy) NSString *resourcename;

@property (nonatomic, copy) NSString *resourcepath;

@property (nonatomic, copy) NSString *resourcetype;

@property (nonatomic, copy) NSString *taskgroup;

@property (nonatomic, copy) NSString *taskid;

@property (nonatomic, copy) NSString *uploadtime;

@end


//resourceid = 5;
//resourcename = "test.sql";
//resourcepath = "matter/";
//resourcetype = 2;
//taskgroup = "<null>";
//taskid = "<null>";
//uploadtime = "2015-12-16T06:07:45Z";