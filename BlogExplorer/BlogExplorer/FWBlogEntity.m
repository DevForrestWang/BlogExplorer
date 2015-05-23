//
//  FWBlogEntity.m
//  BlogExplorer
//
//  Created by Forrest on 15-3-9.
//  Copyright (c) 2015年 Forrest. All rights reserved.
//

#import "FWBlogEntity.h"

@implementation FWBlogItemEntity

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.url forKey:@"url"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%s, title:%@, url:%@", __FUNCTION__, _title, _url];
}

@end

@implementation FWBlogEntity

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.dataType forKey:@"dataType"];
    [aCoder encodeObject:self.author forKey:@"author"];
    [aCoder encodeObject:self.baseURL forKey:@"baseURL"];
    [aCoder encodeObject:self.archiveURL forKey:@"archiveURL"];
    [aCoder encodeObject:self.archiveURLAry forKey:@"archiveURLAry"];
    [aCoder encodeObject:self.startFlag forKey:@"startFlag"];
    [aCoder encodeObject:self.endFlag forKey:@"endFlag"];
    [aCoder encodeObject:self.parseDom forKey:@"parseDom"];
    [aCoder encodeObject:self.itemAry forKey:@"itemAry"];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.dataType = [aDecoder decodeIntegerForKey:@"dataType"];
        self.author = [aDecoder decodeObjectForKey:@"author"];
        self.baseURL = [aDecoder decodeObjectForKey:@"baseURL"];
        self.archiveURL = [aDecoder decodeObjectForKey:@"archiveURL"];
        self.archiveURLAry = [aDecoder decodeObjectForKey:@"archiveURLAry"];
        self.startFlag = [aDecoder decodeObjectForKey:@"startFlag"];
        self.endFlag = [aDecoder decodeObjectForKey:@"endFlag"];
        self.parseDom = [aDecoder decodeObjectForKey:@"parseDom"];
        self.itemAry = [aDecoder decodeObjectForKey:@"itemAry"];
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%s, dataType:%lu, author:%@, baseURL:%@, archiveURL:%@, _archiveURLAry:%@, startFlag:%@, endFlag:%@, parseDom:%@, item:%@", __FUNCTION__, _dataType, _author, _baseURL, _archiveURL, _archiveURLAry, _startFlag, _endFlag, _parseDom, _itemAry];
}

@end
