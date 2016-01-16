//
//  ChooseIntensityCell.h
//  EQCollect_HD
//
//  Created by shi on 15/11/13.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseIntensityCell : UITableViewCell

/**
 *  创建 Cell
 */
+(instancetype)cellWithTableView:(UITableView *)tableView model:(NSDictionary *)dict;

/**
 *  计算cell高度
 */
+(CGFloat)heightForCell:(NSDictionary *)dict tableView:(UITableView *)tableView;

@end
