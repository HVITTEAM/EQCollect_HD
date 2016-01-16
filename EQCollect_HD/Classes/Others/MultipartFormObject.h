//
//  MultipartFormObject.h
//  EQCollect_HD
//
//  Created by shi on 15/12/24.
//  Copyright © 2015年 董徐维. All rights reserved.

//图片数据类，上传图片时使用

#import <Foundation/Foundation.h>

@interface MultipartFormObject : NSObject

@property(strong,nonatomic)NSData *fileData;             //文件数据

@property(copy,nonatomic)NSString *name;                 //名字，与服务器对应

@property(copy,nonatomic)NSString *fileName;             //文件名

@property(copy,nonatomic)NSString *mimeType;            //数据的类型

@end
