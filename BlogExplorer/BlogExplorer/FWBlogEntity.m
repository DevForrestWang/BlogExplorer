//
//  FWBlogEntity.m
//  BlogExplorer
//
//  Created by Forrest on 15-3-9.
//  Copyright (c) 2015年 Forrest. All rights reserved.
//

#import "FWBlogEntity.h"

@implementation FWBlogItemEntity

- (NSString *)description
{
    return [NSString stringWithFormat:@"%s, title:%@, url:%@", __FUNCTION__, _title, _url];
}

@end

@implementation FWBlogEntity

- (NSString *)description
{
    return [NSString stringWithFormat:@"%s, dataType:%lu, author:%@, baseURL:%@, archiveURL:%@, startFlag:%@, endFlag:%@, parseDom:%@, item:%@", __FUNCTION__, _dataType, _author, _baseURL, _archiveURL, _startFlag, _endFlag, _parseDom, _itemAry];
}

@end
