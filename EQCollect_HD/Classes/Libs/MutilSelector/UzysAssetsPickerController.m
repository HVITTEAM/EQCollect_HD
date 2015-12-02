//
//  UzysAssetsPickerController.m
//  UzysAssetsPickerController
//
//  Created by Uzysjung on 2014. 2. 12..
//  Copyright (c) 2014 Uzys. All rights reserved.
//

#import "UzysAssetsPickerController.h"
#import "UzysAssetsViewCell.h"
#import "UzysWrapperPickerController.h"
#import "UzysGroupPickerView.h"
//#import "UzysGroupPickerViewController.h"


@interface UzysAssetsPickerController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegateFlowLayout>
//View
@property (weak, nonatomic) IBOutlet UIButton *btnTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (weak, nonatomic) IBOutlet UIView *navigationTop;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *labelSelectedMedia;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;

@property (nonatomic, strong)IBOutlet UIView *noAssetView;
@property (nonatomic, strong)IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UzysWrapperPickerController *picker;
@property (nonatomic, strong) UzysGroupPickerView *groupPicker;
//@property (nonatomic, strong) UzysGroupPickerViewController *groupPicker;

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, assign) NSInteger numberOfPhotos;
@property (nonatomic, assign) NSInteger numberOfVideos;
@property (nonatomic, assign) NSInteger maximumNumberOfSelection;

- (IBAction)btnAction:(id)sender;
- (IBAction)indexDidChangeForSegmentedControl:(id)sender;

@end

@implementation UzysAssetsPickerController

#pragma mark - ALAssetsLibrary

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred,^
                  {
                      library = [[ALAssetsLibrary alloc] init];
                  });
    return library;
}


- (id)init
{
    self = [super initWithNibName:@"UzysAssetsPickerController" bundle:nil];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsLibraryUpdated:) name:ALAssetsLibraryChangedNotification object:nil];
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
    self.assetsLibrary = nil;
    self.assetsGroup = nil;
    self.assets = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initVariable];
    [self initImagePicker];
    [self setupOneMediaTypeSelection];

    __weak typeof(self) weakSelf = self;
    [self setupGroup:^{
        [weakSelf.groupPicker.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    } withSetupAsset:YES];
    [self setupCollectionView];
    [self setupGroupPickerview];
}

- (void)initVariable
{
    self.assetsFilter = [ALAssetsFilter allPhotos];
    self.maximumNumberOfSelection = self.maximumNumberOfSelectionPhoto;
    self.view.clipsToBounds = YES;
    
    self.btnDone.layer.cornerRadius = 15;
    self.btnDone.clipsToBounds = YES;
    
    self.noAssetView.hidden = YES;
}
- (void)initImagePicker
{
    UzysWrapperPickerController *picker = [[UzysWrapperPickerController alloc] init];
//    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes =
        [UIImagePickerController availableMediaTypesForSourceType:
         UIImagePickerControllerSourceTypeCamera];
    }
    self.picker = picker;
}

- (void)setupGroupPickerview
{
    __weak typeof(self) weakSelf = self;
    self.groupPicker = [[UzysGroupPickerView alloc] initWithGroups:self.groups];

    self.groupPicker.blockTouchCell = ^(NSInteger row){
        [weakSelf changeGroup:row filter:weakSelf.assetsFilter];
    };
    
    [self.view insertSubview:self.groupPicker aboveSubview:self.bottomView];
    [self.view bringSubviewToFront:self.navigationTop];
    [self menuArrowRotate];
}
- (void)setupOneMediaTypeSelection
{
    if(_maximumNumberOfSelectionMedia > 0)
    {
        self.assetsFilter = [ALAssetsFilter allAssets];
        self.maximumNumberOfSelection = self.maximumNumberOfSelectionMedia;
        self.segmentedControl.hidden = YES;
        self.labelSelectedMedia.hidden = NO;
        if(_maximumNumberOfSelection >1)
            self.labelSelectedMedia.text = @"Choose media";
        else
            self.labelSelectedMedia.text = @"Choose media";

    }
    else
    {
        if(_maximumNumberOfSelectionPhoto ==0)
        {
            self.assetsFilter = [ALAssetsFilter allVideos];
            self.maximumNumberOfSelection = self.maximumNumberOfSelectionVideo;
            self.segmentedControl.hidden = YES;
            self.labelSelectedMedia.hidden = NO;
            if(_maximumNumberOfSelection >1)
                self.labelSelectedMedia.text = @"Choose videos";
            else
                self.labelSelectedMedia.text = @"Choose a video";
        }
        else if(_maximumNumberOfSelectionVideo ==0)
        {
            self.assetsFilter = [ALAssetsFilter allPhotos];
            self.segmentedControl.selectedSegmentIndex = 0;
            self.maximumNumberOfSelection = self.maximumNumberOfSelectionPhoto;
            self.segmentedControl.hidden = YES;
            self.labelSelectedMedia.hidden = NO;
            self.labelSelectedMedia.text = [NSString stringWithFormat:@"最多选%d张",(int)self.maximumNumberOfSelectionPhoto];
        }
        else
        {
            self.segmentedControl.hidden = NO;
            self.labelSelectedMedia.hidden = YES;
        }
        
    }
}
- (void)setupCollectionView
{
    UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize                     = CGSizeMake(100, 100);
    layout.sectionInset                 = UIEdgeInsetsMake(0, 10, 0, 10);
    layout.minimumInteritemSpacing      = 1.0;
    layout.minimumLineSpacing           = 10.0;

     self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView registerClass:[UzysAssetsViewCell class]
            forCellWithReuseIdentifier:kAssetsViewCellIdentifier];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceVertical = YES;
    
    [self.view insertSubview:self.collectionView atIndex:0];
}

- (void)changeGroup:(NSInteger)item filter:(ALAssetsFilter *)filter
{
    self.assetsFilter = filter;
    self.assetsGroup = self.groups[item];
    [self setupAssets:nil];
    [self.groupPicker.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:item inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self.groupPicker dismiss:YES];
    [self menuArrowRotate];
}
- (void)changeAssetType:(BOOL)isPhoto endBlock:(voidBlock)endBlock
{
    if(isPhoto)
    {
        self.maximumNumberOfSelection = self.maximumNumberOfSelectionPhoto;
        self.assetsFilter = [ALAssetsFilter allPhotos];
        [self setupAssets:endBlock];
    }
    else
    {
        self.maximumNumberOfSelection = self.maximumNumberOfSelectionVideo;
        self.assetsFilter = [ALAssetsFilter allVideos];
        [self setupAssets:endBlock];
        
    }
}
- (void)setupGroup:(voidBlock)endblock withSetupAsset:(BOOL)doSetupAsset
{
    if (!self.assetsLibrary)
    {
        self.assetsLibrary = [self.class defaultAssetsLibrary];
    }
    
    if (!self.groups)
        self.groups = [[NSMutableArray alloc] init];
    else
        [self.groups removeAllObjects];
    
    
    __weak typeof(self) weakSelf = self;
    
    ALAssetsFilter *assetsFilter = [ALAssetsFilter allAssets]; // number of Asset
    
    ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group)
        {
            [group setAssetsFilter:assetsFilter];
            NSInteger groupType = [[group valueForProperty:ALAssetsGroupPropertyType] integerValue];
            if(groupType == ALAssetsGroupSavedPhotos)
            {
                [weakSelf.groups insertObject:group atIndex:0];
                if(doSetupAsset)
                {
                    weakSelf.assetsGroup = group;
                    [weakSelf setupAssets:nil];
                }
            }
            else
            {
                if (group.numberOfAssets > 0)
                    [weakSelf.groups addObject:group];
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.groupPicker reloadData];
                if(endblock)
                    endblock();
            });
        }
    };

    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
        [self showNotAllowed];
        self.segmentedControl.enabled = NO;
        self.btnDone.enabled = NO;
        self.btnCamera.enabled = NO;
        [self.btnTitle setTitle:NSLocalizedStringFromTable(@"Not Allowed", @"UzysAssetsPickerController",nil) forState:UIControlStateNormal];
        [self.btnTitle setImage:nil forState:UIControlStateNormal];
        
    };
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                      usingBlock:resultsBlock
                                    failureBlock:failureBlock];
}

- (void)setupAssets:(voidBlock)successBlock
{
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    if (!self.assets)
        self.assets = [[NSMutableArray alloc] init];
    else
        [self.assets removeAllObjects];
    
    if(!self.assetsGroup)
    {
        self.assetsGroup = self.groups[0];
    }
    [self.assetsGroup setAssetsFilter:self.assetsFilter];
    NSInteger assetCount = [self.assetsGroup numberOfAssets];
    ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if (asset)
        {
            [self.assets addObject:asset];
            
            NSString *type = [asset valueForProperty:ALAssetPropertyType];
            
            if ([type isEqual:ALAssetTypePhoto])
                self.numberOfPhotos ++;
            if ([type isEqual:ALAssetTypeVideo])
                self.numberOfVideos ++;
        }
        
        else if (self.assets.count >= assetCount)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadData];
                if(successBlock)
                    successBlock();
                
            });

        }
    };
    [self.assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:resultsBlock];
}
- (void)reloadData
{
    [self.collectionView reloadData];
    [self.btnDone setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)self.collectionView.indexPathsForSelectedItems
                            .count] forState:UIControlStateNormal];
    [self showNoAssetsIfNeeded];
}
- (void)setAssetsCountWithSelectedIndexPaths:(NSArray *)indexPaths
{
    [self.btnDone setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)indexPaths.count] forState:UIControlStateNormal];
}


- (void)showNotAllowed
{
    self.title              = nil;
    
    UIView *lockedView      = [[UIView alloc] initWithFrame:self.collectionView.bounds];
    UIImageView *locked     = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UzysAssetPickerController.bundle/uzysAP_ico_no_access"]];
    locked.contentMode      = UIViewContentModeCenter;
    
    CGRect rect             = CGRectInset(self.collectionView.bounds, 8, 8);
    UILabel *title          = [[UILabel alloc] initWithFrame:rect];
    UILabel *message        = [[UILabel alloc] initWithFrame:rect];
    
    title.text              = NSLocalizedStringFromTable(@"This app does not have access to your photos or videos.", @"UzysAssetsPickerController",nil);
    title.font              = [UIFont boldSystemFontOfSize:17.0];
    title.textColor         = [UIColor colorWithRed:129.0/255.0 green:136.0/255.0 blue:148.0/255.0 alpha:1];
    title.textAlignment     = NSTextAlignmentCenter;
    title.numberOfLines     = 5;
    
    message.text            = NSLocalizedStringFromTable(@"You can enable access in Privacy Settings.", @"UzysAssetsPickerController",nil);
    message.font            = [UIFont systemFontOfSize:14.0];
    message.textColor       = [UIColor colorWithRed:129.0/255.0 green:136.0/255.0 blue:148.0/255.0 alpha:1];
    message.textAlignment   = NSTextAlignmentCenter;
    message.numberOfLines   = 5;
    
    [title sizeToFit];
    [message sizeToFit];
    
    locked.center           = CGPointMake(lockedView.center.x, lockedView.center.y - locked.bounds.size.height /2 - 20);
    title.center            = locked.center;
    message.center          = locked.center;
    
    rect                    = title.frame;
    rect.origin.y           = locked.frame.origin.y + locked.frame.size.height + 10;
    title.frame             = rect;
    
    rect                    = message.frame;
    rect.origin.y           = title.frame.origin.y + title.frame.size.height + 5;
    message.frame           = rect;
    
    [lockedView addSubview:locked];
    [lockedView addSubview:title];
    [lockedView addSubview:message];
    [self.collectionView addSubview:lockedView];
}

- (void)showNoAssetsIfNeeded
{
    __weak typeof(self) weakSelf = self;
    
    voidBlock setNoImage = ^{
        UIImageView *imgView = (UIImageView *)[weakSelf.noAssetView viewWithTag:kTagNoAssetViewImageView];
        imgView.contentMode = UIViewContentModeCenter;
        imgView.image = [UIImage imageNamed:@"UzysAssetPickerController.bundle/uzysAP_ico_no_image"];
        
        UILabel *title = (UILabel *)[weakSelf.noAssetView viewWithTag:kTagNoAssetViewTitleLabel];
        title.text = NSLocalizedStringFromTable(@"No Photos", @"UzysAssetsPickerController",nil);
        UILabel *msg = (UILabel *)[weakSelf.noAssetView viewWithTag:kTagNoAssetViewMsgLabel];
        msg.text = NSLocalizedStringFromTable(@"You can sync photos onto your iPhone using iTunes.",@"UzysAssetsPickerController", nil);
    };
    voidBlock setNoVideo = ^{
        UIImageView *imgView = (UIImageView *)[weakSelf.noAssetView viewWithTag:kTagNoAssetViewImageView];
        imgView.image = [UIImage imageNamed:@"UzysAssetPickerController.bundle/uzysAP_ico_no_video"];
        NSLog(@"no video");
        UILabel *title = (UILabel *)[weakSelf.noAssetView viewWithTag:kTagNoAssetViewTitleLabel];
        title.text = NSLocalizedStringFromTable(@"No Videos", @"UzysAssetsPickerController",nil);
        UILabel *msg = (UILabel *)[weakSelf.noAssetView viewWithTag:kTagNoAssetViewMsgLabel];
        msg.text = NSLocalizedStringFromTable(@"You can sync videos onto your iPhone using iTunes.",@"UzysAssetsPickerController", nil);

    };
    
    if(self.assets.count ==0)
    {
        self.noAssetView.hidden = NO;
        if(self.segmentedControl.hidden == NO)
        {
            if(self.segmentedControl.selectedSegmentIndex ==0)
            {
                setNoImage();
            }
            else
            {
                setNoVideo();
            }
        }
        else
        {
            if(self.maximumNumberOfSelectionMedia >0)
            {
                UIImageView *imgView = (UIImageView *)[self.noAssetView viewWithTag:kTagNoAssetViewImageView];
                imgView.image = [UIImage imageNamed:@"UzysAssetPickerController.bundle/uzysAP_ico_no_image"];
                NSLog(@"no media");
                UILabel *title = (UILabel *)[self.noAssetView viewWithTag:kTagNoAssetViewTitleLabel];
                title.text = NSLocalizedStringFromTable(@"No Videos", @"UzysAssetsPickerController",nil);
                UILabel *msg = (UILabel *)[self.noAssetView viewWithTag:kTagNoAssetViewMsgLabel];
                msg.text = NSLocalizedStringFromTable(@"You can sync media onto your iPhone using iTunes.",@"UzysAssetsPickerController", nil);

            }
            else if(self.maximumNumberOfSelectionPhoto == 0)
            {
                setNoVideo();
            }
            else if(self.maximumNumberOfSelectionVideo == 0)
            {
                setNoImage();
            }
        }
    }
    else
    {
        self.noAssetView.hidden = YES;
    }
}


#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = kAssetsViewCellIdentifier;
    
    UzysAssetsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell applyData:[self.assets objectAtIndex:indexPath.row]];
    
    return cell;
}


#pragma mark - Collection View Delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return ([collectionView indexPathsForSelectedItems].count < self.maximumNumberOfSelection);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self setAssetsCountWithSelectedIndexPaths:collectionView.indexPathsForSelectedItems];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self setAssetsCountWithSelectedIndexPaths:collectionView.indexPathsForSelectedItems];
}


#pragma mark - Actions

- (void)finishPickingAssets
{
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems)
    {
        [assets addObject:[self.assets objectAtIndex:indexPath.item]];
    }
    
    if([assets count]>0)
    {
        UzysAssetsPickerController *picker = (UzysAssetsPickerController *)self;
        
        if([picker.delegate respondsToSelector:@selector(UzysAssetsPickerController:didFinishPickingAssets:)])
            [picker.delegate UzysAssetsPickerController:picker didFinishPickingAssets:assets];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}
#pragma mark - Notification

- (void)assetsLibraryUpdated:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //recheck here
        if([notification.name isEqualToString:ALAssetsLibraryChangedNotification])
        {
            NSDictionary* info = [notification userInfo];
            NSSet *updatedAssets = [info objectForKey:ALAssetLibraryUpdatedAssetsKey];
            NSSet *updatedAssetGroup = [info objectForKey:ALAssetLibraryUpdatedAssetGroupsKey];
            NSSet *deletedAssetGroup = [info objectForKey:ALAssetLibraryDeletedAssetGroupsKey];
            NSSet *insertedAssetGroup = [info objectForKey:ALAssetLibraryInsertedAssetGroupsKey];
            NSLog(@"updated assets:%@", updatedAssets);
            NSLog(@"updated asset group:%@", updatedAssetGroup);
            NSLog(@"deleted asset group:%@", deletedAssetGroup);
            NSLog(@"inserted asset group:%@", insertedAssetGroup);
            
            if(notification.userInfo == nil)
            {
                //AllClear
                [self setupGroup:nil withSetupAsset:YES];
                return;
            }
            if(insertedAssetGroup.count >0 || deletedAssetGroup.count > 0)
            {
                [self setupGroup:nil withSetupAsset:NO];
                return;
            }
            if(notification.userInfo.count == 0) {
                return;
            }
            
            if(updatedAssets.count  <2 && updatedAssetGroup.count ==0 && deletedAssetGroup.count == 0 && insertedAssetGroup.count == 0)
            {
                [self.assetsLibrary assetForURL:[updatedAssets allObjects][0] resultBlock:^(ALAsset *asset) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if([[[self.assets[0] valueForProperty:ALAssetPropertyAssetURL] absoluteString] isEqualToString:[[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString]])
                        {
                            NSIndexPath *newPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            [self.collectionView selectItemAtIndexPath:newPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                            [self setAssetsCountWithSelectedIndexPaths:self.collectionView.indexPathsForSelectedItems];
                        }
                        
                    });

                } failureBlock:nil];
                return;
            }
            NSMutableArray *selectedItems = [NSMutableArray array];
            NSArray *selectedPath = self.collectionView.indexPathsForSelectedItems;
            
            for (NSIndexPath *idxPath in selectedPath)
            {
                [selectedItems addObject:[self.assets objectAtIndex:idxPath.row]];
            }
            NSInteger beforeAssets = self.assets.count;
            [self setupAssets:^{
                for (ALAsset *item in selectedItems)
                {
                    for(ALAsset *asset in self.assets)
                    {
                        if([[[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString] isEqualToString:[[item valueForProperty:ALAssetPropertyAssetURL] absoluteString]])
                        {
                            NSUInteger idx = [self.assets indexOfObject:asset];
                            NSIndexPath *newPath = [NSIndexPath indexPathForRow:idx inSection:0];
                            [self.collectionView selectItemAtIndexPath:newPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                        }
                    }
                }
                [self setAssetsCountWithSelectedIndexPaths:self.collectionView.indexPathsForSelectedItems];
                if(self.assets.count > beforeAssets)
                {
                    [self.collectionView setContentOffset:CGPointMake(0, 0) animated:NO];
                }
            }];
        }
        
    });
}
#pragma mark - Property
- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    [self.btnTitle setTitle:title forState:UIControlStateNormal];
}
- (void)menuArrowRotate
{
    [UIView animateWithDuration:0.35 animations:^{
        if(self.groupPicker.isOpen)
        {
            self.btnTitle.imageView.transform = CGAffineTransformMakeRotation(M_PI);
        }
        else
        {
            self.btnTitle.imageView.transform = CGAffineTransformIdentity;
        }
    } completion:^(BOOL finished) {
    }];

}
#pragma mark - Control Action
- (IBAction)btnAction:(id)sender {

    UIButton *btn = (UIButton *)sender;
    
    switch (btn.tag) {
        case kTagButtonCamera:
        {
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                
                UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                      message:@"Device has no camera"
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil];
                [myAlertView show];
            }
            else
            {
//                [self initImagePicker];
                __weak typeof(self) weakSelf = self;
                [self presentViewController:self.picker animated:YES completion:^{
                    
                    if(![weakSelf.assetsGroup isEqual:weakSelf.groups[0]] )
                    {
                        weakSelf.assetsGroup = weakSelf.groups[0];
                        [weakSelf changeGroup:0 filter:weakSelf.assetsFilter];
                    }
                }];
            }
        }
            break;
        case kTagButtonClose:
        {
            if([self.delegate respondsToSelector:@selector(UzysAssetsPickerControllerDidCancel:)])
            {
                
            }
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
            break;
        case kTagButtonGroupPicker:
        {
            [self.groupPicker toggle];
            [self menuArrowRotate];
        }
            break;
        case kTagButtonDone:
            [self finishPickingAssets];
            break;
        default:
            break;
    }
}

- (IBAction)indexDidChangeForSegmentedControl:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    if(selectedSegment ==0)
    {
        [self changeAssetType:YES endBlock:nil];
    }
    else
    {
        [self changeAssetType:NO endBlock:nil];
    }
}


#pragma mark - UIImagerPickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __weak typeof(self) weakSelf = self;
    
    if (CFStringCompare((CFStringRef) [info objectForKey:UIImagePickerControllerMediaType], kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        if(self.segmentedControl.selectedSegmentIndex ==1)
        {
            self.segmentedControl.selectedSegmentIndex = 0;
            self.maximumNumberOfSelection = weakSelf.maximumNumberOfSelectionPhoto;
            if(self.segmentedControl.hidden ==NO)
                self.assetsFilter = [ALAssetsFilter allPhotos];
        }
            UIImage *image = info[UIImagePickerControllerOriginalImage];
            [self.assetsLibrary writeImageToSavedPhotosAlbum:image.CGImage metadata:info[UIImagePickerControllerMediaMetadata] completionBlock:^(NSURL *assetURL, NSError *error) {
                NSLog(@"writeImageToSavedPhotosAlbum");
            }];
    }
    else //
    {
        if(self.segmentedControl.selectedSegmentIndex ==0)
        {
            self.segmentedControl.selectedSegmentIndex = 1;
            self.maximumNumberOfSelection = self.maximumNumberOfSelectionVideo;
            if(self.segmentedControl.hidden ==NO)
                self.assetsFilter = [ALAssetsFilter allVideos];
        }
            [self.assetsLibrary writeVideoAtPathToSavedPhotosAlbum:info[UIImagePickerControllerMediaURL] completionBlock:^(NSURL *assetURL, NSError *error) {

            }];
    }
    [picker dismissViewControllerAnimated:YES completion:^{}];

    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UIViewController Property

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return nil;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

@end
