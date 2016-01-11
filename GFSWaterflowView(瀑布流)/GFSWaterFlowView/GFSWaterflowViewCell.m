//
//  GFSWaterflowViewCell.m
//  GFSWaterflowView（瀑布流）
//
//  Created by 管复生 on 16/1/11.
//  Copyright © 2016年 GFS. All rights reserved.
//

#import "GFSWaterflowViewCell.h"

@implementation GFSWaterflowViewCell

+ (instancetype)cellWithReusableIdentifier:(NSString *)identifier
{
    GFSWaterflowViewCell *cell = [[GFSWaterflowViewCell alloc]init];
    cell.identifier = identifier;
    return cell;
}

@end
