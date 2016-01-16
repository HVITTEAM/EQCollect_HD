//
//  WebViewController.h
//  EQCollect_HD
//
//  Created by shi on 15/12/16.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property(strong,nonatomic)NSURL *fileUrl;               //打开文件的 URL 路径

@property(strong,nonatomic)NSString *fileName;           //打开文件的文件名

@end
