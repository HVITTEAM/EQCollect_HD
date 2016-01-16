//
//  ImageCollectionFlowLayout.m
//  EQCollect_HD
//
//  Created by shi on 16/1/4.
//  Copyright © 2016年 董徐维. All rights reserved.
//

#define kColumn  5

#import "ImageCollectionFlowLayout.h"

@implementation ImageCollectionFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
   NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    
    for (int i = 0; i < attributes.count; i++) {
        
        NSInteger row = i/kColumn;
        NSInteger col = i%kColumn;
        
        UICollectionViewLayoutAttributes *currentLayoutAttributes = attributes[i];
        CGRect frame = currentLayoutAttributes.frame;
        frame.origin.x = self.minimumInteritemSpacing + col * (currentLayoutAttributes.size.width + self.minimumInteritemSpacing);
        frame.origin.y = self.minimumLineSpacing + row * (currentLayoutAttributes.size.height+self.minimumLineSpacing);
        currentLayoutAttributes.frame = frame;
    }
    return attributes;
}

@end
