//
//  UzysGroupPickerView.m
//  UzysAssetsPickerController
//
//  Created by Uzysjung on 2014. 2. 13..
//  Copyright (c) 2014 Uzys. All rights reserved.
//


#import "UzysGroupPickerView.h"
#import "UzysGroupViewCell.h"
#import "UzysAssetsPickerController_Configuration.h"

#define BounceAnimationPixel 5
#define NavigationHeight 64
@implementation UzysGroupPickerView

- (id)initWithGroups:(NSMutableArray *)groups
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        // Initialization code
        self.groups = groups;
        [self setupLayout];
        [self setupTableView];
        [self addObserver:self forKeyPath:@"groups" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}
- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"groups"];
}

- (void)setupLayout
{
    CGSize screenSize = [self getScreenSize];
    self.frame = CGRectMake(0, - screenSize.height, screenSize.width,screenSize.height);
    self.layer.cornerRadius = 4;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor lightGrayColor];
    
}
- (void)setupTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavigationHeight, self.bounds.size.width, self.bounds.size.height -NavigationHeight) style:UITableViewStylePlain];
    self.tableView.contentInset = UIEdgeInsetsMake(1, 0, 0, 0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.rowHeight = kGroupPickerViewCellLength;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.tableView];
    
    
    self.tableView.backgroundColor = [UIColor redColor];
}
- (void)reloadData
{
    [self.tableView reloadData];
}
- (void)show
{
    CGSize screenSize = [self getScreenSize];
    
    [UIView animateWithDuration:0.4f delay:0.f options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.frame = CGRectMake(0, BounceAnimationPixel ,screenSize.width, screenSize.height);
    } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15f delay:0.f options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
                    self.frame = CGRectMake(0, 0 , screenSize.width, screenSize.height);
            } completion:^(BOOL finished) {
            }];
    }];
    self.isOpen = YES;
}
- (void)dismiss:(BOOL)animated
{
    CGSize screenSize = [self getScreenSize];
    if (!animated)
    {
        self.frame = CGRectMake(0, -screenSize.height, screenSize.width, screenSize.height );
    }
    else
    {
        [UIView animateWithDuration:0.4f animations:^{
            self.frame = CGRectMake(0, - screenSize.height, screenSize.width, screenSize.height);
        } completion:^(BOOL finished) {
        }];
    }
    self.isOpen = NO;

}
- (void)toggle
{
    if(self.frame.origin.y <0)
    {
        [self show];
    }
    else
    {
        [self dismiss:YES];
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"kGroupViewCellIdentifier";
    
    UzysGroupViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UzysGroupViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [cell applyData:[self.groups objectAtIndex:indexPath.row]];
    return cell;
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kGroupPickerViewCellLength;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.blockTouchCell)
        self.blockTouchCell(indexPath.row);
}

//by swy
-(CGSize)getScreenSize
{
    CGFloat screenW;
    CGFloat screenH;
    if (IOS_VERSION < 8.0) {
        screenW = [UIScreen mainScreen].bounds.size.height;
        screenH = [UIScreen mainScreen].bounds.size.width;
    }else{
        screenW = [UIScreen mainScreen].bounds.size.width;
        screenH = [UIScreen mainScreen].bounds.size.height;
    }
    return CGSizeMake(screenW, screenH);
}

@end
