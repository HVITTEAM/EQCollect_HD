//
//  MessageViewController.m
//  EQCollect_HD
//
//  Created by shi on 15/11/14.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageTableHelper.h"
#import "MessageModel.h"

@interface MessageViewController ()
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UITextField *timeTextField;
@property (strong,nonatomic)MessageModel *messageData;            //如果为空则表示还没添加提示，否则表示提示已经存在
@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.contentTextView.layer.borderColor = [HMColor(200, 200, 200) CGColor];
    self.contentTextView.layer.borderWidth = 0.5f;
    self.contentTextView.layer.cornerRadius = 7;
    self.contentTextView.layer.masksToBounds = YES;
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(uploadMessage)];
    
    NSMutableArray *arr = [[MessageTableHelper sharedInstance] selectDataByAttribute:@"pointid" value:self.pointModel.pointid];
    if (arr.count ==0) {
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd HH:mm"];
        self.timeTextField.text = [formatter stringFromDate:date];
    }else{
        self.messageData = [arr lastObject];
        self.phoneNumTextField.text = self.messageData.phoneNum;
        self.contentTextView.text = self.messageData.content;
        self.timeTextField.text = self.messageData.time;
    }
}

-(void)setPointModel:(PointModel *)pointModel
{
    _pointModel = pointModel;
}

-(void)uploadMessage
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                  @"content":self.contentTextView.text,
                                                                                  @"phoneNum":self.phoneNumTextField.text,
                                                                                  @"time":self.timeTextField.text,
                                                                                  @"pointid":self.pointModel.pointid,
                                                                                  @"upload":@"0"
                                                                                  }];
    
    if (!self.messageData) {//说明要新增加一条提示
        
        MBProgressHUD *mbprogress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        //创建字典对象作为上传参数
        NSMutableDictionary *parameters1 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                            self.phoneNumTextField.text,@"msgtel",
                                            self.contentTextView.text,@"msgcontent",
                                            self.pointModel.pointid,@"pointid",
                                            nil];
        NSLog(@"%@",parameters1);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:URL_addmsg parameters:parameters1 success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"数据上传成功: %@", responseObject);
            //上传数据成功则更新本地数据
            dict[@"messageId"] = [NSString stringWithFormat:@"%u",arc4random()];
            [[MessageTableHelper sharedInstance] insertDataWith:dict];
            [mbprogress removeFromSuperview];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"数据上传失败:");
            [mbprogress removeFromSuperview];
        }];
    }else{//提示已存在，所以是更新提示
        dict[@"messageId"] = self.messageData.messageId;
        [[MessageTableHelper sharedInstance] updateDataWith:dict];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)back
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end

