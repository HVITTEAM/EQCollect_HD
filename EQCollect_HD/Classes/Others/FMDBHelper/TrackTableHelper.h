//
//  TrackTableHelper.h
//  EQCollect_HD
//
//  Created by shi on 15/11/30.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TrackModel;

@interface TrackTableHelper : NSObject
{
    FMDatabase *db;
    NSString *database_path;
}

+(TrackTableHelper *)sharedInstance;

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
-(BOOL)insertDataWithTrackinfoModel:(TrackModel *)model;

/**
 *  根据某个字段删除数据
 */
-(BOOL)deleteDataByAttribute:(NSString *)attribute value:(NSString *)value;

/**
 *  删除某天之前的数据aDayString格式为 yyyyMMdd
 */
-(BOOL)deleteTracksOfBeforeDay:(NSString *)aDayString;

/**
 *  根据字段查询数据
 */
-(NSMutableArray *)selectDataByAttribute:(NSString *)attribute value:(NSString *)value;
@end
