//
//  GFSWaterflowView.m
//  GFSWaterflowView(瀑布流)
//
//  Created by 管复生 on 16/1/11.
//  Copyright © 2016年 GFS. All rights reserved.
//

#import "GFSWaterflowView.h"
#import "GFSWaterflowViewCell.h"

#define GFSWaterflowViewDefaultNumberOfColums 3
#define GFSWaterflowViewDefaultMargin 7
#define GFSWaterflowViewDefaultCellHeight 70
@interface GFSWaterflowView()
/**
 *  所有cell的frame数据
 */
@property(nonatomic,strong)NSMutableArray *cellFrames;
/**
 *  正在展示的cell
 */
@property(nonatomic,strong)NSMutableDictionary *displayingCells;
/**
 *  缓存池（用Set无序，存放离开屏幕的cell）
 */
@property(nonatomic,strong)NSMutableSet *reusableCells;
@end
@implementation GFSWaterflowView

#pragma mark 初始化
- (NSMutableArray *)cellFrames
{
    if (!_cellFrames) {
        _cellFrames = [NSMutableArray array];
    }
    return _cellFrames;
}
- (NSMutableDictionary *)displayingCells
{
    if (!_displayingCells) {
        _displayingCells = [[NSMutableDictionary alloc]init];
    }
    return _displayingCells;
}
- (NSMutableSet *)reusableCells
{
    if (!_reusableCells) {
        _reusableCells = [NSMutableSet set];
    }
    return _reusableCells;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
/**
 *  即将加载到父控制器时调用
 */
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self reloadData];
}
#pragma mark 接口实现
/**
 *  cell的宽度(可通过宽度同比计算高度)
 */
- (CGFloat)cellWidth
{
    long int totalColums = [self numberOfColums];
    CGFloat leftW = [self marginForType:kWaterViewMarginTypeLeft];
    CGFloat rightW = [self marginForType:kWaterViewMarginTypeRight];
    CGFloat columnMargin = [self marginForType:kWaterViewMarginTypeColum];
    return ([UIScreen mainScreen].bounds.size.width - leftW - rightW - (totalColums - 1)*columnMargin)/totalColums ;
}
/**
 *  刷新数据
 */
- (void)reloadData
{
    // 清除之前现实的数据
    [self.displayingCells.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.displayingCells removeAllObjects];
    [self.reusableCells removeAllObjects];
    [self.cellFrames removeAllObjects];
    
    // 新建数据
    long int totalCells = [self.dataSource numberOfCellsInWaterflowView:self];
    long int totalColumns = [self numberOfColums];
    // 间距
    CGFloat leftW = [self marginForType:kWaterViewMarginTypeLeft];
//    CGFloat rightW = [self marginForType:kWaterViewMarginTypeRight];
    CGFloat columnMargin = [self marginForType:kWaterViewMarginTypeColum];
    CGFloat bottomH = [self marginForType:kWaterViewMarginTypeBottom];
    CGFloat rowMargin = [self marginForType:kWaterViewMarginTypeRow];
    CGFloat topH = [self marginForType:kWaterViewMarginTypeTop];
    // cell的宽度
    CGFloat cellW = [self cellWidth];
    
    // 利用一个数组存放所有列最大Y值
    CGFloat maxYOfColumns[totalColumns];
    for (int i = 0 ; i< totalColumns; i++) {
        maxYOfColumns[i] = 0.0;//初始化
    }
    // 计算所有cell的frame
    for (int i = 0; i< totalCells; i++) {
        NSUInteger cellColumn = 0;
        // cell所处列的最大Y值
        CGFloat maxYOfCellColumn = maxYOfColumns[cellColumn];
        for (int j = 1; j< totalColumns; j++) {
            // 获取那一列
            if (maxYOfCellColumn > maxYOfColumns[j]) {
                cellColumn = j;
                maxYOfCellColumn = maxYOfColumns[j];
            }
        }
        // i位置的cell高度
        CGFloat cellH = [self cellHeightAtIndex:i];
        // cell的位置
        CGFloat cellX = leftW + cellColumn*(cellW + columnMargin);
        
        CGFloat cellY = 0;
        if (maxYOfCellColumn == 0) {// 第0行
            cellY = topH;
        }else{
            cellY = maxYOfCellColumn + rowMargin;
        }
        CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
        [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
        // 更新最后一行的y值
        maxYOfColumns[cellColumn] = CGRectGetMaxY(cellFrame);
        
    }
    // 设置contentSize
    CGFloat contentH = maxYOfColumns[0];
    for (int i = 1; i<totalColumns; i++) {
        if (contentH < maxYOfColumns[i]) {
            contentH = maxYOfColumns[i];
        }
    }
    contentH += bottomH;
    self.contentSize = CGSizeMake(0, contentH);
}
/**
 *  当UIScrollView滚动的时候也会调用这个方法
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    // 从数据源获取对应的cell
    NSUInteger totalCell = self.cellFrames.count;
    
    for (int i = 0; i< totalCell; i++) {
        //取出对应位置的cellFrame
        CGRect cellFrame = [self.cellFrames[i] CGRectValue];
        
        // 优先从字典中取出对应位置的cell
        GFSWaterflowViewCell *cell = self.displayingCells[@(i)];
        
        if ([self isInScreen:cellFrame]) {// 在屏幕上
            if (cell == nil) {
                cell = [self.dataSource waterflowView:self cellAtIndex:i];
                cell.frame = cellFrame;
                
                [self addSubview:cell];
                // 添加到字典
                self.displayingCells[@(i)] = cell;
            }
        }else{// 不在屏幕上
            if (cell) {
                [cell removeFromSuperview];
                [self.displayingCells removeObjectForKey:@(i)];
                // 放进缓存池
                [self.reusableCells addObject:cell];
            }
        }
    }
}
/**
 *  取出缓存中的cell
 *
 */
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    __block GFSWaterflowViewCell *reusablecell = nil;
    [self.reusableCells enumerateObjectsUsingBlock:^(GFSWaterflowViewCell *cell, BOOL * _Nonnull stop) {
        if ([cell.identifier isEqualToString:identifier]) {
            reusablecell = cell;
            *stop = YES;
        }
    }];
    if (reusablecell) {// 从缓存池中移除
        [self.reusableCells removeObject:reusablecell];
    }
    return reusablecell;
}
#pragma mark 私有方法
- (BOOL)isInScreen:(CGRect)frame
{
    return (CGRectGetMaxY(frame) > self.contentOffset.y) && (CGRectGetMaxY(frame)< (self.contentOffset.y + self.bounds.size.height));
}
/**
 *  列数
 */
- (NSUInteger)numberOfColums
{
    if ([self.dataSource respondsToSelector:@selector(numberOfColumsInWaterflowView:)]) {
        return [self.dataSource numberOfColumsInWaterflowView:self];
    }else{
        // 如果代理未实现 返回默认值
        return GFSWaterflowViewDefaultNumberOfColums;
    }
}
/**
 *  间距
 */
- (CGFloat)marginForType:(GFSWaterflowViewMarginType)type
{
    if ([self.delegate respondsToSelector:@selector(waterflowView:marginForType:)]) {
        return [self.delegate waterflowView:self marginForType:type];
    }else{
        // 如果代理未实现 返回默认值
        return GFSWaterflowViewDefaultMargin;
    }
}
/**
 *  index位置对应高度
 */
- (CGFloat)cellHeightAtIndex:(NSUInteger)index
{
    if ([self.delegate respondsToSelector:@selector(waterflowView:heightForCellAtIndex:)]) {
       return  [self.delegate waterflowView:self heightForCellAtIndex:index];
    }else{
        return GFSWaterflowViewDefaultCellHeight;
    }
}
#pragma mark 点击事件
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (![self.delegate respondsToSelector:@selector(waterflowView:didSelectCellAtIndex:)]) {
        return;
    }
    // 获得触摸点
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    __block NSNumber *selectIndex = nil;
    [self.displayingCells enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, GFSWaterflowViewCell *cell, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(cell.frame, point)) {
            selectIndex = key;
            *stop = YES;
        }
    }];
    if (selectIndex) {
        [self.delegate waterflowView:self didSelectCellAtIndex:[selectIndex unsignedIntegerValue]];
    }
}
@end
