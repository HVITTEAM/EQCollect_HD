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
#import "PictureVO.h"
#import <AVFoundation/AVFoundation.h>
#import "UzysAssetsPickerController.h"
#import "SWYPhotoBrowserViewController.h"

@interface ImageCollectionView ()<UIAlertViewDelegate,UIImagePickerControllerDelegate,UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate,UzysAssetsPickerControllerDelegate>

@property (nonatomic, assign)BOOL isShowAddBtn;                    //是否显示新增图片的按钮

@end

@implementation ImageCollectionView

#pragma mark -- 生命周期方法 --
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initCollectionView];
    self.dataProvider = [[NSMutableArray alloc]init];
}

#pragma mark -- 初始化子视图方法 --
/**
 *  初始化集合视图属性
 */
-(void)initCollectionView
{
    [self.collectionView registerNib:[UINib nibWithNibName:@"SQCollectionCell" bundle:nil] forCellWithReuseIdentifier:kcellIdentifier];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.scrollEnabled = NO;
}


#pragma mark -- getter 和 setter方法 --
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
    if (self.showType!=kActionTypeShow && _dataProvider.count<10) {
        self.isShowAddBtn = YES;
    }else {
        self.isShowAddBtn = NO;
    }
    
    [self.collectionView reloadData];
}

#pragma mark -- 协议方法 --
#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSUInteger num = self.dataProvider.count;
    if (self.isShowAddBtn) {
        return num + 1;
    }else{
        return num;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //重用cell
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kcellIdentifier forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    UIImageView *delImageView  = (UIImageView *)[cell viewWithTag:2];
    
    //在不显示新增图片按钮时，index 最大是self.dataProvider.count-1，如果等于self.dataProvider.count，说明当前显示的是新增图片按钮
    if ( indexPath.row ==self.dataProvider.count) {
        delImageView.hidden = YES;
        imageView.image = [UIImage imageNamed:@"icon_addpic"];
    }else{
        
        delImageView.hidden = NO;
        
        if (self.showType == kActionTypeShow) {
           delImageView.hidden = YES;
        }
        
        PictureVO *vo = self.dataProvider[indexPath.row];
        //创建缩略图来显示
        UIImage *img = [[UIImage alloc] initWithData:vo.imageData];
        imageView.image = [img scaleImageToSize:CGSizeMake(cellWidth,cellHeight)];
    }
    return cell;
}

#pragma mark UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    //如果等于self.dataProvider.count说明点击了新增图片按钮
    if (index == self.dataProvider.count) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"请选择图片来源" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从手机相册选择", nil];
        [alert show];
    }else{
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

#pragma mark UIAlertViewDelegate 
/**
 *  选择获取图片模式
 */
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)         //拍照
        [self shootPicturePrVideo];
    else if(buttonIndex==2)          //照片库中选取
        [self selectExistingPictureOrVideo];
}

#pragma UIImagePickerControllerDelegate
/**
 *  拍照完成
 */
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

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark  UzysAssetsPickerControllerDelegate
/**
 *  照片选取完成
 */
- (void)UzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if([[assets[0] valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]) //Photo
        {
            [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                ALAsset *representation = obj;
                
                if (self.isExitThread) {
                    return ;
                }
                
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

#pragma -- 事件方法 --
/**
 *  拍照
 */
-(void)shootPicturePrVideo
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        NSArray *mediatypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([mediatypes count]>0) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.mediaTypes = mediatypes;
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            NSString *requiredmediatype = (NSString *)kUTTypeImage;
            NSArray *arrmediatypes = [NSArray arrayWithObject:requiredmediatype];
            [picker setMediaTypes:arrmediatypes];
            [self.parentViewController presentViewController:picker animated:YES completion:nil];
        }
    }else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"错误信息!" message:@"当前设备不支持拍摄功能" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
        [alert show];
    }
}

/**
 *  从相册获取
 */
-(void)selectExistingPictureOrVideo
{
    NSUInteger num = self.dataProvider.count;
    UzysAssetsPickerController *pickerVC = [[UzysAssetsPickerController alloc] init];
    pickerVC.delegate = self;
    pickerVC.maximumNumberOfSelectionVideo = 0;
    pickerVC.maximumNumberOfSelectionPhoto = num==0?10:10-num;
    [self.parentViewController presentViewController:pickerVC animated:YES completion:^{
    }];
}

/**
 *  浏览图片
 */
-(void)showImageWhthCurrentIdx:(NSInteger)idx
{
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for(PictureVO* vo in self.dataProvider)
    {
        UIImage *img = [[UIImage alloc] initWithData:vo.imageData];
        [images addObject:img];
    }
    SWYPhotoBrowserViewController *photoBrowser = [[SWYPhotoBrowserViewController alloc] initPhotoBrowserWithImages:images currentIndex:idx];
    [self.parentViewController presentViewController:photoBrowser animated:YES completion:nil];
}

/**
 *  根据当前图片数调整view高度
 */
-(void)changeViewHeight
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    //单行的高度
    CGFloat itemHeight = flowLayout.itemSize.height + flowLayout.minimumLineSpacing * 2;
    
    if (self.changeHeightBlock) {
        if (self.isShowAddBtn) {
            if (self.dataProvider.count + 1 > 5) {
                //2行的高度
                itemHeight = flowLayout.itemSize.height * 2 + flowLayout.minimumLineSpacing * 3;
            }
        }else{
            if (self.dataProvider.count > 5) {
                //2行的高度
                itemHeight = flowLayout.itemSize.height * 2 + flowLayout.minimumLineSpacing * 3;
            }
        }
        self.changeHeightBlock(itemHeight);
    }
}

-(void)dealloc
{
    NSLog(@"ImageCollectionView 释放了吗");
}

@end
