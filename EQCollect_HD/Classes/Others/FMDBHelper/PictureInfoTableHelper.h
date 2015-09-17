//
//  PictureInfoTableHelper.h
//  EQCollect_HD
//
//  Created by shi on 15/9/16.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PictureInfoTableHelper : NSObject
{
    FMDatabase *db;
    NSString *database_path;
}

+(PictureInfoTableHelper *)sharedInstance;
/**初始化数据库**/
- (void)initDataBase;
/**创建表**/
- (void)createTable;
/**插入数据**/
-(BOOL) insertDataWith:(NSDictionary *)dict;
/**删除数据**/
-(BOOL) deleteDataByPictureid:(NSString *)pictureidStr;
///**查询数据**/
//- (NSMutableArray *)selectData;
/**根据字段查询数据**/
-(NSMutableArray *) selectDataByAttribute:(NSString *)attribute value:(NSString *)value;

@end
