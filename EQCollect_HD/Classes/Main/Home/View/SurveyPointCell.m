//
//  SurveyPointCell.m
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/1.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "SurveyPointCell.h"

@interface SurveyPointCell ()
@property (strong, nonatomic) IBOutlet UILabel *pointTitleText;
@property (strong, nonatomic) IBOutlet UILabel *pointAddressText;
@property (strong, nonatomic) IBOutlet UILabel *pointTimeText;
@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
@property (weak, nonatomic) IBOutlet UILabel *pointIdText;
@end

@implementation SurveyPointCell

- (void)awakeFromNib {
    // Initialization code
    self.uploadBtn.layer.cornerRadius = 7.0f;
    self.uploadBtn.layer.masksToBounds = YES;
    self.deleteBtn.layer.cornerRadius = 7.0f;
    self.deleteBtn.layer.masksToBounds = YES;
    self.messageBtn.layer.cornerRadius = 7.0f;
    self.messageBtn.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setModel:(PointModel *)model
{
    _model = model;
    //设置cell的属性
    self.pointTitleText.text =[NSString stringWithFormat:@"名称:%@",model.pointname];
    self.pointIdText.text = [NSString stringWithFormat:@"编号:%@",model.pointid];
    self.pointTimeText.text = model.pointtime;
    self.pointAddressText.text = [NSString stringWithFormat:@"调查地址:%@",model.pointlocation];
    
    //上传按钮处于选中状态，表示已经上传
    if ([model.upload isEqualToString:kdidUpload]) {
        self.uploadBtn.selected = YES;
        [self.uploadBtn setTitle:@"已上传" forState:UIControlStateNormal];
        [self.uploadBtn setBackgroundColor:HMColor(0, 160, 70)];
    }else{
        self.uploadBtn.selected = NO;
        [self.uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
        [self.uploadBtn setBackgroundColor:HMColor(102, 147, 255)];
    }
}


- (IBAction)deleteSurveyPoint:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"警告" message:@"数据一但删除将不可恢复" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
}
- (IBAction)upLoadSurveyPoint:(UIButton *)sender {
    //如果上传按钮处于选中状态，表示已经上传
    if (!sender.selected) {
        if ([self.delegate respondsToSelector:@selector(infocell:didClickUpLoadBtnAtIndexPath:)]) {
            [self.delegate infocell:self didClickUpLoadBtnAtIndexPath:self.indexPath];
        }
    } else{
        [[[UIAlertView alloc] initWithTitle:nil message:@"您已经上传过了" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }
}

- (IBAction)showMessageView:(id)sender {
    if ([self.delegate respondsToSelector:@selector(infocell:didClickMessageBtnAtIndexPath:)]) {
        [self.delegate infocell:self didClickMessageBtnAtIndexPath:self.indexPath];
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
