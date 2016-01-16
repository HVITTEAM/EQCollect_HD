//
//  NoteViewController.m
//  EQCollect_HD
//
//  Created by shi on 15/12/16.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import "NoteViewController.h"
#import "NoteModel.h"
#import "WebViewController.h"
#import "DownloadedNoteModel.h"

@interface NoteViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(strong,nonatomic)UITableView *allTableView;                          //所有文件视图

@property(strong,nonatomic)UITableView *downloadTableView;                     //下载的文件视图

@property(strong,nonatomic)NSMutableArray *allDatas;                           //所有文件视图数据

@property(strong,nonatomic)NSMutableArray *downloadDatas;                      //下载的文件视图数据

@property(strong,nonatomic)UISegmentedControl *segment;

@property(strong,nonatomic)AFHTTPRequestOperation *afOperation;                 //AFNetworking请求

@end

@implementation NoteViewController

#pragma mark -- 生命周期方法 --
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNaviBar];
    
    [self initTableView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect talbeRect = self.view.bounds;
    talbeRect.origin.y = 44;
    self.allTableView.frame = talbeRect;
    self.downloadTableView.frame = talbeRect;
}

#pragma mark -- 初始化子视图方法 --
/**
 *  初始化导航栏
 */
-(void)initNaviBar
{
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style: UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationItem.titleView = [self segment];
}

/**
 *  添加两个tableView
 */
-(void)initTableView
{
    [self.view addSubview:self.downloadTableView];
    [self.view addSubview:self.allTableView];
     //下拉刷新
    [self.allTableView.header beginRefreshing];
}

#pragma mark -- getter 和 setter 方法 --
/**
 *  allTableView的 getter 方法
 */
-(UITableView *)allTableView
{
    if (!_allTableView) {
        _allTableView = [[UITableView alloc] init];
        _allTableView.dataSource = self;
        _allTableView.delegate = self;
        _allTableView.tableFooterView = [[UIView alloc] init];
        _allTableView.backgroundColor = HMGlobalBg;
        _allTableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadFirstData)];
        _allTableView.backgroundView = [self createBackgroudView:@"没有获取到文件信息!"];
        _allTableView.backgroundView.hidden = YES;
    }
    return _allTableView;
}

/**
 *  downloadTableView的 getter 方法
 */
-(UITableView *)downloadTableView
{
    if (!_downloadTableView) {
        _downloadTableView = [[UITableView alloc] init];
        _downloadTableView.dataSource = self;
        _downloadTableView.delegate = self;
        _downloadTableView.tableFooterView = [[UIView alloc] init];
        _downloadTableView.backgroundColor = HMGlobalBg;
        _downloadTableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(fetchDataFromDatabase)];
        _downloadTableView.backgroundView = [self createBackgroudView:@"没有下载的文件!"];
        _downloadTableView.backgroundView.hidden = YES;
    }
    return _downloadTableView;
}

/**
 * allDatas的 getter 方法
 */
-(NSMutableArray *)allDatas
{
    if (!_allDatas) {
        _allDatas = [[NSMutableArray alloc] init];
    }
    return _allDatas;
}

/**
 * downloadDatas的 getter 方法
 */
-(NSMutableArray *)downloadDatas
{
    if (!_downloadDatas) {
        _downloadDatas = [[NSMutableArray alloc] init];
    }
    return _downloadDatas;
}

/**
 * segment的 getter 方法
 */
-(UISegmentedControl *)segment
{
    if (!_segment) {
        _segment = [[UISegmentedControl alloc] initWithItems:@[@"全部",@"已下载"]];
        _segment.selectedSegmentIndex = 0;
        [_segment addTarget:self action:@selector(segmentedControlValueChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _segment;
}

#pragma mark -- 协议方法 --
#pragma mark Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.allTableView) {
        return self.allDatas.count;
    }
    return self.downloadDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.allTableView) {            //显示所有数据
        static NSString *noteCellId = @"noteCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noteCellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:noteCellId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NoteModel *model = self.allDatas[indexPath.row];
        cell.textLabel.text = model.resourcename;
        cell.detailTextLabel.text = model.uploadtime;
        
        //设置下载的按钮
        UIButton *accessoryViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        accessoryViewBtn.frame = CGRectMake(0, 0, 30, 30);
        [accessoryViewBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [accessoryViewBtn setBackgroundImage:[UIImage imageNamed:@"down_icon"] forState:UIControlStateNormal];
        [accessoryViewBtn addTarget:self action:@selector(accessoryDownloadButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = accessoryViewBtn;
        
        return cell;
    }else{              //显示下载数据
        static NSString *noteCellId = @"downloadNoteCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noteCellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:noteCellId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        DownloadedNoteModel *model = self.downloadDatas[indexPath.row];
        cell.textLabel.text = model.resourcename;
        
        //设置删除的按钮
        UIButton *accessoryViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        accessoryViewBtn.frame = CGRectMake(0, 0, 30, 30);
        [accessoryViewBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [accessoryViewBtn setBackgroundImage:[UIImage imageNamed:@"del_icon"] forState:UIControlStateNormal];
        [accessoryViewBtn addTarget:self action:@selector(accessoryDeleteButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.accessoryView = accessoryViewBtn;

        
        return cell;
    }
}

#pragma mark  UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.allTableView) {
        return;
    }
    //用UIWebView 打开文件
    DownloadedNoteModel *model = self.downloadDatas[indexPath.row];
    [self openFileWithDownloadedNoteModel:model];
}

#pragma mark -- 事件方法 --
-(void)back
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  切换UISegmentedControl控件时调用
 */
-(void)segmentedControlValueChange:(UISegmentedControl *)segment
{
    //交换两个tableView的位置
    [self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    [self fetchDataFromDatabase ];
}

/**
 *  allTableView下拉刷新从服务器获取文件数据
 */
-(void)loadFirstData
{
    //说明已经在请求数据了
    if (self.afOperation != nil) {
        return;
    }
   self.afOperation = [CommonRemoteHelper RemoteWithUrl:URL_resources parameters:nil type:CommonRemoteTypePost success:^(id responseObject) {
        [self.allDatas removeAllObjects];
        for (int i = 0;i < ((NSArray *)responseObject).count; i++) {
            NoteModel *model = [NoteModel objectWithKeyValues:responseObject[i]];
            [self.allDatas addObject:model];
        }
        [self.allTableView reloadData];
        [self.allTableView.header endRefreshing];
        self.afOperation = nil;
       
       [self setBackgroudViewOfTableViews ];
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.allTableView.header endRefreshing];
        self.afOperation = nil;
        [NoticeHelper AlertShow:@"数据下载失败" view:self.view];
        [self setBackgroudViewOfTableViews];
    }];
}

/**
 *  downloadTableView下拉刷新,从本地获取下载完成的文件列表
 */
-(void)fetchDataFromDatabase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths lastObject];
    NSString *fileDirectory = [documentPath stringByAppendingPathComponent:@"files"];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:fileDirectory]) {
        
        [self.downloadDatas removeAllObjects];
        
        NSArray *files=[fileManager subpathsAtPath:fileDirectory];
        
        for (NSString *fileName in files) {
            
            NSString *absolutePath=[fileDirectory stringByAppendingPathComponent:fileName];
            
            NSString *pathEncoding = [absolutePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSURL *fileUrl = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",pathEncoding]];
            DownloadedNoteModel *downMode = [[DownloadedNoteModel alloc] init];
            downMode.resourcename = fileName;
            downMode.resourceUrl = fileUrl;
            [self.downloadDatas addObject:downMode];
        }
    }

    
    [self.downloadTableView reloadData];
    [self.downloadTableView.header endRefreshing];
    
    [self setBackgroudViewOfTableViews];
}

/**
 *  点击下载按钮时触发
 */
-(void)accessoryDownloadButtonTapped:(UIButton *)sender event:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    
    //如果点击位置不在下载按钮上什么事也不做
    if (![sender pointInside:[touch locationInView:sender] withEvent:event])
    {
        return;
    }
    //如果点击了下载按钮，获取点击点对应的 cell 位置
    CGPoint touchPosition = [touch locationInView:self.allTableView];
    NSIndexPath *tapedIndexPath = [self.allTableView indexPathForRowAtPoint:touchPosition];
    
    NoteModel *model = self.allDatas[tapedIndexPath.row];
    
    //创建一个 url 字符串
    NSString *urlStr = [NSString stringWithFormat:@"%@%@%@%@",URL_base,@"/upload/",model.resourcepath,model.resourcename];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self downLoadFileWithURL:urlStr];
}

/**
 *  点击删除按钮时触发
 */
-(void)accessoryDeleteButtonTapped:(UIButton *)sender event:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    
    //如果点击位置不在下载按钮上什么事也不做
    if (![sender pointInside:[touch locationInView:sender] withEvent:event])
    {
        return;
    }
    //如果点击了删除按钮，获取点击点对应的 cell 位置
    CGPoint touchPosition = [touch locationInView:self.downloadTableView];
    NSIndexPath *tapedIndexPath = [self.downloadTableView indexPathForRowAtPoint:touchPosition];
    
    DownloadedNoteModel *model = self.downloadDatas[tapedIndexPath.row];

    //获取文件路径
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths lastObject];
    NSString *fielPath = [documentPath stringByAppendingFormat:@"/files/%@",model.resourcename];
    
    //如果存在，删除文件
    if ([fileManager fileExistsAtPath:fielPath]) {
        [fileManager removeItemAtPath:fielPath error:nil];
        [self fetchDataFromDatabase];
        [NoticeHelper AlertShow:[NSString stringWithFormat:@"删除文件%@成功",model.resourcename] view:self.view];
    }
}

/**
 *  根据 URL 路径去服务器上下载文件
 */
-(void)downLoadFileWithURL:(NSString *)urlStr
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSProgress *progress = nil;
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        //获取下载文件夹
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [paths lastObject];
        NSString *fileDirectoryPath = [documentPath stringByAppendingPathComponent:@"files"];
        
        //如果下载文件夹不存在，创建一个
        if (![fileManager fileExistsAtPath:fileDirectoryPath]) {
           [fileManager createDirectoryAtPath:fileDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        //设置下载文件的存放路径
        NSURL *fileDirectoryURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",fileDirectoryPath]];
        return [fileDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        [NoticeHelper AlertShow:[NSString stringWithFormat:@"%@文件下载成功",response.suggestedFilename] view:self.view];
    }];
    [downloadTask resume];
}

/**
 *  打开一个本地文件
 */
-(void)openFileWithDownloadedNoteModel:(DownloadedNoteModel *)model
{
    WebViewController *webVC = [[WebViewController alloc] init];
    webVC.fileUrl = model.resourceUrl;
    webVC.fileName = model.resourcename;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
    [self presentViewController:nav animated:YES completion:nil];
}

/**
 *  创建一个 tableview 的背景 view
 */
-(UIView *)createBackgroudView:(NSString *)msgStr
{
    UIView *bkView = [[UIView alloc]init];
    
    UIImageView *iconImageView = [[UIImageView alloc] init];
    iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    iconImageView.image = [UIImage imageNamed:@"navi_icon"];
    iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [bkView addSubview:iconImageView];
    
    UITextField *msgTextField = [[UITextField alloc] init];
    msgTextField.translatesAutoresizingMaskIntoConstraints = NO;
    msgTextField.textAlignment = NSTextAlignmentCenter;
    msgTextField.font = [UIFont systemFontOfSize:15];
    msgTextField.textColor = [UIColor lightGrayColor];
    msgTextField.text = msgStr;
    [bkView addSubview:msgTextField];
    
    NSDictionary *viewDict = NSDictionaryOfVariableBindings(bkView,iconImageView,msgTextField);
    
    [bkView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[iconImageView]|" options:0 metrics:nil views:viewDict]];
    [bkView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[msgTextField]|" options:0 metrics:nil views:viewDict]];
    [bkView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[iconImageView]-10-[msgTextField]" options:0 metrics:nil views:viewDict]];
    
    NSLayoutConstraint *cons = [NSLayoutConstraint constraintWithItem:iconImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:bkView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-100];
    
    [bkView addConstraint:cons];
    
    return bkView;
}

-(void)setBackgroudViewOfTableViews
{
    //设置背景 view 隐藏与显示
    if (self.downloadDatas.count == 0) {
        self.downloadTableView.backgroundView.hidden = NO;
    }else{
        self.downloadTableView.backgroundView.hidden = YES;
    }
    
    if (self.allDatas.count == 0) {
        self.allTableView.backgroundView.hidden = NO;
    }else{
        self.allTableView.backgroundView.hidden = YES;
    }
    
}


-(void)dealloc
{
    NSLog(@"NoteViewController 释放了吗");
}

@end
