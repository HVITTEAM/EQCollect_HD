//
//  PictureVO.h
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/16.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PictureVO : NSObject

@property (nonatomic,copy) NSString *name;
@property (strong, nonatomic)UIImage *image;
@property (strong, nonatomic)NSData *imageData;
//@property (nonatomic,copy)NSString *fileUrl;
@end
