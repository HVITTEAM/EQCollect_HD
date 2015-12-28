//
//  DamageinfoTableHelper.m
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/7.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

//房屋震害信息表(damageinfo)

#define TABLENAME        @"DAMAGEINFOTAB"

#define DAMAGEID         @"damageid"                              //房屋震害编号
#define DAMAGETIME       @"damagetime"                            //调查时间
#define BUILDINGAGE      @"buildingage"                           //建造年代
#define DAMAGEAREA       @"damagearea"                            //房屋面积
#define FIELDTYPE        @"fieldtype"                             //场地类型
#define DAMAGELEVEL      @"damagelevel"                           //破坏等级
#define ZRCORXQ          @"zrcorxq"                               //自然村或小区
#define DWORZH           @"dworzh"                                //单位或住户
#define FORTIFICATIONINTENSITY    @"fortificationintensity"       //设防烈度
#define DAMAGESITUATION  @"damagesituation"                       //破坏情况
#define DAMAGEINDEX      @"damageindex"                           //震害指数(自动)
#define DAMAGERINDEX     @"damagerindex"                          //震害指数(人工)
#define HOUSETYPE        @"housetype"                             //房屋类型

#define POINTID          @"pointid"                                //调查点编号
#define UPLOAD           @"upload"                                 //上传状态

#import "DamageinfoTableHelper.h"

@implementation DamageinfoTableHelper

+(DamageinfoTableHelper *)sharedInstance
{
    static DamageinfoTableHelper *damageinfoTableHelper;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        damageinfoTableHelper = [[DamageinfoTableHelper alloc] init];
        [damageinfoTableHelper initDataBase];
        [damageinfoTableHelper createTable];

    });
    return damageinfoTableHelper;
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
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' PRIMARY KEY,'%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT,'%@' TEXT, '%@' TEXT,'%@' TEXT,'%@' TEXT,'%@' TEXT,'%@' TEXT,'%@' TEXT)",TABLENAME,DAMAGEID,DAMAGETIME,BUILDINGAGE,DAMAGEAREA,FIELDTYPE,DAMAGELEVEL,ZRCORXQ,DWORZH,FORTIFICATIONINTENSITY,DAMAGESITUATION,DAMAGEINDEX,DAMAGERINDEX,HOUSETYPE,POINTID,UPLOAD];
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating DAMAGEINFOTAB table");
        } else {
            NSLog(@"success to creating DAMAGEINFOTAB table");
        }
        [db close];
    }
}

-(BOOL) insertDataWith:(NSDictionary *)dict
{
    BOOL res = NO;
    if ([db open]) {
        NSString *insertSql1= [NSString stringWithFormat:
                               @"INSERT INTO '%@' ('%@','%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@','%@', '%@','%@','%@', '%@','%@')  VALUES ('%@','%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@','%@', '%@','%@', '%@','%@')",
                               TABLENAME,DAMAGEID,DAMAGETIME,BUILDINGAGE,DAMAGEAREA,FIELDTYPE,DAMAGELEVEL,ZRCORXQ,DWORZH,FORTIFICATIONINTENSITY,DAMAGESITUATION,DAMAGEINDEX,DAMAGERINDEX,HOUSETYPE,POINTID,UPLOAD,dict[@"damageid"],dict[@"damagetime"],dict[@"buildingage"],dict[@"damagearea"],dict[@"fieldtype"],dict[@"damagelevel"],dict[@"zrcorxq"],dict[@"dworzh"],dict[@"fortificationintensity"],dict[@"damagesituation"],dict[@"damageindex"],dict[@"damagerindex"],dict[@"housetype"],dict[@"pointid"],dict[@"upload"]];
        
        NSLog(@"+++++++++++++++++++++++++++++++++++++++++++%@",insertSql1);
       res = [db executeUpdate:insertSql1];
        if (!res) {
            NSLog(@"error when insert DAMAGEINFOTAB table");
        } else {
            NSLog(@"success to insert DAMAGEINFOTAB table");
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
                               @"UPDATE %@ SET %@ = '%@',%@ = '%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@' ,%@ = '%@',%@ = '%@'WHERE %@ = '%@' ",TABLENAME,DAMAGETIME,dict[@"damagetime"],BUILDINGAGE,dict[@"buildingage"],DAMAGEAREA,dict[@"damagearea"],FIELDTYPE,dict[@"fieldtype"],DAMAGELEVEL,dict[@"damagelevel"],ZRCORXQ,dict[@"zrcorxq"],DWORZH,dict[@"dworzh"],FORTIFICATIONINTENSITY,dict[@"fortificationintensity"],DAMAGESITUATION,dict[@"damagesituation"],DAMAGEINDEX,dict[@"damageindex"],DAMAGERINDEX,dict[@"damagerindex"],HOUSETYPE,dict[@"housetype"],POINTID,dict[@"pointid"],UPLOAD,dict[@"upload"],DAMAGEID,dict[@"damageid"]];
        res = [db executeUpdate:updateSql];
        if (!res) {
            NSLog(@"error when update DAMAGEINFOTAB table");
        } else {
            NSLog(@"success to update DAMAGEINFOTAB table");
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
                               @"UPDATE %@ SET %@ = '%@' WHERE %@ = '%@' ",TABLENAME,UPLOAD,uploadFlag,DAMAGEID,idString];
        result = [db executeUpdate:updateSql];
        if (!result) {
            NSLog(@"error when UploadFlag db table");
        }else{
            NSLog(@"success to UploadFlag db table");
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
            NSLog(@"error when delete DAMAGEINFOTAB table");
        } else {
            NSLog(@"success to delete DAMAGEINFOTAB table");
        }
        [db close];
    }
    return res;
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
            NSString *damageid = [rs stringForColumn:DAMAGEID];
            NSString *damagetime = [rs stringForColumn:DAMAGETIME];
            NSString *buildingage= [rs stringForColumn:BUILDINGAGE];
            NSString *damagearea  = [rs stringForColumn:DAMAGEAREA];
            NSString *fieldtype  = [rs stringForColumn:FIELDTYPE];
            NSString *damagelevel  = [rs stringForColumn:DAMAGELEVEL];
            NSString *zrcorxq  = [rs stringForColumn:ZRCORXQ];
            NSString *dworzh  = [rs stringForColumn:DWORZH];
            NSString *fortificationintensity  = [rs stringForColumn:FORTIFICATIONINTENSITY];
            NSString *damagesituation  = [rs stringForColumn:DAMAGESITUATION];
            NSString *damageindex  = [rs stringForColumn:DAMAGEINDEX];
            NSString *damagerindex  = [rs stringForColumn:DAMAGERINDEX];
            NSString *housetype  = [rs stringForColumn:HOUSETYPE];
            NSString *pointid  = [rs stringForColumn:POINTID];
            NSString *upload  = [rs stringForColumn:UPLOAD];
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:damageid forKey:@"damageid"];
            [dict setObject:damagetime forKey:@"damagetime"];
            [dict setObject:buildingage forKey:@"buildingage"];
            [dict setObject:damagearea forKey:@"damagearea"];
            [dict setObject:fieldtype forKey:@"fieldtype"];
            [dict setObject:damagelevel forKey:@"damagelevel"];
            [dict setObject:zrcorxq forKey:@"zrcorxq"];
            [dict setObject:dworzh forKey:@"dworzh"];
            [dict setObject:fortificationintensity forKey:@"fortificationintensity"];
            [dict setObject:damagesituation forKey:@"damagesituation"];
            [dict setObject:damageindex forKey:@"damageindex"];
            [dict setObject:damagerindex forKey:@"damagerindex"];
            [dict setObject:housetype forKey:@"housetype"];
            [dict setObject:pointid forKey:@"pointid"];
            [dict setObject:upload forKey:@"upload"];
    
            [dataCollect addObject:[DamageModel objectWithKeyValues:dict]];
        }
        [db close];
    }
    return dataCollect;
}

-(NSMutableArray *) selectDataByAttribute:(NSString *)attribute value:(NSString *)value;
{
    NSMutableArray *dataCollect = [[NSMutableArray alloc] init];
    if ([db open])
    {
        NSString * sql = [NSString stringWithFormat: @"SELECT * FROM %@ WHERE %@ ='%@'",TABLENAME,attribute,value];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next])
        {
            NSString *damageid = [rs stringForColumn:DAMAGEID];
            NSString *damagetime = [rs stringForColumn:DAMAGETIME];
            NSString *buildingage= [rs stringForColumn:BUILDINGAGE];
            NSString *damagearea  = [rs stringForColumn:DAMAGEAREA];
            NSString *fieldtype  = [rs stringForColumn:FIELDTYPE];
            NSString *damagelevel  = [rs stringForColumn:DAMAGELEVEL];
            NSString *zrcorxq  = [rs stringForColumn:ZRCORXQ];
            NSString *dworzh  = [rs stringForColumn:DWORZH];
            NSString *fortificationintensity  = [rs stringForColumn:FORTIFICATIONINTENSITY];
            NSString *damagesituation  = [rs stringForColumn:DAMAGESITUATION];
            NSString *damageindex  = [rs stringForColumn:DAMAGEINDEX];
            NSString *damagerindex  = [rs stringForColumn:DAMAGERINDEX];
            NSString *housetype  = [rs stringForColumn:HOUSETYPE];
            NSString *pointid  = [rs stringForColumn:POINTID];
            NSString *upload  = [rs stringForColumn:UPLOAD];
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:damageid forKey:@"damageid"];
            [dict setObject:damagetime forKey:@"damagetime"];
            [dict setObject:buildingage forKey:@"buildingage"];
            [dict setObject:damagearea forKey:@"damagearea"];
            [dict setObject:fieldtype forKey:@"fieldtype"];
            [dict setObject:damagelevel forKey:@"damagelevel"];
            [dict setObject:zrcorxq forKey:@"zrcorxq"];
            [dict setObject:dworzh forKey:@"dworzh"];
            [dict setObject:fortificationintensity forKey:@"fortificationintensity"];
            [dict setObject:damagesituation forKey:@"damagesituation"];
            [dict setObject:damageindex forKey:@"damageindex"];
            [dict setObject:damagerindex forKey:@"damagerindex"];
            [dict setObject:housetype forKey:@"housetype"];
            [dict setObject:pointid forKey:@"pointid"];
            [dict setObject:upload forKey:@"upload"];
            
            [dataCollect addObject:[DamageModel objectWithKeyValues:dict]];
        }
        [db close];
    }
    return dataCollect;
}

-(NSInteger)getMaxIdOfRecords
{
    NSInteger maxid = 0;
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT MAX(damageid) AS maxid FROM %@ ",TABLENAME];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            maxid = [rs intForColumn:@"maxid"];
        }
    }
    [db close];
    return maxid;
}

@end


