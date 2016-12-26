//
//  MAPointAnnotation.h
//  MAMapKit
//
//  Created by xiaoming han on 13-12-24.
//  Copyright (c) 2013年 xiaoming han. All rights reserved.
//

#import "MAShape.h"

/*!
 @brief 点标注数据
 */
@interface MAPointAnnotation : MAShape

/*!
 @brief 经纬度
 */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end
