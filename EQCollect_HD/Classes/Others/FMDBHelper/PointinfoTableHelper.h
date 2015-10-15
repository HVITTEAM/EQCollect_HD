//
//  FMDBHelper.h
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/7.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//  调查点表

#import <Foundation/Foundation.h>
@class PointModel;

@interface PointinfoTableHelper : NSObject
{
    FMDatabase *db;
    NSString *database_path;
}

+(PointinfoTableHelper *)sharedInstance;
/**初始化数据库**/
- (void)initDataBase;
/**创建表**/
- (void)createTable;
/**插入数据**/
-(BOOL) insertDataWith:(NSDictionary *)dict;
/**根据某个字段删除数据**/
-(BOOL) deleteDataByAttribute:(NSString *)attribute value:(NSString *)value;
/**查询数据**/
- (NSMutableArray *)selectData;
/**更新数据**/
-(BOOL) updateDataWith:(NSDictionary *)dict;
/**更新上传标识**/
-(BOOL)updateUploadFlag:(NSString *)uploadFlag ID:(NSString *)idString;
@end
