//
//  SWYMapTypeSelectView.h
//  EQ_DisasterReport
//
//  Created by shi on 15/11/3.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, mapType)
{
    mapTypeStandard,   // 2D地图
    mapTypeSatellite,  // 卫星地图
    mapType3D          // 3D地图
};

@protocol MapTypeSelectViewDelegate;

@interface SWYMapTypeSelectView : UIView
/*背景按钮*/
@property(nonatomic,strong)UIButton *bkView;

@property(nonatomic,weak)id<MapTypeSelectViewDelegate>delegate;

/**显示view到指定的视图上*/
- (void)showMapTypeViewToView:(UIView *)superView position:(CGPoint)loc;

/**从指定view上删除*/
-(void)removeMapTypeView;

@end

@protocol MapTypeSelectViewDelegate <NSObject>
/**选择地图类型后回调*/
-(void)mapTypeSelectView:(SWYMapTypeSelectView *)mapTypeView selectedType:(mapType)type;

@end