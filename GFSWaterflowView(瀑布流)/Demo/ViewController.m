//
//  ViewController.m
//  GFSWaterflowView(瀑布流)
//
//  Created by 管复生 on 16/1/11.
//  Copyright © 2016年 GFS. All rights reserved.
//

#import "ViewController.h"
#import "GFSWaterflowView.h"
#import "GFSWaterflowViewCell.h"
@interface ViewController ()<GFSWaterflowViewDataSource,GFSWaterflowViewDelegate>
@property(nonatomic,weak)GFSWaterflowView *waterflowView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GFSWaterflowView *waterflowView = [[GFSWaterflowView alloc]init];
    
    
    waterflowView.delegate  = self;
    waterflowView.dataSource = self;
    waterflowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    waterflowView.frame = self.view.bounds;
    [self.view addSubview:waterflowView];
    self.waterflowView = waterflowView;
}
#pragma mark 数据源方法
- (NSUInteger)numberOfCellsInWaterflowView:(GFSWaterflowView *)waterflowView
{
    return 50;
}
- (GFSWaterflowViewCell *)waterflowView:(GFSWaterflowView *)waterflowView cellAtIndex:(NSInteger)index
{
    static NSString *ID = @"cell";
    
    GFSWaterflowViewCell *cell = [waterflowView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [GFSWaterflowViewCell cellWithReusableIdentifier:ID];
    }
    cell.backgroundColor = GFSRandomColor;
    [cell addSubview:[UIButton buttonWithType:UIButtonTypeContactAdd]];
    
    UILabel *label = [[UILabel alloc] init];
    label.tag = 10;
    label.frame = CGRectMake(0, 0, 50, 20);
    [cell addSubview:label];
    UILabel *currentLabel = (UILabel *)[cell viewWithTag:10];
    currentLabel.text = [NSString stringWithFormat:@"%ld", index];
    
//    NSLog(@"%ld %p", index, cell);
    return cell;
}
#pragma mark 代理方法
- (CGFloat)waterflowView:(GFSWaterflowView *)waterflowView heightAtIndex:(NSUInteger)index
{
    switch (index % 3) {
        case 0: return 70;
        case 1: return 100;
        case 2: return 90;
        default: return 110;
    }
}
- (void)waterflowView:(GFSWaterflowView *)waterflowView didSelectCellAtIndex:(NSUInteger)index
{
    NSLog(@"点击了第%ld个cell", index);
}
@end
