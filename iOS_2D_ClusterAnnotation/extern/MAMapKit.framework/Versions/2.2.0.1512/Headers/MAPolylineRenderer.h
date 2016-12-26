//
//  MAPolylineRenderer.h
//  MAMapKit
//
//  Created by xiaoming han on 13-12-19.
//  Copyright (c) 2013年 xiaoming han. All rights reserved.
//

#import "MAOverlayPathRenderer.h"
#import "MAPolyline.h"

/*!
 @brief 此类是MAPolyline的显示多段线renderer,可以通过MAOverlayPathRenderer修改其fill和stroke attributes
 */
@interface MAPolylineRenderer : MAOverlayPathRenderer

/*!
 @brief 根据指定的MAPolyline生成一个多段线renderer
 @param polyline 指定MAPolyline
 @return 新生成的多段线renderer
 */
- (id)initWithPolyline:(MAPolyline *)polyline;

/*!
 @brief 关联的MAPolyline model
 */
@property (nonatomic, readonly) MAPolyline *polyline;

@end
