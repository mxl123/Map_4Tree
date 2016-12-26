//
//  ClusterAnnotationCalloutView.h
//  officialDemo2D
//
//  Created by yi chen on 14-5-21.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClusterAnnotationCalloutView : UIView <UITableViewDataSource>

@property (nonatomic, strong) NSArray * pois;
@property (nonatomic, strong) UITableView * tableView;

@end
