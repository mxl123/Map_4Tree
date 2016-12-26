//
//  AnnotationClusterViewController.m
//  officialDemo2D
//
//  Created by yi chen on 14-5-15.
//  Copyright (c) 2014年 . All rights reserved.
//

#import "AnnotationClusterViewController.h"
#import "PoiDetailViewController.h"
#import "CoordinateQuadTree.h"
#import "ClusterAnnotation.h"
#import "ClusterAnnotationView.h"

#define kCalloutViewMargin -8

@interface AnnotationClusterViewController ()<UITableViewDelegate>

@property (nonatomic, strong) CoordinateQuadTree* coordinateQuadTree;

@property (nonatomic, strong) ClusterAnnotation* activeAnnotation;

@end

@implementation AnnotationClusterViewController

#pragma mark - update Annotation

/* 更新annotation. */
- (void)updateMapViewAnnotationsWithAnnotations:(NSArray *)annotations
{
    /* 用户滑动时，保留仍然可用的标注，去除屏幕外标注，添加新增区域的标注 */
    NSMutableSet *before = [NSMutableSet setWithArray:self.mapView.annotations];
    [before removeObject:[self.mapView userLocation]];
    NSSet *after = [NSSet setWithArray:annotations];
    
    /* 保留仍然位于屏幕内的annotation. */
    NSMutableSet *toKeep = [NSMutableSet setWithSet:before];
    [toKeep intersectSet:after];
    
    /* 需要添加的annotation. */
    NSMutableSet *toAdd = [NSMutableSet setWithSet:after];
    [toAdd minusSet:toKeep];
    
    /* 删除位于屏幕外的annotation. */
    NSMutableSet *toRemove = [NSMutableSet setWithSet:before];
    [toRemove minusSet:after];
    
    /* 更新. */
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView addAnnotations:[toAdd allObjects]];
        [self.mapView removeAnnotations:[toRemove allObjects]];
    });
}

- (void)addAnnotationsToMapView:(MAMapView *)mapView
{
    NSLog(@"calculate annotations.");
    if (self.coordinateQuadTree.root == nil)
    {
        NSLog(@"tree is not ready.");
        return;
    }

    /* 根据当前zoomLevel和zoomScale 进行annotation聚合. */
    double zoomScale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;

    NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:mapView.visibleMapRect
                                                                        withZoomScale:zoomScale
                                                                         andZoomLevel:mapView.zoomLevel];
    /* 更新annotation. */
    [self updateMapViewAnnotationsWithAnnotations:annotations];
}

/* annotation弹出的动画. */
- (void)addBounceAnnimationToView:(UIView *)view
{
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    bounceAnimation.values = @[@(0.05), @(1.1), @(0.9), @(1)];
    bounceAnimation.duration = 0.6;
    
    NSMutableArray *timingFunctions = [[NSMutableArray alloc] initWithCapacity:bounceAnimation.values.count];
    for (NSUInteger i = 0; i < bounceAnimation.values.count; i++)
    {
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    }
    [bounceAnimation setTimingFunctions:timingFunctions.copy];
    
    bounceAnimation.removedOnCompletion = NO;
    
    [view.layer addAnimation:bounceAnimation forKey:@"bounce"];
}

#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    /* mapView区域变化时重算annotation. */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self addAnnotationsToMapView:self.mapView];
    });

}

- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    id<MAAnnotation> annotation = view.annotation;
    
    if ([annotation isKindOfClass:[ClusterAnnotation class]])
    {
        ClusterAnnotation *clusterAnnotation = (ClusterAnnotation*)annotation;
        
        PoiDetailViewController *detail = [[PoiDetailViewController alloc] init];
        detail.poi = [clusterAnnotation.pois lastObject];
        
        /* 进入POI详情页面. */
        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[ClusterAnnotation class]])
    {
        /* dequeue重用annotationView. */
        static NSString *const AnnotatioViewReuseID = @"AnnotatioViewReuseID";
        
        ClusterAnnotationView *annotationView = (ClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotatioViewReuseID];
        
        if (!annotationView)
        {
            annotationView = [[ClusterAnnotationView alloc] initWithAnnotation:annotation
                                                               reuseIdentifier:AnnotatioViewReuseID];
        }
        
        /* 设置annotationView的属性. */
        annotationView.annotation = annotation;
        annotationView.annotation = annotation;
        annotationView.canShowCallout = NO;
        annotationView.count = [(ClusterAnnotation *)annotation count];
        /* 设置calloutTableView的delegate. */
        annotationView.responseDelegate = self;
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    /* 为新添的annotationView添加弹出动画. */
    for (UIView *view in views)
    {
        [self addBounceAnnimationToView:view];
    }
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    if ([view isKindOfClass:[ClusterAnnotationView class]]) {
        
        ClusterAnnotationView *clusterView = (ClusterAnnotationView *)view;
        
        /* 记录当前选中的annotation. */
        self.activeAnnotation = (ClusterAnnotation *)view.annotation;
        
        /* 调整地图中心以便完整地显示calloutView. */
//        [self.mapView setCenterCoordinate:self.activeAnnotation.coordinate animated:YES];

        CGRect frame = [clusterView convertRect:clusterView.calloutView.frame toView:self.mapView];
        
        frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(kCalloutViewMargin, kCalloutViewMargin, kCalloutViewMargin, kCalloutViewMargin));
        
        if (!CGRectContainsRect(self.mapView.frame, frame))
        {
            /* 计算地图中心偏移量. */
            CGSize offset = [self offsetToContainRect:frame inRect:self.mapView.frame];
            
            CGPoint theCenter = self.mapView.center;
            theCenter = CGPointMake(theCenter.x - offset.width, theCenter.y - offset.height);
            
            CLLocationCoordinate2D coordinate = [self.mapView convertPoint:theCenter toCoordinateFromView:self.mapView];
            
            [self.mapView setCenterCoordinate:coordinate animated:YES];
        }

    }
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PoiDetailViewController *detail = [[PoiDetailViewController alloc] init];
    detail.poi = self.activeAnnotation.pois[indexPath.row];
    
    /* 进入POI详情页面. */
    [self.navigationController pushViewController:detail animated:YES];
    
}

#pragma mark - SearchPOI

/* 搜索POI. */
- (void)searchPoiWithKeyword:(NSString *)keyword
{
    AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
    
    request.searchType          = AMapSearchType_PlaceKeyword;
    request.keywords            = keyword;
    request.city                = @[@"010"];
    request.requireExtension    = YES;
    request.offset = 100;
    request.page = 10;
    
    [self.search AMapPlaceSearch:request];
}

/* POI 搜索回调. */
- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)respons
{
    if (respons.pois.count == 0)
    {
        return;
    }

    NSLog(@"response pois %d", [respons.pois count]);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        /* 建立四叉树. */
        [self.coordinateQuadTree buildTreeWithPOIs:respons.pois];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            /* 建树完成，计算当前mapView区域内需要显示的annotation. */
            NSLog(@"First time calculate annotations.");
            [self addAnnotationsToMapView:self.mapView];

        });
    });
    
    /* 如果只有一个结果，设置其为中心点. */
    if (respons.pois.count == 1)
    {
        self.mapView.centerCoordinate = [respons.pois[0] coordinate];
    }
    /* 如果有多个结果, 设置地图使所有的annotation都可见. */
    else
    {
        [self.mapView showAnnotations:self.mapView.annotations animated:NO];
    }
}

/*!
 计算outerRect为了包含innerRect需要偏移的量
 @param innerRect
 @param outerRect
 @return outerRect的偏移量
 */
- (CGSize)offsetToContainRect:(CGRect)innerRect inRect:(CGRect)outerRect
{
    CGFloat nudgeRight  = fmaxf(0, CGRectGetMinX(outerRect) - (CGRectGetMinX(innerRect)));
    CGFloat nudgeLeft   = fminf(0, CGRectGetMaxX(outerRect) - (CGRectGetMaxX(innerRect)));
    CGFloat nudgeTop    = fmaxf(0, CGRectGetMinY(outerRect) - (CGRectGetMinY(innerRect)));
    CGFloat nudgeBottom = fminf(0, CGRectGetMaxY(outerRect) - (CGRectGetMaxY(innerRect)));
    
    return CGSizeMake(nudgeLeft ?: nudgeRight, nudgeTop ?: nudgeBottom);
}

#pragma mark - Life Cycle

- (id)init
{
    if (self = [super init])
    {
        self.coordinateQuadTree = [[CoordinateQuadTree alloc] init];
        
        [self setTitle:@"Cluster Annotations"];
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self searchPoiWithKeyword:@"Apple"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self.coordinateQuadTree clean];
}

@end
