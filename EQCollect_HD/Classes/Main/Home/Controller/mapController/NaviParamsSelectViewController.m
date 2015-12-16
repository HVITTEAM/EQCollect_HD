//
//  NaviParamsSelectViewController.m
//  EQCollect_HD
//
//  Created by shi on 15/11/29.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import "NaviParamsSelectViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "NavPointAnnotation.h"
typedef NS_ENUM(NSInteger, SelectPoint)
{
    SelectPointStartPoint, // 当前操作为选择起始点
    SelectPointWayPoint,   // 当前操作为选择途径点
    SelectPointEndPoint,   // 当前操作为选择终止点
};


@interface NaviParamsSelectViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,AMapSearchDelegate>
@property (weak, nonatomic) IBOutlet UITextField *startPointTextField;
@property (weak, nonatomic) IBOutlet UITextField *endPointTextField;
@property (weak, nonatomic) IBOutlet UITableView *resultTableView;

@property (strong,nonatomic) NSArray *dataProvides;
@property (strong,nonatomic) AMapSearchAPI *searchApi;
@property (strong,nonatomic) NavPointAnnotation *startAnnotation;
@property (strong,nonatomic) NavPointAnnotation *endAnnotation;
@property (assign,nonatomic) BOOL isStartCurrentLocation;               //是否从当前位置开始
@property (assign,nonatomic) TravelTypes travelType;                    //交通方式
@property (assign,nonatomic) SelectPoint selectPoint;                   //当前正在选择什么点
@end

@implementation NaviParamsSelectViewController

#pragma mark ------ 生命周期方法 -----
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initTextField];
    
    self.resultTableView.delegate = self;
    self.resultTableView.dataSource = self;

    self.searchApi = [[AMapSearchAPI alloc] init];
    self.searchApi.delegate = self;
    
    self.selectPoint = SelectPointStartPoint;  //默认正在选择起点
    self.isStartCurrentLocation = YES;    //默认起点为当前位置
    self.travelType = TravelTypeCar;    //默认交通方式为车
}

#pragma mark ------ getter、setter及初始化方法  -----
-(NSArray *)dataProvides
{
    if (!_dataProvides) {
        _dataProvides = [[NSArray alloc] init];
    }
    return _dataProvides;
}

-(void)initTextField
{
    //起点文本框
    UILabel *startLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    startLb.text = @"起点:";
    startLb.textAlignment = NSTextAlignmentCenter;
    startLb.font = [UIFont systemFontOfSize:14];
    self.startPointTextField.leftViewMode = UITextFieldViewModeAlways;
    self.startPointTextField.leftView = startLb;
    self.startPointTextField.delegate = self;
    self.startPointTextField.userInteractionEnabled = NO;
    [self.startPointTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    //终点文本框
    UILabel *endLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    endLb.text = @"终点:";
    endLb.textAlignment = NSTextAlignmentCenter;
    endLb.font = [UIFont systemFontOfSize:14];
    self.endPointTextField.leftViewMode = UITextFieldViewModeAlways;
    self.endPointTextField.leftView = endLb;
    self.endPointTextField.delegate = self;
    [self.endPointTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

#pragma mark ------ 协议方法 -----
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataProvides.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
       cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:11];
    }
    
    cell.textLabel.text = ((NavPointAnnotation *)self.dataProvides[indexPath.row]).title;
    cell.detailTextLabel.text = ((NavPointAnnotation *)self.dataProvides[indexPath.row]).subtitle;
    return  cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectPoint == SelectPointStartPoint) {
        self.startPointTextField.text = ((NavPointAnnotation *)self.dataProvides[indexPath.row]).title;
        self.startAnnotation = self.dataProvides[indexPath.row];
        self.startAnnotation.navPointType = NavPointAnnotationStart;
    }else{
        self.endPointTextField.text = ((NavPointAnnotation *)self.dataProvides[indexPath.row]).title;
        self.endAnnotation = self.dataProvides[indexPath.row];
        self.endAnnotation.navPointType = NavPointAnnotationEnd;
    }
}

#pragma mark - UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.startPointTextField) {
        self.selectPoint = SelectPointStartPoint;
    }else{
        self.selectPoint = SelectPointEndPoint;
    }
}

#pragma mark AMapSearchDelegate
//实现POI搜索对应的回调函数
-(void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if(response.pois.count == 0)
    {
        AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
        if (self.selectPoint == SelectPointStartPoint) {
            geo.address = self.startPointTextField.text;
        }else{
            geo.address = self.endPointTextField.text;
        }
        [self.searchApi AMapGeocodeSearch: geo];
        return;
    }
    
    NSMutableArray *poiAnnotations = [[NSMutableArray alloc] init];
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        NavPointAnnotation *annotation = [[NavPointAnnotation alloc] init];
        annotation.title = obj.name;
        annotation.subtitle = obj.address;
        annotation.coordinate = CLLocationCoordinate2DMake(obj.location.latitude, obj.location.longitude);
        [poiAnnotations addObject:annotation];
    }];
    self.dataProvides = poiAnnotations;
    [self.resultTableView reloadData];
}

//实现正向地理编码的回调函数
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    //NSLog(@"正向地理编码结果数量%d",response.geocodes.count);
    if(response.geocodes.count == 0){
        return;
    }
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    for (AMapGeocode *geocode in response.geocodes) {
        NavPointAnnotation *pointAnnotation = [[NavPointAnnotation alloc] init];
        pointAnnotation.coordinate = CLLocationCoordinate2DMake(geocode.location.latitude, geocode.location.longitude);
        pointAnnotation.title = geocode.formattedAddress;
        [annotations addObject:pointAnnotation];
    }
    self.dataProvides = annotations;
    [self.resultTableView reloadData];
}

#pragma mark ------ 事件方法 -----
/**
 * 获取交通方式
 **/
- (IBAction)getTravelType:(id)sender {
    UISegmentedControl *seg = (UISegmentedControl *)sender;
    self.travelType = [seg selectedSegmentIndex];
}

/**
 * 将参数回传，从而计算路径
 **/
- (IBAction)getRouteBtnClicked:(UIButton *)sender {
    
    if (self.isStartCurrentLocation) {
        if (!self.endAnnotation) {
           [[[UIAlertView alloc] initWithTitle:nil message:@"请输入终点" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
            return;
        }
    }else{
        if (!self.endAnnotation || !self.startAnnotation) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"请输入起点或终点" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
            return;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(getRoute:start:end:travelType:)]) {
        [self.delegate getRoute:self.isStartCurrentLocation start:self.startAnnotation end:self.endAnnotation travelType:self.travelType];
    }
}

/**
 * 取消或使用当前位置作为起点,按钮选中时使用当前位置
 **/
- (IBAction)currentLocationBtnClickee:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.startPointTextField.text = @"当前位置";
        self.startPointTextField.userInteractionEnabled = NO;
    }else{
        self.startPointTextField.text = nil;
        self.startPointTextField.userInteractionEnabled = YES;
    }
    self.isStartCurrentLocation = sender.selected;
}

/**
 * 文本内容改变时调用
 **/
-(void)textFieldDidChange:(UITextField *)field
{
    NSLog(@"NaviParamsSelectViewController 文本改变");
    
    NSString *text = field.text;
    if (text==nil || text.length == 0) {
        //如果输入内容为空，将数据源置空
        self.dataProvides  = [[NSArray alloc] init];
        [self.resultTableView reloadData];
        //根据用户操作将起点或终点置空
        if (self.selectPoint == SelectPointStartPoint) {
            self.startAnnotation = nil;
        }else {
            self.endAnnotation = nil;
        }
        return;
    }
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    request.keywords = field.text;
    request.types = @"汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施";
    request.sortrule = 0;
    //request.city                = @"010";
    request.requireExtension = YES;
    [self.searchApi AMapPOIKeywordsSearch:request];
}

@end
