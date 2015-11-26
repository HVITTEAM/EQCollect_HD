//
//  EQMapViewController.m
//  EQCollect_HD
//
//  Created by shi on 15/11/26.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import "EQMapViewController.h"
#import "CityListViewController.h"

@interface EQMapViewController ()
@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) AMapSearchAPI *search;

@end

@implementation EQMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initMapView];
    [self initNavi];
}

-(void)initMapView
{
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64)];
    self.mapView.showsCompass= YES;
    self.mapView.compassOrigin= CGPointMake(self.mapView.compassOrigin.x, 22);
    self.mapView.showsScale = YES;
    self.mapView.scaleOrigin= CGPointMake(self.mapView.scaleOrigin.x, 22);
    [self.mapView setZoomLevel:14 animated:YES];
     self.mapView.rotateEnabled= NO;
     self.mapView.rotateCameraEnabled= NO;
    
    self.mapView.showsUserLocation = YES;
    [self.mapView setUserTrackingMode: MAUserTrackingModeFollow animated:YES];
    
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
}

-(void)initNavi
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"城市列表" style:UIBarButtonItemStylePlain target:self action:@selector(downloadCityList)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation)
    {
        //取出当前位置的坐标
        NSLog(@"----latitude : %f,----longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
    }
}


-(void)downloadCityList
{
    CityListViewController *cityListVC = [[CityListViewController alloc] init];
    [self.navigationController pushViewController:cityListVC animated:YES];
}

- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
    
    [self clearMapView];
    
    [self clearSearch];
}

- (void)clearMapView
{
    self.mapView.showsUserLocation = NO;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    self.mapView.delegate = nil;
}

- (void)clearSearch
{
    self.search.delegate = nil;
}

@end
