//
//  ImageCollectionView.m
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/17.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#define cellHeight 70
#define cellWidth 70
static NSString *kcellIdentifier = @"collectionCellID";

#import "ImageCollectionView.h"

@interface ImageCollectionView ()

@end

@implementation ImageCollectionView
{
    BOOL isFull;//是否已经选择十张
    MWPhotoBrowser *_browser;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initCollectionView];
    
    _dataProvider = [[NSMutableArray alloc]init];
}

/**
 *  初始化服务类别列表
 */
-(void)initCollectionView
{
    [self.collectionView registerNib:[UINib nibWithNibName:@"SQCollectionCell" bundle:nil] forCellWithReuseIdentifier:kcellIdentifier];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.scrollEnabled = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

/**
 *  重写dataProvider属性的的 setter方法
 */
-(void)setDataProvider:(NSMutableArray *)dataProvider
{
    _dataProvider = dataProvider;
    [self setAddBtn];
    [self changeViewHeight];
}

/**
 *  重写showType属性的的 setter方法
 */
-(void)setShowType:(ActionType)showType
{
     _showType=showType;
    [self setAddBtn];
    [self changeViewHeight];
}

/**
 *  设置是否要显示添加图片的按钮
 */
-(void)setAddBtn
{
    if (_showType!=kActionTypeShow && _dataProvider.count<10) {
        self.isShowAddBtn = YES;
    }else self.isShowAddBtn = NO;
    
    [self.collectionView reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSUInteger num = self.dataProvider.count;
    if (self.isShowAddBtn) {
        if (num+1<=5) {
            return 1;
        }else {
            return 2;
        }
    }else {
        if (num <=5) {
            return 1;
        }else{
            return 2;
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSUInteger num = self.dataProvider.count;
    if (self.isShowAddBtn) {
        if (num+1<=5) {
            return num+1;
        }else {
            if (section ==0) {
                return 5;
            }else return num+1-5;
        }
    }else{
        if (num<=5) {
            return num;
        }else{
            if (section == 0) {
                return 5;
            }else return num-5;
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.section * 5 +indexPath.row;
    //重用cell
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kcellIdentifier forIndexPath:indexPath];
    //赋值
    UIImageView *imageV = (UIImageView *)[cell viewWithTag:1];
    UIImageView *delImageV  = (UIImageView *)[cell viewWithTag:2];
    
    //在不显示新增图片按钮时，index 最大是self.dataProvider.count-1，如果等于self.dataProvider.count，说明当前显示的是新增图片按钮
    if ( index==self.dataProvider.count) {
        delImageV.hidden = YES;
        imageV.image = [UIImage imageNamed:@"icon_addpic"];
    }else{
        if (self.showType == kActionTypeShow) {
           delImageV.hidden = YES;
        }else delImageV.hidden = NO;
        
        PictureVO *vo = self.dataProvider[index];
        //创建缩略图来显示
        UIImage *img = [[UIImage alloc] initWithData:vo.imageData];
        imageV.image = [img scaleImageToSize:CGSizeMake(cellWidth,cellHeight)];
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(cellWidth, cellHeight);
}

/**
 *  设置横向间距
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

/**
 *  设置竖向间距
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

/**
 *  定义每个section的 margin
 */
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return section==0?UIEdgeInsetsMake(10, 0, 7, 0):UIEdgeInsetsMake(7, 0, 0, 0);//分别为上、左、下、右
}

#pragma mark --UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.section * 5 +indexPath.row;
    //在不显示新增图片按钮时，index 最大是self.dataProvider.count-1，如果等于self.dataProvider.count，说明当前显示新增图片按钮，且点击了新增图片按钮
    if (index == self.dataProvider.count) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"请选择图片来源" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从手机相册选择", nil];
        [alert show];
    }
    else
    {
        if (self.showType==kActionTypeShow){
           [self showImageWhthCurrentIdx:index];
        }else if (self.showType == kActionTypeAdd) {
            //如果是新增，点击就直接从数组中删除
            [self.dataProvider removeObjectAtIndex:index];
            [self setAddBtn];
            [self changeViewHeight];
        }else{
            //如果是编辑，点击除了从数组中删除外还要从数据库删除记录，从沙盒删除图片
            NSString *imgName = ((PictureVO*)self.dataProvider[index]).name;
            [[PictureInfoTableHelper sharedInstance] deleteImageByAttribute:@"pictureName" value:imgName];
            [self.dataProvider removeObjectAtIndex:index];
            [self setAddBtn];
            [self changeViewHeight];
        }
    }
}

#pragma mark -- 拍照选择模块
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
        [self shootPicturePrVideo];
    else if(buttonIndex==2)
        [self selectExistingPictureOrVideo];
}

/**从相机*/
-(void)shootPicturePrVideo
{
    [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
}

/**从相册*/
-(void)selectExistingPictureOrVideo
{
    NSUInteger num = self.dataProvider.count;
    UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
    picker.delegate = self;
    picker.maximumNumberOfSelectionVideo = 0;
    picker.maximumNumberOfSelectionPhoto = num==0?10:10-num;
    [self.nav presentViewController:picker animated:YES completion:^{
    }];
}

#pragma 拍照模块
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        NSData *data;
        data = UIImageJPEGRepresentation(image, 0.000005);//压缩图片
        //关闭相册界面
        [picker dismissViewControllerAnimated:NO completion:nil];
        PictureVO *imgVo = [[PictureVO alloc] init];
        imgVo.name = currentDateStr;
        imgVo.imageData = data;
        
        if (self.dataProvider.count < 10) {
            [self.dataProvider addObject:imgVo];
        }else{
            [[[UIAlertView alloc] initWithTitle:nil message:@"已达到最大可选张数" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil]  show];
        }
        [self setAddBtn];
        //调整view高度
        [self changeViewHeight];

    }
}

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:NO completion:nil];
}

-(void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType
{
    NSArray *mediatypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if([UIImagePickerController isSourceTypeAvailable:sourceType] &&[mediatypes count]>0)
    {
        NSArray *mediatypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
        CommonUIImagePickerController *picker = [[CommonUIImagePickerController alloc] init];
        picker.mediaTypes = mediatypes;
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = sourceType;
        NSString *requiredmediatype = (NSString *)kUTTypeImage;
        NSArray *arrmediatypes = [NSArray arrayWithObject:requiredmediatype];
        [picker setMediaTypes:arrmediatypes];
        [self.nav presentViewController:picker animated:YES completion:nil];
    }
    else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"错误信息!" message:@"当前设备不支持拍摄功能" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - 浏览图片
-(void)showImageWhthCurrentIdx:(NSInteger)idx
{
    // Browser
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    MWPhoto *photo;
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = NO;
    BOOL startOnGrid = YES;
    
    for(PictureVO* vo in self.dataProvider)
    {
//        NSUInteger idx = [self.dataProvider indexOfObject:vo];
//        if (idx == self.dataProvider.count - 1)
//            break;
        UIImage *img = [[UIImage alloc] initWithData:vo.imageData];
        photo = [MWPhoto photoWithImage:img];
        photo.caption = vo.name;
        [photos addObject:photo];
    }
    
    // Options
    self.photos = photos;
    self.thumbs = thumbs;
    // Create browser
    _browser= [[MWPhotoBrowser alloc] initWithDelegate:self];
    _browser.displayActionButton = displayActionButton;//分享按钮,默认是
    _browser.displayNavArrows = displayNavArrows;//左右分页切换,默认否
    _browser.displaySelectionButtons = displaySelectionButtons;//是否显示选择按钮在图片上,默认否
    _browser.alwaysShowControls = displaySelectionButtons;//控制条件控件 是否显示,默认否
    _browser.zoomPhotosToFill = NO;//是否全屏,默认是
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;//是否全屏
#endif
    _browser.enableGrid = enableGrid;//是否允许用网格查看所有图片,默认是
    _browser.startOnGrid = startOnGrid;//是否第一张,默认否
    _browser.enableSwipeToDismiss = YES;
    [_browser showNextPhotoAnimated:YES];
    [_browser showPreviousPhotoAnimated:YES];
    [_browser setCurrentPhotoIndex:idx];
    
    UINavigationController *nav0 = [[UINavigationController alloc] initWithRootViewController:_browser];
    nav0.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav0 animated:YES completion:nil];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return _photos.count;
}

- (id )photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}


-(void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser
{
    [photoBrowser dismissViewControllerAnimated:YES completion:nil];
    _browser = nil;
    self.photos = nil;
    self.thumbs = nil;
}

#pragma mark - UzysAssetsPickerControllerDelegate
- (void)UzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if([[assets[0] valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]) //Photo
        {
            [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                ALAsset *representation = obj;
                
                UIImage *img = [UIImage imageWithCGImage:representation.defaultRepresentation.fullResolutionImage
                                                   scale:representation.defaultRepresentation.scale
                                             orientation:(UIImageOrientation)representation.defaultRepresentation.orientation];
                //实例化一个NSDateFormatter对象
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                //设定时间格式,这里可以设置成自己需要的格式
                [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
                //用[NSDate date]可以获取系统当前时间
                NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
                
                NSData *data;
                data = UIImageJPEGRepresentation(img, 0.000005);//压缩图片
                PictureVO *imgVo = [[PictureVO alloc] init];
                imgVo.name = [currentDateStr stringByAppendingFormat:@"_%lu",(unsigned long)idx];
                imgVo.imageData = data;

                if (self.dataProvider.count < 10) {
                    [self.dataProvider addObject:imgVo];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setAddBtn];
                    //调整view高度
                    [self changeViewHeight];
                });

            }];
        }
    });
}

/**
 *  根据当前图片数调整view高度
 */
-(void)changeViewHeight
{
    //默认为一行5张，高度为87,两行时高度为164
    
    CGFloat h = 87;
    if (self.changeHeightBlock) {
        
        if (self.isShowAddBtn) {
            if (self.dataProvider.count + 1 > 5) {
                h=164;
            }
        }else{
            if (self.dataProvider.count > 5) {
                h=164;
            }
        }
        self.changeHeightBlock(h);
    }
}

@end
