//
//  PictureInfoTableHelper.m
//  EQCollect_HD
//
//  Created by shi on 15/9/16.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "PictureInfoTableHelper.h"
#import "PictureMode.h"

#define TABLENAME         @"PICTUREINFOTAB"
#define kPictureid         @"pictureid"
#define kPictureName       @"pictureName"
#define kPicturePath       @"picturePath"
#define kReleteid          @"releteid"
#define kReletetable       @"reletetable"


@implementation PictureInfoTableHelper

+(PictureInfoTableHelper *)sharedInstance
{
    static PictureInfoTableHelper *pictureInfoTableHelper;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pictureInfoTableHelper = [[PictureInfoTableHelper alloc] init];
        [pictureInfoTableHelper initDataBase];
        [pictureInfoTableHelper createTable];
    });
    return pictureInfoTableHelper;
}

-(void)initDataBase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    database_path = [documents stringByAppendingPathComponent:DBNAME];
    
    db = [FMDatabase databaseWithPath:database_path];
}

- (void)createTable
{
    if ([db open]) {
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@'INTEGER PRIMARY KEY AUTOINCREMENT, '%@' TEXT, '%@' TEXT,'%@' TEXT,'%@' TEXT)",TABLENAME,kPictureid,kPictureName,kPicturePath,kReleteid,kReletetable];
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating imgaedb table");
        } else {
           NSLog(@"success to creating imgaedb table");
        }
        [db close];
    }
}

//-(BOOL)insertDataWith:(NSDictionary *)dict
//{
//    BOOL result = NO;
//    if ([db open]) {
//        NSString *insertSql1= [NSString stringWithFormat:
//                               @"INSERT INTO '%@' ('%@', '%@', '%@','%@')  VALUES ('%@', '%@', '%@','%@')",
//                               TABLENAME,kPictureName,kPicturePath,kReleteid,kReletetable,dict[@"pictureName"], dict[@"picturePath"],dict[@"releteid"],dict[@"reletetable"]];
//        BOOL res = [db executeUpdate:insertSql1];
//        if (!res) {
//           // NSLog(@"error when insert db Imgtable");
//            result = NO;
//        } else {
//            //NSLog(@"success to insert db Imgtable");
//            result = YES;
//        }
//        [db close];
//    }
//    return result;
//}

////////////////////

-(BOOL)insertDataWithPictureModel:(PictureMode *)model
{
    BOOL res = NO;
    if ([db open]) {
        NSString *insertSql= [NSString stringWithFormat:
                               @"INSERT INTO '%@' ('%@', '%@', '%@','%@')  VALUES ('%@', '%@', '%@','%@')",
                               TABLENAME,kPictureName,kPicturePath,kReleteid,kReletetable,model.pictureName,model.picturePath,model.releteid,model.reletetable];
        res = [db executeUpdate:insertSql];
        if (!res) {
            NSLog(@"error when insert PictureInfo Imgtable");
        } else {
            NSLog(@"success to insert PictureInfo Imgtable");
        }
        [db close];
    }
    return res;
}

/////////////////

/**
 *  根据releteid，reletetable 字段查询相应的图片
 *
 *  @param reletetable 关联的表名
 *  @param releteid    关联表中某条记录的id
 */
-(NSMutableArray *)selectDataByReleteTable:(NSString *)reltable Releteid:(NSString *)relid
{
    NSMutableArray *dataCollect = [[NSMutableArray alloc] init];
    if ([db open])
    {
        NSString * sql = [NSString stringWithFormat: @"SELECT * FROM %@ where %@ = '%@' AND %@ = '%@'",TABLENAME,kReletetable,reltable,kReleteid,relid];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next])
        {
            NSString * pictureName = [rs stringForColumn:kPictureName];
            NSString * picturePath = [rs stringForColumn:kPicturePath];
            NSString * releteid = [rs stringForColumn:kReleteid];
            NSString * reletetable = [rs stringForColumn:kReletetable];

            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:pictureName forKey:kPictureName];
            [dict setObject:picturePath forKey:kPicturePath];
            [dict setObject:releteid forKey:kReleteid];
            [dict setObject:reletetable forKey:kReletetable];
            
            [dataCollect addObject:[PictureMode objectWithKeyValues:dict]];
        }
        [db close];
    }
    return dataCollect;
}

/**
 *  从沙盒目录中删除图片并删除数据表中的记录
 *
 *  @param reltable 关联的表
 *  @param relid    关联记录的 ID
 *
 *  @return  成功返回 yes，失败返回 no
 */
-(BOOL)deleteImageByReleteTable:(NSString *)reltable Releteid:(NSString *)relid
{
    BOOL result = YES;
    NSMutableArray *picResultSet = [[NSMutableArray alloc] init];
    
    if ([db open]) {
        //从数据库中找出所有对应的图片记录，并取出图片名字和图片路径这两个字段
        NSString * sql = [NSString stringWithFormat: @"SELECT %@,%@ FROM %@ WHERE %@ = '%@' AND %@ = '%@'",kPicturePath,kPictureid,TABLENAME,kReletetable,reltable,kReleteid,relid];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            NSString *pPath = [rs stringForColumnIndex:0];
            NSString *pId = [rs stringForColumnIndex:1];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:pPath forKey:@"pPath"];
            [dict setObject:pId forKey:@"pId"];
            [picResultSet addObject:dict];
        }
        
        for (int i=0; i<picResultSet.count; i++) {
            result = [[NSFileManager defaultManager]removeItemAtPath:picResultSet[i][@"pPath"] error:nil];
            if (!result) {
                [db close];
                return result;
            }
            NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' ",TABLENAME,kPictureid,picResultSet[i][@"pId"]];
            result = [db executeUpdate:deleteSql];
            if (!result) {
                //NSLog(@"error when delete db table");
            } else {
                //NSLog(@"success to delete db table");
            }
        }
    }
    [db close];
    return result;
}

/**
 *  从沙盒目录中删除图片并删除数据表中的记录，通常是根据图片名来删除
 *
 *  @param attribute 属性名
 *  @param value     属性值
 *
 *  @return   成功返回 yes，失败返回 no
 */
-(BOOL)deleteImageByAttribute:(NSString *)attribute value:(NSString *)value
{
    BOOL result = NO;
    NSString *picFilepath;
    if ([db open])
    {
        NSString *selectsql = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@='%@'",kPicturePath,TABLENAME,attribute,value];
        NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@'",TABLENAME, attribute, value];
        FMResultSet *rs = [db executeQuery:selectsql];
        while ([rs next]) {
             picFilepath = [rs stringForColumn:kPicturePath];
        }
        
        if (picFilepath!=nil) {
           BOOL re = [[NSFileManager defaultManager] removeItemAtPath:picFilepath error:nil];
            if (re) {
                BOOL res = [db executeUpdate:deleteSql];
                if (!res) {
                    //NSLog(@"error when delete db table");
                    result = NO;
                } else {
                    //NSLog(@"success to delete db table");
                    result = YES;
                }

            }
        }
      [db close];
    }
    return result;
}

/**
 *  根据releteid，reletetable 字段删除相应的记录,不删除沙盒中的图片
 *
 *  @param reletetable 关联的表名
 *  @param releteid    关联表中某条记录的id
 */
-(BOOL)deleteDataByReleteTable:(NSString *)reltable Releteid:(NSString *)relid
{
    BOOL result = NO;
    if ([db open])
    {
        
        NSString *deleteSql = [NSString stringWithFormat:
                               @"delete from %@ where %@ = '%@' AND %@ = '%@'",
                               TABLENAME,kReletetable,reltable,kReleteid, relid];
        BOOL res = [db executeUpdate:deleteSql];
        
        if (!res) {
            //NSLog(@"error when delete db table");
            result = NO;
        } else {
            //NSLog(@"success to delete db table");
            result = YES;
        }
        [db close];
    }
    return result;
}

@end


