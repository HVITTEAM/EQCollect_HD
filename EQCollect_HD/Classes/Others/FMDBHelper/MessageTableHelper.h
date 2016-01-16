//
//  MessageTableHelper.h
//  EQCollect_HD
//
//  Created by shi on 15/11/14.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MessageModel;

@interface MessageTableHelper : NSObject
{
    FMDatabase *db;
    NSString *database_path;
}

+(MessageTableHelper *)sharedInstance;

/**
 *  插入数据
 */
-(BOOL)insertDataWithMessageinfoModel:(MessageModel *)model;

/**
 *  更新数据
 */
-(BOOL)updateDataWithMessageinfoModel:(MessageModel *)model;

/**
 *  根据某个字段删除数据
 */
-(BOOL)deleteDataByAttribute:(NSString *)attribute value:(NSString *)value;

/**
 *  根据字段查询数据
 */
-(NSMutableArray *)selectDataByAttribute:(NSString *)attribute value:(NSString *)value;

/**
 *  更新上传标识
 */
-(BOOL)updateUploadFlag:(NSString *)uploadFlag ID:(NSString *)idString;

@end
