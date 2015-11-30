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
typedef NS_ENUM(NSInteger, MapSelectPointState)
{
    MapSelectPointStateNone = 0,
    MapSelectPointStateStartPoint, // 当前操作为选择起始点
    MapSelectPointStateWayPoint,   // 当前操作为选择途径点
    MapSelectPointStateEndPoint,   // 当前操作为选择终止点
};


@interface NaviParamsSelectViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,AMapSearchDelegate>
@property (weak, nonatomic) IBOutlet UITextField *startPointTextField;
@property (weak, nonatomic) IBOutlet UITextField *endPointTextField;
@property (weak, nonatomic) IBOutlet UITableView *resultTableView;

@property (strong,nonatomic) NSArray *dataProvides;

@property (strong,nonatomic)AMapSearchAPI *searchApi;
@property (assign,nonatomic)MapSelectPointState pointState;
@property (assign,nonatomic)BOOL isStartCurrentLocation;
@property (assign,nonatomic)TravelTypes travelType;

@property (nonatomic, strong) NavPointAnnotation *startAnnotation;
@property (nonatomic, strong) NavPointAnnotation *endAnnotation;

@end

@implementation NaviParamsSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.startPointTextField.delegate = self;
    [self.startPointTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    UILabel *startLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    startLb.text = @"起点位置:";
    startLb.textAlignment = NSTextAlignmentCenter;
    self.startPointTextField.leftView = startLb;
    
    self.endPointTextField.delegate = self;
    [self.endPointTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    UILabel *endLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    endLb.text = @"终点位置:";
    endLb.textAlignment = NSTextAlignmentCenter;
    self.endPointTextField.leftView = endLb;
    
    self.resultTableView.delegate = self;
    self.resultTableView.dataSource = self;
    

    
    self.searchApi = [[AMapSearchAPI alloc] init];
    self.searchApi.delegate = self;
    
    self.searchApi = [[AMapSearchAPI alloc] init];
    self.searchApi.delegate = self;
    
    self.pointState = MapSelectPointStateStartPoint;
    self.isStartCurrentLocation = YES;
    self.travelType = TravelTypeCar;
}

-(NSArray *)dataProvides
{
    if (!_dataProvides) {
        _dataProvides = [[NSArray alloc] init];
    }
    return _dataProvides;
}

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
    if (self.pointState == MapSelectPointStateStartPoint) {
        self.startPointTextField.text = ((NavPointAnnotation *)self.dataProvides[indexPath.row]).title;
        self.startAnnotation = self.dataProvides[indexPath.row];
        self.startAnnotation.navPointType = NavPointAnnotationStart;
    }else{
        self.endPointTextField.text = ((NavPointAnnotation *)self.dataProvides[indexPath.row]).title;
        self.endAnnotation = self.dataProvides[indexPath.row];
        self.endAnnotation.navPointType = NavPointAnnotationEnd;
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.startPointTextField) {
        self.pointState = MapSelectPointStateStartPoint;
    }else{
        self.pointState = MapSelectPointStateEndPoint;
    }
}

//实现POI搜索对应的回调函数
-(void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if(response.pois.count == 0)
    {

        AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
        if (self.pointState == MapSelectPointStateStartPoint) {
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
        
        //[poiAnnotations addObject:[[NavPointAnnotation alloc] initWithPOI:obj]];
        [poiAnnotations addObject:annotation];
    }];
    self.dataProvides = poiAnnotations;
    [self.resultTableView reloadData];

}



#pragma mark - AMapSearchDelegate
//实现正向地理编码的回调函数
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    NSLog(@"response.geocodes.count    %d",response.geocodes.count);
    if(response.geocodes.count == 0)
    {
        return;
    }
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    for (AMapGeocode *result in response.geocodes) {
        NavPointAnnotation *pointAnnotation = [[NavPointAnnotation alloc] init];
        pointAnnotation.coordinate = CLLocationCoordinate2DMake(result.location.latitude, result.location.longitude);
        pointAnnotation.title = result.formattedAddress;
        [annotations addObject:pointAnnotation];
    }
    self.dataProvides = annotations;
    [self.resultTableView reloadData];
}


- (IBAction)getTravelType:(id)sender {
    UISegmentedControl *seg = (UISegmentedControl *)sender;
    self.travelType = [seg selectedSegmentIndex];
}

-(void)textFieldDidChange:(UITextField *)field
{
    NSLog(@"adfsa");
    
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    request.keywords = field.text;
    request.types = @"汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施";
    request.sortrule = 0;
    //request.city                = @"010";
    request.requireExtension = YES;
    [self.searchApi AMapPOIKeywordsSearch:request];

}
- (IBAction)getRouteBtnClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    if ([self.delegate respondsToSelector:@selector(getRoute:start:end:travelType:)]) {
        [self.delegate getRoute:self.isStartCurrentLocation start:self.startAnnotation end:self.endAnnotation travelType:self.travelType];
    }
}

- (IBAction)currentLocationBtnClickee:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.startPointTextField.text = @"当前位置";
    }else{
        self.startPointTextField.text = nil;
    }
    self.isStartCurrentLocation = sender.selected;

}


@end
