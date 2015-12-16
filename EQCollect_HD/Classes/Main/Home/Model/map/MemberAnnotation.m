//
//  MemberAnnotation.m
//  EQCollect_HD
//
//  Created by shi on 15/12/9.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import "MemberAnnotation.h"

@implementation MemberAnnotation
{
    NSString *_title;
    NSString *_subTitle;
    CLLocationCoordinate2D _coordinate;
}

-(instancetype)initWithLon:(float)lon lat:(float)lat memberName:(NSString *)name address:(NSString *)addr
{
    self = [super init];
    if (self) {
        _title = name;
        _subTitle = addr;
        _coordinate = CLLocationCoordinate2DMake(lat,lon);
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return _coordinate;
}

- (NSString *)title
{
    return _title;
}

- (NSString *)subtitle
{
    return _subTitle;
}


@end
