//
//  PointinfoViewController.m
//  EQCollect_HD
//
//  Created by shi on 15/9/7.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//
#define kNormalNavHeight 64
#define kAddNavheight 44
#import "PointinfoViewController.h"

@interface PointinfoViewController ()
{
    
}
@end

@implementation PointinfoViewController
{
    CGFloat _navHeight;       // 导航栏与状态栏总的高度
    CGFloat keyBoardHeight;   //键盘高度
    
    NSMutableArray *imageArr;//图片数组
    
    NSMutableArray *imageViews;//图片视图数组
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initPointinfoVC];
    
    imageArr = [[NSMutableArray alloc] init];
    
    imageViews = [[NSMutableArray alloc] init];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showPointinfoData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

/**
 *  初始化调查点信息控制器
 */
-(void)initPointinfoVC
{
    keyBoardHeight = 352;
    //默认情况下ScrollView中的内容不会被导航栏遮挡
    _navHeight = 0;
    if (self.isAdd ) {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        self.navigationItem.leftBarButtonItem = leftItem;
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(addPointinfo)];
        self.navigationItem.rightBarButtonItem = rightItem;
        
        //当为新增时没有状态栏，高度为44
        _navHeight = kAddNavheight;
    }
    //获取设备当前方向
    UIDeviceOrientation devOrientation = [[UIDevice currentDevice] orientation];
    //将UIDeviceOrientation类型转为UIInterfaceOrientation
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)devOrientation;
    //根据屏幕方向设置视图的约束
    [self rotationToInterfaceOrientation:interfaceOrientation];
    
    self.textInputViews = @[
                            self.pointidTextF,
                            self.pointlocationTextF,
                            self.pointnameTextF,
                            self.pointtimeTextF,
                            self.earthidTextF,
                            self.pointlonTextF,
                            self.pointlatTextF,
                            self.pointgroupTextF,
                            self.pointintensityTextF,
                            self.pointcontentTextV
                            ];
    for (int i = 0;i < self.textInputViews.count-1; i++) {
        UITextField *textF = self.textInputViews[i];
        textF.delegate = self;
        //设置tag
        textF.tag = 1000+i;
    }
    //pointcontentTextV类型是UITextView单独处理
    self.pointcontentTextV.delegate = self;
    self.pointcontentTextV.tag = 1000 + self.textInputViews.count-1;
}

/**
 *  获取调查点下的图片
 */
-(void)getImages
{
    //获取图片之前需要把当前视图中得imageView清除
    if (imageViews)
    {
        for (UIImageView * imgView in imageViews)
        {
            [imgView removeFromSuperview];
        }
        imageViews = [[NSMutableArray alloc] init];
    }
    
    imageArr = [[PictureInfoTableHelper sharedInstance] selectDataByAttribute:@"pointid" value:self.pointinfo.pointid];
    //循环添加图片
    for(PictureMode* pic in imageArr)
    {
        PictureVO *vo = [[PictureVO alloc] init];
        vo.name = pic.pictureName;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", pic.pictureName]];
        UIImage *img = [UIImage imageWithContentsOfFile:filePath];
        vo.image = img;
        [self showImage:vo index:[imageArr indexOfObject:pic]];
    }
}

-(void)showPointinfoData
{
    if (!self.isAdd)
    {
        self.pointidTextF.text = self.pointinfo.pointid;
        self.earthidTextF.text = self.pointinfo.earthid;
        self.pointlocationTextF.text = self.pointinfo.pointlocation;
        self.pointlonTextF.text = self.pointinfo.pointlon;
        self.pointlatTextF.text = self.pointinfo.pointlat;
        self.pointnameTextF.text = self.pointinfo.pointname;
        self.pointtimeTextF.text = self.pointinfo.pointtime;
        self.pointgroupTextF.text = self.pointinfo.pointgroup;
        self.pointintensityTextF.text = self.pointinfo.pointintensity;
        self.pointcontentTextV.text = self.pointinfo.pointcontent;
        [self getImages];
    }else
    {
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd HH:mm"];
        self.pointtimeTextF.text = [formatter stringFromDate:date];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration;
{
    switch (interfaceOrientation)
    {
        case UIInterfaceOrientationPortrait:
            keyBoardHeight = 264 - 100;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            keyBoardHeight = 264 - 100;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            keyBoardHeight = 352;
            break;
        case UIInterfaceOrientationLandscapeRight:
            keyBoardHeight = 352;
            break;
        default:
            break;
    }
    [self rotationToInterfaceOrientation:interfaceOrientation];
}

/**
 *  旋转屏幕时更改约束
 *
 *  @param interfaceOrientation 要旋转的方向
 */
-(void)rotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(UIInterfaceOrientationIsLandscape(interfaceOrientation)&&!self.isAdd)
    {
        //设备为横屏且不是新增界面，设置为横屏约束
        self.pointidWidthCons.constant = 180;
    }else{
        //设备为竖屏或新增界面，设置为竖屏约束
        self.pointidWidthCons.constant = 100;
    }
    self.pointidTopCons.constant = 20+_navHeight;
    //更新约束
    [self.view updateConstraintsIfNeeded];
}

#pragma mark UITextFieldDelegate方法
//开始编辑输入框的时候，软键盘出现，执行此事件
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    int offset = CGRectGetMaxY(frame) - (self.view.frame.size.height - keyBoardHeight);
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

//输入框编辑完成以后，将视图恢复到原始状态
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyNext) {
        //根据tag获取下一个文本框
        UITextField *textF =(UITextField *)[self.view viewWithTag:textField.tag+1];
        [textF becomeFirstResponder];
    }
    if (textField.returnKeyType == UIReturnKeyDone) {
        [textField resignFirstResponder];
    }
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL canEdit;
    
    if (self.isAdd) {
        switch (textField.tag) {
            case 1003:
                canEdit = NO;
                break;
            default:
                canEdit = YES;
                break;
        }
    }else canEdit = NO;
    
    return canEdit;
}


#pragma mark UITextViewDelegate方法
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    CGRect frame = textView.frame;
    int offset = CGRectGetMaxY(frame) - (self.view.frame.size.height - keyBoardHeight);
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

//输入框编辑完成以后，将视图恢复到原始状态
-(void)textViewDidEndEditing:(UITextView *)textView
{
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.isAdd) {
        return YES;
    }else return NO;
}

-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)addPointinfo
{
    NSString *pointid = self.pointidTextF.text;
    NSString *earthid = self.earthidTextF.text;
    NSString *pointlocation = self.pointlocationTextF.text;
    NSString *pointlon = self.pointlonTextF.text;
    NSString *pointlat = self.pointlatTextF.text;
    NSString *pointname = self.pointnameTextF.text;
    NSString *pointtime = self.pointtimeTextF.text;
    NSString *pointgroup = self.pointgroupTextF.text;
    NSString *pointperson1 = @"person1";
    NSString *pointperson2 = @"person2";
    NSString *pointintensity = self.pointintensityTextF.text;
    NSString *pointcontent = self.pointcontentTextV.text;
    
    //判断文本输入框是否为空，如果为空则提示并返回
    for (int i=0; i<self.textInputViews.count; i++) {
        if (i!=self.textInputViews.count-1) {
            UITextField *textF = (UITextField *)self.textInputViews[i];
            if (textF.text ==nil || textF.text.length <=0) {
                [[[UIAlertView alloc] initWithTitle:nil message:@"所填项目不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
                return;
            }
        }else{
            UITextView *textV = (UITextView *)self.textInputViews[i];
            if (textV.text ==nil || textV.text.length <=0) {
                [[[UIAlertView alloc] initWithTitle:nil message:@"数据不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
                return;
            }
        }
    }
    //创建字典对象并向表中插和数据
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          pointid,@"pointid",
                          earthid,@"earthid",
                          pointlocation,@"pointlocation",
                          pointlon, @"pointlon",
                          pointlat, @"pointlat",
                          pointname,@"pointname",
                          pointtime,@"pointtime",
                          pointgroup,@"pointgroup",
                          pointperson1,@"pointperson1",
                          pointperson2,@"pointperson2",
                          pointintensity,@"pointintensity",
                          pointcontent,@"pointcontent", nil];
    
    BOOL result = [[PointinfoTableHelper sharedInstance] insertDataWith:dict];
    if (!result) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"新建数据出错,请确定编号唯一" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }else{
        [self saveImages];
        self.pointidTextF.text = nil;
        self.earthidTextF.text = nil;
        self.pointlocationTextF.text = nil;
        self.pointlonTextF.text = nil;
        self.pointlatTextF.text = nil;
        self.pointnameTextF.text = nil;
        self.pointtimeTextF.text = nil;
        self.pointgroupTextF.text = nil;
        self.pointintensityTextF.text = nil;
        self.pointcontentTextV.text = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:kAddPointinfoSucceedNotification object:nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)saveImages
{
    //保存图片
    for(PictureVO* v in imageArr)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", v.name]];
        BOOL result = [UIImagePNGRepresentation(v.image)writeToFile: filePath    atomically:YES];  // 写入本地沙盒
        if (result)
        {
            NSLog(@"success to writeFile");
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  v.name,@"pictureName",
                                  filePath,@"picturePath",
                                  self.pointidTextF.text,@"pointid",
                                  nil];
            NSLog(@"%@",filePath);
            //保存数据库
            [[PictureInfoTableHelper sharedInstance] insertDataWith:dict];
        }
    }
}

#pragma mark Photo 相关方法

- (IBAction)getImgBtnClickHandler:(id)sender
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"请选择图片来源" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从手机相册选择", nil];
    [alert show];
}

#pragma mark 拍照选择模块
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
        [self shootPiicturePrVideo];
    else if(buttonIndex==2)
        [self selectExistingPictureOrVideo];
}

/**从相机*/
-(void)shootPiicturePrVideo
{
    [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
}

///**从相册*/
-(void)selectExistingPictureOrVideo
{
    [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
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
    //输出格式为：2010-10-27 10:22:13
    NSLog(@"%@",currentDateStr);
    
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
        imgVo.image = [UIImage imageWithData:data];
        [imageArr addObject:imgVo];
        [self addImgToview:imgVo];
    }
}

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"您取消了选择图片");
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
        [self presentViewController:picker animated:YES completion:nil];
    }
    else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"错误信息!" message:@"当前设备不支持拍摄功能" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
        [alert show];
    }
}


#pragma mark - 浏览图片
-(void)tapAction:(UITapGestureRecognizer*)tap
{
    NSLog(@"显示采集图片");
    
    // Browser
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    MWPhoto *photo;
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = NO;
    BOOL startOnGrid = YES;
    
    for(PictureMode* imgmodel in imageArr)
    {
        //获取保存的图片
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", imgmodel.pictureName]];   // 保存文件的名称
        UIImage *img = [UIImage imageWithContentsOfFile:filePath];
        photo = [MWPhoto photoWithImage:img];
        photo.caption = imgmodel.pictureName;
        [photos addObject:photo];
    }
    
    // Options
    self.photos = photos;
    self.thumbs = thumbs;
    // Create browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;//分享按钮,默认是
    browser.displayNavArrows = displayNavArrows;//左右分页切换,默认否
    browser.displaySelectionButtons = displaySelectionButtons;//是否显示选择按钮在图片上,默认否
    browser.alwaysShowControls = displaySelectionButtons;//控制条件控件 是否显示,默认否
    browser.zoomPhotosToFill = NO;//是否全屏,默认是
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;//是否全屏
#endif
    browser.enableGrid = enableGrid;//是否允许用网格查看所有图片,默认是
    browser.startOnGrid = startOnGrid;//是否第一张,默认否
    browser.enableSwipeToDismiss = YES;
    [browser showNextPhotoAnimated:YES];
    [browser showPreviousPhotoAnimated:YES];
    [browser setCurrentPhotoIndex:tap.view.tag];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:browser];
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
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

/*
 **
 * 在视图上添加照片
 **/
-(void)addImgToview:(PictureVO *)imgVo
{
    float imageCount = imageArr.count;
    UIImageView *img = [[UIImageView alloc]initWithImage:imgVo.image];
    img.frame = CGRectMake((imageCount *120), 20, 100, 100);
    self.imageBgview.contentSize = CGSizeMake(CGRectGetMaxX(img.frame), 100);
    [self.imageBgview addSubview:img];
    
}

/*
 * 展示采集图片
 * index 照片序列
 **/
-(void)showImage:(PictureVO *)imgVo index:(NSUInteger)index
{
    UIImageView *img = [[UIImageView alloc]initWithImage:imgVo.image];
    img.frame = CGRectMake(index * 120, 20, 100, 100);
    [self.imageBgview addSubview:img];
    [imageViews addObject:img];
    self.imageBgview.contentSize = CGSizeMake(CGRectGetMaxX(img.frame), 100);
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [img addGestureRecognizer:tap];
    img.userInteractionEnabled = YES;
}

@end

