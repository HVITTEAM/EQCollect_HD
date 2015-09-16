//
//  PictureMode.h
//  EQCollect_HD
//
//  Created by shi on 15/9/16.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//


//#define TABLENAME         @"pictureInfo"
//#define PICTUREID         @"pictureid"
//#define PICTURENAME       @"pictureName"
//#define PICTUREPATH       @"picturePath"
//#define POINTID           @"pointid"

#import <Foundation/Foundation.h>

@interface PictureMode : NSObject
@property (nonatomic, copy) NSString *pictureid;
@property (nonatomic, copy) NSString *pictureName;
@property (nonatomic, copy) NSString *picturePath;
@property (nonatomic, copy) NSString *pointid;
@end
