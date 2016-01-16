//
//  ImageCollectionView.h
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/17.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^changeHeight)(CGFloat);

@interface ImageCollectionView : UICollectionViewController

@property (nonatomic, strong) NSMutableArray *dataProvider;        //数据源

//@property (nonatomic, weak) UINavigationController *nav;

@property (nonatomic, assign) ActionType showType;                 //页面类型

@property (nonatomic ,assign) BOOL isExitThread;                    //线程退出标志

@property (nonatomic,copy)changeHeight changeHeightBlock;          //根据图片的数量改变view的高度的 block

@end
