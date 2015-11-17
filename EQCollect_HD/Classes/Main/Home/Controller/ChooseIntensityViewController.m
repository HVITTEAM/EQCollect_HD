//
//  ChooseIntensityViewController.m
//  EQCollect_HD
//
//  Created by shi on 15/11/13.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import "ChooseIntensityViewController.h"
#import "ChooseIntensityCell.h"

@interface ChooseIntensityViewController ()
@property(nonatomic,strong)NSArray *dataProvider;
@end

@implementation ChooseIntensityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.title = @"选择烈度";
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationItem.title = @"选择烈度";
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

+(instancetype)sharedInstance
{
    static ChooseIntensityViewController *chooseIntensityViewController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        chooseIntensityViewController = [[ChooseIntensityViewController alloc] init];

    });
    return chooseIntensityViewController;
}

-(NSArray *)dataProvider
{
    if (!_dataProvider) {
        _dataProvider = @[@{@"intensity":@"Ⅰ",
                            @"feel":@"无感",
                            @"damage":@"无",
                            @"other":@"无"
                              },
                          @{@"intensity":@"Ⅱ",
                            @"feel":@"室内个别静止中的人有感觉",
                            @"damage":@"无",
                            @"other":@"无"
                            },
                          @{@"intensity":@"Ⅲ",
                            @"feel":@"室内少数静止中的人有感觉",
                            @"damage":@"门、窗轻微作响",
                            @"other":@"悬挂物微动"
                            },
                          @{@"intensity":@"Ⅳ",
                            @"feel":@"室内多少人有感觉,室外少数人有感觉,少数人梦中惊醒",
                            @"damage":@"门、窗作响",
                            @"other":@"不稳定器物翻倒"
                            },
                          @{@"intensity":@"Ⅴ",
                            @"feel":@"室内普遍有感觉,室外多数人有感觉,多数人梦中惊醒",
                            @"damage":@"门客、屋顶、屋架颤动作响，灰土掉落，抹灰出现微细裂缝",
                            @"other":@"无"
                            },
                          @{@"intensity":@"Ⅵ",
                            @"feel":@"惊慌失措，仓惶逃出",
                            @"damage":@"损坏--个别砖瓦掉落、墙体微细裂缝",
                            @"other":@"河岸和松软土上出现裂缝,饱和砂层出现喷砂冒水。地面上有的砖烟囱轻度裂缝、掉头"
                            },
                          @{@"intensity":@"Ⅶ",
                            @"feel":@"大多数人仓惶逃出",
                            @"damage":@"轻度破坏--局部破坏、开裂，但不妨碍使用",
                            @"other":@"河岸出现坍方。饱和砂层常见喷砂冒水。松软土上地裂缝较多。大多数砖烟囱中等破坏"
                            },
                          @{@"intensity":@"Ⅷ",
                            @"feel":@"摇晃颠簸，行走困难",
                            @"damage":@"中等破坏--结构受损，需要修理",
                            @"other":@"干硬土上亦有裂缝。大多数砖烟囱严重破坏"
                            },
                          @{@"intensity":@"Ⅸ",
                            @"feel":@"干硬土上亦有裂缝,大多数砖烟囱严重破坏",
                            @"damage":@"严重破坏--墙体龟裂，局部倒塌，复修困难",
                            @"other":@"干硬土上有许多地方出现裂缝，基岩上可能出现裂缝。滑坡、坍方常见。砖烟囱出现倒塌"
                            },
                          @{@"intensity":@"Ⅹ",
                            @"feel":@"骑自行车的人会摔倒,处于不稳状态的人会掉出几尺远,有抛起感",
                            @"damage":@"倒塌--大部倒塌，不堪修复",
                            @"other":@"山崩和地震断裂出现。基岩上的拱桥破坏。大多数砖烟囱从根部破坏或倒毁"
                            },
                          @{@"intensity":@"Ⅺ",
                            @"feel":@"无",
                            @"damage":@"毁灭",
                            @"other":@"地震断裂延续很长。山崩常见。基岩上拱桥毁坏"
                            },
                          @{@"intensity":@"Ⅻ",
                            @"feel":@"无",
                            @"damage":@"无",
                            @"other":@"地面剧烈变化，山河改观"
                            }
                          ];
    }
    return _dataProvider;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataProvider.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = self.dataProvider[indexPath.row];
    ChooseIntensityCell *cell = [ChooseIntensityCell cellWithTableView:tableView model:dict];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = self.dataProvider[indexPath.row];
    CGFloat h = [ChooseIntensityCell heightForCell:dict];
    return h;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(viewController:selectedIntensity:)]) {
        
        NSString *romeNUm = [self switchNumToRomeNumWithNum:indexPath.row];
        
        [self.delegate viewController:self selectedIntensity:romeNUm];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(NSString *)switchNumToRomeNumWithNum:(NSInteger)num
{
    NSArray *romes = @[@"Ⅰ",@"Ⅱ",@"Ⅲ",@"Ⅳ",@"Ⅴ",@"Ⅵ",@"Ⅶ",@"Ⅷ",@"Ⅸ",@"Ⅹ",@"Ⅺ",@"Ⅻ"];
    return romes[num];
}

-(void)back
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
