//
//  OtherCell.h
//  EQCollect_HD
//
//  Created by shi on 15/12/10.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoCell.h"

@interface OtherCell : InfoCell
@property (weak, nonatomic) IBOutlet UILabel *otherIdLb;
@property (weak, nonatomic) IBOutlet UILabel *lonLb;
@property (weak, nonatomic) IBOutlet UILabel *latLb;
@property (weak, nonatomic) IBOutlet UILabel *timeLb;
@property (weak, nonatomic) IBOutlet UILabel *addressLb;

@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@end
