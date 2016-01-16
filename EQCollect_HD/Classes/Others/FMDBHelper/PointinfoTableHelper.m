//
//  FMDBHelper.m
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/7.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//
//字段	          描述	          类型
//pointid	     调查点编号	      Int
//earthid	     地震编号	          Int
//pointlocation	 调查点地点	      Varchar
//pointlon	     调查点经度	      Float
//pointlat	     调查点经度	      Float
//pointname	     调查点名称	      Varchar
//pointtime	     生成时间	          Date
//pointgroup	 小组名称	          Varchar
//pointperson1	 小组成员1	      Date
//pointperson2	 小组成员2         Varchar
//pointintensity 评定烈度	          Varchar
//pointcontent	 调查简述	          Varchar

#define TABLENAME      @"POINTINFOTAB"
#define kPointid        @"pointid"
#define kEarthid        @"earthid"
#define kPointlocation  @"pointlocation"
#define kPointlon       @"pointlon"
#define kPointlat       @"pointlat"
#define kPointname      @"pointname"
#define kPointtime      @"pointtime"
#define kPointgroup     @"pointgroup"
#define kPointperson    @"pointperson"
#define kPointintensity @"pointintensity"
#define kPointcontent   @"pointcontent"
#define kUploadFlag     @"upload"


#import "PointinfoTableHelper.h"

@implementation PointinfoTableHelper

+(PointinfoTableHelper *)sharedInstance
{
    static PointinfoTableHelper *pointinfoTableHelper;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pointinfoTableHelper = [[PointinfoTableHelper alloc] init];
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
    NSLog(@"----pointinfoTableHelper-----%@",database_path);
    db = [FMDatabase databaseWithPath:database_path];
}

- (void)createTable
{
    if ([db open]) {
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' PRIMARY KEY, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT)",TABLENAME,kPointid,kEarthid,kPointlocation,kPointlon,kPointlat,kPointname,kPointtime,kPointgroup,kPointperson,kPointintensity,kPointcontent,kUploadFlag];
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating Pointinfo table");
        } else {
            NSLog(@"success to creating Pointinfo table");
        }
        [db close];
    }
}

-(BOOL)insertDataWithPointinfoModel:(PointModel *)model
{
    BOOL res = NO;
    if ([db open]) {
        NSString *insertSql1= [NSString stringWithFormat:
                               @"INSERT INTO '%@' ('%@','%@', '%@', '%@', '%@',  '%@', '%@', '%@', '%@', '%@', '%@', '%@')  VALUES ('%@','%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')",
                               TABLENAME,kPointid, kEarthid, kPointlocation,kPointlon,kPointlat,kPointname,kPointtime,kPointgroup,kPointperson,kPointintensity,kPointcontent,kUploadFlag,model.pointid,model.earthid,model.pointlocation,model.pointlon,model.pointlat,model.pointname, model.pointtime,model.pointgroup,model.pointperson,model.pointintensity,model.pointcontent,model.upload];
        res = [db executeUpdate:insertSql1];
        if (!res) {
            NSLog(@"error when insert Pointinfo table");
        } else {
            NSLog(@"success to insert Pointinfo table");
        }
        [db close];
    }
    return res;
}

-(BOOL)updateDataWithPointinfoModel:(PointModel *)model
{
    BOOL res = NO;
    if ([db open])
    {
        NSString *updateSql = [NSString stringWithFormat:
                               @"UPDATE %@ SET %@ = '%@',%@ = '%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@',%@='%@', %@='%@', %@='%@' WHERE %@ = '%@' ",TABLENAME,kPointid,model.pointid,kEarthid,model.earthid,kPointlocation,model.pointlocation,kPointlon,model.pointlon,kPointlat,model.pointlat,kPointname,model.pointname,kPointtime,model.pointtime,kPointgroup,model.pointgroup,kPointperson,model.pointperson,kPointintensity,model.pointintensity,kPointcontent,model.pointcontent,kUploadFlag,model.upload,kPointid,model.pointid];
        
        res = [db executeUpdate:updateSql];
        if (!res) {
            NSLog(@"error when update Pointinfo table");
        } else {
            NSLog(@"success to update Pointinfo table");
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
                            @"UPDATE %@ SET %@ = '%@' WHERE %@ = '%@' ",TABLENAME,kUploadFlag,uploadFlag,kPointid,idString];
        result = [db executeUpdate:updateSql];
        if (!result) {
            NSLog(@"error when update UploadFlag table");
        }else{
            NSLog(@"success to update UploadFlag table");
        }
      [db close];
    }
    return result;
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
            NSLog(@"error when delete Pointinfo table");
        } else {
            NSLog(@"success to delete Pointinfo table");
        }
        [db close];
    }
    return res;
}

- (NSMutableArray *)selectData;
{
    NSMutableArray *dataCollect = [[NSMutableArray alloc] init];
    if ([db open])
    {
        NSString * sql = [NSString stringWithFormat: @"SELECT * FROM %@",TABLENAME];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next])
        {
            NSString * pointid = [rs stringForColumn:kPointid];
            NSString * earthid = [rs stringForColumn:kEarthid];
            NSString * pointlocation = [rs stringForColumn:kPointlocation];
            NSString * pointlon = [rs stringForColumn:kPointlon];
            NSString * pointlat = [rs stringForColumn:kPointlat];
            NSString * pointname = [rs stringForColumn:kPointname];
            NSString * pointtime = [rs stringForColumn:kPointtime];
            NSString * pointgroup = [rs stringForColumn:kPointgroup];
            NSString * pointperson = [rs stringForColumn:kPointperson];
            NSString * pointintensity = [rs stringForColumn:kPointintensity];
            NSString * pointcontent = [rs stringForColumn:kPointcontent];
            NSString * upload = [rs stringForColumn:kUploadFlag];
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:pointid forKey:kPointid];
            [dict setObject:earthid forKey:kEarthid];
            [dict setObject:pointlocation forKey:kPointlocation];
            [dict setObject:pointlon forKey:kPointlon];
            [dict setObject:pointlat forKey:kPointlat];
            [dict setObject:pointname forKey:kPointname];
            [dict setObject:pointtime forKey:kPointtime];
            [dict setObject:pointgroup forKey:kPointgroup];
            [dict setObject:pointperson forKey:kPointperson];
            [dict setObject:pointintensity forKey:kPointintensity];
            [dict setObject:pointcontent forKey:kPointcontent];
            [dict setObject:upload forKey:kUploadFlag];

            [dataCollect addObject:[PointModel objectWithKeyValues:dict]];
        }
        [db close];
    }
    return dataCollect;
}

@end
