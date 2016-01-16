//
//  sharedAppUtil.h 系统缓存
//  GPSNavDemo
//
//  Created by 董徐维 on 15/3/11.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface SharedAppUtil : NSObject

+(SharedAppUtil *)defaultCommonUtil;

/**
 *  将罗马数字表示的烈度转换成阿拉伯数字表示
 */
+(NSString *)switchRomeNumToNum:(NSString *)romeNum;

/**
 *  将阿拉伯数字表示的烈度转换成罗马数字表示
 */
+(NSString *)switchNumToRomeNumWithNum:(NSInteger)num;

/**
 *  将IndexPath转换成罗马数字表示
 */
+(NSString *)switchIndexPathToRomeNumWithIndexPath:(NSIndexPath *)idx;



@end
