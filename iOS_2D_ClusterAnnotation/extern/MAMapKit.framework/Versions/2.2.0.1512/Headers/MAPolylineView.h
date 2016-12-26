//
//  MAPolylineView.h
//  MAMapKitNew
//
//  Created by 刘博 on 14-2-10.
//  Copyright (c) 2014年 xiaoming han. All rights reserved.
//

#import "MAOverlayPathView.h"
#import "MAPolyline.h"

/*!
 @brief 此类是MAPolyline的显示多段线View,可以通过MAOverlayPathView修改其fill和stroke attributes
 */
@interface MAPolylineView : MAOverlayPathView

/*!
 @brief 根据指定的MAPolyline生成一个多段线view
 @param polyline 指定MAPolyline
 @return 新生成的多段线view
 */
- (id)initWithPolyline:(MAPolyline *)polyline;

/*!
 @brief 关联的MAPolyline model
 */
@property (nonatomic, readonly) MAPolyline *polyline;

@end
