//
//  AbnormalinfoCell.h
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^deleteAbnormalinfo)();

@interface AbnormalinfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *abnormalTitleText;
@property (weak, nonatomic) IBOutlet UILabel *abnormaltimeText;
@property (weak, nonatomic) IBOutlet UILabel *intensityText;
@property (weak, nonatomic) IBOutlet UILabel *crediblyText;
@property (weak, nonatomic) IBOutlet UILabel *analysisText;

@property (copy)deleteAbnormalinfo deleteAbnormalinfoBlock;
- (IBAction)deleteAbnormalinfo:(id)sender;

@end
