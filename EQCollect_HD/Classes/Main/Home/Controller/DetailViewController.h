//  
//
//  Created by 董徐维 on 15/8/12.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//123

#import <UIKit/UIKit.h>
#import "SurveyPointCell.h"
@class PointinfoViewController;

@interface DetailViewController : UITableViewController <UISplitViewControllerDelegate,UIAlertViewDelegate,UISearchBarDelegate,InfoCellDelegate>

//@property (nonatomic, retain) UINavigationController *nav;
@property (nonatomic, retain) PointinfoViewController *pointinfoVC;

@property (nonatomic, retain) NSMutableArray *dataProvider;        //所有的调查点信息
@property (nonatomic, retain) NSArray *filtedData;        //需要显示的调查点信息

@end
