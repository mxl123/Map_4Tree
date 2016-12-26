//
//  MAShape.h
//  MAMapKit
//
//  Created by xiaoming han on 13-12-13.
//  Copyright (c) 2013年 xiaoming han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAAnnotation.h"

/*!
 @brief 该类为一个抽象类，定义了基于MAAnnotation的MAShape类的基本属性和行为，不能直接使用，必须子类化之后才能使用
 */
@interface MAShape : NSObject <MAAnnotation>

/*!
 @brief 标题
 */
@property (nonatomic, copy) NSString *title;

/*!
 @brief 副标题
 */
@property (nonatomic, copy) NSString *subtitle;

@end
