//
//  AbnormalinfoCell.m
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "AbnormalinfoCell.h"

@implementation AbnormalinfoCell

- (void)awakeFromNib {
    // Initialization code
    self.uploadBtn.layer.cornerRadius = 7.0f;
    self.uploadBtn.layer.masksToBounds = YES;
    self.deleteBtn.layer.cornerRadius = 7.0f;
    self.deleteBtn.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteAbnormalinfo:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"警告" message:@"数据一但删除将不可恢复" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
}

- (IBAction)upLoadAbnormalinfo:(UIButton *)sender {
    //如果上传按钮处于选中状态，表示已经上传
    if (!sender.selected) {
        if ([self.delegate respondsToSelector:@selector(infocell:didClickUpLoadBtnAtIndexPath:)]) {
            [self.delegate infocell:self didClickUpLoadBtnAtIndexPath:self.indexPath];
        }
    } else{
        [[[UIAlertView alloc] initWithTitle:nil message:@"您已经上传过了" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }
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
