//
//  DamageinfoTableHelper.m
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/7.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

//房屋震害信息表(damageinfo)

#define TABLENAME        @"DAMAGEINFOTAB"
#define kDamageid         @"damageid"                              //房屋震害编号
#define kDamagetime       @"damagetime"                            //调查时间
#define kBuildingage      @"buildingage"                           //建造年代
#define kDamagearea       @"damagearea"                            //房屋面积
#define kFieldtype        @"fieldtype"                             //场地类型
#define kDamagelevel      @"damagelevel"                           //破坏等级
#define kZrcorxq          @"zrcorxq"                               //自然村或小区
#define kDworzh           @"dworzh"                                //单位或住户
#define kFortificationintensity    @"fortificationintensity"       //设防烈度
#define kDamagesituation  @"damagesituation"                       //破坏情况
#define kDamageindex      @"damageindex"                           //震害指数(自动)
#define kDamagerindex     @"damagerindex"                          //震害指数(人工)
#define kHousetype        @"housetype"                             //房屋类型

#define kPointid          @"pointid"                                //调查点编号
#define kUploadFlag           @"upload"                                 //上传状态


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
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' PRIMARY KEY,'%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT,'%@' TEXT, '%@' TEXT,'%@' TEXT,'%@' TEXT,'%@' TEXT,'%@' TEXT,'%@' TEXT)",TABLENAME,kDamageid,kDamagetime,kBuildingage,kDamagearea,kFieldtype,kDamagelevel,kZrcorxq,kDworzh,kFortificationintensity,kDamagesituation,kDamageindex,kDamagerindex,kHousetype,kPointid,kUploadFlag];
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating DAMAGEINFOTAB table");
        } else {
            NSLog(@"success to creating DAMAGEINFOTAB table");
        }
        [db close];
    }
}

-(BOOL)insertDataWithDamageinfoModel:(DamageModel *)model
{
    BOOL res = NO;
    if ([db open]) {
        NSString *insertSql= [NSString stringWithFormat:
                               @"INSERT INTO '%@' ('%@','%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@','%@', '%@','%@','%@', '%@','%@')  VALUES ('%@','%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@','%@', '%@','%@', '%@','%@')",
                               TABLENAME,kDamageid,kDamagetime,kBuildingage,kDamagearea,kFieldtype,kDamagelevel,kZrcorxq,kDworzh,kFortificationintensity,kDamagesituation,kDamageindex,kDamagerindex,kHousetype,kPointid,kUploadFlag,model.damageid,model.damagetime,model.buildingage,model.damagearea,model.fieldtype,model.damagelevel,model.zrcorxq,model.dworzh,model.fortificationintensity,model.damagesituation,model.damageindex,model.damagerindex,model.housetype,model.pointid,model.upload];
        
        res = [db executeUpdate:insertSql];
        if (!res) {
            NSLog(@"error when insert damageinfo table");
        } else {
            NSLog(@"success to insert damageinfo table");
        }
        [db close];
    }
    return res;
    
}

-(BOOL)updateDataWithDamageinfoModel:(DamageModel *)model
{
    BOOL res = NO;
    if ([db open])
    {
        NSString *updateSql = [NSString stringWithFormat:
                               @"UPDATE %@ SET %@ = '%@',%@ = '%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@' ,%@ = '%@',%@ = '%@'WHERE %@ = '%@' ",TABLENAME,kDamagetime,model.damagetime,kBuildingage,model.buildingage,kDamagearea,model.damagearea,kFieldtype,model.fieldtype,kDamagelevel,model.damagelevel,kZrcorxq,model.zrcorxq,kDworzh,model.dworzh,kFortificationintensity,model.fortificationintensity,kDamagesituation,model.damagesituation,kDamageindex,model.damageindex,kDamagerindex,model.damagerindex,kHousetype,model.housetype,kPointid,model.pointid,kUploadFlag,model.upload,kDamageid,model.damageid];
        
        NSLog(@"-------------%@",updateSql);
        
        res = [db executeUpdate:updateSql];
        if (!res) {
            NSLog(@"error when update damageinfo table");
        } else {
            NSLog(@"success to update damageinfo table");
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
                               @"UPDATE %@ SET %@ = '%@' WHERE %@ = '%@' ",TABLENAME,kUploadFlag,uploadFlag,kDamageid,idString];
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

-(BOOL)deleteDataByAttribute:(NSString *)attribute value:(NSString *)value
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

-(NSMutableArray *)selectData
{
    NSMutableArray *dataCollect = [[NSMutableArray alloc] init];
    if ([db open])
    {
        NSString * sql = [NSString stringWithFormat: @"SELECT * FROM %@",TABLENAME];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next])
        {
            NSString *damageid = [rs stringForColumn:kDamageid];
            NSString *damagetime = [rs stringForColumn:kDamagetime];
            NSString *buildingage= [rs stringForColumn:kBuildingage];
            NSString *damagearea  = [rs stringForColumn:kDamagearea];
            NSString *fieldtype  = [rs stringForColumn:kFieldtype];
            NSString *damagelevel  = [rs stringForColumn:kDamagelevel];
            NSString *zrcorxq  = [rs stringForColumn:kZrcorxq];
            NSString *dworzh  = [rs stringForColumn:kDworzh];
            NSString *fortificationintensity  = [rs stringForColumn:kFortificationintensity];
            NSString *damagesituation  = [rs stringForColumn:kDamagesituation];
            NSString *damageindex  = [rs stringForColumn:kDamageindex];
            NSString *damagerindex  = [rs stringForColumn:kDamagerindex];
            NSString *housetype  = [rs stringForColumn:kHousetype];
            NSString *pointid  = [rs stringForColumn:kPointid];
            NSString *upload  = [rs stringForColumn:kUploadFlag];
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:damageid forKey:kDamageid];
            [dict setObject:damagetime forKey:kDamagetime];
            [dict setObject:buildingage forKey:kBuildingage];
            [dict setObject:damagearea forKey:kDamagearea];
            [dict setObject:fieldtype forKey:kFieldtype];
            [dict setObject:damagelevel forKey:kDamagelevel];
            [dict setObject:zrcorxq forKey:kZrcorxq];
            [dict setObject:dworzh forKey:kDworzh];
            [dict setObject:fortificationintensity forKey:kFortificationintensity];
            [dict setObject:damagesituation forKey:kDamagesituation];
            [dict setObject:damageindex forKey:kDamageindex];
            [dict setObject:damagerindex forKey:kDamagerindex];
            [dict setObject:housetype forKey:kHousetype];
            [dict setObject:pointid forKey:kPointid];
            [dict setObject:upload forKey:kUploadFlag];
    
            [dataCollect addObject:[DamageModel objectWithKeyValues:dict]];
        }
        [db close];
    }
    return dataCollect;
}

-(NSMutableArray *)selectDataByAttribute:(NSString *)attribute value:(NSString *)value;
{
    NSMutableArray *dataCollect = [[NSMutableArray alloc] init];
    if ([db open])
    {
        NSString * sql = [NSString stringWithFormat: @"SELECT * FROM %@ WHERE %@ ='%@'",TABLENAME,attribute,value];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next])
        {
            NSString *damageid = [rs stringForColumn:kDamageid];
            NSString *damagetime = [rs stringForColumn:kDamagetime];
            NSString *buildingage= [rs stringForColumn:kBuildingage];
            NSString *damagearea  = [rs stringForColumn:kDamagearea];
            NSString *fieldtype  = [rs stringForColumn:kFieldtype];
            NSString *damagelevel  = [rs stringForColumn:kDamagelevel];
            NSString *zrcorxq  = [rs stringForColumn:kZrcorxq];
            NSString *dworzh  = [rs stringForColumn:kDworzh];
            NSString *fortificationintensity  = [rs stringForColumn:kFortificationintensity];
            NSString *damagesituation  = [rs stringForColumn:kDamagesituation];
            NSString *damageindex  = [rs stringForColumn:kDamageindex];
            NSString *damagerindex  = [rs stringForColumn:kDamagerindex];
            NSString *housetype  = [rs stringForColumn:kHousetype];
            NSString *pointid  = [rs stringForColumn:kPointid];
            NSString *upload  = [rs stringForColumn:kUploadFlag];
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:damageid forKey:kDamageid];
            [dict setObject:damagetime forKey:kDamagetime];
            [dict setObject:buildingage forKey:kBuildingage];
            [dict setObject:damagearea forKey:kDamagearea];
            [dict setObject:fieldtype forKey:kFieldtype];
            [dict setObject:damagelevel forKey:kDamagelevel];
            [dict setObject:zrcorxq forKey:kZrcorxq];
            [dict setObject:dworzh forKey:kDworzh];
            [dict setObject:fortificationintensity forKey:kFortificationintensity];
            [dict setObject:damagesituation forKey:kDamagesituation];
            [dict setObject:damageindex forKey:kDamageindex];
            [dict setObject:damagerindex forKey:kDamagerindex];
            [dict setObject:housetype forKey:kHousetype];
            [dict setObject:pointid forKey:kPointid];
            [dict setObject:upload forKey:kUploadFlag];
            
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


