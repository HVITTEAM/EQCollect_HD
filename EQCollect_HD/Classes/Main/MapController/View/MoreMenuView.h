//
//  MoreMenuView.h
//  officialDemoNavi
//
//  Created by AutoNavi on 15/1/28.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapNaviKit/AMapNaviCommonObj.h>

@protocol MoreMenuViewDelegate;

@interface MoreMenuView : UIView

@property (nonatomic, assign) id<MoreMenuViewDelegate> delegate;

@property (nonatomic, assign) AMapNaviViewShowMode viewShowMode;
@property (nonatomic, assign) BOOL showNightType;

@end

@protocol MoreMenuViewDelegate <NSObject>
@optional

- (void)moreMenuViewFinishButtonClicked;
- (void)moreMenuViewViewModeChangeTo:(AMapNaviViewShowMode)viewShowMode;
- (void)moreMenuViewNightTypeChangeTo:(BOOL)isShowNightType;

@end