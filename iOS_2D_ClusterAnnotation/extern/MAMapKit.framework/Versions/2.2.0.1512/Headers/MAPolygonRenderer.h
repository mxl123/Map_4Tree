//
//  MAPolygonRenderer.h
//  MAMapKit
//
//  Created by xiaoming han on 13-12-19.
//  Copyright (c) 2013年 xiaoming han. All rights reserved.
//

#import "MAOverlayPathRenderer.h"
#import "MAPolygon.h"

/*!
 @brief 此类是MAPolygon的显示多边形Renderer,可以通过MAOverlayPathRenderer修改其fill和stroke attributes
 */
@interface MAPolygonRenderer : MAOverlayPathRenderer

/*!
 @brief 根据指定的多边形生成一个多边形renderer
 @param polygon 指定的多边形数据对象
 @return 新生成的多边形renderer
 */
- (id)initWithPolygon:(MAPolygon *)polygon;

/*!
 @brief 关联的MAPolygon model
 */
@property (nonatomic, readonly) MAPolygon *polygon;

@end
