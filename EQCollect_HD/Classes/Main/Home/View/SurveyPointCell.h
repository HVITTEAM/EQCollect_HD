//
//  SurveyPointCell.h
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/1.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^deleteSurveyPoint)();

@interface SurveyPointCell : UITableViewCell<UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *pointTitleText;
@property (strong, nonatomic) IBOutlet UILabel *pointAddressText;
@property (strong, nonatomic) IBOutlet UILabel *pointTimeText;

@property (copy)deleteSurveyPoint deletePointBlock;

- (IBAction)deleteSurveyPoint:(id)sender;
@end
