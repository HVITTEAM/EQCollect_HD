//
//  AbnormalinfoListController.m
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "AbnormalinfoListController.h"
#import "PictureMode.h"

@interface AbnormalinfoListController ()

@property (nonatomic, retain) NSMutableArray *dataProvider;

@end

@implementation AbnormalinfoListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //下拉刷新
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(rereshing)];

    self.tableView.backgroundColor = HMGlobalBg;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self.tableView.header beginRefreshing];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataProvider.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
        
    if ([abnormalInfo.upload isEqualToString:@"1"]) {
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AbnormalinfoViewController *abnormalinfoVC1 = [[AbnormalinfoViewController alloc] initWithNibName:@"AbnormalinfoViewController" bundle:nil];
    abnormalinfoVC1.abnormalinfo = self.dataProvider[indexPath.row];
    abnormalinfoVC1.actionType = kActionTypeShow;
    abnormalinfoVC1.delegate = self;
    [self.nav pushViewController:abnormalinfoVC1 animated:YES];
}

#pragma mark - InfoCellDelegate
//删除cell
-(void)infoCell:(InfoCell *)cell didClickDeleteBtnAtIndexPath:(NSIndexPath *)indexPath
{
    //获取Cell的数据
    AbnormalinfoModel * abnormalInfo = [self.dataProvider objectAtIndex:indexPath.row];
    
    //从数据库表中删除这个宏观异常信息
    BOOL result = YES;
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



////上传数据
//-(void)infocell:(InfoCell *)cell didClickUpLoadBtnAtIndexPath:(NSIndexPath *)indexPath
//{
//    AbnormalinfoModel *model = [self.dataProvider objectAtIndex:indexPath.row];
//    //上传数据 。。。。
//    //上传数据成功则更新本地数据
//    BOOL result = [[AbnormalinfoTableHelper sharedInstance]updateUploadFlag:@"1" ID:model.abnormalid];
//    if (result) {
//        model.upload = @"1";
//        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//    }
//}

//上传数据
-(void)infocell:(InfoCell *)cell didClickUpLoadBtnAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.pointUploadFlag isEqualToString:@"0"]) {
        [[[UIAlertView alloc] initWithTitle:@"警告" message:@"请先上传调查点数据表信息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
        return;
    }

    MBProgressHUD *mbprogress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AbnormalinfoModel *model = [self.dataProvider objectAtIndex:indexPath.row];
    //获取要上传的图片
    NSArray *imgs = [[PictureInfoTableHelper sharedInstance] selectDataByReleteTable:@"ABNORMALINFOTAB" Releteid:model.abnormalid];
    
    //创建字典对象作为上传参数
    NSDictionary *parameters1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          model.abnormalid,@"abnormalid",
                          //model.abnormaltime,@"abnormaltime",
                          model.informant,@"informant",
                          @"123", @"abnormalintensity",
                          model.groundwater, @"groundwater",
                          model.abnormalhabit,@"abnormalhabit",
                          model.abnormalphenomenon,@"abnormalphenomenon",
                          model.other,@"other",
                          model.implementation,@"implementation",
                          model.abnormalanalysis,@"abnormalanalysis",
                          model.credibly,@"credibly",
                          model.pointid,@"pointid",
                         // @"0",@"upload",
                          nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_addabnormal parameters:parameters1 success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"数据上传成功: %@", responseObject);
        if (imgs.count > 0) {
            //信息上传成功后上传对应的图片
            //NSDictionary *parameters2 = @{@"v": @"参数"};
            NSDictionary *parameters2 = @{@"id":model.abnormalid,@"from":@"abnormal"};
            [manager POST:URL_addimg parameters:parameters2 constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                //循环添加要上传的图片
                for (PictureMode *picmodel in imgs) {
                    NSURL *filePath = [NSURL fileURLWithPath:picmodel.picturePath];
                    NSData * imagedata = [NSData dataWithContentsOfURL:filePath];
                    [formData appendPartWithFileData:imagedata name:@"file" fileName:[NSString stringWithFormat:@"%@.jpg",picmodel.pictureName] mimeType:@"image/jpeg"];
                }
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"图片上传成功: %@", responseObject);
                //上传数据成功则更新本地数据
                BOOL result = [[AbnormalinfoTableHelper sharedInstance]updateUploadFlag:@"1" ID:model.abnormalid];
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
        }else{
            NSLog(@"不用上传图片");
            //上传数据成功则更新本地数据
            BOOL result = [[AbnormalinfoTableHelper sharedInstance]updateUploadFlag:@"1" ID:model.abnormalid];
            if (result) {
                model.upload = @"1";
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                });
                [mbprogress removeFromSuperview];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"数据上传失败:");
        [mbprogress removeFromSuperview];
    }];
    
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
    self.dataProvider = [[AbnormalinfoTableHelper sharedInstance] selectDataByAttribute:@"pointid" value:self.pointid];
    [self.tableView reloadData];
}

-(void)updateAbnormalinfo:(NSNotification *)notification
{
    [self.tableView.header beginRefreshing];
}

-(void)addAbnormalinfoSuccess:(id)abnormalinfoVC
{
    [abnormalinfoVC dismissViewControllerAnimated:YES completion:nil];
    [self updateAbnormalinfo:nil];
}

-(void)updateAbnormalinfoSuccess:(AbnormalinfoViewController *)abnormalinfoVC
{
    [self updateAbnormalinfo:nil];
}

-(void)dealloc
{
    NSLog(@"AbnormalinfoListController释放了吗。。。。。。。。。。。。。");
}

@end
