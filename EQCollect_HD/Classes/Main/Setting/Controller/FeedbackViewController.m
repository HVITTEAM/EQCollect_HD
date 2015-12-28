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
    
    self.contentTextView.layer.borderColor = HMColor(200, 200, 200).CGColor;
    self.contentTextView.layer.borderWidth = 0.5f;
    self.contentTextView.layer.cornerRadius = 8.0f;
    self.contentTextView.layer.masksToBounds = YES;
    
    self.sendBtn.layer.cornerRadius = 5.0f;
    self.sendBtn.layer.masksToBounds = YES;
}

#pragma mark -- 协议方法 --

#pragma mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            [self showAlertMsg:@"结果: 邮件被取消发送" title:@"发送结果"];
            break;
        case MFMailComposeResultSent:
            [self showAlertMsg:@"结果: 发送成功" title:@"发送结果"];
            break;
        case MFMailComposeResultFailed:
            [self showAlertMsg:@"结果:  发送失败" title:@"发送结果"];
            break;
        case MFMailComposeResultSaved:
            [self showAlertMsg:@"结果: 邮件被保存了" title:@"发送结果"];
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- 事件方法 --
- (IBAction)sendMail:(id)sender {
    
    NSString* subjectStr = self.subjectTextFiew.text;
    NSString* contentStr = self.contentTextView.text;
    if(subjectStr != nil && subjectStr.length > 0 && contentStr != nil && contentStr.length > 0){
        if ([MFMailComposeViewController canSendMail]){
            
            // 创建MFMailComposeViewController对象
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            
            // 为MFMailComposeViewController对象指定mailComposeDelegate
            picker.mailComposeDelegate = self;
            picker.navigationBar.tintColor = [UIColor blackColor];
            
            // 设置收件人，此处可通过NSArray集合指定多个收件人
            picker.toRecipients = [NSArray arrayWithObject:@"swyhei8080@qq.com"];
            
            // 设置邮件主题
            picker.subject = subjectStr;
            
            // 设置邮件正文
            [picker setMessageBody:contentStr isHTML:NO];
            
            // 显示MFMailComposeViewController控制器
            [self presentViewController:picker animated:YES completion:nil];
            
        }else{
            [self showAlertMsg:@"你的设备不支持发邮件，需要配置你的设备" title:@"请配置邮件"];
        }
    }else{
        [self showAlertMsg:nil title:@"内容不能为空"];
    }
}


- (void)showAlertMsg:(NSString*) msg title:(NSString *)titleStr
{
    [[[UIAlertView alloc] initWithTitle:titleStr
                                message:msg
                               delegate:nil
                      cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
}

@end
