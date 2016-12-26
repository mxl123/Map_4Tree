//
//  ClusterAnnotationView.h
//  officialDemo2D
//
//  Created by yi chen on 14-5-15.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>
#import "ClusterAnnotationCalloutView.h"


@interface ClusterAnnotationView : MAAnnotationView

@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, strong) ClusterAnnotationCalloutView *calloutView;
@property (nonatomic, strong) id<UITableViewDelegate> responseDelegate;

@end
