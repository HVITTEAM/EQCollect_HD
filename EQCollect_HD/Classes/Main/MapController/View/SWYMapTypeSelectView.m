//
//  SWYMapTypeSelectView.m
//  EQ_DisasterReport
//
//  Created by shi on 15/11/3.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import "SWYMapTypeSelectView.h"
#define kMargin 20

@implementation SWYMapTypeSelectView
{
    CGFloat imgwidth;   //图片宽
}

- (instancetype)init
{
    if (self = [super init]) {
        [self initMapTypeView];
    }
    return self;
}

/**
 *  初始化视图
 */
- (void)initMapTypeView
{
    //创建半透明的背景按钮，点击退出
    self.bkView = [UIButton buttonWithType:UIButtonTypeCustom];
    self.bkView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
    [self.bkView addTarget:self action:@selector(removeMapTypeView) forControlEvents:UIControlEventTouchUpInside];
    
    //循环创建内部视图
    for (int i = 0; i<3; i++) {
        UIButton *imgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        imgBtn.userInteractionEnabled = YES;
        imgBtn.tag = 30+i;
        
        if (i==0) {
            [imgBtn setBackgroundImage: [self resizableImageWithImageName:@"mapType_standardimage_normal"] forState:UIControlStateNormal];
            [imgBtn setBackgroundImage: [self resizableImageWithImageName:@"mapType_standardimage_selected"] forState:UIControlStateSelected];
            imgBtn.selected = YES;
        }else if (i==1){
            [imgBtn setBackgroundImage:[self resizableImageWithImageName:@"mapType_satelliteImage_normal"] forState:UIControlStateNormal];
            [imgBtn setBackgroundImage:[self resizableImageWithImageName:@"mapType_satelliteImage_selected"] forState:UIControlStateSelected];
        }else{
            [imgBtn setBackgroundImage:[self resizableImageWithImageName:@"mapType_3DImage_normal"] forState:UIControlStateNormal];
            [imgBtn setBackgroundImage:[self resizableImageWithImageName:@"mapType_3DImage_selected"] forState:UIControlStateSelected];
        }
        
        [imgBtn addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:imgBtn];
    }
    
    //设置 view 属性
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = YES;
}

/**
 *  对视图布局
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    //计算图片宽
    imgwidth = (self.width - 4*kMargin)/3;
    
    for (int i = 0; i<3; i++) {
        UIImageView *imgBtn = (UIImageView *)[self viewWithTag:30+i];
        imgBtn.frame = CGRectMake(kMargin+i*(imgwidth+kMargin), kMargin, imgwidth, imgwidth*0.75);  //设置图片高为宽的0.75倍
    }
}

/**
 *  显示这个view到指定的父视图上
 *
 *  @param superView 父视图
 *  @param loc  位置
 */
- (void)showMapTypeViewToView:(UIView *)superView position:(CGPoint)loc
{
    //计算view的宽高
    CGFloat width = superView.bounds.size.width/3;
    CGFloat height = (width-4*kMargin)/3 *0.75+2*kMargin;
    
    //添加背景按钮
    self.bkView.frame = superView.bounds;
    [superView addSubview:self.bkView];
    
    [superView addSubview:self];
    
    self.layer.anchorPoint = CGPointMake(1, 0);
    self.frame = CGRectMake(superView.width - width - 70, loc.y, width, height);
    
    //设置出现动画
    CGAffineTransform transform = CGAffineTransformMakeScale(0, 0);
    transform = CGAffineTransformTranslate(transform,-(width-10), 0);
    self.transform = transform;
    [UIView animateWithDuration:0.5 animations:^{
        self.transform = CGAffineTransformIdentity;
        
    }];

}

/**
 *  从父视图上删除view
 */
-(void)removeMapTypeView
{
    [self.bkView removeFromSuperview];
    [self removeFromSuperview];
}

/**
 *  点击按钮后将选择的地图类型回调
 */
-(void)selectType:(UIButton *)sender
{
    for (int i=0; i<3; i++) {
        UIButton *btn = [self viewWithTag:30+i];
        btn.selected = NO;
    }
    sender.selected = YES;
    
    if ([self.delegate respondsToSelector:@selector(mapTypeSelectView:selectedType:)]) {
        [self.delegate mapTypeSelectView:self selectedType:sender.tag-30];
    }
}

- (UIImage *)resizableImageWithImageName:(NSString *)name
{
    UIImage *image = [UIImage imageWithName:name];
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch];
}
@end
