//
//  ReactioninfoListController.m
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "ReactioninfoListController.h"
#import "ReactioninfoCell.h"
#import "PictureMode.h"
#import "MultipartFormObject.h"

@interface ReactioninfoListController ()<InfoCellDelegate>

@property (nonatomic, retain) NSMutableArray *dataProvider;        //数据源

@property (strong,nonatomic) MBProgressHUD *mbprogress;            //等待指示器

@end

@implementation ReactioninfoListController
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
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataProvider.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reactioninfoCellId = @"reactioninfoCell";
    ReactioninfoCell *cell = [tableView dequeueReusableCellWithIdentifier:reactioninfoCellId];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ReactioninfoCell" owner:nil options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //获取cell的数据
    ReactionModel * reactioninfo = [self.dataProvider objectAtIndex:indexPath.row];
    //设置cell的属性
    cell.reactionTittle.text = [NSString stringWithFormat:@"编号:%@",reactioninfo.reactionid];
    cell.reactiontime.text = reactioninfo.reactiontime;
    cell.reactionaddress.text = [NSString stringWithFormat:@"地址:%@",reactioninfo.reactionaddress];
    cell.informantname.text = [NSString stringWithFormat:@"被调查者:%@",reactioninfo.informantname];
    
    if ([reactioninfo.upload isEqualToString:kdidUpload]) {
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
    //跳转到新增人物反应界面
    ReactioninfoViewController *reactionVC = [[ReactioninfoViewController alloc]initWithNibName:@"ReactioninfoViewController" bundle:nil];
    reactionVC.reactioninfo = self.dataProvider[indexPath.row];
    reactionVC.actionType = kActionTypeShow;
    reactionVC.delegate = self;
    [self.parentViewController.navigationController pushViewController:reactionVC animated:YES];
}

#pragma mark ReactioninfoDelegate
/**
 *  新增人物反应信息后回调
 */
-(void)addReactioninfoSuccess:(ReactioninfoViewController *)reactioninfoVC
{
    [reactioninfoVC dismissViewControllerAnimated:YES completion:nil];
    [self.tableView.header beginRefreshing];
}

/**
 *  更新人物反应信息后回调
 */
-(void)updateReactioninfoSuccess:(ReactioninfoViewController *)reactioninfoVC
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
    ReactionModel * reactioninfo = [self.dataProvider objectAtIndex:indexPath.row];
    
    //从数据库表中删除这个人物反应信息
    BOOL result = YES;
    //先删图片，再删数据信息
    result = [[PictureInfoTableHelper sharedInstance] deleteImageByReleteTable:@"REACTIONINFOTAB" Releteid:reactioninfo.reactionid];
    if (result) {
        result = [[ReactioninfoTableHelper sharedInstance] deleteDataByAttribute:@"reactionid" value:reactioninfo.reactionid];
    }
    if (result) {
        //删除成功，则重新获取数据并刷新
        [self.dataProvider removeObject:reactioninfo];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    }else{
        [[[UIAlertView alloc] initWithTitle:nil message:@"删除数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }
}

/**
 *  上传人物反应信息数据
 */
-(void)infocell:(InfoCell *)cell didClickUpLoadBtnAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.pointUploadFlag isEqualToString:kdidNotUpload]) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"请先上传该条数据对应的调查点信息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
        return;
    }
    
    self.mbprogress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    ReactionModel *model = [self.dataProvider objectAtIndex:indexPath.row];

    //创建字典对象作为上传参数
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                          model.reactionid,@"reactionid",
                          model.reactiontime,@"reactiontime",
                          model.informantname,@"informantname",
                          model.informantage, @"informantage",
                          model.informanteducation, @"informanteducation",
                          model.informantjob,@"informantjob",
                          model.reactionaddress,@"reactionaddress",
                          model.rockfeeling,@"rockfeeling",
                          model.throwfeeling,@"throwfeeling",
                          model.throwtings,@"throwtings",
                          model.throwdistance,@"throwdistance",
                          model.fall,@"fall",
                          model.hang,@"hang",
                          model.furnituresound,@"furnituresound",
                          model.furnituredump,@"furnituredump",
                          model.soundsize,@"soundsize",
                          model.sounddirection,@"sounddirection",
                          model.pointid,@"pointid",
                          nil];
    
    [CommonRemoteHelper RemoteWithUrl:URL_addreaction parameters:parameters type:CommonRemoteTypePost success:^(id responseObject) {
        NSLog(@"数据上传成功: %@", responseObject);
        [self uploadImagesOfReactioninfoWithIndexPath:indexPath];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.mbprogress removeFromSuperview];
        [[[UIAlertView alloc] initWithTitle:nil message:@"人物反应数据上传失败,请检查网络是否异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }];
}

#pragma mark -- 内部方法 --
/**
 *  上传人物反应图片,上传成功刷新数据；没有需要上传图片则刷新数据
 */
-(void)uploadImagesOfReactioninfoWithIndexPath:(NSIndexPath *)indexpath
{
    ReactionModel *model = [self.dataProvider objectAtIndex:indexpath.row];
    //获取要上传的图片
    NSArray *imgs = [[PictureInfoTableHelper sharedInstance] selectDataByReleteTable:@"REACTIONINFOTAB" Releteid:model.reactionid];
    
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
        
        NSDictionary *params = @{@"id":model.reactionid,@"from":@"reaction"};
        
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
    ReactionModel *model = [self.dataProvider objectAtIndex:indexpath.row];
    //更新本地数据库这条数据的上传状态
    BOOL result = [[ReactioninfoTableHelper sharedInstance]updateUploadFlag:kdidUpload ID:model.reactionid];
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
    self.dataProvider = [[ReactioninfoTableHelper sharedInstance] selectDataByAttribute:@"pointid" value:self.pointid];
    [self.tableView reloadData];
}

-(void)dealloc
{
    NSLog(@"ReactioninfoListController释放了吗。。。。。。。。。。。。。");
}

@end

