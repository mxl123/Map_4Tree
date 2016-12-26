//
//  ClusterAnnotationCalloutView.m
//  officialDemo2D
//
//  Created by yi chen on 14-5-21.
//  Copyright (c) 2014年 . All rights reserved.
//

#import "ClusterAnnotationCalloutView.h"
#import <AMapSearchKit/AMapCommonObj.h>

#define kArrorHeight    10

@interface ClusterAnnotationCalloutView()

@end

@implementation ClusterAnnotationCalloutView

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.pois count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    AMapPOI * poi = self.pois[indexPath.row];
    
    cell.textLabel.text = poi.name;
    cell.textLabel.textColor = [UIColor blackColor];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", poi.address, poi.tel];
    cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    return cell;
}

#pragma mark - Initialization

- (void)initTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.bounds.origin.x
                                                                   , self.bounds.origin.y
                                                                   , self.bounds.size.width
                                                                   , self.bounds.size.height - kArrorHeight)];
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = YES;
    self.tableView.backgroundColor = [UIColor clearColor];

    [self addSubview:self.tableView];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        [self initTableView];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - draw rect

- (void)drawRect:(CGRect)rect
{
    [self drawInContext:UIGraphicsGetCurrentContext()];
}

- (void)drawInContext:(CGContextRef)context
{
    CGContextSetLineWidth(context, 0.25);
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.8].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    
    [self getDrawPath:context];
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)getDrawPath:(CGContextRef)context
{
    CGRect rrect = self.bounds;
    CGFloat radius = 8.0;
    CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect),
    maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect),
    maxy = CGRectGetMaxY(rrect)-kArrorHeight;
    
    CGContextMoveToPoint(context, midx+kArrorHeight, maxy);
    CGContextAddLineToPoint(context,midx, maxy+kArrorHeight);
    CGContextAddLineToPoint(context,midx-kArrorHeight, maxy);
    
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextClosePath(context);
}

@end
