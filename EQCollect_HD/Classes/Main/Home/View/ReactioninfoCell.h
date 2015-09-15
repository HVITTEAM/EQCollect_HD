//
//  ReactioninfoCell.h
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^deleteReactioninfo)();

@interface ReactioninfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *reactionTittle;
@property (weak, nonatomic) IBOutlet UILabel *informantname;
@property (weak, nonatomic) IBOutlet UILabel *informantage;
@property (weak, nonatomic) IBOutlet UILabel *informanteducation;
@property (weak, nonatomic) IBOutlet UILabel *reactionaddress;
@property (weak, nonatomic) IBOutlet UILabel *reactiontime;

@property (copy)deleteReactioninfo deleteReactioninfoBlock;

- (IBAction)deleteReactioninfo:(id)sender;

@end
