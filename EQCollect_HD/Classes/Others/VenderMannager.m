//
//  VenderMannager.m
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/7.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "VenderMannager.h"

@implementation VenderMannager

+ (void)load
{
    static dispatch_once_t onceToken;dispatch_once(&onceToken, ^{
        // TODO
        NSLog(@"第三方服务注册完毕");
    });
}
@end
