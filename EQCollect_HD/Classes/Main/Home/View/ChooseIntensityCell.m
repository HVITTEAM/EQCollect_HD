//
//  ChooseIntensityCell.m
//  EQCollect_HD
//
//  Created by shi on 15/11/13.
//  Copyright © 2015年 董徐维. All rights reserved.
//
#define margin 10
#import "ChooseIntensityCell.h"

@interface ChooseIntensityCell ()
@property (weak, nonatomic) IBOutlet UILabel *intensityLb;
@property (weak, nonatomic) IBOutlet UILabel *feelLb;
@property (weak, nonatomic) IBOutlet UILabel *damageLb;
@property (weak, nonatomic) IBOutlet UILabel *otherLb;
@end


@implementation ChooseIntensityCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(instancetype)cellWithTableView:(UITableView *)tableView model:(NSDictionary *)dict
{
    static NSString *chooseIntensityCellID = @"chooseIntensityCell";
    ChooseIntensityCell *cell = [tableView dequeueReusableCellWithIdentifier:chooseIntensityCellID];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ChooseIntensityCell" owner:nil options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.intensityLb.text = dict[@"intensity"];
    cell.feelLb.text = dict[@"feel"];
    cell.damageLb.text = dict[@"damage"];
    cell.otherLb.text = dict[@"other"];
    return cell;
}

+(CGFloat)heightForCell:(NSDictionary *)dict
{
    static ChooseIntensityCell *cell = nil;
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ChooseIntensityCell" owner:nil options:nil] lastObject];
    }
    
    cell.intensityLb.preferredMaxLayoutWidth = 540 - 4*margin-60;
    cell.feelLb.preferredMaxLayoutWidth = 540 - 4*margin-60;
    cell.damageLb.preferredMaxLayoutWidth = 540 - 4*margin-60;
    cell.otherLb.preferredMaxLayoutWidth = 540 - 4*margin-60;
    
    cell.intensityLb.text = dict[@"intensity"];
    cell.feelLb.text = dict[@"feel"];
    cell.damageLb.text = dict[@"damage"];
    cell.otherLb.text = dict[@"other"];
    
    [cell.contentView updateConstraintsIfNeeded];
    [cell.contentView layoutIfNeeded];
    
    CGFloat h = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height+1;
    return h;
}

@end