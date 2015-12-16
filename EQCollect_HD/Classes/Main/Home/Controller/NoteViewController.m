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


@interface NoteViewController ()

@property(strong,nonatomic)NSMutableArray *dataProvider;

@property(strong,nonatomic)AFHTTPRequestOperationManager *manager;

@end

@implementation NoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNaviBar];
    
    [self initTableView];
    
}

-(void)initNaviBar
{
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style: UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = leftItem;
}

-(void)initTableView
{
    //下拉刷新
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadFirstData)];

    [self.tableView.header beginRefreshing];

}

-(NSMutableArray *)dataProvider
{
    if (!_dataProvider) {
        _dataProvider = [[NSMutableArray alloc] init];
    }
    return _dataProvider;
}

-(AFHTTPRequestOperationManager *)manager
{
    if (!_manager) {
        _manager = [AFHTTPRequestOperationManager manager];
    }
    return _manager;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataProvider.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *noteCellId = @"noteCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noteCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:noteCellId];
    }
    
    NoteModel *model = self.dataProvider[indexPath.row];
    
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
    self.manager = [AFHTTPRequestOperationManager manager];
    [self.manager POST:URL_resources parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        
        for (int i = 0;i < ((NSArray *)responseObject).count; i++) {
            NoteModel *model = [NoteModel objectWithKeyValues:responseObject[i]];
            [self.dataProvider addObject:model];
            [self.tableView reloadData];
            [self.tableView.header endRefreshing];
        }
        
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"数据下载失败:%@",error);
        [self.tableView.header endRefreshing];
    }];

}

-(void)loadNextData
{

}

-(void)accessoryButtonTapped:(UIButton *)sender event:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    
    if (![sender pointInside:[touch locationInView:sender] withEvent:event])
    {
        return;
    }
    
    CGPoint touchPosition = [touch locationInView:self.tableView];
    
    NSIndexPath *tapedIndexPath = [self.tableView indexPathForRowAtPoint:touchPosition];
    
    NoteModel *model = self.dataProvider[tapedIndexPath.row];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@%@%@",URL_base,@"/upload/",model.resourcepath,model.resourcename];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@",urlStr);
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

@end
