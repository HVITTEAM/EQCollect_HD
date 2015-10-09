//
//  DamageinfoCell.h
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoCell.h"

@interface DamageinfoCell : InfoCell<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *damageid;
@property (weak, nonatomic) IBOutlet UILabel *damageintensity;
@property (weak, nonatomic) IBOutlet UILabel *fortificationintensity;
@property (weak, nonatomic) IBOutlet UILabel *damagesituation;
@property (weak, nonatomic) IBOutlet UILabel *damageaddress;
@property (weak, nonatomic) IBOutlet UILabel *damagetime;

- (IBAction)deleteDamageinfo:(id)sender;

@end
