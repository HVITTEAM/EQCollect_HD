//
//  ReactioninfoCell.h
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoCell.h"

@interface ReactioninfoCell : InfoCell<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *reactionTittle;
@property (weak, nonatomic) IBOutlet UILabel *informantname;
@property (weak, nonatomic) IBOutlet UILabel *reactionaddress;
@property (weak, nonatomic) IBOutlet UILabel *reactiontime;
@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

- (IBAction)upLoadreactioninfo:(UIButton *)sender;
- (IBAction)deleteReactioninfo:(id)sender;

@end
