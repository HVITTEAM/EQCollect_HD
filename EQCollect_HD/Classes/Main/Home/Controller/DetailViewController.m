//
//
//  Created by 董徐维 on 15/8/12.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "DetailViewController.h"
#import "PointinfoViewController.h"
#import "SurveyPointCell.h"
#import "MessageViewController.h"
#import "AppDelegate.h"
#import "EarthInfo.h"
#import "OtherTableHelper.h"
#import "PointDetailViewController.h"
#import "MultipartFormObject.h"

@interface DetailViewController ()<UISplitViewControllerDelegate,UISearchBarDelegate,InfoCellDelegate,PointinfoDelegate>
@property (strong,nonatomic) NSMutableArray *dataProvider;        //所有的调查点信息

@property (strong,nonatomic) NSMutableArray *filtedDatas;        //需要显示的调查点信息

@property (strong,nonatomic) MBProgressHUD *mbprogress;

@end

@implementation DetailViewController

#pragma mark -- 生命周期方法 --
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNavgation];
    
    [self initTableView];
}

#pragma mark -- getter 和 setter方法 --
-(NSMutableArray *)filtedDatas
{
    if (!_filtedDatas) {
        _filtedDatas = [[NSMutableArray alloc] init];
    }
    return _filtedDatas;
}

-(NSMutableArray *)dataProvider
{
    if (!_dataProvider) {
        _dataProvider = [[NSMutableArray alloc] init];
    }
    return _dataProvider;
}

#pragma mark -- 初始化设置方法 --
/**
 *  初始化导航栏
 */
-(void)initNavgation
{
    self.navigationItem.title = @"调查点管理";
    
    //设置导航栏颜色
    self.navigationController.navigationBar.barTintColor = HMColor(102, 147, 255);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"新增" style:UIBarButtonItemStylePlain target:self action:@selector(addSurveyPointClickHandler)];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
}

/**
 *  初始化UITableView
 */
-(void)initTableView
{
    //搜索框
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBar.placeholder = @"搜索";
    searchBar.delegate = self;
    // 添加 searchbar 到 headerview
    self.tableView.tableHeaderView = searchBar;

    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reflesh)];
    [self.tableView.header beginRefreshing];
    
    self.tableView.backgroundColor = HMGlobalBg;
    
    self.tableView.tableFooterView = [[UITableView alloc] init];
}

#pragma mark -- 协议方法 --
#pragma mark 分割控制器代理方法
#pragma mark 控制左边的目录（masterViewController）是否隐藏
- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}

#pragma mark 即将显示某个控制器（masterViewController）
- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}

#pragma mark 即将隐藏某个控制器（masterViewController）
- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"菜单";
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filtedDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *surveyPointCellId = @"surveyPointCell";
    SurveyPointCell *cell = [tableView dequeueReusableCellWithIdentifier:surveyPointCellId];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"SurveyPointCell" owner:nil options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //根据indexPath获取cell的数据
    PointModel * pointInfo = [self.filtedDatas objectAtIndex:indexPath.row];
    cell.model = pointInfo;
    cell.indexPath = indexPath;
    cell.delegate = self;

    return  cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //创建一个调查点详情控制器
    PointDetailViewController *pointDetailVC = [[PointDetailViewController alloc] init];
    pointDetailVC.pointinfo = self.filtedDatas[indexPath.row];
    [self.navigationController pushViewController:pointDetailVC animated:YES];
}

#pragma mark UISearchBar delegate
/**
 *  UISearchBar的协议方法。根据用户输入的字符串来查找相应的内容
 */
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0 || searchText == nil) {
        self.filtedDatas = self.dataProvider;
    }else{
         //使用谓词来过虑，只要调查点信息中有一个属性包含用户输入的字符串，这个调查点就会显示
        NSPredicate* pred = [NSPredicate predicateWithFormat:@"pointid CONTAINS[c]%@  OR earthid CONTAINS[c]%@  OR pointlocation CONTAINS[c]%@  OR pointlon CONTAINS[c]%@  OR pointlat CONTAINS[c]%@  OR pointname CONTAINS[c]%@  OR pointtime CONTAINS[c]%@  OR pointgroup CONTAINS[c]%@  OR pointintensity CONTAINS[c]%@  OR pointcontent CONTAINS[c]%@" ,searchText, searchText, searchText, searchText, searchText, searchText, searchText, searchText, searchText, searchText];
        self.filtedDatas = [[self.dataProvider filteredArrayUsingPredicate:pred] mutableCopy];
    }
    [self.tableView reloadData];
}

#pragma mark InfoCellDelegate
/**
 *  删除cell
 */
-(void)infoCell:(InfoCell *)cell didClickDeleteBtnAtIndexPath:(NSIndexPath *)indexPath
{
    //根据indexPath获取cell的数据
    PointModel * pointInfo = [self.filtedDatas objectAtIndex:indexPath.row];
    
    BOOL result = YES;
    /**从数据库表中删除数据**/
    //删除宏观异常信息
    NSMutableArray *abnor = [[AbnormalinfoTableHelper sharedInstance]selectDataByAttribute:@"pointid" value:pointInfo.pointid];
    for (int i = 0; i<abnor.count; i++) {
        AbnormalinfoModel *abnorModel = abnor[i];
        result = [[PictureInfoTableHelper sharedInstance] deleteImageByReleteTable:@"ABNORMALINFOTAB" Releteid:abnorModel.abnormalid];
        if (result) {
            result =[[AbnormalinfoTableHelper sharedInstance] deleteDataByAttribute:@"abnormalid" value:abnorModel.abnormalid];
        }
    }
    
    //删除人物反应数据
    NSMutableArray *react = [[ReactioninfoTableHelper sharedInstance] selectDataByAttribute:@"pointid" value:pointInfo.pointid];
    for (int i = 0; i<react.count; i++) {
        ReactionModel *reactModel = react[i];
        result = [[PictureInfoTableHelper sharedInstance] deleteImageByReleteTable:@"REACTIONINFOTAB" Releteid:reactModel.reactionid];
        if (result) {
            result = [[ReactioninfoTableHelper sharedInstance] deleteDataByAttribute:@"reactionid" value:reactModel.reactionid];
        }
    }
    
    //删除房屋震害数据
    NSMutableArray *damage = [[DamageinfoTableHelper sharedInstance] selectDataByAttribute:@"pointid" value:pointInfo.pointid];
    for (int i = 0; i<damage.count; i++) {
        DamageModel *damageModel = damage[i];
        result = [[PictureInfoTableHelper sharedInstance] deleteImageByReleteTable:@"DAMAGEINFOTAB" Releteid:damageModel.damageid];
        if (result) {
            result = [[DamageinfoTableHelper sharedInstance] deleteDataByAttribute:@"damageid" value:damageModel.damageid];
        }
    }
    
    //删除其它数据
    NSMutableArray *others = [[OtherTableHelper sharedInstance] selectDataByAttribute:@"pointid" value:pointInfo.pointid];
    for (int i = 0; i<others.count; i++) {
        OtherModel *otherModel = others[i];
        result = [[PictureInfoTableHelper sharedInstance] deleteImageByReleteTable:@"OTHERTAB" Releteid:otherModel.otherid];
        if (result) {
            result = [[OtherTableHelper sharedInstance] deleteDataByAttribute:@"otherid" value:otherModel.otherid];
        }
    }
    
    //删除调查点数据
    if (result) {
        result = [[PointinfoTableHelper sharedInstance] deleteDataByAttribute:@"pointid" value:pointInfo.pointid];
    }
    
    if (result) {
        //数据库中删除成功，则重新获取数据刷新界面
        [self.filtedDatas removeObject:pointInfo];
        [self.dataProvider removeObject:pointInfo];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    }else{
        [[[UIAlertView alloc] initWithTitle:nil message:@"删除数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }
}

/**
 *  上传cell
 */
-(void)infocell:(InfoCell *)cell didClickUpLoadBtnAtIndexPath:(NSIndexPath *)indexPath
{
    self.mbprogress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //默认地震 ID为一个字符串:@"未获取到地震编号"
    NSString *earthiddefault = kearthidDefault;
    
    PointModel *model = [self.filtedDatas objectAtIndex:indexPath.row];

    if ([model.earthid isEqualToString:earthiddefault]) {
        //如果 model 中的地震 id等于默认的，说明没获取到，需要去获取一次
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *earthid = appDelegate.earthinfo.earthid;
        if (!earthid) {
            [self getEarthidWithIndexPath:indexPath];
        }else{
             model.earthid = earthid;
            [self uploadPointinfoWithIndexPath:indexPath];
        }
    }else{
       [self uploadPointinfoWithIndexPath:indexPath];
    }
}

/**
 *  创建提示消息
 */
-(void)infocell:(InfoCell *)cell didClickMessageBtnAtIndexPath:(NSIndexPath *)indexPath
{
    PointModel *mode = self.filtedDatas[indexPath.row];
    MessageViewController *meageVC = [[MessageViewController alloc] init];
    meageVC.pointModel = mode;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:meageVC];
    navi.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navi animated:YES completion:nil];
}

#pragma mark PointinfoDelegate
/**
 *  新增调查点成功后回调
 */
-(void)addPointinfoSuccess:(PointinfoViewController *)pointinfoVC
{
    [pointinfoVC dismissViewControllerAnimated:YES completion:nil];
    [self.tableView.header beginRefreshing];
}

/**
 *  更新调查点信息成功后回调
 */
-(void)updatePointinfoSuccess:(PointinfoViewController *)pointinfoVC
{
    [self.tableView.header beginRefreshing];
}

#pragma mark -- 事件方法 --
/**
 *  新增调查点
 */
-(void)addSurveyPointClickHandler
{
    PointinfoViewController *pointinfoVC = [[PointinfoViewController alloc] init];
    pointinfoVC.actionType = kActionTypeAdd;
    pointinfoVC.delegate = self;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:pointinfoVC];
    navi.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navi animated:YES completion:nil];
}

#pragma mark -- 网络请求相关方法 --
/**
 *  去服务器获取本次地震ID
 */
-(void)getEarthidWithIndexPath:(NSIndexPath *)indexPath
{
    [CommonRemoteHelper RemoteWithUrl:URL_isstart parameters:nil type:CommonRemoteTypePost success:^(id responseObject) {
        NSLog(@"DetailViewController 获取 earthid  %@",responseObject);
        NSArray *responseArray = (NSArray *)responseObject;
        if (!responseArray || responseArray.count == 0) {
            [self.mbprogress removeFromSuperview];
            [[[UIAlertView alloc] initWithTitle:nil message:@"没有获取到地震编号,无法上传调查点数据,请确定本次地震预案已经开启" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        }else{
            //成功
            AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appdelegate.earthinfo = [EarthInfo objectWithKeyValues:[responseObject firstObject]];
            PointModel *model = [self.filtedDatas objectAtIndex:indexPath.row];
            model.earthid = appdelegate.earthinfo.earthid;
            
            [self uploadPointinfoWithIndexPath:indexPath];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.mbprogress removeFromSuperview];
        [[[UIAlertView alloc] initWithTitle:nil message:@"没有获取到地震编号,无法上传调查点数据,请检查网络是否异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }];
}

/**
 *  发送请求上传调查点信息
 */
-(void)uploadPointinfoWithIndexPath:(NSIndexPath *)indexPath
{
    PointModel *model = [self.filtedDatas objectAtIndex:indexPath.row];
    
    NSString * intensity  = [SharedAppUtil switchRomeNumToNum:model.pointintensity];
    
    //创建字典对象作为上传参数
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        model.pointid,@"pointid",
                                        model.earthid,@"earthid",
                                        model.pointlocation,@"location",
                                        model.pointlon, @"lon",
                                        model.pointlat, @"lat",
                                        model.pointname,@"name",
                                        model.pointtime,@"time",
                                        model.pointgroup,@"group",
                                        model.pointperson,@"person",
                                        intensity,@"intensity",
                                        model.pointcontent,@"content",
                                        nil];
    
    [CommonRemoteHelper RemoteWithUrl:URL_addpoint parameters:parameters type:CommonRemoteTypePost success:^(id responseObject) {
        NSLog(@"调查点数据上传成功: %@", responseObject);
        [self uploadImagesOfPointInfoWithIndexPath:indexPath];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.mbprogress removeFromSuperview];
        [[[UIAlertView alloc] initWithTitle:nil message:@"调查点数据上传失败,请检查网络是否异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }];
}

/**
 *  发送请求上传调查点图片,上传成功刷新数据；没有需要上传图片则刷新数据
 */
-(void)uploadImagesOfPointInfoWithIndexPath:(NSIndexPath *)indexpath
{
    PointModel *model = [self.filtedDatas objectAtIndex:indexpath.row];
    
    NSArray *imgs = [[PictureInfoTableHelper sharedInstance] selectDataByReleteTable:@"POINTINFOTAB" Releteid:model.pointid];
    //获取要上传的图片
    if (imgs.count > 0) {
        
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
        
        NSDictionary *params = @{@"id":model.pointid,@"from":@"point"};
        
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
    PointModel *model = [self.filtedDatas objectAtIndex:indexpath.row];
    //更新本地数据库上传状态
    BOOL result = [[PointinfoTableHelper sharedInstance]updateUploadFlag:kdidUpload ID:model.pointid];
    if (result) {
        //刷新界面
        model.upload = kdidUpload;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationLeft];
        });
    }
}

#pragma mark 集成刷新控件
/**
 *  集成刷新控件
 */
-(void)reflesh
{
    [self getDataProvider];
    [self.tableView.header endRefreshing];
}

/**
 *  获取数据
 */
-(void)getDataProvider
{
    self.dataProvider = [[PointinfoTableHelper sharedInstance] selectData];
    self.filtedDatas = self.dataProvider;
    [self.tableView reloadData];
}

-(void)dealloc
{
    NSLog(@"DetailViewController 释放了吗");
}

@end
