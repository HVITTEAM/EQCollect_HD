//
//  ChooseIntensityCell.m
//  EQCollect_HD
//
//  Created by shi on 15/11/13.
//  Copyright © 2015年 董徐维. All rights reserved.
//
#define kMargin 10
#define kTitleViewWidth 60

#import "ChooseIntensityCell.h"

@interface ChooseIntensityCell ()

@property (weak, nonatomic) IBOutlet UILabel *intensityLb;         //烈度 Label(罗马数字)

@property (weak, nonatomic) IBOutlet UILabel *feelLb;              //感觉描述Label

@property (weak, nonatomic) IBOutlet UILabel *feelTitleLb;         //感觉标题Label(人的感觉)

@property (weak, nonatomic) IBOutlet UILabel *damageLb;            //建筑损坏描述Label

@property (weak, nonatomic) IBOutlet UILabel *otherLb;             //其它描述Label

@property (weak, nonatomic) IBOutlet UIView *titleView;            //烈度的边框

@end

@implementation ChooseIntensityCell

- (void)awakeFromNib {
    // Initialization code
    
    self.titleView.layer.borderColor = HMGlobalBg.CGColor;
    self.titleView.layer.borderWidth = 1.0f;
    self.titleView.layer.cornerRadius = 8.0f;
    self.titleView.layer.masksToBounds = YES;
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

+(CGFloat)heightForCell:(NSDictionary *)dict tableView:(UITableView *)tableView
{
    static ChooseIntensityCell *cell = nil;
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ChooseIntensityCell" owner:nil options:nil] lastObject];
    }
    
    [cell.feelTitleLb sizeToFit];
    CGFloat feelTitleLbWidth = cell.feelTitleLb.width;
    
    CGFloat cellWidth = tableView.bounds.size.width;
    
    cell.intensityLb.preferredMaxLayoutWidth = cellWidth - 4 * kMargin - kTitleViewWidth - feelTitleLbWidth;
    cell.feelLb.preferredMaxLayoutWidth = cellWidth - 4 * kMargin - kTitleViewWidth - feelTitleLbWidth;
    cell.damageLb.preferredMaxLayoutWidth = cellWidth - 4 * kMargin - kTitleViewWidth - feelTitleLbWidth;
    cell.otherLb.preferredMaxLayoutWidth = cellWidth - 4 * kMargin - kTitleViewWidth - feelTitleLbWidth;
    
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