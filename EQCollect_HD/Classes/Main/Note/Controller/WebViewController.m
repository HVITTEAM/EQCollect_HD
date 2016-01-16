//
//  WebViewController.m
//  EQCollect_HD
//
//  Created by shi on 15/12/16.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewController

#pragma mark -- 生命周期方法 --
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initNavBar];
    
    self.webView.scalesPageToFit = YES;
    NSURLRequest *request = [NSURLRequest requestWithURL:self.fileUrl];
    [self.webView loadRequest:request];
}

#pragma mark -- 初始化子视图方法 --
/**
 *  根据 URL 路径去服务器上下载文件
 */
-(void)initNavBar
{
    self.navigationItem.title = self.fileName;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style: UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = leftItem;
}

#pragma mark -- 协议方法 --
#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{

}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{

}

-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
