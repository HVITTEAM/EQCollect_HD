//
//  NaviParamsSelectViewController.h
//  EQCollect_HD
//
//  Created by shi on 15/11/29.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, TravelTypes)
{
    TravelTypeCar = 0,    // 驾车方式
    TravelTypeWalk,       // 步行方式
};
@class NavPointAnnotation;
@protocol NaviParamsSelectViewControllerDelegate;
@interface NaviParamsSelectViewController : UIViewController
@property(weak,nonatomic)id<NaviParamsSelectViewControllerDelegate>delegate;
@end

@protocol NaviParamsSelectViewControllerDelegate <NSObject>

-(void)getRoute:(BOOL)isStartCurrentLocation start:(NavPointAnnotation *)startAnnotation end:(NavPointAnnotation *)endAnnotation travelType:(TravelTypes)travelType;
@end