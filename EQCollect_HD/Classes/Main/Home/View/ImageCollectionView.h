//
//  ImageCollectionView.h
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/17.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"
#import "CommonUIImagePickerController.h"
#import "PictureVO.h"
#import <AVFoundation/AVFoundation.h>
#import "UzysAssetsPickerController.h"

typedef void(^changeHeight)(CGFloat);

@interface ImageCollectionView : UICollectionViewController<UIAlertViewDelegate,UIImagePickerControllerDelegate,MWPhotoBrowserDelegate,UzysAssetsPickerControllerDelegate,UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate>

@property (nonatomic, retain) NSMutableArray *dataProvider;

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;

@property (nonatomic, retain) UINavigationController *nav;
/**页面方式**/
@property (nonatomic, assign) ActionType showType;

@property (nonatomic,assign)BOOL isShowAddBtn;

/**根据图片的数改变view的高度**/
@property (nonatomic,copy)changeHeight changeHeightBlock;
@end
