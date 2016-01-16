//
//  DownloadedNoteModel.h
//  EQCollect_HD
//
//  Created by shi on 15/12/28.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadedNoteModel : NSObject

@property (nonatomic, copy) NSString *resourcename;         //资源名字

@property (nonatomic, strong) NSURL *resourceUrl;           //资源路径

@end
