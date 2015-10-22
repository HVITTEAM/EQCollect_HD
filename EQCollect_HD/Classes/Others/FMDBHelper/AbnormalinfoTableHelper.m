//
//  AbnormalinfoTableHelper.m
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/7.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

//宏观异常信息表(abnormalinfo)
//字段	              描述	         类型
//abnormalid	     宏观异常编号    	  Int
//abnormaltime	     调查时间     	  Date
//informant	         被调查者	          Varchar
//abnormalintensity	 烈度	          Varchar
//groundwater	     地下水         	  Varchar
//abnormalhabit	     动植物习性	      Varchar
//abnormalphenomenon 物化现象          Varchar
//other	             其他	          Varchar
//implementation	 落实情况	          Varchar
//abnormalanalysis 	 初步分析	          Varchar
//credibly	         可信度	          Varchar

#define TABLENAME          @"ABNORMALINFOTAB"
#define ABNORMALID         @"abnormalid"
#define ABNORMALTIME       @"abnormaltime"
#define INFORMANT          @"informant"
#define ABNORMALINTENSITY  @"abnormalintensity"
#define GROUPDWATER        @"groundwater"
#define ABNORMALHABIT      @"abnormalhabit"
#define ABNORMALPHENOMENON @"abnormalphenomenon"
#define OTHER              @"other"
#define IMPLEMENTATION     @"implementation"
#define ABNORMALANALYSIS   @"abnormalanalysis"
#define CREDIBLY           @"credibly"

#define POINTID            @"pointid"
#define UPLOAD             @"upload"

#import "AbnormalinfoTableHelper.h"

@implementation AbnormalinfoTableHelper

+(AbnormalinfoTableHelper *)sharedInstance
{
    static AbnormalinfoTableHelper *abnormalinfoTableHelper;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        abnormalinfoTableHelper = [[AbnormalinfoTableHelper alloc] init];
        [abnormalinfoTableHelper initDataBase];
        [abnormalinfoTableHelper createTable];
    });
    return abnormalinfoTableHelper;
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
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' PRIMARY KEY,'%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT)",TABLENAME,ABNORMALID,ABNORMALTIME,
                                     INFORMANT,ABNORMALINTENSITY,GROUPDWATER,ABNORMALHABIT,ABNORMALPHENOMENON,OTHER,IMPLEMENTATION,ABNORMALANALYSIS,CREDIBLY,POINTID,UPLOAD];
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            //NSLog(@"error when creating db table");
        } else {
            //NSLog(@"success to creating db table");
        }
        [db close];
    }
}

-(BOOL) insertDataWith:(NSDictionary *)dict
{
    BOOL result = NO;
    if ([db open]) {
        NSString *insertSql1= [NSString stringWithFormat:
                               @"INSERT INTO '%@' ('%@','%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')  VALUES ('%@','%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')",
                               TABLENAME,ABNORMALID,ABNORMALTIME,INFORMANT,ABNORMALINTENSITY,GROUPDWATER,ABNORMALHABIT,ABNORMALPHENOMENON,OTHER,IMPLEMENTATION,ABNORMALANALYSIS,CREDIBLY, POINTID,UPLOAD,dict[@"abnormalid"],dict[@"abnormaltime"], dict[@"informant"],dict[@"abnormalintensity"], dict[@"groundwater"], dict[@"abnormalhabit"],dict[@"abnormalphenomenon"], dict[@"other"], dict[@"implementation"],dict[@"abnormalanalysis"], dict[@"credibly"],dict[@"pointid"],dict[@"upload"]];
        BOOL res = [db executeUpdate:insertSql1];
        if (!res) {
            //NSLog(@"error when insert db table");
            result = NO;
        } else {
           //NSLog(@"success to insert db table");
            result = YES;
        }
        [db close];
    }
    return result;
}

-(BOOL) updateDataWith:(NSDictionary *)dict
{
    BOOL result = NO;
    if ([db open])
    {
        NSString *updateSql = [NSString stringWithFormat:
                               @"UPDATE %@ SET %@ = '%@', %@ = '%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@',%@='%@', %@='%@', %@='%@' WHERE %@ = '%@'  ",TABLENAME,ABNORMALID,dict[@"abnormalid"],ABNORMALTIME,dict[@"abnormaltime"],INFORMANT,dict[@"informant"],ABNORMALINTENSITY,dict[@"abnormalintensity"],GROUPDWATER,dict[@"groundwater"],ABNORMALHABIT,dict[@"abnormalhabit"],ABNORMALPHENOMENON,dict[@"abnormalphenomenon"],OTHER,dict[@"other"],IMPLEMENTATION,dict[@"implementation"],ABNORMALANALYSIS,dict[@"abnormalanalysis"],CREDIBLY,dict[@"credibly"],POINTID,dict[@"pointid"],UPLOAD,dict[@"upload"],ABNORMALID,dict[@"abnormalid"]];
        BOOL res = [db executeUpdate:updateSql];
        if (!res) {
            //NSLog(@"error when update db table");
            result = NO;
        } else {
            //NSLog(@"success to update db table");
            result = YES;
        }
        [db close];
    }
    return result;
}

-(BOOL)updateUploadFlag:(NSString *)uploadFlag ID:(NSString *)idString
{
    BOOL result = NO;
    if ([db open]) {
        NSString *updateSql = [NSString stringWithFormat:
                               @"UPDATE %@ SET %@ = '%@' WHERE %@ = '%@' ",TABLENAME,UPLOAD,uploadFlag,ABNORMALID,idString];
        NSLog(@"%@",updateSql);
        result = [db executeUpdate:updateSql];
        if (!result) {
            NSLog(@"error when update db table");
        }else{
            NSLog(@"success to update db table");
        }
        [db close];
    }
    return result;
}

-(BOOL) deleteDataByAttribute:(NSString *)attribute value:(NSString *)value
{
    BOOL result = NO;
    if ([db open])
    {
        
        NSString *deleteSql = [NSString stringWithFormat:
                               @"delete from %@ where %@ = '%@'",
                               TABLENAME, attribute, value];
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

-(NSMutableArray *) selectData
{
    NSMutableArray *dataCollect = [[NSMutableArray alloc] init];
    if ([db open])
    {
        NSString * sql = [NSString stringWithFormat: @"SELECT * FROM %@",TABLENAME];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next])
        {
            NSString * abnormalid = [rs stringForColumn:ABNORMALID];
            NSString * abnormaltime = [rs stringForColumn:ABNORMALTIME];
            NSString * informant = [rs stringForColumn:INFORMANT];
            NSString * abnormalintensity = [rs stringForColumn:ABNORMALINTENSITY];
            NSString * groundwater = [rs stringForColumn:GROUPDWATER];
            NSString * abnormalhabit = [rs stringForColumn:ABNORMALHABIT];
            NSString * abnormalphenomenon = [rs stringForColumn:ABNORMALPHENOMENON];
            NSString * other = [rs stringForColumn:OTHER];
            NSString * implementation = [rs stringForColumn:IMPLEMENTATION];
            NSString * abnormalanalysis = [rs stringForColumn:ABNORMALANALYSIS];
            NSString * credibly = [rs stringForColumn:CREDIBLY];
            NSString * pointid = [rs stringForColumn:POINTID];
            NSString * upload = [rs stringForColumn:UPLOAD];

            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:abnormalid forKey:@"abnormalid"];
            [dict setObject:abnormaltime forKey:@"abnormaltime"];
            [dict setObject:informant forKey:@"informant"];
            [dict setObject:abnormalintensity forKey:@"abnormalintensity"];
            [dict setObject:groundwater forKey:@"groundwater"];
            [dict setObject:abnormalhabit forKey:@"abnormalhabit"];
            [dict setObject:abnormalphenomenon forKey:@"abnormalphenomenon"];
            [dict setObject:other forKey:@"other"];
            [dict setObject:implementation forKey:@"implementation"];
            [dict setObject:abnormalanalysis forKey:@"abnormalanalysis"];
            [dict setObject:credibly forKey:@"credibly"];
            [dict setObject:pointid forKey:@"pointid"];
            [dict setObject:upload forKey:@"upload"];
            
            [dataCollect addObject:[AbnormalinfoModel objectWithKeyValues:dict]];
        }
        [db close];
    }
    return dataCollect;
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
            NSString * abnormalid = [rs stringForColumn:ABNORMALID];
            NSString * abnormaltime = [rs stringForColumn:ABNORMALTIME];
            NSString * informant = [rs stringForColumn:INFORMANT];
            NSString * abnormalintensity = [rs stringForColumn:ABNORMALINTENSITY];
            NSString * groundwater = [rs stringForColumn:GROUPDWATER];
            NSString * abnormalhabit = [rs stringForColumn:ABNORMALHABIT];
            NSString * abnormalphenomenon = [rs stringForColumn:ABNORMALPHENOMENON];
            NSString * other = [rs stringForColumn:OTHER];
            NSString * implementation = [rs stringForColumn:IMPLEMENTATION];
            NSString * abnormalanalysis = [rs stringForColumn:ABNORMALANALYSIS];
            NSString * credibly = [rs stringForColumn:CREDIBLY];
            NSString * pointid = [rs stringForColumn:POINTID];
            NSString * upload = [rs stringForColumn:UPLOAD];
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:abnormalid forKey:@"abnormalid"];
            [dict setObject:abnormaltime forKey:@"abnormaltime"];
            [dict setObject:informant forKey:@"informant"];
            [dict setObject:abnormalintensity forKey:@"abnormalintensity"];
            [dict setObject:groundwater forKey:@"groundwater"];
            [dict setObject:abnormalhabit forKey:@"abnormalhabit"];
            [dict setObject:abnormalphenomenon forKey:@"abnormalphenomenon"];
            [dict setObject:other forKey:@"other"];
            [dict setObject:implementation forKey:@"implementation"];
            [dict setObject:abnormalanalysis forKey:@"abnormalanalysis"];
            [dict setObject:credibly forKey:@"credibly"];
            [dict setObject:pointid forKey:@"pointid"];
            [dict setObject:upload forKey:@"upload"];
        
            
            [dataCollect addObject:[AbnormalinfoModel objectWithKeyValues:dict]];
        }
        [db close];
    }
    return dataCollect;
}

//-(NSInteger)getNumberOfRecords
//{
//    NSInteger count = 0;
//    if ([db open]) {
//        NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) AS count FROM %@ ",TABLENAME];
//        FMResultSet * rs = [db executeQuery:sql];
//        while ([rs next]) {
//            count = [rs intForColumn:@"count"];
//            NSLog(@"%ld",count);
//        }
//    }
//    [db close];
//    return count;
//}

-(NSInteger)getMaxIdOfRecords
{
    NSInteger maxid = 0;
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT MAX(abnormalid) AS maxid FROM %@ ",TABLENAME];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            maxid = [rs intForColumn:@"maxid"];
        }
    }
    [db close];
    return maxid;
}

@end


