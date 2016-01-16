//
//  DamageinfoListController.m
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "DamageinfoListController.h"
#import "DamageinfoCell.h"
#import "PictureMode.h"
#import "MultipartFormObject.h"

@interface DamageinfoListController ()<InfoCellDelegate>

@property (nonatomic, retain) NSMutableArray *dataProvider;          //数据源

@property (strong,nonatomic) MBProgressHUD *mbprogress;            //等待指示器

@end

@implementation DamageinfoListController
#pragma mark -- 生命周期方法 --
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //下拉刷新
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
#pragma mark Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataProvider.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *damageinfoCellId = @"damageinfoCell";
    DamageinfoCell *cell = [tableView dequeueReusableCellWithIdentifier:damageinfoCellId];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DamageinfoCell" owner:nil options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //获取cell的数据
    DamageModel * damageinfo = [self.dataProvider objectAtIndex:indexPath.row];
    //设置cell的属性
    cell.damageid.text = [NSString stringWithFormat:@"编号:%@",damageinfo.damageid];
    cell.damagetime.text = damageinfo.damagetime;
    
    if ([damageinfo.upload isEqualToString:kdidUpload]) {
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

#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //跳转到新增房屋震害界面
    DamageinfoViewController *damageinfoVC = [[DamageinfoViewController alloc] initWithNibName:@"DamageinfoViewController" bundle:nil];
    damageinfoVC.damageinfo = self.dataProvider[indexPath.row];
    damageinfoVC.actionType = kActionTypeShow;
    damageinfoVC.delegate = self;
    [self.parentViewController.navigationController pushViewController:damageinfoVC animated:YES];
}

#pragma mark DamageinfoDelegate
/**
 *  新增房屋震害信息后回调
 */
-(void)addDamageinfoSuccess:(DamageinfoViewController *)damageinfoVC
{
    [damageinfoVC dismissViewControllerAnimated:YES completion:nil];
    [self.tableView.header beginRefreshing];
}

/**
 *  更新房屋震害信息后回调
 */
-(void)updateDamageinfoSuccess:(DamageinfoViewController *)damageinfoVC
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
    DamageModel * damageinfo = [self.dataProvider objectAtIndex:indexPath.row];
    
    //从数据库表中删除房屋震害信息
    BOOL result = YES;
    result = [[PictureInfoTableHelper sharedInstance] deleteImageByReleteTable:@"DAMAGEINFOTAB" Releteid:damageinfo.damageid];
    if (result) {
        result = [[DamageinfoTableHelper sharedInstance] deleteDataByAttribute:@"damageid" value:damageinfo.damageid];
    }
    if (result) {
        //如果删除成功，则把房屋震害信息从dataProvider数组中删除并刷新界面
        [self.dataProvider removeObject:damageinfo];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    }else{
        [[[UIAlertView alloc] initWithTitle:nil message:@"删除数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }
}

/**
 *  上传房屋震害信息数据
 */
-(void)infocell:(InfoCell *)cell didClickUpLoadBtnAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.pointUploadFlag isEqualToString:kdidNotUpload]) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"请先上传该条数据对应的调查点信息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
        return;
    }

    self.mbprogress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    DamageModel *model = [self.dataProvider objectAtIndex:indexPath.row];
    NSString * fortificationintensity  = [SharedAppUtil switchRomeNumToNum:model.fortificationintensity];
    
    //创建字典对象作为上传参数
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                          model.damageid,@"damageid",
                          model.pointid,@"pointid",
                          model.buildingage, @"buildingage",
                          model.damagearea,@"damagearea",
                          model.fieldtype,@"fieldtype",
                          model.damagelevel,@"damagelevel",
                          model.zrcorxq,@"zrcorxq",
                          model.dworzh,@"dworzh",
                          fortificationintensity,@"fortificationintensity",
                          model.damagesituation,@"damagesituation",
                          model.damageindex,@"damageindex",
                          model.damagerindex,@"damagerindex",
                          model.housetype,@"housetype",
                          model.damagetime,@"damagetime",
                          nil];
    
    [CommonRemoteHelper RemoteWithUrl:URL_adddamage parameters:parameters type:CommonRemoteTypePost success:^(id responseObject) {
        NSLog(@"数据上传成功: %@", responseObject);
        [self uploadImagesOfDamageinfoWithIndexPath:indexPath];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.mbprogress removeFromSuperview];
        [[[UIAlertView alloc] initWithTitle:nil message:@"房屋震害数据上传失败,请检查网络是否异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }];
}

#pragma mark -- 内部方法 --
/**
 *  上传房屋震害图片,上传成功刷新数据；没有需要上传图片则刷新数据
 */
-(void)uploadImagesOfDamageinfoWithIndexPath:(NSIndexPath *)indexpath
{
    DamageModel *model = [self.dataProvider objectAtIndex:indexpath.row];
    //获取要上传的图片
    NSArray *imgs = [[PictureInfoTableHelper sharedInstance] selectDataByReleteTable:@"DAMAGEINFOTAB" Releteid:model.damageid];
    
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
        
       NSDictionary *params = @{@"id":model.damageid,@"from":@"damage"};
        
       [CommonRemoteHelper remoteImageWithUrl:URL_addimg parameters:params formObjects:formObjects success:^(id responseObject) {
            NSLog(@"图片上传成功: %@", responseObject);
            //上传图片成功则更新本地数据
            [self.mbprogress removeFromSuperview];
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
    DamageModel *model = [self.dataProvider objectAtIndex:indexpath.row];
    //更新本地数据库这条数据的上传状态
    BOOL result = [[DamageinfoTableHelper sharedInstance]updateUploadFlag:kdidUpload ID:model.damageid];
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
    self.dataProvider = [[DamageinfoTableHelper sharedInstance] selectDataByAttribute:@"pointid" value:self.pointid];
    [self.tableView reloadData];
}

-(void)dealloc
{
    NSLog(@"DamageinfoListController释放了吗。。。。。。。。。。。。。");
}

@end