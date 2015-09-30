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

/**根据字段删除数据**/
-(BOOL) deleteDataByReleteTable:(NSString *)reltable Releteid:(NSString *)relid;

/**根据字段查询数据**/
-(NSMutableArray *) selectDataByReleteTable:(NSString *)reltable Releteid:(NSString *)relid;

/**根据字段删除沙盒中的图片**/
-(BOOL)deletePictureFromDocumentDirectoryByReleteTable:(NSString *)reltable Releteid:(NSString *)relid;

-(BOOL) deleteImageByAttribute:(NSString *)attribute value:(NSString *)value;

-(BOOL) deleteDataByAttribute:(NSString *)attribute value:(NSString *)value;

@end
