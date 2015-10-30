//
//  SurveyPointCell.h
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/1.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoCell.h"

@interface SurveyPointCell : InfoCell<UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *pointTitleText;
@property (strong, nonatomic) IBOutlet UILabel *pointAddressText;
@property (strong, nonatomic) IBOutlet UILabel *pointTimeText;
@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UILabel *pointIdText;

- (IBAction)deleteSurveyPoint:(id)sender;
@end

