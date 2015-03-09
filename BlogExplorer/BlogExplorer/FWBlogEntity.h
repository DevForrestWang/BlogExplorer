//
//  FWBlogEntity.h
//  BlogExplorer
//
//  Created by Forrest on 15-3-9.
//  Copyright (c) 2015年 Forrest. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FWDataTypeEnum) {
    FWDataType_Base,
    FWDataType_OctopressData,
    FWDataType_PageData,
};

@interface FWBlogItemEntity : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *url;

@end

@interface FWBlogEntity : NSObject

@property (nonatomic, assign) FWDataTypeEnum dataType;    // 数据类型
@property (nonatomic, strong) NSString *author;           // 作者
@property (nonatomic, strong) NSString *baseURL;          // 基本URL，
@property (nonatomic, strong) NSString *archiveURL;       // 索引URL

@property (nonatomic, strong) NSString *startFlag;        // 字符串开始标志
@property (nonatomic, strong) NSString *endFlag;          // 字符串结束标志
@property (nonatomic, strong) NSString *parseDom;         // 查找的dom内容
@property (nonatomic, strong) NSArray *itemAry;           // FWBlogItemEntity 的数据

@end
