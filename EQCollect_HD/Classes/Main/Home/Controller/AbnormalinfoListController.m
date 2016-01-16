//
//  AbnormalinfoListController.m
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "AbnormalinfoListController.h"
#import "AbnormalinfoCell.h"
#import "PictureMode.h"
#import "MultipartFormObject.h"

@interface AbnormalinfoListController ()<InfoCellDelegate>

@property (strong,nonatomic) NSMutableArray *dataProvider;            //数据源

@property (strong,nonatomic) MBProgressHUD *mbprogress;               //等待指示器

@end

@implementation AbnormalinfoListController

#pragma mark -- 生命周期方法 --
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //设置下拉刷新
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(rereshing)];
    self.tableView.backgroundColor = HMGlobalBg;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView.header beginRefreshing];
}

#pragma mark -- getter 和 setter方法 --
-(NSMutableArray *)dataProvider
{
    if (!_dataProvider) {
        _dataProvider = [[NSMutableArray alloc] init];
    }
    return _dataProvider;
}

#pragma mark -- 协议方法 --

#pragma mark   Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataProvider.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *abnormalinfoCellId = @"abnormalinfoCell";
    AbnormalinfoCell *cell = [tableView dequeueReusableCellWithIdentifier:abnormalinfoCellId];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AbnormalinfoCell" owner:nil options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //获取Cell的数据
    AbnormalinfoModel * abnormalInfo = [self.dataProvider objectAtIndex:indexPath.row];
    //设置cell的属性
    cell.abnormalIdText.text = [NSString stringWithFormat:@"编号:%@",abnormalInfo.abnormalid];
    cell.abnormaltimeText.text = abnormalInfo.abnormaltime;
    cell.intensityText.text = [NSString stringWithFormat:@"烈度:%@",abnormalInfo.abnormalintensity];
    cell.crediblyText.text = [NSString stringWithFormat:@"可信度:%@",abnormalInfo.credibly];
    cell.informantText.text = [NSString stringWithFormat:@"被调查者:%@",abnormalInfo.informant];
    
    //判断是否已上传
    if ([abnormalInfo.upload isEqualToString:kdidUpload]) {
        cell.uploadBtn.selected = YES;
        [cell.uploadBtn setBackgroundColor:HMColor(0, 160, 70)];
        [cell.uploadBtn setTitle:@"已上传" forState:UIControlStateNormal];
    }else{
        cell.uploadBtn.selected = NO;
        [cell.uploadBtn setBackgroundColor:HMColor(102, 147, 255)];
        [cell.uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
    }
    
    cell.indexPath = indexPath;
    cell.delegate = self;

    return cell;
}

#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //跳转到宏观异常信息界面
    AbnormalinfoViewController *abnormalinfoVC = [[AbnormalinfoViewController alloc] initWithNibName:@"AbnormalinfoViewController" bundle:nil];
    abnormalinfoVC.abnormalinfo = self.dataProvider[indexPath.row];
    abnormalinfoVC.actionType = kActionTypeShow;
    abnormalinfoVC.delegate = self;
    [self.parentViewController.navigationController pushViewController:abnormalinfoVC animated:YES];
}

#pragma mark AbnormalinfoDelegate
/**
 *  新增宏观异常信息后回调
 */
-(void)addAbnormalinfoSuccess:(id)abnormalinfoVC
{
    [abnormalinfoVC dismissViewControllerAnimated:YES completion:nil];
    [self.tableView.header beginRefreshing];
}

/**
 *  更新宏观异常信息后回调
 */
-(void)updateAbnormalinfoSuccess:(AbnormalinfoViewController *)abnormalinfoVC
{
    [self.tableView.header beginRefreshing];
}

#pragma mark  InfoCellDelegate
/**
 *  删除cell
 */
-(void)infoCell:(InfoCell *)cell didClickDeleteBtnAtIndexPath:(NSIndexPath *)indexPath
{
    //获取Cell的数据
    AbnormalinfoModel * abnormalInfo = [self.dataProvider objectAtIndex:indexPath.row];
    
    //从数据库表中删除这个宏观异常信息
    BOOL result = YES;
    
    //先删图片，再删数据信息
    result = [[PictureInfoTableHelper sharedInstance] deleteImageByReleteTable:@"ABNORMALINFOTAB" Releteid:abnormalInfo.abnormalid];
    if (result) {
        result = [[AbnormalinfoTableHelper sharedInstance] deleteDataByAttribute:@"abnormalid" value:abnormalInfo.abnormalid];
    }
    if (result) {
        //删除成功，则重新获取数据并刷新界面
        [self.dataProvider removeObject:abnormalInfo];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    }else{
        [[[UIAlertView alloc] initWithTitle:nil message:@"删除数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }
}

/**
 *  上传宏观异常信息数据
 */
-(void)infocell:(InfoCell *)cell didClickUpLoadBtnAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.pointUploadFlag isEqualToString:kdidNotUpload]) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"请先上传该条数据对应的调查点信息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
        return;
    }

    self.mbprogress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AbnormalinfoModel *model = [self.dataProvider objectAtIndex:indexPath.row];
    NSString * intensity  = [SharedAppUtil switchRomeNumToNum:model.abnormalintensity];

    //创建字典对象作为上传参数
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                          model.abnormalid,@"abnormalid",
                          model.abnormaltime,@"abnormaltime",
                          model.informant,@"informant",
                          intensity, @"abnormalintensity",
                          model.groundwater, @"groundwater",
                          model.abnormalhabit,@"abnormalhabit",
                          model.abnormalphenomenon,@"abnormalphenomenon",
                          model.other,@"other",
                          model.implementation,@"implementation",
                          model.abnormalanalysis,@"abnormalanalysis",
                          model.credibly,@"credibly",
                          model.pointid,@"pointid",
                          nil];
    
    
    [CommonRemoteHelper RemoteWithUrl:URL_addabnormal parameters:parameters type:CommonRemoteTypePost success:^(id responseObject) {
        NSLog(@"数据上传成功: %@", responseObject);
        [self uploadImagesOfAbnormalinfoWithIndexPath:indexPath];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.mbprogress removeFromSuperview];
        [[[UIAlertView alloc] initWithTitle:nil message:@"宏观异常数据上传失败,请检查网络是否异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }];
}

#pragma mark -- 内部方法 --
/**
 *  上传宏观异常图片,上传成功刷新数据；没有需要上传图片则刷新数据
 */
-(void)uploadImagesOfAbnormalinfoWithIndexPath:(NSIndexPath *)indexpath
{
     AbnormalinfoModel *model = [self.dataProvider objectAtIndex:indexpath.row];
    
    //获取要上传的图片
    NSArray *imgs = [[PictureInfoTableHelper sharedInstance] selectDataByReleteTable:@"ABNORMALINFOTAB" Releteid:model.abnormalid];
    
    if (imgs.count > 0) {
        //信息上传成功后上传对应的图片
        //创建MultipartFormObject对象数组,用来存储图片数据
        NSMutableArray *formObjects = [[NSMutableArray alloc] init];
        
        for (PictureMode *picmodel in imgs) {
            MultipartFormObject *formObj = [[MultipartFormObject alloc] init];
            
            NSURL *filePath = [NSURL fileURLWithPath:picmodel.picturePath];
            formObj.fileData = [NSData dataWithContentsOfURL:filePath];
            
            formObj.name = @"file";
            
            formObj.fileName = [NSString stringWithFormat:@"%@.jpg",picmodel.pictureName];
            
            formObj.mimeType = @"image/jpeg";
            
            [formObjects addObject:formObj];
        }
        
        NSDictionary *params = @{@"id":model.abnormalid,@"from":@"abnormal"};
        
        [CommonRemoteHelper remoteImageWithUrl:URL_addimg parameters:params formObjects:formObjects success:^(id responseObject) {
            NSLog(@"图片上传成功: %@", responseObject);
            [self.mbprogress removeFromSuperview];
            //上传图片成功则更新本地数据
            [self updateLocalDataAfterUploadSuccessWithIndexpath:indexpath];
  
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"图片上传失败:");
            [self.mbprogress removeFromSuperview];
        }];
    }else{
        NSLog(@"不用上传图片");
        [self.mbprogress removeFromSuperview];
        //上传数据成功则更新本地数据
        [self updateLocalDataAfterUploadSuccessWithIndexpath:indexpath];
    }
}

/**
 *  更新本地数据库并刷新
 */
-(void)updateLocalDataAfterUploadSuccessWithIndexpath:(NSIndexPath *)indexpath
{
    AbnormalinfoModel *model = [self.dataProvider objectAtIndex:indexpath.row];
    //更新本地数据库上传状态
    BOOL result = [[AbnormalinfoTableHelper sharedInstance]updateUploadFlag:kdidUpload ID:model.abnormalid];
    if (result) {
        model.upload = kdidUpload;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationLeft];
        });
    }
}

#pragma mark -- 刷新数据相关方法(MJ) --
/**
 *  刷新数据
 */
-(void)rereshing
{
    [self getDataProvider];
    [self.tableView.header endRefreshing];
}

/**
 *  获取数据
 */
-(void)getDataProvider
{
    self.dataProvider = [[AbnormalinfoTableHelper sharedInstance] selectDataByAttribute:@"pointid" value:self.pointid];
    [self.tableView reloadData];
}

-(void)dealloc
{
    NSLog(@"AbnormalinfoListController释放了吗。。。。。。。。。。。。。");
}

@end
