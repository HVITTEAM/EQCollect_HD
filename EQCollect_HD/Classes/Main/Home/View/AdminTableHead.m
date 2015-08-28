//
//  AdminTableHead.m
//  EQCollect_HD
//
//  Created by shi on 15/8/28.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "AdminTableHead.h"

@implementation AdminTableHead

-(void)awakeFromNib
{
    self.headIconBk.layer.cornerRadius = 8.0;
    self.headIconBk.layer.masksToBounds = YES;
    self.headIconBk.layer.borderWidth = 1.0;
    self.headIconBk.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    self.headIcon.layer.cornerRadius = 8.0;
    self.headIcon.layer.masksToBounds = YES;
}

@end
