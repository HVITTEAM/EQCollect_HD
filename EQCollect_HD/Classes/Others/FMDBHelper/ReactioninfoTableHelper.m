//
//  ReactioninfoTableHelper.m
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/7.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

//人物反应信息表(reactioninfo)
//字段	              描述	            类型
//reactionid	     人物反应编号	        Int
//reactiontime	     调查时间         	Date
//informantname  	 被调查者姓名	        Varchar
//informantage	     被调查者年龄	        Varchar
//informanteducation 被调查者学历	        Varchar
//informantjob	     被调查者职业	        Varchar
//reactionaddress	 所在地	            Varchar
//rockfeeling	     晃动感觉	            Varchar
//throwfeeling	     抛起感觉	            Varchar
//throwtings	     抛弃物	            Varchar
//throwdistance	     抛起距离       	    Varchar
//fall	             搁置物滚落	        Varchar
//hang            	 悬挂物	            Varchar
//furnituresound	 家具声响          	Varchar
//furnituredump	     家具倾倒	            Varchar
//soundsize	         地声大小	            Varchar
//sounddirection	 地声方向       	    Varchar

#define TABLENAME          @"REACTIONINFOTAB"
#define kReactionid         @"reactionid"
#define kReactiontime       @"reactiontime"
#define kInformantname      @"informantname"
#define kInformantage       @"informantage"
#define kInformanteducation @"informanteducation"
#define kInformantjob       @"informantjob"
#define kReactionaddress    @"reactionaddress"
#define kRockfeeling        @"rockfeeling"
#define kThrowfeeling       @"throwfeeling"
#define kThrowtings         @"throwtings"
#define kThrowdistance      @"throwdistance"
#define kFall               @"fall"
#define kHang               @"hang"
#define kFurnituresound     @"furnituresound"
#define kFurnituredump      @"furnituredump"
#define kSoundsize          @"soundsize"
#define kSounddirection     @"sounddirection"

#define kPointid            @"pointid"
#define kUploadFlag             @"upload"


#import "ReactioninfoTableHelper.h"

@implementation ReactioninfoTableHelper

+(ReactioninfoTableHelper *)sharedInstance
{
    static ReactioninfoTableHelper *reactioninfoTableHelper;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        reactioninfoTableHelper = [[ReactioninfoTableHelper alloc] init];
        [reactioninfoTableHelper initDataBase];
        [reactioninfoTableHelper createTable];
    });
    return reactioninfoTableHelper;
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
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' PRIMARY KEY,'%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT,'%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT)",TABLENAME,
                                     kReactionid,kReactiontime,kInformantname,kInformantage,kInformanteducation,kInformantjob,kReactionaddress,kRockfeeling,kThrowfeeling,kThrowtings,kThrowdistance,kFall,kHang,kFurnituresound,kFurnituredump,kSoundsize,kSounddirection,kPointid,kUploadFlag];
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating Reactioninfo table");
        } else {
            NSLog(@"success to creating Reactioninfo table");
        }
        [db close];
    }
}

-(BOOL)insertDataWithReactioninfoModel:(ReactionModel *)model
{
    BOOL res = NO;
    if ([db open]) {
        NSString *insertSql= [NSString stringWithFormat:
                               @"INSERT INTO '%@' ('%@','%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@','%@','%@','%@')  VALUES ('%@','%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@','%@','%@','%@')",
                               TABLENAME,kReactionid,kReactiontime,
                               kInformantname,kInformantage,kInformanteducation,kInformantjob,kReactionaddress,kRockfeeling,kThrowfeeling,kThrowtings,kThrowdistance,kFall,kHang,kFurnituresound,kFurnituredump,kSoundsize,kSounddirection,kPointid,kUploadFlag,model.reactionid,model.reactiontime,model.informantname,model.informantage,model.informanteducation,model.informantjob,model.reactionaddress,model.rockfeeling,model.throwfeeling,model.throwtings,model.throwdistance,model.fall,model.hang,model.furnituresound,model.furnituredump,model.soundsize,model.sounddirection,model.pointid,model.upload];
        res = [db executeUpdate:insertSql];
        if (!res) {
            NSLog(@"error when insert Reactioninfo table");
        } else {
            NSLog(@"success to insert Reactioninfo table");
        }
        [db close];
    }
    return res;
}

-(BOOL)updateDataWithReactioninfoModel:(ReactionModel *)model
{
    BOOL res = NO;
    if ([db open])
    {
        NSString *updateSql = [NSString stringWithFormat:
                               @"UPDATE %@ SET %@ = '%@',%@ = '%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@',%@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@' WHERE %@ = '%@'",TABLENAME,kReactionid,model.reactionid,kReactiontime,model.reactiontime,kInformantname,model.informantname,kInformantage,model.informantage,kInformanteducation,model.informanteducation,kInformantjob,model.informantjob,kReactionaddress,model.reactionaddress,kRockfeeling,model.rockfeeling,kThrowfeeling,model.throwfeeling,kThrowtings,model.throwtings,kThrowdistance,model.throwdistance,kFall,model.fall,kHang,model.hang,kFurnituresound,model.furnituresound,kFurnituredump,model.furnituredump,kSoundsize,model.soundsize,kSounddirection,model.sounddirection,kPointid,model.pointid,kUploadFlag,model.upload,kReactionid,model.reactionid];
        res = [db executeUpdate:updateSql];
        if (!res) {
            NSLog(@"error when update Reactioninfo table");
        } else {
            NSLog(@"success to update Reactioninfo table");
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
                               @"UPDATE %@ SET %@ = '%@' WHERE %@ = '%@' ",TABLENAME,kUploadFlag,uploadFlag,kReactionid,idString];
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
    BOOL res = NO;
    if ([db open])
    {
        
        NSString *deleteSql = [NSString stringWithFormat:
                               @"delete from %@ where %@ = '%@'",
                               TABLENAME, attribute, value];
        res = [db executeUpdate:deleteSql];
        
        if (!res) {
            //NSLog(@"error when delete db table");
        } else {
            //NSLog(@"success to delete db table");
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
            NSString * reactionid = [rs stringForColumn:kReactionid];
            NSString * reactiontime = [rs stringForColumn:kReactiontime];
            NSString * informantname = [rs stringForColumn:kInformantname];
            NSString * informantage = [rs stringForColumn:kInformantage];
            NSString * informanteducation = [rs stringForColumn:kInformanteducation];
            NSString * informantjob = [rs stringForColumn:kInformantjob];
            NSString * reactionaddress = [rs stringForColumn:kReactionaddress];
            NSString * rockfeeling = [rs stringForColumn:kRockfeeling];
            NSString * throwfeeling = [rs stringForColumn:kThrowfeeling];
            NSString * throwtings = [rs stringForColumn:kThrowtings];
            NSString * throwdistance = [rs stringForColumn:kThrowdistance];
            NSString * fall = [rs stringForColumn:kFall];
            NSString * hang = [rs stringForColumn:kHang];
            NSString * furnituresound = [rs stringForColumn:kFurnituresound];
            NSString * furnituredump = [rs stringForColumn:kFurnituredump];
            NSString * sounddirection = [rs stringForColumn:kSounddirection];
            NSString * soundsize = [rs stringForColumn:kSoundsize];
            NSString * pointid = [rs stringForColumn:kPointid];
            NSString * upload = [rs stringForColumn:kUploadFlag];

             NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:reactionid forKey:kReactionid];
            [dict setObject:reactiontime forKey:kReactiontime];
            [dict setObject:informantname forKey:kInformantname];
            [dict setObject:informantage forKey:kInformantage];
            [dict setObject:informanteducation forKey:kInformanteducation];
            [dict setObject:informantjob forKey:kInformantjob];
            [dict setObject:reactionaddress forKey:kReactionaddress];
            [dict setObject:rockfeeling forKey:kRockfeeling];
            [dict setObject:throwfeeling forKey:kThrowfeeling];
            [dict setObject:throwtings forKey:kThrowtings];
            [dict setObject:throwdistance forKey:kThrowdistance];
            [dict setObject:fall forKey:kFall];
            [dict setObject:hang forKey:kHang];
            [dict setObject:furnituresound forKey:kFurnituresound];
            [dict setObject:furnituredump forKey:kFurnituredump];
            [dict setObject:soundsize forKey:kSoundsize];
            [dict setObject:sounddirection forKey:kSounddirection];
            [dict setObject:pointid forKey:kPointid];
            [dict setObject:upload forKey:kUploadFlag];
            
            [dataCollect addObject:[ReactionModel objectWithKeyValues:dict]];
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
            NSString * reactionid = [rs stringForColumn:kReactionid];
            NSString * reactiontime = [rs stringForColumn:kReactiontime];
            NSString * informantname = [rs stringForColumn:kInformantname];
            NSString * informantage = [rs stringForColumn:kInformantage];
            NSString * informanteducation = [rs stringForColumn:kInformanteducation];
            NSString * informantjob = [rs stringForColumn:kInformantjob];
            NSString * reactionaddress = [rs stringForColumn:kReactionaddress];
            NSString * rockfeeling = [rs stringForColumn:kRockfeeling];
            NSString * throwfeeling = [rs stringForColumn:kThrowfeeling];
            NSString * throwtings = [rs stringForColumn:kThrowtings];
            NSString * throwdistance = [rs stringForColumn:kThrowdistance];
            NSString * fall = [rs stringForColumn:kFall];
            NSString * hang = [rs stringForColumn:kHang];
            NSString * furnituresound = [rs stringForColumn:kFurnituresound];
            NSString * furnituredump = [rs stringForColumn:kFurnituredump];
            NSString * sounddirection = [rs stringForColumn:kSounddirection];
            NSString * soundsize = [rs stringForColumn:kSoundsize];
            NSString * pointid = [rs stringForColumn:kPointid];
            NSString * upload = [rs stringForColumn:kUploadFlag];
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:reactionid forKey:kReactionid];
            [dict setObject:reactiontime forKey:kReactiontime];
            [dict setObject:informantname forKey:kInformantname];
            [dict setObject:informantage forKey:kInformantage];
            [dict setObject:informanteducation forKey:kInformanteducation];
            [dict setObject:informantjob forKey:kInformantjob];
            [dict setObject:reactionaddress forKey:kReactionaddress];
            [dict setObject:rockfeeling forKey:kRockfeeling];
            [dict setObject:throwfeeling forKey:kThrowfeeling];
            [dict setObject:throwtings forKey:kThrowtings];
            [dict setObject:throwdistance forKey:kThrowdistance];
            [dict setObject:fall forKey:kFall];
            [dict setObject:hang forKey:kHang];
            [dict setObject:furnituresound forKey:kFurnituresound];
            [dict setObject:furnituredump forKey:kFurnituredump];
            [dict setObject:soundsize forKey:kSoundsize];
            [dict setObject:sounddirection forKey:kSounddirection];
            [dict setObject:pointid forKey:kPointid];
            [dict setObject:upload forKey:kUploadFlag];
            
            [dataCollect addObject:[ReactionModel objectWithKeyValues:dict]];
        }
        [db close];
    }
    return dataCollect;
}

-(NSInteger)getMaxIdOfRecords
{
    NSInteger maxid = 0;
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT MAX(reactionid) AS maxid FROM %@ ",TABLENAME];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            maxid = [rs intForColumn:@"maxid"];
        }
    }
    [db close];
    return maxid;
}

@end

