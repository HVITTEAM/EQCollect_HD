//
//  InfoCell.h
//  EQCollect_HD
//
//  Created by shi on 15/10/9.
//  Copyright © 2015年 董徐维. All rights reserved.
// 作为调查点，宏观异常等信息 cell 的父类，主要定义了InfoCellDelegate协议和两个属性

#import <UIKit/UIKit.h>

@class  InfoCell;

@protocol InfoCellDelegate <NSObject>
@required
//删除cell时调用
- (void)infoCell:(InfoCell *)cell didClickDeleteBtnAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface InfoCell : UITableViewCell
//cell 所在的NSIndexPath
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (weak, nonatomic) id<InfoCellDelegate>delegate;

@end
