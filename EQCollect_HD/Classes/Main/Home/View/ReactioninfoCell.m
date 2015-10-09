//
//  ReactioninfoCell.m
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "ReactioninfoCell.h"

@implementation ReactioninfoCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteReactioninfo:(id)sender {
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
