//
//
//  Created by 董徐维 on 15/8/12.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "DetailViewController.h"
#import "SurveyPointDetailViewController.h"
#import "PointinfoViewController.h"
#import "SurveyPointCell.h"
#import "MessageViewController.h"
#import "AppDelegate.h"
#import "EarthInfo.h"
#import "OtherTableHelper.h"

@interface DetailViewController ()<UISplitViewControllerDelegate,UISearchBarDelegate,InfoCellDelegate,PointinfoDelegate>
@property (nonatomic, retain) NSMutableArray *dataProvider;        //所有的调查点信息
@property (nonatomic, retain) NSArray *filtedData;        //需要显示的调查点信息
@property (nonatomic, strong) MBProgressHUD *mbprogress;

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNavgation];
    [self initTableView];
    self.title = @"调查点管理";
}

-(void)initNavgation
{
    //设置导航栏颜色
    self.navigationController.navigationBar.barTintColor = HMColor(102, 147, 255);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"新增" style:UIBarButtonItemStylePlain target:self action:@selector(addSurveyPointClickHandler)];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
}

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
    return self.filtedData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"surveyPointCell";
    SurveyPointCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"SurveyPointCell" owner:nil options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //根据indexPath获取cell的数据
    PointModel * pointInfo = [self.filtedData objectAtIndex:indexPath.row];
    cell.model = pointInfo;
    cell.indexPath = indexPath;
    cell.delegate = self;

    return  cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SurveyPointDetailViewController *detailview1 = [[SurveyPointDetailViewController alloc] init];
    detailview1.pointinfo = self.filtedData[indexPath.row];
    [self.navigationController pushViewController:detailview1 animated:YES];
}

#pragma mark UISearchBar delegate
/**
 *  UISearchBar的协议方法。根据用户输入的字符串来查找相应的内容。
 */
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0 || searchText == nil) {
        self.filtedData = self.dataProvider;
    }else{
         //使用谓词来过虑，只要调查点信息中有一个属性包含用户输入的字符串，这个调查点就会显示。
        NSPredicate* pred = [NSPredicate predicateWithFormat:@"pointid CONTAINS[c]%@  OR earthid CONTAINS[c]%@  OR pointlocation CONTAINS[c]%@  OR pointlon CONTAINS[c]%@  OR pointlat CONTAINS[c]%@  OR pointname CONTAINS[c]%@  OR pointtime CONTAINS[c]%@  OR pointgroup CONTAINS[c]%@  OR pointintensity CONTAINS[c]%@  OR pointcontent CONTAINS[c]%@" ,searchText, searchText, searchText, searchText, searchText, searchText, searchText, searchText, searchText, searchText];
        self.filtedData = [self.dataProvider filteredArrayUsingPredicate:pred];
    }
    [self.tableView reloadData];
}

#pragma mark addView

-(void)addSurveyPointClickHandler
{
    PointinfoViewController *pointinfoVC = [[PointinfoViewController alloc] init];
    pointinfoVC.actionType = kActionTypeAdd;
    pointinfoVC.delegate = self;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:pointinfoVC];
    navi.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navi animated:YES completion:nil];

}

#pragma mark - InfoCellDelegate
//删除cell
-(void)infoCell:(InfoCell *)cell didClickDeleteBtnAtIndexPath:(NSIndexPath *)indexPath
{
    //根据indexPath获取cell的数据
    PointModel * pointInfo = [self.filtedData objectAtIndex:indexPath.row];
    
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
        [self.dataProvider removeObject:pointInfo];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    }else{
        [[[UIAlertView alloc] initWithTitle:nil message:@"删除数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }

}

//上传按钮被点击
-(void)infocell:(InfoCell *)cell didClickUpLoadBtnAtIndexPath:(NSIndexPath *)indexPath
{
    self.mbprogress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PointModel *model = [self.dataProvider objectAtIndex:indexPath.row];
    NSString *earthiddefault = kearthidDefault;
    if ([model.earthid isEqualToString:earthiddefault]) {
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
    
     //[self uploadPointinfoWithIndexPath:indexPath];
}

-(void)getEarthidWithIndexPath:(NSIndexPath *)indexPath
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_isstart parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"获取 earthid   %@",responseObject);
        NSArray *responseArray = (NSArray *)responseObject;
        if (!responseArray || responseArray.count == 0) {
            [self.mbprogress removeFromSuperview];
            [[[UIAlertView alloc] initWithTitle:nil message:@"没有获取到地震编号,请确定本次预案已经开启" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        }else{
            //成功
            AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appdelegate.earthinfo = [EarthInfo objectWithKeyValues:[responseObject firstObject]];
            PointModel *model = [self.dataProvider objectAtIndex:indexPath.row];
            model.earthid = appdelegate.earthinfo.earthid;
            [self uploadPointinfoWithIndexPath:indexPath];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.mbprogress removeFromSuperview];
        [[[UIAlertView alloc] initWithTitle:nil message:@"没有获取到地震编号,请检查网络是否异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }];
}

-(void)uploadPointinfoWithIndexPath:(NSIndexPath *)indexPath
{

    PointModel *model = [self.dataProvider objectAtIndex:indexPath.row];
    NSString * intensity  = [self switchRomeNumToNum:model.pointintensity];
    
    //获取要上传的图片
    NSArray *imgs = [[PictureInfoTableHelper sharedInstance] selectDataByReleteTable:@"POINTINFOTAB" Releteid:model.pointid];

    //创建字典对象作为上传参数
    NSMutableDictionary *parameters1 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        model.pointid,@"pointid",
                                        model.earthid,@"earthid",
                                        model.earthid,@"1",//测试
                                        model.pointlocation,@"location",
                                        model.pointlon, @"lon",
                                        model.pointlat, @"lat",
                                        model.pointname,@"name",
                                        model.pointtime,@"time",
                                        model.pointgroup,@"group",
                                        model.pointperson,@"person",
                                        intensity,@"intensity",
                                        model.pointcontent,@"content",
                                        //upload,@"upload",
                                        nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_addpoint parameters:parameters1 success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"数据上传成功: %@", responseObject);
        if (imgs.count > 0) {
            //信息上传成功后上传对应的图片
            NSDictionary *parameters2 = @{@"id":model.pointid,@"from":@"point"};
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
                BOOL result = [[PointinfoTableHelper sharedInstance]updateUploadFlag:kdidUpload ID:model.pointid];
                if (result) {
                    model.upload = kdidUpload;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    });
                    [self.mbprogress removeFromSuperview];
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"图片上传失败:");
                [self.mbprogress removeFromSuperview];
            }];
        }else{
            NSLog(@"不用上传图片");
            //上传数据成功则更新本地数据
            BOOL result = [[PointinfoTableHelper sharedInstance]updateUploadFlag:kdidUpload ID:model.pointid];
            if (result) {
                model.upload = kdidUpload;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                });
                [self.mbprogress removeFromSuperview];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"数据上传失败:");
        [self.mbprogress removeFromSuperview];
    }];
  
}

//提示
-(void)infocell:(InfoCell *)cell didClickMessageBtnAtIndexPath:(NSIndexPath *)indexPath
{
    PointModel *mode = self.dataProvider[indexPath.row];
    MessageViewController *meageVC = [[MessageViewController alloc] init];
    meageVC.pointModel = mode;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:meageVC];
    navi.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navi animated:YES completion:nil];
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
    self.filtedData = self.dataProvider;
    [self.tableView reloadData];
}

/**
 *  新增调查点成功后调用
 */
-(void)updatePointinfo:(NSNotification *)notification
{
    [self.tableView.header beginRefreshing];
}

-(void)addPointinfoSuccess:(PointinfoViewController *)pointinfoVC
{
    [pointinfoVC dismissViewControllerAnimated:YES completion:nil];
    [self updatePointinfo:nil];
}

-(void)updatePointinfoSuccess:(PointinfoViewController *)pointinfoVC
{
    [self updatePointinfo:nil];
}


-(NSString *)switchRomeNumToNum:(NSString *)romeNum
{
    NSArray *romes = @[@"Ⅰ",@"Ⅱ",@"Ⅲ",@"Ⅳ",@"Ⅴ",@"Ⅵ",@"Ⅶ",@"Ⅷ",@"Ⅸ",@"Ⅹ",@"Ⅺ",@"Ⅻ"];
    NSUInteger num = [romes indexOfObject:romeNum];
    return [NSString stringWithFormat:@"%d",(int)(num+1)];
}

-(void)dealloc
{
    NSLog(@"DetailViewController 释放了吗");
}
@end
