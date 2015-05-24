//
//  FWBlogStatisticsEntity.m
//  BlogExplorer
//
//  Created by Allison on 15/5/24.
//
//

#import "FWBlogStatisticsEntity.h"

@implementation FWBlogStatisticsEntity

- (NSString *) description {
    return [NSString stringWithFormat:@"%s, authorNumber:%ld, blogNumber:%.0f, sucessedNumber:%.0f, errorNumber:%.0f, errorAuthor:%@", __FUNCTION__, _authorNumber, _blogNumber, _sucessedNumber, _errorNumber, _errorAuthor];
}

@end

