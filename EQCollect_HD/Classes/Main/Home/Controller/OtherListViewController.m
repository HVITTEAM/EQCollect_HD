//
//  OtherListViewController.m
//  EQCollect_HD
//
//  Created by shi on 15/12/10.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import "OtherListViewController.h"
#import "OtherTableHelper.h"
#import "OtherModel.h"
#import "OtherCell.h"
#import "MultipartFormObject.h"

@interface OtherListViewController ()<InfoCellDelegate>

@property (nonatomic, retain) NSMutableArray *dataProvider;         //数据源

@property (strong,nonatomic) MBProgressHUD *mbprogress;            //等待指示器

@end

@implementation OtherListViewController

#pragma  mark --生命周期方法--
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //下拉刷新
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(rereshing)];
    self.tableView.backgroundColor = HMGlobalBg;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView.header beginRefreshing];
}

#pragma  mark --getter 和 setter 方法--
-(NSMutableArray *)dataProvider
{
    if (!_dataProvider) {
        _dataProvider = [[NSMutableArray alloc] init];
    }
    return _dataProvider;
}

#pragma mark -- 协议方法 --
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataProvider.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *otherCellId = @"otherCell";
    OtherCell *cell = [tableView dequeueReusableCellWithIdentifier:otherCellId];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"OtherCell" owner:nil options:nil]lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    OtherModel *model = self.dataProvider[indexPath.row];
    
    cell.otherIdLb.text = [NSString stringWithFormat:@"编号:%@",model.otherid];
    cell.lonLb.text = [NSString stringWithFormat:@"经度:%@",model.otherlon];
    cell.latLb.text = [NSString stringWithFormat:@"纬度:%@",model.otherlat];
    cell.timeLb.text = [NSString stringWithFormat:@"时间:%@",model.othertime];
    cell.addressLb.text = [NSString stringWithFormat:@"地址:%@",model.otheraddress];
    
    if ([model.upload isEqualToString:kdidUpload]) {
        cell.uploadBtn.selected = YES;
        [cell.uploadBtn setBackgroundColor:HMColor(0, 160,70)];
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

#pragma mark - Table view delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 84;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //跳转到新增房屋震害界面
    OtherViewController *otherVC = [[OtherViewController alloc] init];
    otherVC.otherInfor = self.dataProvider[indexPath.row];
    otherVC.actionType = kActionTypeShow;
    otherVC.delegate = self;
    [self.parentViewController.navigationController pushViewController:otherVC animated:YES];
}

#pragma mark - OtherinfoDelegate
/**
 *  新增其它信息后回调
 */
-(void)addOtherInfoSuccess:(OtherViewController *)otherVC
{
    [otherVC dismissViewControllerAnimated:YES completion:nil];
    [self.tableView.header beginRefreshing];
}

/**
 *  更新其它信息后回调
 */
-(void)updateOtherInfoSuccess:(OtherViewController *)otherVC
{
    [self.tableView.header beginRefreshing];
}

#pragma mark - InfoCellDelegate
/**
 *  删除cell
 */
-(void)infoCell:(InfoCell *)cell didClickDeleteBtnAtIndexPath:(NSIndexPath *)indexPath
{
    //获取cell的数据
    OtherModel * model = [self.dataProvider objectAtIndex:indexPath.row];
    
    //从数据库表中删除房屋震害信息
    BOOL result = YES;
    //先删图片，再删数据信息
    result = [[PictureInfoTableHelper sharedInstance] deleteImageByReleteTable:@"OTHERTAB" Releteid:model.pointid];
    if (result) {
        result = [[OtherTableHelper sharedInstance] deleteDataByAttribute:@"otherid" value:model.otherid];
    }
    
    if (result) {
        //如果删除成功，则把房屋震害信息从dataProvider数组中删除并刷新界面
        [self.dataProvider removeObject:model];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    }else{
        [[[UIAlertView alloc] initWithTitle:nil message:@"删除数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }
}

/**
 *  上传其它信息数据
 */
-(void)infocell:(InfoCell *)cell didClickUpLoadBtnAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.pointUploadFlag isEqualToString:kdidNotUpload]) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"请先上传该条数据对应的调查点信息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
        return;
    }
    
    self.mbprogress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    OtherModel *model = [self.dataProvider objectAtIndex:indexPath.row];
    
    //创建字典对象作为上传参数
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 model.otherid,@"otherid",
                                 model.othercontent,@"othercontent",
                                 model.otherlat,@"otherlat",
                                 model.otherlon, @"otherlon",
                                 model.otheraddress, @"otheraddress",
                                 model.othertime,@"othertime",
                                 model.pointid,@"pointid",
                                 nil];
    
    [CommonRemoteHelper RemoteWithUrl:URL_addother parameters:parameters type:CommonRemoteTypePost success:^(id responseObject) {
        NSLog(@"数据上传成功: %@", responseObject);
        [self uploadImagesOfOtherWithIndexPath:indexPath];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.mbprogress removeFromSuperview];
        [[[UIAlertView alloc] initWithTitle:nil message:@"其它表数据上传失败,请检查网络是否异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }];
}

#pragma mark -- 内部方法 --
/**
 *  上传其它表图片,上传成功刷新数据；没有需要上传图片则刷新数据
 */
-(void)uploadImagesOfOtherWithIndexPath:(NSIndexPath *)indexpath
{
    OtherModel *model = [self.dataProvider objectAtIndex:indexpath.row];
    //获取要上传的图片
    NSArray *imgs = [[PictureInfoTableHelper sharedInstance] selectDataByReleteTable:@"OTHERTAB" Releteid:model.otherid];
    
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

        NSDictionary *params = @{@"id":model.otherid,@"from":@"other"};
        
        [CommonRemoteHelper remoteImageWithUrl:URL_addimg parameters:params formObjects:formObjects success:^(id responseObject) {
            NSLog(@"图片上传成功: %@", responseObject);
            [self updateLocalDataAfterUploadSuccessWithIndexpath:indexpath];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"图片上传失败:");
            [self.mbprogress removeFromSuperview];
        }];
        
    }else{
        NSLog(@"不用上传图片图片");
        [self updateLocalDataAfterUploadSuccessWithIndexpath:indexpath];
    }
}

/**
 *  更新本地数据库并刷新
 */
-(void)updateLocalDataAfterUploadSuccessWithIndexpath:(NSIndexPath *)indexpath
{
    OtherModel *model = [self.dataProvider objectAtIndex:indexpath.row];
    //更新本地数据库中这条数据的上传状态
    BOOL result = [[OtherTableHelper sharedInstance]updateUploadFlag:kdidUpload ID:model.otherid];
    if (result) {
        model.upload = kdidUpload;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationLeft];
        });
    }
}

#pragma mark -- 刷新数据方法 --
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
    self.dataProvider = [[OtherTableHelper sharedInstance] selectDataByAttribute:@"pointid" value:self.pointid];
    [self.tableView reloadData];
}

-(void)dealloc
{
    NSLog(@"DamageinfoListController释放了吗。。。。。。。。。。。。。");
}


@end
