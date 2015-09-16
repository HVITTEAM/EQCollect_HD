//
//  DamageinfoTableHelper.m
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/7.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

//房屋震害信息表(damageinfo)
//字段	                 描述	    类型
//damageid	             房屋震害编号	 Int
//damagetime	         调查时间 	 Date
//damageaddress	         地址	     Varchar
//damageintensity        烈度	     Varchar
//zrcorxq	             自然村或小区	 Varchar
//dworzh	             单位或住户	 Varchar
//fortificationintensity 设防烈度	     Varchar
//damagesituation	     破坏情况 	 Varchar
//damageindex	         震害指数	     Float

#define TABLENAME        @"damageinfo"
#define DAMAGEID         @"damageid"
#define DAMAGETIME       @"damagetime"
#define DAMAGEADDRESS    @"damageaddress"
#define DAMAGEINTENSITY  @"damageintensity"
#define ZRCORXQ          @"zrcorxq"
#define DWORZH           @"dworzh"
#define FORTIFICATIONINTENSITY    @"fortificationintensity"
#define DAMAGESITUATION  @"damagesituation"
#define DAMAGEINDEX      @"damageindex"

#define POINTID            @"pointid"

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
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' INTEGER PRIMARY KEY AUTOINCREMENT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT,'%@' TEXT)",TABLENAME,DAMAGEID,DAMAGETIME,
                                     DAMAGEADDRESS,DAMAGEINTENSITY,ZRCORXQ,DWORZH,FORTIFICATIONINTENSITY,DAMAGESITUATION,DAMAGEINDEX,POINTID];
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating db table");
        } else {
            NSLog(@"success to creating db table");
        }
        [db close];
    }
}

-(BOOL) insertDataWith:(NSDictionary *)dict
{
    BOOL result = NO;
    if ([db open]) {
        NSString *insertSql1= [NSString stringWithFormat:
                               @"INSERT INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')  VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')",
                               TABLENAME,DAMAGEID,DAMAGETIME,DAMAGEADDRESS,DAMAGEINTENSITY,ZRCORXQ,DWORZH,FORTIFICATIONINTENSITY,DAMAGESITUATION,DAMAGEINDEX,POINTID,dict[@"damageid"],dict[@"damagetime"], dict[@"damageaddress"],dict[@"damageintensity"], dict[@"zrcorxq"], dict[@"dworzh"],dict[@"fortificationintensity"], dict[@"damagesituation"], dict[@"damageindex"],dict[@"pointid"]];
        BOOL res = [db executeUpdate:insertSql1];
        if (!res) {
            NSLog(@"error when insert db table");
            result = NO;
        } else {
            NSLog(@"success to insert db table");
            result = YES;
        }
        [db close];
    }
    return result;
}

//
//-(void) updateData
//{
//    if ([db open])
//    {
//        NSString *updateSql = [NSString stringWithFormat:
//                               @"UPDATE '%@' SET '%@' = '%@' WHERE '%@' = '%@'",
//                               TABLENAME,   AGE,  @"15" ,AGE,  @"13"];
//        BOOL res = [db executeUpdate:updateSql];
//        if (!res) {
//            NSLog(@"error when update db table");
//        } else {
//            NSLog(@"success to update db table");
//        }
//        [db close];
//
//    }
//
//}
//
-(BOOL) deleteDataByDamageid:(NSString *)damageidStr
{
    BOOL result = NO;
    if ([db open])
    {
        
        NSString *deleteSql = [NSString stringWithFormat:
                               @"delete from %@ where %@ = '%@'",
                               TABLENAME, DAMAGEID, damageidStr];
        BOOL res = [db executeUpdate:deleteSql];
        
        if (!res) {
            NSLog(@"error when delete db table");
            result = NO;
        } else {
            NSLog(@"success to delete db table");
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
            NSString * damageid = [rs stringForColumn:DAMAGEID];
            NSString * damagetime = [rs stringForColumn:DAMAGETIME];
            NSString * damageaddress = [rs stringForColumn:DAMAGEADDRESS];
            NSString * damageintensity = [rs stringForColumn:DAMAGEINTENSITY];
            NSString * zrcorxq = [rs stringForColumn:ZRCORXQ];
            NSString * dworzh = [rs stringForColumn:DWORZH];
            NSString * fortificationintensity = [rs stringForColumn:FORTIFICATIONINTENSITY];
            NSString * damagesituation = [rs stringForColumn:DAMAGESITUATION];
            NSString * damageindex = [rs stringForColumn:DAMAGEINDEX];
            NSString * pointid = [rs stringForColumn:POINTID];
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:damageid forKey:@"damageid"];
            [dict setObject:damagetime forKey:@"damagetime"];
            [dict setObject:damageaddress forKey:@"damageaddress"];
            [dict setObject:damageintensity forKey:@"damageintensity"];
            [dict setObject:zrcorxq forKey:@"zrcorxq"];
            [dict setObject:dworzh forKey:@"dworzh"];
            [dict setObject:fortificationintensity forKey:@"fortificationintensity"];
            [dict setObject:damagesituation forKey:@"damagesituation"];
            [dict setObject:damageindex forKey:@"damageindex"];
            [dict setObject:pointid forKey:@"pointid"];
            [dataCollect addObject:dict];
            //[dataCollect addObject:[DamageModel objectWithKeyValues:dict]];
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
            NSString * damageid = [rs stringForColumn:DAMAGEID];
            NSString * damagetime = [rs stringForColumn:DAMAGETIME];
            NSString * damageaddress = [rs stringForColumn:DAMAGEADDRESS];
            NSString * damageintensity = [rs stringForColumn:DAMAGEINTENSITY];
            NSString * zrcorxq = [rs stringForColumn:ZRCORXQ];
            NSString * dworzh = [rs stringForColumn:DWORZH];
            NSString * fortificationintensity = [rs stringForColumn:FORTIFICATIONINTENSITY];
            NSString * damagesituation = [rs stringForColumn:DAMAGESITUATION];
            NSString * damageindex = [rs stringForColumn:DAMAGEINDEX];
            NSString * pointid = [rs stringForColumn:POINTID];
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:damageid forKey:@"damageid"];
            [dict setObject:damagetime forKey:@"damagetime"];
            [dict setObject:damageaddress forKey:@"damageaddress"];
            [dict setObject:damageintensity forKey:@"damageintensity"];
            [dict setObject:zrcorxq forKey:@"zrcorxq"];
            [dict setObject:dworzh forKey:@"dworzh"];
            [dict setObject:fortificationintensity forKey:@"fortificationintensity"];
            [dict setObject:damagesituation forKey:@"damagesituation"];
            [dict setObject:damageindex forKey:@"damageindex"];
            [dict setObject:pointid forKey:@"pointid"];
            [dataCollect addObject:dict];
//            [DamageModel objectWithKeyValues:dict];
//            [dataCollect addObject:[DamageModel objectWithKeyValues:dict]];
        }
        
        [db close];
    }
    
    return dataCollect;
}

@end


