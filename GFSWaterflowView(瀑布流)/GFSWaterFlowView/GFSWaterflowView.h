//
//  GFSWaterflowView.h
//  GFSWaterflowView(瀑布流)
//
//  Created by 管复生 on 16/1/11.
//  Copyright © 2016年 GFS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kWaterViewMarginTypeTop, // cell顶部间距
    kWaterViewMarginTypeBottom, // cell底部间距
    kWaterViewMarginTypeLeft, // 左边屏幕间距
    kWaterViewMarginTypeRight, // 右边屏幕间距
    kWaterViewMarginTypeColum,// 每一列
    kWaterViewMarginTypeRow,// 每一行
} GFSWaterflowViewMarginType;


@class GFSWaterflowView,GFSWaterflowViewCell;

/**
 *  数据源方法
 */
@protocol GFSWaterflowViewDataSource <NSObject>
@required
/**
 *  一共有多少个数据
 */
- (NSUInteger)numberOfCellsInWaterflowView:(GFSWaterflowView *)waterflowView;
/**
 *  返回index位置对应的cell
 */
- (GFSWaterflowViewCell *)waterflowView:(GFSWaterflowView *)waterflowView cellAtIndex:(NSInteger)index;

@optional
/**
 *  一共有多少列
 */
- (NSUInteger)numberOfColumsInWaterflowView:(GFSWaterflowView *)waterflowView;
@end

/**
 *  代理方法
 */
@protocol GFSWaterflowViewDelegate <UIScrollViewDelegate>

@optional
/**
 *  第index位置cell对应的高度
 */
- (CGFloat)waterflowView:(GFSWaterflowView *)waterflowView heightForCellAtIndex:(NSUInteger)index;
/**
 *  选中第index位置的cell
 */
- (void)waterflowView:(GFSWaterflowView *)waterflowView didSelectCellAtIndex:(NSUInteger)index;
/**
 *  返回间距
 */
- (CGFloat)waterflowView:(GFSWaterflowView *)waterflowView marginForType:(GFSWaterflowViewMarginType)marginType;
@end

@interface GFSWaterflowView : UIScrollView
@property(nonatomic,weak)id<GFSWaterflowViewDataSource> dataSource;
@property(nonatomic,weak)id<GFSWaterflowViewDelegate> delegate;
/**
 *  刷新数据（只要调用这个方法，会重新向数据源和代理发送请求，请求数据）
 */
- (void)reloadData;
/**
 *  cell的宽度
 */
- (CGFloat)cellWidth;
/**
 *  根据标识去缓存池查找可循环利用的cell
 */
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;
@end
