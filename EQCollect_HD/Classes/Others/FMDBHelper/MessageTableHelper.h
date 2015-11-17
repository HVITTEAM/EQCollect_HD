//
//  MessageTableHelper.h
//  EQCollect_HD
//
//  Created by shi on 15/11/14.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageTableHelper : NSObject
{
    FMDatabase *db;
    NSString *database_path;
}

+(MessageTableHelper *)sharedInstance;
-(BOOL) insertDataWith:(NSDictionary *)dict;
-(BOOL) updateDataWith:(NSDictionary *)dict;
-(BOOL) deleteDataByAttribute:(NSString *)attribute value:(NSString *)value;
-(NSMutableArray *) selectDataByAttribute:(NSString *)attribute value:(NSString *)value;
@end
