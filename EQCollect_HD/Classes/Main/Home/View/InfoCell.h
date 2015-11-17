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
@optional
//删除cell时调用
- (void)infoCell:(InfoCell *)cell didClickDeleteBtnAtIndexPath:(NSIndexPath *)indexPath;
//上传 cell 时调用
-(void)infocell:(InfoCell *)cell didClickUpLoadBtnAtIndexPath:(NSIndexPath *)indexPath;

@optional
//上传提示
-(void)infocell:(InfoCell *)cell didClickMessageBtnAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface InfoCell : UITableViewCell
//cell 所在的NSIndexPath
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (weak, nonatomic) id<InfoCellDelegate>delegate;

@end
