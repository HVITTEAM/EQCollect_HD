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


@interface NoteViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(strong,nonatomic)UITableView *allTableView;

@property(strong,nonatomic)UITableView *downloadTableView;

@property(strong,nonatomic)NSMutableArray *allDatas;

@property(strong,nonatomic)NSMutableArray *downloadDatas;

@property(strong,nonatomic)AFHTTPRequestOperationManager *manager;

@property(strong,nonatomic)UISegmentedControl *segment;

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
        _allTableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadFirstData)];
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
        _downloadTableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(fetchDataFromDatabase)];
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
 * manager的 getter 方法
 */
-(AFHTTPRequestOperationManager *)manager
{
    if (!_manager) {
        _manager = [AFHTTPRequestOperationManager manager];
    }
    return _manager;
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

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.allDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *noteCellId = @"noteCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noteCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:noteCellId];
    }
    
    NoteModel *model = self.allDatas[indexPath.row];
    
    cell.textLabel.text = model.resourcename;
    cell.detailTextLabel.text = model.uploadtime;
    
    UIButton *accessoryViewBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60.f, 40.f)];
    [accessoryViewBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [accessoryViewBtn setTitle:@"下载" forState:UIControlStateNormal];
    [accessoryViewBtn addTarget:self action:@selector(accessoryButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = accessoryViewBtn;
    return cell;
}

#pragma mark - 事件方法
-(void)back
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)loadFirstData
{
    NSLog(@"456");
    self.manager = [AFHTTPRequestOperationManager manager];
    [self.manager POST:URL_resources parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        
        [self.allDatas removeAllObjects];
        for (int i = 0;i < ((NSArray *)responseObject).count; i++) {
            NoteModel *model = [NoteModel objectWithKeyValues:responseObject[i]];
            [self.allDatas addObject:model];
        }
        [self.allTableView reloadData];
        [self.allTableView.header endRefreshing];
        
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"数据下载失败:%@",error);
        [self.allTableView.header endRefreshing];
    }];
}

-(void)loadNextData
{

}

-(void)fetchDataFromDatabase
{
    NSLog(@"123");
    [self.downloadTableView.header endRefreshing];
}

-(void)accessoryButtonTapped:(UIButton *)sender event:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    
    if (![sender pointInside:[touch locationInView:sender] withEvent:event])
    {
        return;
    }
    
    CGPoint touchPosition = [touch locationInView:self.allTableView];
    
    NSIndexPath *tapedIndexPath = [self.allTableView indexPathForRowAtPoint:touchPosition];
    
    NoteModel *model = self.allDatas[tapedIndexPath.row];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@%@%@",URL_base,@"/upload/",model.resourcepath,model.resourcename];
    NSLog(@"++++++++++++++++++++%@",urlStr);
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self downLoadFileWithURL:urlStr];
}


-(void)downLoadFileWithURL:(NSString *)urlStr
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSProgress *progress = nil;
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSLog(@"suggestedFilename  %@",[response suggestedFilename]);
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
        [self openFileWithURL:filePath];
    }];
    [downloadTask resume];
}

-(void)openFileWithURL:(NSURL *)url
{
    WebViewController *webVC = [[WebViewController alloc] init];
    webVC.fileUrl = url;
    [self.navigationController pushViewController:webVC animated:YES];
}

-(void)segmentedControlValueChange:(UISegmentedControl *)segment
{
    [self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    NSLog(@"sdfsadfsdf");
}

@end
