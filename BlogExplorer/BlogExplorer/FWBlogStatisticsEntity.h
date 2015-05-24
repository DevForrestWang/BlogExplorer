//
//  FWBlogStatisticsEntity.h
//  BlogExplorer
//
//  Created by Allison on 15/5/24.
//
//

#import <Foundation/Foundation.h>

@interface FWBlogStatisticsEntity : NSObject

@property (nonatomic, assign) NSInteger authorNumber;
@property (nonatomic, assign) CGFloat blogNumber;
@property (nonatomic, assign) CGFloat sucessedNumber;
@property (nonatomic, assign) CGFloat errorNumber;
@property (nonatomic, strong) NSArray *errorAuthor;

@end
