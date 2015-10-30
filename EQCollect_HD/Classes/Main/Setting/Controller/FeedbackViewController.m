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

//- (IBAction)sendMail:(id)sender {
//    
//    NSLog(@"发送邮件。。。。。。。");
//    
//    NSString* subjectStr = self.subjectTextFiew.text;
//    NSString* contentStr = self.contentTextView.text;
//    if(subjectStr != nil && subjectStr.length > 0 && contentStr != nil && contentStr.length > 0)
//    {
//        NSString *mailUrl = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", @"swyhei8080@qq.com",subjectStr, contentStr];
//        NSString* email = [mailUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
//        [[UIApplication sharedApplication] openURL: [NSURL URLWithString:email]];
//    }else{
//        [[[UIAlertView alloc] initWithTitle:@"内容不能为空" message:nil delegate:nil
//                          cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
//    }
//}
- (IBAction)sendMail:(id)sender {
    
    NSLog(@"发送邮件。。。。。。。");
    
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请配置邮件"
                                                            message:@"你的设备不支持发邮件，需要配置你的设备"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }else{
        [[[UIAlertView alloc] initWithTitle:@"内容不能为空" message:nil delegate:nil
                          cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            [self showAlert:@"结果: 邮件被取消发送"];
            break;
        case MFMailComposeResultSent:
            [self showAlert:@"结果: 发送成功"];
            break;
        case MFMailComposeResultFailed:
            [self showAlert:@"结果:  发送失败"];
            break;
        case MFMailComposeResultSaved:
            [self showAlert:@"结果: 邮件被保存了"];
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void) showAlert:(NSString*) msg
{
    [[[UIAlertView alloc] initWithTitle:@"发送结果" message:msg delegate:nil
                      cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
}


@end
