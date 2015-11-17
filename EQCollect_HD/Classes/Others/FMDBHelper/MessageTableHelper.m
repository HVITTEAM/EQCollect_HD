//
//  MessageTableHelper.m
//  EQCollect_HD
//
//  Created by shi on 15/11/14.
//  Copyright © 2015年 董徐维. All rights reserved.
//
//主键自增，内容，号码，调查点外键，时间
#define TABLENAME      @"MESSAGETAB"
#define MESSAGEID      @"messageId"
#define CONTENT        @"content"
#define PHONENUM       @"phoneNum"
#define TIME           @"time"
#define POINTID        @"pointid"
#define UPLOAD         @"upload"

#import "MessageTableHelper.h"
#import "MessageModel.h"

@implementation MessageTableHelper
+(MessageTableHelper *)sharedInstance
{
    static MessageTableHelper *pointinfoTableHelper;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pointinfoTableHelper = [[MessageTableHelper alloc] init];
        [pointinfoTableHelper initDataBase];
        [pointinfoTableHelper createTable];
    });
    return pointinfoTableHelper;
}

-(void)initDataBase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    database_path = [documents stringByAppendingPathComponent:DBNAME];
    NSLog(@"----messageTableHelper-----%@",database_path);
    db = [FMDatabase databaseWithPath:database_path];
}

- (void)createTable
{
    if ([db open]) {
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' PRIMARY KEY, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT)",TABLENAME,MESSAGEID,CONTENT,PHONENUM,TIME,POINTID,UPLOAD];
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating message table");
        } else {
            NSLog(@"success to creating message table");
        }
        [db close];
    }
}

-(BOOL) insertDataWith:(NSDictionary *)dict
{
    BOOL res = NO;
    if ([db open]) {
        NSString *insertSql1= [NSString stringWithFormat:@"INSERT INTO '%@' ('%@','%@', '%@', '%@', '%@','%@')  VALUES ('%@','%@', '%@', '%@', '%@', '%@')",TABLENAME,MESSAGEID, CONTENT, PHONENUM,TIME,POINTID,UPLOAD,dict[@"messageId"],dict[@"content"],dict[@"phoneNum"], dict[@"time"], dict[@"pointid"],dict[@"upload"]];
        res = [db executeUpdate:insertSql1];
        if (!res) {
            NSLog(@"error when insert message table");
        } else {
            NSLog(@"success to insert message table");
        }
        [db close];
    }
    return res;
}

-(BOOL) updateDataWith:(NSDictionary *)dict
{
    BOOL res = NO;
    if ([db open])
    {
        NSString *updateSql = [NSString stringWithFormat:
                               @"UPDATE %@ SET %@ = '%@', %@='%@', %@='%@', %@='%@', %@='%@' WHERE %@ = '%@' ",TABLENAME,CONTENT,dict[@"content"],PHONENUM,dict[@"phoneNum"],TIME,dict[@"time"],POINTID,dict[@"pointid"],UPLOAD,dict[@"upload"],MESSAGEID,dict[@"messageId"]];
        
        NSLog(@"%@",updateSql);
        res = [db executeUpdate:updateSql];
        if (!res) {
            NSLog(@"error when update message table");
        } else {
            NSLog(@"success to update message table");
        }
        [db close];
    }
    return res;
}

-(BOOL) deleteDataByAttribute:(NSString *)attribute value:(NSString *)value
{
    BOOL res = NO;
    if ([db open])
    {
        
        NSString *deleteSql = [NSString stringWithFormat:
                               @"delete from %@ where %@ = '%@'",
                               TABLENAME, attribute, value];
        res = [db executeUpdate:deleteSql];
        
        if (!res) {
            NSLog(@"error when delete message table");
        } else {
            NSLog(@"success to delete message table");
        }
        [db close];
    }
    return res;
}

-(NSMutableArray *) selectDataByAttribute:(NSString *)attribute value:(NSString *)value
{
    NSMutableArray *dataCollect = [[NSMutableArray alloc] init];
    if ([db open])
    {
        NSString * sql = [NSString stringWithFormat: @"SELECT * FROM %@ WHERE %@ ='%@'",TABLENAME,attribute,value];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next])
        {
            NSString * messageId = [rs stringForColumn:MESSAGEID];
            NSString * content   = [rs stringForColumn:CONTENT];
            NSString * phoneNum  = [rs stringForColumn:PHONENUM];
            NSString * time      = [rs stringForColumn:TIME];
            NSString * pointid   = [rs stringForColumn:POINTID];
            NSString * upload   = [rs stringForColumn:UPLOAD];
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:messageId forKey:@"messageId"];
            [dict setObject:content forKey:@"content"];
            [dict setObject:phoneNum forKey:@"phoneNum"];
            [dict setObject:time forKey:@"time"];
            [dict setObject:pointid forKey:@"pointid"];
            [dict setObject:upload forKey:@"upload"];
            
            [dataCollect addObject:[MessageModel objectWithKeyValues:dict]];
        }
        [db close];
    }
    return dataCollect;
}

@end
