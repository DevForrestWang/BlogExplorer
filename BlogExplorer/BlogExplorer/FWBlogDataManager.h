//
//  FWBlogDataManager.h
//  BlogExplorer
//
//  Created by Forrest on 15-3-9.
//  Copyright (c) 2015年 Forrest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FWBlogDataManager : NSObject

- (void)initBaseData;
- (void)parseData:(BOOL)parseAgain;
- (void)readData:(void (^)(NSArray *array))blog;
- (void)saveData;
@end
