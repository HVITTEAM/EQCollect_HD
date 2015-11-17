//
//  ChooseIntensityViewController.h
//  EQCollect_HD
//
//  Created by shi on 15/11/13.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol chooseIntensityDelegate;
@interface ChooseIntensityViewController : UITableViewController
@property(nonatomic,weak)id<chooseIntensityDelegate>delegate;
+(instancetype)sharedInstance;
@end

@protocol chooseIntensityDelegate <NSObject>
-(void)viewController:(ChooseIntensityViewController *)chooseIntensityVC selectedIntensity:(NSString *)intensity;
@end