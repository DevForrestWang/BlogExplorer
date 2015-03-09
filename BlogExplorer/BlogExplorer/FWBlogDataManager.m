//
//  FWBlogDataManager.m
//  BlogExplorer
//
//  Created by Forrest on 15-3-9.
//  Copyright (c) 2015年 Forrest. All rights reserved.
//

#import "FWBlogDataManager.h"

@interface FWBlogDataManager ()

@property (nonatomic, strong) NSMutableArray *urlAry;
@property (nonatomic, strong) NSMutableArray *parseDataAry;

@end

@implementation FWBlogDataManager

- (id) init
{
    self = [super init];
    if (self) {
        _urlAry = [NSMutableArray array];
        _parseDataAry = [NSMutableArray array];
    }
    
    return self;
}

- (void)initBaseData
{
    
}

- (void)parseData:(BOOL)parseAgain
{
    [self parseBaseData];
    [self parsePageData];
}

- (void)readData:(void (^)(NSArray *array))blog
{
    
}

- (void)saveData
{
}

#pragma mark - Private method
- (void)parseBaseData
{
}

- (void)parsePageData
{
}

@end
