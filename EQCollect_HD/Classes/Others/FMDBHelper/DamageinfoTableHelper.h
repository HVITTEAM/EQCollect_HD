//
//  DamageinfoTableHelper.h
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/7.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//   房屋震害信息表

#import <Foundation/Foundation.h>

@interface DamageinfoTableHelper : NSObject
{
    FMDatabase *db;
    NSString *database_path;
}

+(DamageinfoTableHelper *)sharedInstance;
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
/**根据字段查询数据**/
-(NSMutableArray *) selectDataByAttribute:(NSString *)attribute value:(NSString *)value;
/**获得数据表中数据的最大id值 **/
-(NSInteger)getMaxIdOfRecords;
/**更新数据**/
-(BOOL) updateDataWith:(NSDictionary *)dict;
@end
