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
#define kAbnormalid         @"abnormalid"
#define kAbnormaltime       @"abnormaltime"
#define kInformant          @"informant"
#define kAbnormalintensity  @"abnormalintensity"
#define kGroundwater        @"groundwater"
#define kAbnormalhabit      @"abnormalhabit"
#define kAbnormalphenomenon @"abnormalphenomenon"
#define kOther              @"other"
#define kImplementation     @"implementation"
#define kAbnormalanalysis   @"abnormalanalysis"
#define kCredibly           @"credibly"

#define kPointid            @"pointid"
#define kUploadFlag         @"upload"


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
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' PRIMARY KEY,'%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT)",TABLENAME,kAbnormalid,kAbnormaltime,
                                     kInformant,kAbnormalintensity,kGroundwater,kAbnormalhabit,kAbnormalphenomenon,kOther,kImplementation,kAbnormalanalysis,kCredibly,kPointid,kUploadFlag];
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating Abnormalinfo table");
        } else {
            NSLog(@"success to creating Abnormalinfo table");
        }
        [db close];
    }
}

-(BOOL)insertDataWithAbnormalinfoModel:(AbnormalinfoModel *)model
{
    BOOL res = NO;
    if ([db open]) {
        NSString *insertSql= [NSString stringWithFormat:
                               @"INSERT INTO '%@' ('%@','%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')  VALUES ('%@','%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')",
                               TABLENAME,kAbnormalid,kAbnormaltime,kInformant,kAbnormalintensity,kGroundwater,kAbnormalhabit,kAbnormalphenomenon,kOther,kImplementation,kAbnormalanalysis,kCredibly, kPointid,kUploadFlag,model.abnormalid,model.abnormaltime,model.informant,model.abnormalintensity,model.groundwater,model.abnormalhabit,model.abnormalphenomenon,model.other,model.implementation,model.abnormalanalysis,model.credibly,model.pointid,model.upload];
        
        res = [db executeUpdate:insertSql];
        if (!res) {
            NSLog(@"error when insert Abnormalinfo table");
        } else {
            NSLog(@"success to insert Abnormalinfo table");
        }
        [db close];
    }
    return res;
}

-(BOOL)updateDataWithAbnormalinfoModel:(AbnormalinfoModel *)model
{
    BOOL res = NO;
    if ([db open])
    {
        NSString *updateSql = [NSString stringWithFormat:
                               @"UPDATE %@ SET %@ = '%@', %@ = '%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@',%@='%@', %@='%@', %@='%@' WHERE %@ = '%@'  ",TABLENAME,kAbnormalid,model.abnormalid,kAbnormaltime,model.abnormaltime,kInformant,model.informant,kAbnormalintensity,model.abnormalintensity,kGroundwater,model.groundwater,kAbnormalhabit,model.abnormalhabit,kAbnormalphenomenon,model.abnormalphenomenon,kOther,model.other,kImplementation,model.implementation,kAbnormalanalysis,model.abnormalanalysis,kCredibly,model.credibly,kPointid,model.pointid,kUploadFlag,model.upload,kAbnormalid,model.abnormalid];
        
        res = [db executeUpdate:updateSql];
        if (!res) {
            NSLog(@"error when update Abnormalinfo table");
        } else {
            NSLog(@"success to update Abnormalinfo table");
        }
        [db close];
    }
    return res;
}

-(BOOL)updateUploadFlag:(NSString *)uploadFlag ID:(NSString *)idString
{
    BOOL result = NO;
    if ([db open]) {
        NSString *updateSql = [NSString stringWithFormat:
                               @"UPDATE %@ SET %@ = '%@' WHERE %@ = '%@' ",TABLENAME,kUploadFlag,uploadFlag,kAbnormalid,idString];
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
            NSString * abnormalid = [rs stringForColumn:kAbnormalid];
            NSString * abnormaltime = [rs stringForColumn:kAbnormaltime];
            NSString * informant = [rs stringForColumn:kInformant];
            NSString * abnormalintensity = [rs stringForColumn:kAbnormalintensity];
            NSString * groundwater = [rs stringForColumn:kGroundwater];
            NSString * abnormalhabit = [rs stringForColumn:kAbnormalhabit];
            NSString * abnormalphenomenon = [rs stringForColumn:kAbnormalphenomenon];
            NSString * other = [rs stringForColumn:kOther];
            NSString * implementation = [rs stringForColumn:kImplementation];
            NSString * abnormalanalysis = [rs stringForColumn:kAbnormalanalysis];
            NSString * credibly = [rs stringForColumn:kCredibly];
            NSString * pointid = [rs stringForColumn:kPointid];
            NSString * upload = [rs stringForColumn:kUploadFlag];

            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:abnormalid forKey:kAbnormalid];
            [dict setObject:abnormaltime forKey:kAbnormaltime];
            [dict setObject:informant forKey:kInformant];
            [dict setObject:abnormalintensity forKey:kAbnormalintensity];
            [dict setObject:groundwater forKey:kGroundwater];
            [dict setObject:abnormalhabit forKey:kAbnormalhabit];
            [dict setObject:abnormalphenomenon forKey:kAbnormalphenomenon];
            [dict setObject:other forKey:kOther];
            [dict setObject:implementation forKey:kImplementation];
            [dict setObject:abnormalanalysis forKey:kAbnormalanalysis];
            [dict setObject:credibly forKey:kCredibly];
            [dict setObject:pointid forKey:kPointid];
            [dict setObject:upload forKey:kUploadFlag];
            
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
            NSString * abnormalid = [rs stringForColumn:kAbnormalid];
            NSString * abnormaltime = [rs stringForColumn:kAbnormaltime];
            NSString * informant = [rs stringForColumn:kInformant];
            NSString * abnormalintensity = [rs stringForColumn:kAbnormalintensity];
            NSString * groundwater = [rs stringForColumn:kGroundwater];
            NSString * abnormalhabit = [rs stringForColumn:kAbnormalhabit];
            NSString * abnormalphenomenon = [rs stringForColumn:kAbnormalphenomenon];
            NSString * other = [rs stringForColumn:kOther];
            NSString * implementation = [rs stringForColumn:kImplementation];
            NSString * abnormalanalysis = [rs stringForColumn:kAbnormalanalysis];
            NSString * credibly = [rs stringForColumn:kCredibly];
            NSString * pointid = [rs stringForColumn:kPointid];
            NSString * upload = [rs stringForColumn:kUploadFlag];
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:abnormalid forKey:kAbnormalid];
            [dict setObject:abnormaltime forKey:kAbnormaltime];
            [dict setObject:informant forKey:kInformant];
            [dict setObject:abnormalintensity forKey:kAbnormalintensity];
            [dict setObject:groundwater forKey:kGroundwater];
            [dict setObject:abnormalhabit forKey:kAbnormalhabit];
            [dict setObject:abnormalphenomenon forKey:kAbnormalphenomenon];
            [dict setObject:other forKey:kOther];
            [dict setObject:implementation forKey:kImplementation];
            [dict setObject:abnormalanalysis forKey:kAbnormalanalysis];
            [dict setObject:credibly forKey:kCredibly];
            [dict setObject:pointid forKey:kPointid];
            [dict setObject:upload forKey:kUploadFlag];
        
            [dataCollect addObject:[AbnormalinfoModel objectWithKeyValues:dict]];
        }
        [db close];
    }
    return dataCollect;
}

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


