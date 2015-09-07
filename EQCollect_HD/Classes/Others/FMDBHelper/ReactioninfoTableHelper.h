//
//  ReactioninfoTableHelper.h
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/7.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//   人物反应信息表

#import <Foundation/Foundation.h>

@interface ReactioninfoTableHelper : NSObject
{
    FMDatabase *db;
    NSString *database_path;
}

+(ReactioninfoTableHelper *)sharedInstance;
/**初始化数据库**/
- (void)initDataBase;
/**创建表**/
- (void)createTable;
/**插入数据**/
- (void)insertData;
/**查询数据**/
- (void)selectData;
@end
