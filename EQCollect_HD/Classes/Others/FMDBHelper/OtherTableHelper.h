//
//  OtherTableHelper.h
//  EQCollect_HD
//
//  Created by shi on 15/12/10.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OtherModel;

@interface OtherTableHelper : NSObject
{
    FMDatabase *db;
    NSString *database_path;
}

+(OtherTableHelper *)sharedInstance;

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
-(BOOL)insertDataWithOtherinfoModel:(OtherModel *)model;

/**
 *  根据某个字段删除数据
 */
-(BOOL)deleteDataByAttribute:(NSString *)attribute value:(NSString *)value;

/**
 *  查询数据
 */
- (NSMutableArray *)selectData;

/**
 *  根据字段查询数据
 */
-(NSMutableArray *) selectDataByAttribute:(NSString *)attribute value:(NSString *)value;

/**
 *  更新数据
 */
-(BOOL)updateDataWithOtherinfoModel:(OtherModel *)model;

/**
 *  更新上传标识
 */
-(BOOL)updateUploadFlag:(NSString *)uploadFlag ID:(NSString *)idString;

@end
