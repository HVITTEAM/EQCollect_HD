//
//  MemberAnnotation.h
//  EQCollect_HD
//
//  Created by shi on 15/12/9.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapNaviKit/MAMapKit.h>

@interface MemberAnnotation : NSObject<MAAnnotation>
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
-(instancetype)initWithLon:(float)lon lat:(float)lat memberName:(NSString *)name address:(NSString *)addr;
@end
