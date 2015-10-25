//
//  FeedbackViewController.m
//  EQCollect_HD
//
//  Created by shi on 15/10/24.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import "FeedbackViewController.h"
#import <MessageUI/MessageUI.h>

@interface FeedbackViewController () <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *subjectTextFiew;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.contentTextView.layer.borderColor = [[UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1.0f] CGColor];
    self.contentTextView.layer.borderWidth = 0.5f;
    self.contentTextView.layer.cornerRadius = 8.0f;
    self.contentTextView.layer.masksToBounds = YES;
    
    self.sendBtn.layer.cornerRadius = 5.0f;
    self.sendBtn.layer.masksToBounds = YES;

}

- (IBAction)sendMail:(id)sender {
    
    NSLog(@"发送邮件。。。。。。。");
    
    NSString* subjectStr = self.subjectTextFiew.text;
    NSString* contentStr = self.contentTextView.text;
    if(subjectStr != nil && subjectStr.length > 0 && contentStr != nil && contentStr.length > 0)
    {
        NSString *mailUrl = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", @"swyhei8080@qq.com",subjectStr, contentStr];
        NSString* email = [mailUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString:email]];
    }else{
        [[[UIAlertView alloc] initWithTitle:@"内容不能为空" message:nil delegate:nil
                          cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }
}


@end
