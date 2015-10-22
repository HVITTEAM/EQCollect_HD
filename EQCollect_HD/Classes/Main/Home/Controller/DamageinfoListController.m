//
//  DamageinfoListController.m
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "DamageinfoListController.h"
#import "DamageinfoViewController.h"
#import "PictureMode.h"

@interface DamageinfoListController ()
{
    MBProgressHUD *_H ;
}

@end

@implementation DamageinfoListController

- (void)viewDidLoad {
    [super viewDidLoad];
    //下拉刷新
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(rereshing)];

    self.tableView.backgroundColor = HMGlobalBg;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getDataProvider];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDamageinfo:) name:kAddDamageinfoSucceedNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataProvider.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *damageinfoCellId = @"damageinfoCell";
    DamageinfoCell *cell = [tableView dequeueReusableCellWithIdentifier:damageinfoCellId];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DamageinfoCell" owner:nil options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //获取cell的数据
    DamageModel * damageinfo = [self.dataProvider objectAtIndex:indexPath.row];
    //设置cell的属性
    cell.damageid.text = [NSString stringWithFormat:@"NO.%lu   %@",indexPath.row,damageinfo.damageid];
    cell.damagetime.text = damageinfo.damagetime;
    cell.damageintensity.text = damageinfo.damageintensity;
    cell.damagesituation.text = damageinfo.damagesituation;
    cell.damageaddress.text = damageinfo.damageaddress;
    cell.fortificationintensity.text = damageinfo.fortificationintensity;
    
    if ([damageinfo.upload isEqualToString:@"1"]) {
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (!self.damageinfoVC) {
//        self.damageinfoVC = [[DamageinfoViewController alloc] initWithNibName:@"DamageinfoViewController" bundle:nil];
//    }
//    self.damageinfoVC.damageinfo = self.dataProvider[indexPath.row];
//    self.damageinfoVC.actionType = kActionTypeShow;
//    [self.nav pushViewController:self.damageinfoVC animated:YES];
    
    DamageinfoViewController *damageinfoVC1 = [[DamageinfoViewController alloc] initWithNibName:@"DamageinfoViewController" bundle:nil];
    damageinfoVC1.damageinfo = self.dataProvider[indexPath.row];
    damageinfoVC1.actionType = kActionTypeShow;
    [self.nav pushViewController:damageinfoVC1 animated:YES];
}

-(void)updateDamageinfo:(NSNotification *)notification
{
    [self.tableView.header beginRefreshing];
}

#pragma mark - InfoCellDelegate
//删除cell
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

//上传数据
-(void)infocell:(InfoCell *)cell didClickUpLoadBtnAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.pointUploadFlag isEqualToString:@"0"]) {
        [[[UIAlertView alloc] initWithTitle:@"警告" message:@"请先上传调查点数据表信息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
        return;
    }
    
    MBProgressHUD *mbprogress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    DamageModel *model = [self.dataProvider objectAtIndex:indexPath.row];
    //获取要上传的图片
    NSArray *imgs = [[PictureInfoTableHelper sharedInstance] selectDataByReleteTable:@"DAMAGEINFOTAB" Releteid:model.damageid];
    
    //创建字典对象作为上传参数
    NSDictionary *parameters1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          model.damageid,@"damageid",
                          //model.damagetime,@"damagetime",
                          model.damageaddress,@"damageaddress",
                          model.damageintensity, @"damageintensity",
                          model.zrcorxq, @"zrcorxq",
                          model.dworzh,@"dworzh",
                          model.fortificationintensity,@"fortificationintensity",
                          model.damagesituation,@"damagesituation",
                          model.damageindex,@"damageindex",
                          model.pointid,@"pointid",
                          //@"0",@"upload",
                          nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_adddamage parameters:parameters1 success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"数据上传成功: %@", responseObject);
        //信息上传成功后上传对应的图片
        //NSDictionary *parameters2 = @{@"v": @"参数"};
        NSDictionary *parameters2 = @{@"id":model.damageid,@"from":@"damage"};
        [manager POST:URL_addimg parameters:parameters2 constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            //循环添加要上传的图片
            for (PictureMode *picmodel in imgs) {
                NSURL *filePath = [NSURL fileURLWithPath:picmodel.picturePath];
                NSData * imagedata = [NSData dataWithContentsOfURL:filePath];
                [formData appendPartWithFileData:imagedata name:@"file" fileName:[NSString stringWithFormat:@"%@.png",picmodel.pictureName] mimeType:@"image/png"];
            }
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"图片上传成功: %@", responseObject);
            //上传数据成功则更新本地数据
            BOOL result = [[DamageinfoTableHelper sharedInstance]updateUploadFlag:@"1" ID:model.damageid];
            if (result) {
                model.upload = @"1";
                dispatch_async(dispatch_get_main_queue(), ^{
                   [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                });
                 [mbprogress removeFromSuperview];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"图片上传失败:");
             [mbprogress removeFromSuperview];
        }];
        //[mbprogress removeFromSuperview];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"数据上传失败:");
         [mbprogress removeFromSuperview];
        
    }];
    
//    //上传数据成功则更新本地数据
//    BOOL result = [[DamageinfoTableHelper sharedInstance]updateUploadFlag:@"1" ID:model.damageid];
//    if (result) {
//        model.upload = @"1";
//        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//    }
}

-(void)dealloc
{
    
    NSLog(@"DamageinfoListController释放了吗。。。。。。。。。。。。。");
}

@end