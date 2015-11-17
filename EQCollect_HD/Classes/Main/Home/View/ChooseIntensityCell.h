//
//  ChooseIntensityCell.h
//  EQCollect_HD
//
//  Created by shi on 15/11/13.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseIntensityCell : UITableViewCell
+(instancetype)cellWithTableView:(UITableView *)tableView model:(NSDictionary *)dict;
+(CGFloat)heightForCell:(NSDictionary *)dict;

@end
