//
//  ZongheShowViewController.m
//  officialDemoNavi
//
//  Created by LiuX on 14-9-1.
//  Copyright (c) 2014年 AutoNavi. All rights reserved.
//

#import "NavigationViewController.h"
#import "NavPointAnnotation.h"
#import "RouteShowViewController.h"
#import "MoreMenuView.h"
#import "POIAnnotation.h"
#import "NaviParamsSelectViewController.h"
#import "TrackTableHelper.h"
#import "TrackModel.h"
#import "SWYMapTypeSelectView.h"
#import "AppDelegate.h"
#import "MemberAnnotation.h"
#import "UserModel.h"
#import "CurrentUser.h"

#define kSetingViewHeight 215

typedef NS_ENUM(NSInteger, MapSelectPointState)
{
    MapSelectPointStateNone = 0,
    MapSelectPointStateStartPoint, // 当前操作为选择起始点
    MapSelectPointStateWayPoint,   // 当前操作为选择途径点
    MapSelectPointStateEndPoint,   // 当前操作为选择终止点
};

typedef NS_ENUM(NSInteger, NavigationTypes)
{
    NavigationTypeNone = 0,
    NavigationTypeSimulator, // 模拟导航
    NavigationTypeGPS,       // 实时导航
};

////////////////by swy//////////////////////
/**
 *  地图上的属性控制按钮类型的枚举（by swy）
 */
typedef NS_ENUM(NSInteger, ControlButtonType) {
    ControlButtonTypeTraffic = 20,           //切换路况信息按钮
    ControlButtonTypeMapType,                //切换地图显示类型按钮
    ControlButtonTypeMylocation,             //我的位置(跟随模式)
};


@interface NavigationViewController () <AMapNaviViewControllerDelegate,
                                        UIGestureRecognizerDelegate,
                                        MoreMenuViewDelegate,NaviParamsSelectViewControllerDelegate,MapTypeSelectViewDelegate>
{
    UILabel *_wayPointLabel;
    UILabel *_strategyLabel;
    
    MapSelectPointState _selectPointState;
    NavigationTypes     _naviType;
    TravelTypes         _travelType;
    
    BOOL _startCurrLoc;   // 起始点使用当前位置？
    BOOL _hasCurrLoc;
    
    UITapGestureRecognizer *_mapViewTapGesture;
    
    NSDictionary *_strategyMap;
    
    MoreMenuView *_moreMenuView;
    
}

@property (nonatomic, strong) AMapNaviViewController *naviViewController;

@property (nonatomic, strong) NavPointAnnotation *beginAnnotation;
@property (nonatomic, strong) NavPointAnnotation *wayAnnotation;
@property (nonatomic, strong) NavPointAnnotation *endAnnotation;

@property (nonatomic, weak) RouteShowViewController *routeShowVC;

/////////////////SWY///////////////////////
@property (nonatomic, strong) NSString *searchContent;
@property (nonatomic, strong) UIPopoverController *navRoutPopover;                //弹出视图，用于导航路径搜索
@property (nonatomic, strong) MAUserLocation *currUserLocation;

@property (nonatomic,strong) UIButton *beforeYesterBtn;         //前天按钮
@property (nonatomic,strong) UIButton *yesterBtn;               //昨天按钮
@property (nonatomic,strong) UIButton *todayBtn;                //今天按钮
@property (nonatomic,strong) UIButton *clearTrackBtn;           //清除路径按钮
@property (nonatomic, strong) UIButton *trafficSwitchBtn;       //切换交通图
@property (nonatomic, strong) UIButton *mapTypeSwitchBtn;       //切换地图类型
@property (nonatomic, strong) UIButton *mylocationBtn;          //切换用户跟随模式

@end

@implementation NavigationViewController


#pragma mark - Life Cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initTravelType];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNaviViewController];
    
    [self initBottomBar];
    
    [self initControlButton];
    
    [self fetchMemberLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:animated];
    
    [self configMapView];
    
    [self initSettingState];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


#pragma mark - Utils

- (void)initCalRouteStrategyMap
{
    _strategyMap = @{@"速度优先"   : @0,
                     @"费用优先"   : @1,
                     @"距离优先"   : @2,
                     @"普通路优先"             : @3,
                     @"时间优先(躲避拥堵)"      : @4,
                     @"躲避拥堵且不走收费道路"   : @12};
}


- (void)initTravelType
{
    _travelType = TravelTypeCar;
}


- (void)configMapView
{
    [self.mapView setDelegate:self];
    
    [self.mapView setFrame:CGRectMake(0, 64, self.view.width, self.view.height-64)];
    
    [self.view insertSubview:self.mapView atIndex:0];
    
    _hasCurrLoc = NO;
    
    self.mapView.showsUserLocation = YES;
    
    ///////////////////////////////////////by swy////////////////////////////////////
    self.mapView.showsCompass= YES;
    self.mapView.compassOrigin= CGPointMake(self.mapView.compassOrigin.x-27, 22);
    self.mapView.showsScale = YES;
    self.mapView.scaleOrigin= CGPointMake(self.mapView.scaleOrigin.x, 22);
    [self.mapView setZoomLevel:14 animated:YES];
    self.mapView.rotateEnabled= NO;
    self.mapView.rotateCameraEnabled= NO;
    
    [self.mapView setUserTrackingMode: MAUserTrackingModeFollow animated:YES];
}


- (void)initNaviViewController
{
    if (_naviViewController == nil)
    {
        _naviViewController = [[AMapNaviViewController alloc] initWithMapView:self.mapView delegate:self];
    }
}

/**
 *   创建底部按钮栏(前天，昨天，今天) （by swy）
 */
-(void)initBottomBar
{
    UIView *bottomBar;
    if (IOS_VERSION<8.0) {
        bottomBar = [[UIView alloc] initWithFrame:CGRectMake((MTScreenH-320)/2, MTScreenW-80,320, 40)];
    }else{
        bottomBar = [[UIView alloc] initWithFrame:CGRectMake((MTScreenW-320)/2, MTScreenH-80,320, 40)];
    }
    bottomBar.layer.cornerRadius = 7;
    bottomBar.layer.masksToBounds = YES;
    [self.view addSubview:bottomBar];
    
    //创建清理路径按钮
    self.clearTrackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.clearTrackBtn.frame = CGRectMake(CGRectGetMaxX(bottomBar.frame)+10,bottomBar.frame.origin.y, 60, 40);
    self.clearTrackBtn.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    [self.clearTrackBtn setTitle:@"隐藏" forState: UIControlStateNormal];
    [self.clearTrackBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.clearTrackBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    self.clearTrackBtn.layer.cornerRadius = 7;
    self.clearTrackBtn.layer.masksToBounds = YES;
    self.clearTrackBtn.hidden = YES;
    [self.clearTrackBtn addTarget:self action:@selector(clearTrack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.clearTrackBtn];
    
    CGFloat btnWidth = bottomBar.width/3;
    CGFloat btnHeight = 40;
    //创建前天按钮
    self.beforeYesterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.beforeYesterBtn.frame = CGRectMake(0, 0, btnWidth, btnHeight);
    self.beforeYesterBtn.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    [self.beforeYesterBtn setTitle:@"前天" forState: UIControlStateNormal];
    [self.beforeYesterBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.beforeYesterBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.beforeYesterBtn addTarget:self action:@selector(bottomBarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:self.beforeYesterBtn];
    
    //创建昨天按钮
    self. yesterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.yesterBtn.frame = CGRectMake(btnWidth, 0, btnWidth, btnHeight);
    self.yesterBtn.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    [self.yesterBtn setTitle:@"昨天" forState: UIControlStateNormal];
    [self.yesterBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.yesterBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.yesterBtn addTarget:self action:@selector(bottomBarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:self.yesterBtn];
    
    //创建今天按钮
    self.todayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.todayBtn.frame = CGRectMake(2*btnWidth, 0,btnWidth, btnHeight);
    self.todayBtn.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    [self.todayBtn setTitle:@"今天" forState: UIControlStateNormal];
    [self.todayBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.todayBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.todayBtn addTarget:self action:@selector(bottomBarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:self.todayBtn];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(btnWidth, (btnHeight-10)/2, 1, btnHeight-30)];
    line1.backgroundColor = [UIColor lightGrayColor];
    [bottomBar addSubview:line1];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(2*btnWidth, (btnHeight-10)/2, 1, btnHeight-30)];
    line2.backgroundColor = [UIColor lightGrayColor];
    [bottomBar addSubview:line2];
}

/**
 *  初始化地图属性的控制按钮（by swy）
 */
-(void)initControlButton
{
    CGFloat screenWidth;
    CGFloat screenHeigth;
    if (IOS_VERSION<8.0) {
        screenWidth = MTScreenH;
        screenHeigth = MTScreenW;
    }else{
        screenWidth = MTScreenW;
        screenHeigth = MTScreenH;
    }
    
    //切换交通情况按钮
    self.trafficSwitchBtn = [self createBtnWithNormalImageName:@"trafficSwitch_icon_normal"
                                             selectedImageName:@"trafficSwitch_icon_selected"];
    self.trafficSwitchBtn.x = screenWidth - 70;
    self.trafficSwitchBtn.y = 140;
    self.trafficSwitchBtn.tag = ControlButtonTypeTraffic;
    
    //切换地图类型掉按钮
    self.mapTypeSwitchBtn = [self createBtnWithNormalImageName:@"mapTypeSwitch_icon"
                                             selectedImageName:@"mapTypeSwitch_icon"];
    self.mapTypeSwitchBtn.x = screenWidth - 70;
    self.mapTypeSwitchBtn.y = 190;
    self.mapTypeSwitchBtn.tag = ControlButtonTypeMapType;
    
    //切换跟随模式按钮
    self.mylocationBtn = [self createBtnWithNormalImageName:@"locationIconNone"
                                          selectedImageName:@"locationIconNone"];
    self.mylocationBtn.x = 40;
    self.mylocationBtn.y = screenHeigth-75;
    self.mylocationBtn.tag = ControlButtonTypeMylocation;
}

- (void)initSettingState
{
    _beginAnnotation = nil;
    _wayAnnotation   = nil;
    _endAnnotation   = nil;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    _selectPointState = MapSelectPointStateNone;
    _naviType = NavigationTypeNone;
}

- (void)initMoreMenuView
{
    _moreMenuView = [[MoreMenuView alloc] initWithFrame:self.naviViewController.view.bounds];
    _moreMenuView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _moreMenuView.delegate = self;
}


- (void)calRoute
{
    NSArray *startPoints;
    NSArray *wayPoints;
    NSArray *endPoints;
    
    if (_wayAnnotation)
    {
        wayPoints = @[[AMapNaviPoint locationWithLatitude:_wayAnnotation.coordinate.latitude
                                                longitude:_wayAnnotation.coordinate.longitude]];
    }
    
    if (_endAnnotation)
    {
        endPoints = @[[AMapNaviPoint locationWithLatitude:_endAnnotation.coordinate.latitude
                                                longitude:_endAnnotation.coordinate.longitude]];
    }
    
    if (_beginAnnotation)
    {
        startPoints = @[[AMapNaviPoint locationWithLatitude:_beginAnnotation.coordinate.latitude
                                                  longitude:_beginAnnotation.coordinate.longitude]];
    }
    
    if (_startCurrLoc)
    {
        if (endPoints.count > 0)
        {
            if (_travelType == TravelTypeCar)
            {
                [self.naviManager calculateDriveRouteWithEndPoints:endPoints
                                                         wayPoints:wayPoints
                                                   drivingStrategy:0];
            }
            else if (_travelType == TravelTypeWalk)
            {
                [self.naviManager calculateWalkRouteWithEndPoints:endPoints];
            }
            return;
        }
    }
    else
    {
        if (startPoints.count > 0 && endPoints.count > 0)
        {
            if (_travelType == TravelTypeCar)
            {
                [self.naviManager calculateDriveRouteWithStartPoints:startPoints
                                                           endPoints:endPoints
                                                           wayPoints:wayPoints
                                                     drivingStrategy:0];
            }
            else if (_travelType == TravelTypeWalk)
            {
                [self.naviManager calculateWalkRouteWithStartPoints:startPoints endPoints:endPoints];
            }
            
            return;
        }
    }
}

#pragma mark - MAMapView Delegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    UIButton *accessoryView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [accessoryView setBackgroundImage:[UIImage imageNamed:@"navi_icon"] forState:UIControlStateNormal];
    
    if ([annotation isKindOfClass:[NavPointAnnotation class]])
    {
        static NSString *navPointAnnotationID = @"NavPointAnnotation";
        
        MAPinAnnotationView *pointAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:navPointAnnotationID];
        if (pointAnnotationView == nil)
        {
            pointAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                                  reuseIdentifier:navPointAnnotationID];
        }
        
        pointAnnotationView.animatesDrop   = NO;
        pointAnnotationView.canShowCallout = NO;
        pointAnnotationView.draggable      = NO;
        
        NavPointAnnotation *navAnnotation = (NavPointAnnotation *)annotation;
        
        if (navAnnotation.navPointType == NavPointAnnotationStart)
        {
            [pointAnnotationView setPinColor:MAPinAnnotationColorGreen];
        }
        else if (navAnnotation.navPointType == NavPointAnnotationWay)
        {
            [pointAnnotationView setPinColor:MAPinAnnotationColorPurple];
        }
        else if (navAnnotation.navPointType == NavPointAnnotationEnd)
        {
            [pointAnnotationView setPinColor:MAPinAnnotationColorRed];
        }
        return pointAnnotationView;
    }
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *maPointAnnotationID = @"MAPointAnnotation";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:maPointAnnotationID];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:maPointAnnotationID];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;
        annotationView.leftCalloutAccessoryView = accessoryView;
        return annotationView;
    }
    if ([annotation isKindOfClass:[POIAnnotation class]])
    {
        static NSString *poiAnnotationID = @"POIAnnotation";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:poiAnnotationID];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:poiAnnotationID];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;
        annotationView.leftCalloutAccessoryView = accessoryView;
        return annotationView;
    }
    
    if ([annotation isKindOfClass:[MemberAnnotation class]]) {
        static NSString *memberAnnotatioID = @"memberAnnotatio";
        MAAnnotationView*annotationView = (MAAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:memberAnnotatioID];
        if (annotationView == nil)
        {
            annotationView = (MAAnnotationView *)[[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:memberAnnotatioID];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.image = [UIImage imageNamed:@"navi_icon"];
        return annotationView;
    }
    
    return nil;
}

-(void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    self.endAnnotation = [[NavPointAnnotation alloc] init];
    [self.endAnnotation setCoordinate:((MAPointAnnotation *)view.annotation).coordinate];
    self.endAnnotation.title        = @"终点";
    self.endAnnotation.navPointType = NavPointAnnotationEnd;
    [self.mapView addAnnotation:self.endAnnotation];
    _startCurrLoc = YES;
    _naviType = NavigationTypeGPS;
    [self calRoute];
}

- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineView *polylineView = [[MAPolylineView alloc] initWithPolyline:overlay];
        polylineView.lineWidth = 5.0f;
        polylineView.strokeColor = [UIColor redColor];
        
        return polylineView;
    }
    return nil;
}


- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    // 第一次定位时才将定位点显示在地图中心
    if (!_hasCurrLoc)
    {
        _hasCurrLoc = YES;
        
        [self.mapView setCenterCoordinate:userLocation.coordinate];
        [self.mapView setZoomLevel:14 animated:NO];
    }
    self.currUserLocation = userLocation;
}


#pragma mark - AMapNaviManager Delegate

- (void)naviManager:(AMapNaviManager *)naviManager didPresentNaviViewController:(UIViewController *)naviViewController
{
    [super naviManager:naviManager didPresentNaviViewController:naviViewController];
    
    if (_naviType == NavigationTypeGPS)
    {
        [self.naviManager startGPSNavi];
    }
    else if (_naviType == NavigationTypeSimulator)
    {
        [self.naviManager startEmulatorNavi];
    }
}

- (void)naviManager:(AMapNaviManager *)naviManager didDismissNaviViewController:(UIViewController *)naviViewController
{
    [super naviManager:naviManager didDismissNaviViewController:naviViewController];
    
    if (_naviType == NavigationTypeGPS)
    {
        [self.mapView setDelegate:self];
        
        [_routeShowVC configMapView];
    }
    else
    {
        [self configMapView];
        
        [self initSettingState];
    }
}

- (void)naviManagerOnCalculateRouteSuccess:(AMapNaviManager *)naviManager
{
    [super naviManagerOnCalculateRouteSuccess:naviManager];
    
    if (_naviType == NavigationTypeGPS)
    {
        // 如果_routeShowVC不为nil，说明是偏航重算导致的算路，什么也不做
        if (!_routeShowVC)
        {
            RouteShowViewController *routeShowVC = [[RouteShowViewController alloc] initWithNavManager:naviManager
                                                                naviController:_naviViewController
                                                                       mapView:self.mapView];
            self.routeShowVC = routeShowVC;
            
            routeShowVC.title = @"线路展示";
            
            [self.navigationController pushViewController:routeShowVC animated:YES];
        }
    }
    else if (_naviType == NavigationTypeSimulator)
    {
        [self.naviManager presentNaviViewController:self.naviViewController animated:YES];
    }
}

#pragma mark - AManNaviViewController Delegate

- (void)naviViewControllerCloseButtonClicked:(AMapNaviViewController *)naviViewController
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.iFlySpeechSynthesizer stopSpeaking];
    });
    
    [self.naviManager stopNavi];
    [self.naviManager dismissNaviViewControllerAnimated:YES];
}


- (void)naviViewControllerMoreButtonClicked:(AMapNaviViewController *)naviViewController
{
    if (_moreMenuView == nil)
    {
        [self initMoreMenuView];
    }
    
    [_moreMenuView setViewShowMode:naviViewController.viewShowMode];
    [_moreMenuView setShowNightType:naviViewController.showStandardNightType];
    
    [naviViewController.view addSubview:_moreMenuView];
}


- (void)naviViewControllerTurnIndicatorViewTapped:(AMapNaviViewController *)naviViewController
{
    [self.naviManager readNaviInfoManual];
}

#pragma mark - MoreMenuView Delegate

- (void)moreMenuViewFinishButtonClicked
{
    [_moreMenuView removeFromSuperview];
    
    _moreMenuView.delegate = nil;
    _moreMenuView = nil;
}

- (void)moreMenuViewViewModeChangeTo:(AMapNaviViewShowMode)viewShowMode
{
    if (self.naviViewController)
    {
        [self.naviViewController setViewShowMode:viewShowMode];
    }
}

- (void)moreMenuViewNightTypeChangeTo:(BOOL)isShowNightType
{
    if (self.naviViewController)
    {
        [self.naviViewController setShowStandardNightType:isShowNightType];
    }
}


#pragma mark - UISearchBarDelegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.searchContent = searchBar.text;
    [searchBar resignFirstResponder];
    
    NSArray *array = [self.mapView annotations];
    [self.mapView removeAnnotations:array];
    
    self.searchApi = [[AMapSearchAPI alloc] init];
    self.searchApi.delegate = self;
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    request.keywords = searchBar.text;
    request.types = @"汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施";
    request.sortrule = 0;
    //request.city                = @"010";
    request.requireExtension = YES;
    [self.searchApi AMapPOIKeywordsSearch:request];

}

//实现POI搜索对应的回调函数
-(void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if(response.pois.count == 0)
    {
        self.searchApi = [[AMapSearchAPI alloc] init];
        self.searchApi.delegate = self;
        AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
        geo.address = self.searchContent;
        [self.searchApi AMapGeocodeSearch: geo];

        return;
    }
    
    
    NSMutableArray *poiAnnotations = [[NSMutableArray alloc] init];
    
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        
        [poiAnnotations addObject:[[POIAnnotation alloc] initWithPOI:obj]];
        
    }];
    
    /* 将结果以annotation的形式加载到地图上. */
    [self.mapView addAnnotations:poiAnnotations];
    
    /* 如果只有一个结果，设置其为中心点. */
    if (poiAnnotations.count == 1)
    {
        [self.mapView setCenterCoordinate:[((POIAnnotation *)poiAnnotations[0]) coordinate]];
    }
    /* 如果有多个结果, 设置地图使所有的annotation都可见. */
    else
    {
        [self.mapView showAnnotations:poiAnnotations animated:NO];
    }

}

#pragma mark - AMapSearchDelegate
//实现正向地理编码的回调函数
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    if(response.geocodes.count == 0)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"无法查询到地址，请更换内容后重试" delegate: nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        return;
    }
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    for (AMapGeocode *result in response.geocodes) {
        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
        pointAnnotation.coordinate = CLLocationCoordinate2DMake(result.location.latitude, result.location.longitude);
        //pointAnnotation.subtitle = result.district;
        NSString *address = [NSString stringWithFormat:@"%@%@%@%@%@%@",result.province,result.city,result.district,result.township,result.neighborhood,result.building];
        pointAnnotation.title = address;
        [annotations addObject:pointAnnotation];
    }
    [self.mapView addAnnotations:annotations];
    /* 如果只有一个结果，设置其为中心点. */
    if (response.geocodes.count == 1)
    {
        [self.mapView setCenterCoordinate:[((MAPointAnnotation *)annotations[0]) coordinate]];
    }
    /* 如果有多个结果, 设置地图使所有的annotation都可见. */
    else
    {
        [self.mapView showAnnotations:annotations animated:NO];
    }
}

-(void)getRoute:(BOOL)isStartCurrentLocation start:(NavPointAnnotation *)startAnnotation end:(NavPointAnnotation *)endAnnotation travelType:(TravelTypes)travelType
{
    self.beginAnnotation = startAnnotation;
    self.endAnnotation = endAnnotation;
    
    [self.mapView addAnnotation:self.endAnnotation];
    [self.mapView addAnnotation:self.beginAnnotation];
    _startCurrLoc = isStartCurrentLocation;
    _naviType = NavigationTypeGPS;
    _travelType = travelType;
    [self calRoute];
}

-(void)showNaviParamsViewController
{
    NaviParamsSelectViewController *naviParVC = [[NaviParamsSelectViewController alloc] init];
    naviParVC.delegate = self;
    
    self.navRoutPopover = [[UIPopoverController alloc] initWithContentViewController:naviParVC];

    [self.navRoutPopover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItems[1]
                                  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

////////////////////////////////////////////////by swy///////////////////////////////////////////////////////////

#pragma mark MapTypeSelectViewDelegate方法
/**
 *  选择地图显示类型后回调
 */
-(void)mapTypeSelectView:(SWYMapTypeSelectView *)mapTypeView selectedType:(mapType)type
{
    switch (type) {
        case mapTypeStandard:           //标准地图
            [self.mapView setCameraDegree:0 animated:YES duration:0.5];
            self.mapView.mapType = MAMapTypeStandard;
            break;
        case mapTypeSatellite:          //卫星图
            [self.mapView setCameraDegree:0 animated:YES duration:0.5];
            self.mapView.mapType = MAMapTypeSatellite;
            break;
        case mapType3D:                 //3D
            [self.mapView setCameraDegree:70.0f animated:YES duration:0.5];
            break;
    }
}

/**
 *  创建一个地图属性控制按钮
 */
-(UIButton *)createBtnWithNormalImageName:(NSString *)norImageName selectedImageName:(NSString *)seltImageName
{
    UIButton *btn = [[UIButton alloc] init];
    btn.bounds = CGRectMake(0, 0, 40, 40);
    
    UIImage *norImage = [UIImage imageNamed:norImageName];
    UIImage *seltImage = [UIImage imageNamed:seltImageName];
    [btn setImage:norImage forState:UIControlStateNormal];
    [btn setImage:seltImage forState:UIControlStateSelected];
    
    [self.view addSubview:btn];
    
    [btn addTarget:self action:@selector(mapControlBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

/**
 *  隐藏轨迹
 */
-(void)clearTrack:(UIButton *)sender
{
    //清除当前地图上的路径
    [self.mapView removeOverlays:self.mapView.overlays];
    //隐藏clearTrackBtn按钮
    sender.hidden = YES;
}

/**
 *  地图底部工具条上按钮点击后(前天，昨天，今天)
 */
-(void)bottomBarBtnClicked:(UIButton *)clickedBtn
{
    //前天、昨天、今天对应的 NSDate
    NSDate *today = [NSDate date];
    NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow:24*60*60*(-1)];
    NSDate * beforeYesterday = [NSDate dateWithTimeIntervalSinceNow:24*60*60*(-2)];

    //将NSDate转换成字符串
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *todaystr = [formatter stringFromDate:today];
    NSString *yesterdaystr = [formatter stringFromDate:yesterday];
    NSString *beforeYesterdaystr = [formatter stringFromDate:beforeYesterday];

    if (clickedBtn == self.beforeYesterBtn) {  //点击了前天按钮
        [self addTrackToMapWithDay:beforeYesterdaystr];
    }else if (clickedBtn == self.yesterBtn){   //点击了昨天按钮
        [self addTrackToMapWithDay:yesterdaystr];
    }else{   //点击了今天按钮
        [self addTrackToMapWithDay:todaystr];
    }
}

/**
 *  点击前天昨天今天按钮后调用，在地图上显示轨迹
 *  aDayString参数格式为:yyyyMMdd
 */
-(void)addTrackToMapWithDay:(NSString *)aDayString
{
    //清除当前地图上的路径
    [self.mapView removeOverlays:self.mapView.overlays];
    
    //从数据库中获取这一天的位置信息
    NSMutableArray *trackArray = [[TrackTableHelper sharedInstance] selectDataByAttribute:@"time"
                                                                                    value:aDayString];
    NSUInteger num = trackArray.count;
    if (num <= 0) {
        [NoticeHelper AlertShow:@"没有相关数据!" view:self.view];
        return;
    }
    
    CLLocationCoordinate2D coordinates[num];
    for (int i = 0;i < num; i++) {
        TrackModel *model = trackArray[i];
        coordinates[i] = CLLocationCoordinate2DMake([model.lat doubleValue], [model.lon doubleValue]);
    }
    //创建一个路径
    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coordinates
                                                         count:sizeof(coordinates)/sizeof(coordinates[0])];
    //路径添加到地图上
    [self.mapView addOverlay:polyline];
    [self.mapView setVisibleMapRect:[polyline boundingMapRect] animated:NO];
    
    //显示clearTrackBtn按钮
    self.clearTrackBtn.hidden = NO;
}

/**
 *  点击地图上的属性控制按钮后调用
 */
-(void)mapControlBtnClicked:(UIButton *)sender
{
    if (sender.tag == ControlButtonTypeTraffic) {
        //切换交通图
        sender.selected = !sender.isSelected;
        self.mapView.showTraffic = sender.isSelected;
    }else if (sender.tag == ControlButtonTypeMylocation){
        UIImage *image;
        //切换用户跟随模式
        switch (self.mapView.userTrackingMode) {
            case MAUserTrackingModeNone:
                //切换成Follow模式
                [self.mapView setUserTrackingMode: MAUserTrackingModeFollow animated:YES];
                image = [UIImage imageNamed:@"locationIconFollow"];
                NSLog(@"Follow");
                break;
            case MAUserTrackingModeFollow:
                //切换成Heading模式
                [self.mapView setUserTrackingMode: MAUserTrackingModeFollowWithHeading animated:YES];
                image = [UIImage imageNamed:@"locationIconHeading"];
                NSLog(@"Heading");
                break;
            case MAUserTrackingModeFollowWithHeading:
                //切换成None模式
                [self.mapView setUserTrackingMode: MAUserTrackingModeNone animated:YES];
                [self.mapView setCenterCoordinate:self.currUserLocation.coordinate animated:YES];
                [self.mapView setZoomLevel:14 animated:NO];
                image = [UIImage imageNamed:@"locationIconNone"];
                NSLog(@"None");
                break;
        }
        [sender setImage:image forState:UIControlStateNormal];
        NSLog(@"%f",self.mapView.zoomLevel);
    }else{
        //切换地图类型
        SWYMapTypeSelectView *selectView =  [[SWYMapTypeSelectView alloc] init];
        selectView.delegate = self;
        [selectView showMapTypeViewToView:self.view position:CGPointMake(sender.x, CGRectGetMaxY(sender.frame))];
    }
}

/**
 *  向服务器请求同伴位置信息
 */
-(void)fetchMemberLocation
{
    [CommonRemoteHelper RemoteWithUrl:URL_showusers parameters:nil type:CommonRemoteTypeGet success:^(id responseObject) {
        NSLog(@"NavigationViewController----------------------%@",responseObject);
        //NSArray *objects = (NSArray *)responseObject;
        [self addMemberToMap:responseObject];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"NavigationViewController----------------------%@",@"失败");
    }];
}

/**
 *  将同伴位置信息作为标注点添加到地图上
 */
-(void)addMemberToMap:(NSArray *)members
{
    if (members.count == 0 || !members) {
        return;
    }
    //获取当前用户信息
    CurrentUser *currentUser = [CurrentUser shareInstance];
    
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    
    for (NSDictionary *memberInfoDict in members) {
        //用户自己的位置不需要添加
        if ([memberInfoDict[@"userid"] doubleValue] != [currentUser.userid doubleValue] ) {
            
            MemberAnnotation *annotation = [[MemberAnnotation alloc] initWithLon:[memberInfoDict[@"lon"] floatValue]
                                                                       lat:[memberInfoDict[@"lat"] floatValue]
                                                                memberName:memberInfoDict[@"name"]
                                                                   address:memberInfoDict[@"useraddress"]];
            [annotations addObject:annotation];
        }
    }
    [self.mapView addAnnotations:annotations];
    [self.mapView showAnnotations:annotations animated:NO];
}

-(void)dealloc
{
    if (self.navRoutPopover.isPopoverVisible) {
        [self.navRoutPopover dismissPopoverAnimated:YES];
    }
}

@end
