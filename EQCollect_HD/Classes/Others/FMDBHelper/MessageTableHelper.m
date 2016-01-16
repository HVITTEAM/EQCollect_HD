//
//  MessageTableHelper.m
//  EQCollect_HD
//
//  Created by shi on 15/11/14.
//  Copyright © 2015年 董徐维. All rights reserved.
//
//主键自增，内容，号码，调查点外键，时间
#define TABLENAME      @"MESSAGETAB"
#define kMessageId      @"messageId"
#define kContent        @"content"
#define kPhoneNum       @"phoneNum"
#define kTime           @"time"

#define kPointid        @"pointid"
#define kUploadFlag         @"upload"


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
    db = [FMDatabase databaseWithPath:database_path];
}

- (void)createTable
{
    if ([db open]) {
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' PRIMARY KEY, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT)",TABLENAME,kMessageId,kContent,kPhoneNum,kTime,kPointid,kUploadFlag];
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating message table");
        } else {
            NSLog(@"success to creating message table");
        }
        [db close];
    }
}

-(BOOL)insertDataWithMessageinfoModel:(MessageModel *)model
{
    BOOL res = NO;
    if ([db open]) {
        NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@' ('%@','%@', '%@', '%@', '%@','%@')  VALUES ('%@','%@', '%@', '%@', '%@', '%@')",TABLENAME,kMessageId, kContent, kPhoneNum,kTime,kPointid,kUploadFlag,model.messageId,model.content,model.phoneNum,model.time,model.pointid,model.upload];
        res = [db executeUpdate:insertSql];
        if (!res) {
            NSLog(@"error when insert message table");
        } else {
            NSLog(@"success to insert message table");
        }
        [db close];
    }
    return res;
}

-(BOOL)updateDataWithMessageinfoModel:(MessageModel *)model
{
    BOOL res = NO;
    if ([db open])
    {
        NSString *updateSql = [NSString stringWithFormat:
                               @"UPDATE %@ SET %@ = '%@', %@='%@', %@='%@', %@='%@', %@='%@' WHERE %@ = '%@' ",TABLENAME,kContent,model.content,kPhoneNum,model.phoneNum,kTime,model.time,kPointid,model.pointid,kUploadFlag,model.upload,kMessageId,model.messageId];
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

-(BOOL)deleteDataByAttribute:(NSString *)attribute value:(NSString *)value
{
    BOOL res = NO;
    if ([db open])
    {
        
        NSString *deleteSql = [NSString stringWithFormat:
                                                    @"delete from %@ where %@ = '%@'",TABLENAME, attribute, value];
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

-(NSMutableArray *)selectDataByAttribute:(NSString *)attribute value:(NSString *)value
{
    NSMutableArray *dataCollect = [[NSMutableArray alloc] init];
    if ([db open])
    {
        NSString * sql = [NSString stringWithFormat: @"SELECT * FROM %@ WHERE %@ ='%@'",TABLENAME,attribute,value];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next])
        {
            NSString * messageId = [rs stringForColumn:kMessageId];
            NSString * content   = [rs stringForColumn:kContent];
            NSString * phoneNum  = [rs stringForColumn:kPhoneNum];
            NSString * time      = [rs stringForColumn:kTime];
            NSString * pointid   = [rs stringForColumn:kPointid];
            NSString * upload   = [rs stringForColumn:kUploadFlag];
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:messageId forKey:kMessageId];
            [dict setObject:content forKey:kContent];
            [dict setObject:phoneNum forKey:kPhoneNum];
            [dict setObject:time forKey:kTime];
            [dict setObject:pointid forKey:kPointid];
            [dict setObject:upload forKey:kUploadFlag];
            
            [dataCollect addObject:[MessageModel objectWithKeyValues:dict]];
        }
        [db close];
    }
    return dataCollect;
}

-(BOOL)updateUploadFlag:(NSString *)uploadFlag ID:(NSString *)idString
{
    BOOL result = NO;
    if ([db open]) {
        NSString *updateSql = [NSString stringWithFormat:
                               @"UPDATE %@ SET %@ = '%@' WHERE %@ = '%@' ",TABLENAME,kUploadFlag,uploadFlag,kPointid,idString];
        result = [db executeUpdate:updateSql];
        if (!result) {
            NSLog(@"error when update other table");
        }else{
            NSLog(@"success to update other table");
        }
        [db close];
    }
    return result;
}

@end
