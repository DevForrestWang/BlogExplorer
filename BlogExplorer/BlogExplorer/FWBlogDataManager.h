//
//  FWBlogDataManager.h
//  BlogExplorer
//
//  Created by Forrest on 15-3-9.
//  Copyright (c) 2015年 Forrest. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FWBlogStatisticsEntity;

typedef void(^BlogStatisticsBlock) (FWBlogStatisticsEntity *statisticsData);

@interface FWBlogDataManager : NSObject

- (void)initURLData;
- (void)loadLocalData:(void (^)(NSArray *blogAry))block;
- (void)parseData:(BOOL)forceParse block:(void (^)(NSArray *blogAry))block;
- (void)loadStatusData:(BlogStatisticsBlock)block;

@end
