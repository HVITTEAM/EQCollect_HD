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

@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;        //电话号码文本框

@property (weak, nonatomic) IBOutlet UITextView *contentTextView;           //提示内容文本框

@property (weak, nonatomic) IBOutlet UITextField *timeTextField;            //时间文本框

@property (strong,nonatomic) UIBarButtonItem *leftItem;                   //导航栏上的左侧按钮

@property (strong,nonatomic) UIBarButtonItem *rightItem;                  //导航栏上的右侧按钮

@property (strong,nonatomic)MessageModel *messageData;      //如果为空则表示本地数据库中没数据，否则表示提示已经存在

@end

@implementation MessageViewController

#pragma mark -- 生命周期方法 --
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.contentTextView.layer.borderColor = [HMColor(200, 200, 200) CGColor];
    self.contentTextView.layer.borderWidth = 0.5f;
    self.contentTextView.layer.cornerRadius = 7;
    self.contentTextView.layer.masksToBounds = YES;
    
    [self initNaviBar];
    
    [self showMessageData];
}

#pragma mark -- 初始化子视图方法 --
/**
 *  初始化导航栏
 */
-(void)initNaviBar
{
    self.leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = self.leftItem;
    self.rightItem = [[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(uploadMessage)];
}

#pragma mark -- 事件方法 --
/**
 *  上传提示信息
 */
-(void)uploadMessage
{
    if (!self.messageData) {    //为空说明这条数据没保存
        [self addMessageInfo];
    }else{
        [self updateMessageInfo];
    }
    
    //先上传调查点之后才能上传提示
    if ([self.pointModel.upload isEqualToString:kdidNotUpload]) {
        [NoticeHelper AlertShow:@"请先上传对应调查点信息！" view:self.view];
        return;
    }
    
    MBProgressHUD *mbprogress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //创建上传参数
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       self.phoneNumTextField.text,@"msgtel",
                                       self.contentTextView.text,@"msgcontent",
                                       self.pointModel.pointid,@"pointid",
                                       nil];
    [CommonRemoteHelper RemoteWithUrl:URL_addmsg parameters:parameters type:CommonRemoteTypePost success:^(id responseObject) {
        //上传数据成功则更新本地数据
        [mbprogress removeFromSuperview];
        [[MessageTableHelper sharedInstance]updateUploadFlag:kdidUpload ID:self.pointModel.pointid];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"数据上传失败:");
        [mbprogress removeFromSuperview];

    }];
}

#pragma mark -- 内部方法 --
/**
 *  显示数据，先去数据库中找，找到就显示，没找到说明这次是新增，显示时间
 */
-(void)showMessageData
{
    self.timeTextField.userInteractionEnabled = NO;
    
    //从数据库获取数据
    NSMutableArray *msgModelArr = [[MessageTableHelper sharedInstance]selectDataByAttribute:@"pointid" value:self.pointModel.pointid];
    if (msgModelArr.count ==0) {
        //数据库中不存在，说明新增
        self.navigationItem.rightBarButtonItem = self.rightItem;
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        self.timeTextField.text = [formatter stringFromDate:date];

    }else{
        //数据库中存在，则给messageData赋值
        self.messageData = [msgModelArr lastObject];
        
        self.phoneNumTextField.text = self.messageData.phoneNum;
        self.contentTextView.text = self.messageData.content;
        self.timeTextField.text = self.messageData.time;
        
        if ([self.messageData.upload isEqualToString:kdidNotUpload]){
            
            self.navigationItem.rightBarButtonItem = self.rightItem;
            
            self.phoneNumTextField.userInteractionEnabled = YES;
            self.contentTextView.userInteractionEnabled = YES;
            
        }else{
            self.phoneNumTextField.userInteractionEnabled = NO;
            self.contentTextView.userInteractionEnabled = NO;
        }
    }
}

/**
 *  新增数据
 */
-(void)addMessageInfo
{
    MessageModel *msgModel = [[MessageModel alloc] init];
    msgModel.content = self.contentTextView.text;
    msgModel.phoneNum = self.phoneNumTextField.text;
    msgModel.time = self.timeTextField.text;
    msgModel.pointid = self.pointModel.pointid;
    msgModel.upload = kdidNotUpload;
    
    msgModel.messageId = [NSString stringWithFormat:@"%u",arc4random()];
    //保存到数据库
    [[MessageTableHelper sharedInstance]insertDataWithMessageinfoModel:msgModel];
}

/**
 *  更新数据
 */
-(void)updateMessageInfo
{
    MessageModel *msgModel = [[MessageModel alloc] init];
    msgModel.content = self.contentTextView.text;
    msgModel.phoneNum = self.phoneNumTextField.text;
    msgModel.time = self.messageData.time;
    msgModel.pointid = self.messageData.pointid;
    msgModel.upload = self.messageData.upload;
    
    msgModel.messageId = self.messageData.messageId;
    //更新数据
    [[MessageTableHelper sharedInstance]updateDataWithMessageinfoModel:msgModel];
}

-(void)back
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end

