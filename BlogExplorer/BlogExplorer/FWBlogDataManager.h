//
//  FWBlogDataManager.h
//  BlogExplorer
//
//  Created by Forrest on 15-3-9.
//  Copyright (c) 2015年 Forrest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FWBlogDataManager : NSObject

- (void)initURLData;
- (void)parseData:(BOOL)forceParse block:(void (^)(NSArray *blogAry))block;
- (void)saveData;
@end
