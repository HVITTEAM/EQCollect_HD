//
//  PictureInfoTableHelper.h
//  EQCollect_HD
//
//  Created by shi on 15/9/16.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PictureMode;

@interface PictureInfoTableHelper : NSObject
{
    FMDatabase *db;
    NSString *database_path;
}

+(PictureInfoTableHelper *)sharedInstance;

/**
 *  初始化数据库
 */
- (void)initDataBase;

/**
 *  创建表
 */
- (void)createTable;

/**
 *  插入数据
 */
//-(BOOL) insertDataWith:(NSDictionary *)dict;
-(BOOL)insertDataWithPictureModel:(PictureMode *)model;

/**
 *  根据字段删除数据，不删除沙盒中的图片
 */
-(BOOL) deleteDataByReleteTable:(NSString *)reltable Releteid:(NSString *)relid;

/**
 *  根据字段查询数据
 */
-(NSMutableArray *) selectDataByReleteTable:(NSString *)reltable Releteid:(NSString *)relid;

/**
 *  根据字段删除沙盒中的图片并删除表中的记录
 */
-(BOOL)deleteImageByReleteTable:(NSString *)reltable Releteid:(NSString *)relid;

/**
 *  根据字段删除沙盒中的图片并删除表中的记录，主要是根据图片名字来删除
 */
-(BOOL) deleteImageByAttribute:(NSString *)attribute value:(NSString *)value;

@end
