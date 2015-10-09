//
//  SurveyPointCell.m
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/1.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "SurveyPointCell.h"

@implementation SurveyPointCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteSurveyPoint:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"警告" message:@"数据一但删除将不可恢复" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==1) {
        if ([self.delegate respondsToSelector:@selector(infoCell:didClickDeleteBtnAtIndexPath:)]) {
            [self.delegate infoCell:self didClickDeleteBtnAtIndexPath:self.indexPath];
        }
    }
}
@end
