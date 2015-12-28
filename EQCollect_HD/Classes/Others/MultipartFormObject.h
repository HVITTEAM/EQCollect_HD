//
//  MultipartFormObject.h
//  EQCollect_HD
//
//  Created by shi on 15/12/24.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MultipartFormObject : NSObject

@property(strong,nonatomic)NSData *fileData;

@property(copy,nonatomic)NSString *name;

@property(copy,nonatomic)NSString *fileName;

@property(copy,nonatomic)NSString *mimeType;

@end
