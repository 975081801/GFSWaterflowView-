//
//  GFSWaterflowViewCell.h
//  GFSWaterflowView（瀑布流）
//
//  Created by 管复生 on 16/1/11.
//  Copyright © 2016年 GFS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GFSWaterflowViewCell : UIView
/**
 *  标识
 */
@property(nonatomic,copy)NSString *identifier;
+ (instancetype)cellWithReusableIdentifier:(NSString *)identifier;
@end
