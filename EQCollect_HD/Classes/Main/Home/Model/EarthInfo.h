//
//  EarthInfo.h
//  EQCollect_HD
//
//  Created by shi on 15/11/16.
//  Copyright © 2015年 董徐维. All rights reserved.
//

//{
//    deep = "1.5";
//    earthid = 5;
//    earthlevel = "\U2160\U7ea7\U3001\U2161\U7ea7\U54cd\U5e94";
//    earthstage = "\U7b2c\U4e00\U9636\U6bb5";
//    earthstatus = 1;
//    earthtime = "2015-11-01T16:00:00Z";
//    from = test;
//    ftime = "2015-11-01T16:00:00Z";
//    lat = "30.686477";
//    location = "\U6d59\U6c5f\U7701\U6e56\U5dde\U5e02\U5434\U5174\U533a\U57ed\U6eaa\U9547\U674e\U5bb6\U5751";
//    lon = "119.893232";
//    ml = "2.1";
//    planid = 1;
//    planname = "\U6d4b\U8bd5";
//    starttime = "2015-11-12T01:21:30Z";
//    type = 1;
//}

#import <Foundation/Foundation.h>

@interface EarthInfo : NSObject

@property(nonatomic,copy)NSString *deep;
@property(nonatomic,copy)NSString *earthid;
@property(nonatomic,copy)NSString *earthlevel;
@property(nonatomic,copy)NSString *earthstage;
@property(nonatomic,copy)NSString *earthstatus;
@property(nonatomic,copy)NSString *earthtime;
@property(nonatomic,copy)NSString *from;
@property(nonatomic,copy)NSString *ftime;
@property(nonatomic,copy)NSString *lat;
@property(nonatomic,copy)NSString *lon;
@property(nonatomic,copy)NSString *location;
@property(nonatomic,copy)NSString *ml;
@property(nonatomic,copy)NSString *planid;
@property(nonatomic,copy)NSString *planname;
@property(nonatomic,copy)NSString *starttime;
@property(nonatomic,copy)NSString *type;

@end

