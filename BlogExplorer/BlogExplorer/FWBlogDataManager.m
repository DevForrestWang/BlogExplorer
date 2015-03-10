//
//  FWBlogDataManager.m
//  BlogExplorer
//
//  Created by Forrest on 15-3-9.
//  Copyright (c) 2015年 Forrest. All rights reserved.
//

#import "FWBlogDataManager.h"
#import "TFHpple.h"
#import "FWBlogEntity.h"

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

- (void) dealloc
{
}

- (void)initURLData
{
    [_urlAry removeAllObjects];
    [self makeWholePage:_urlAry];
    [self makeBaseData:_urlAry];
    [self makePageData:_urlAry];
}

- (void)parseData:(BOOL)forceParse block:(void (^)(NSArray *blogAry))block
{
    if (!block) {
        NSLog(@"%s, the block is empty.", __FUNCTION__);
        return;
    }
    
    [_parseDataAry removeAllObjects];
    for (FWBlogEntity *data in _urlAry) {
        if (data.dataType == FWDataType_WholePage) {
            [_parseDataAry addObject:data];
        }
        else if (data.dataType == FWDataType_BaseData)
        {
            if ([self parseBaseData:data]) {
                [_parseDataAry addObject:data];
            }
        }
        else if (data.dataType == FWDataType_PageData)
        {
            if ([self parsePageData:data]) {
                [_parseDataAry addObject:data];
            }
        }
    }
    
    block(_parseDataAry);
}

- (void)saveData
{
}

#pragma mark - Private method
- (void) makeWholePage:(NSMutableArray *)array
{
    FWBlogEntity *raywenderlich = [[FWBlogEntity alloc] init];
    raywenderlich.dataType = FWDataType_WholePage;
    raywenderlich.author = @"Raywenderlich";
    raywenderlich.baseURL = @"http://www.raywenderlich.com/tutorials";
    raywenderlich.archiveURL = @"http://www.raywenderlich.com/tutorials";
    [array addObject:raywenderlich];
    
    FWBlogEntity *nshipster = [[FWBlogEntity alloc] init];
    nshipster.dataType = FWDataType_WholePage;
    nshipster.author = @"Nshipster";
    nshipster.baseURL = @"http://nshipster.com/";
    nshipster.archiveURL = @"http://nshipster.com/";
    [array addObject:nshipster];
    
    FWBlogEntity *objc = [[FWBlogEntity alloc] init];
    objc.dataType = FWDataType_WholePage;
    objc.author = @"objc";
    objc.baseURL = @"http://www.objc.io/";
    objc.archiveURL = @"http://www.objc.io/";
    [array addObject:objc];
    
    FWBlogEntity *objcCN = [[FWBlogEntity alloc] init];
    objcCN.dataType = FWDataType_WholePage;
    objcCN.author = @"objc中国";
    objcCN.baseURL = @"http://objccn.io/";
    objcCN.archiveURL = @"http://objccn.io/";
    [array addObject:objcCN];
}

- (void) makeBaseData:(NSMutableArray *)array
{
    [self makeBaseBlogEntity:array
                      author:@"唐乔"
                     baseURL:@"http://www.devtang.com"
                  archiveURL:@"http://www.devtang.com/blog/archives/"
                   startFlag:@"<div id=\"blog-archives\">"
                     endFlag:@"<aside class=\"sidebar\">"
                    parseDom:@"//h1/a"];
    
    [self makeBaseBlogEntity:array
                      author:@"Tony"
                     baseURL:@""
                  archiveURL:@"http://itony.me/archives"
                   startFlag:@"<div class=\"pta-postarchives\">"
                     endFlag:@"<footer class=\"entry-meta\">"
                    parseDom:@"//li/a"];
    /*
    [self makeBaseBlogEntity:array
                      author:@"破船之家"
                     baseURL:@"http://beyondvincent.com"
                  archiveURL:@"http://beyondvincent.com/archives/"
                   startFlag:@"<div class=\"mid-col\">"
                     endFlag:@"<footer id=\"footer\">"
                    parseDom:@"//h1/a"];
    
    [self makeBaseBlogEntity:array
                      author:@"Rannie’s Page"
                     baseURL:@"http://rannie.github.io/"
                  archiveURL:@"http://rannie.github.io/"
                   startFlag:@"<div class=\"page-content\">"
                     endFlag:@"<footer class=\"site-footer\">"
                    parseDom:@"//h2/a"];
    
    [self makeBaseBlogEntity:array
                      author:@"nvie.com"
                     baseURL:@"http://nvie.com/"
                  archiveURL:@"http://nvie.com/posts/"
                   startFlag:@"<div class=\"site-container\">"
                     endFlag:@"<div id=\"footer\">"
                    parseDom:@"//h2/a"];
    
    
    
    [self makeBaseBlogEntity:array
                      author:@""
                     baseURL:@""
                  archiveURL:@""
                   startFlag:@""
                     endFlag:@""
                    parseDom:@""];
    */
}

- (void)makeBaseBlogEntity:(NSMutableArray *)array
                              author:(NSString *)author
                             baseURL:(NSString *)baseURL
                          archiveURL:(NSString *)archiveURL
                           startFlag:(NSString *)startFlag
                             endFlag:(NSString *)endFlag
                            parseDom:(NSString *)parseDom
{
    FWBlogEntity *data = [[FWBlogEntity alloc] init];
    data.dataType = FWDataType_BaseData;
    data.author = author;
    data.baseURL = baseURL;
    data.archiveURL = archiveURL;
    data.startFlag = startFlag;
    data.endFlag = endFlag;
    data.parseDom = parseDom;
    [array addObject:data];
}

- (void) makePageData:(NSMutableArray *)array
{
    
}

- (BOOL)parseBaseData:(FWBlogEntity *) blogData
{
    NSString* htmlContent = [NSString stringWithContentsOfURL:[NSURL URLWithString:blogData.archiveURL]
                                                     encoding:NSUTF8StringEncoding error:nil];
    NSRange range = [htmlContent rangeOfString:blogData.startFlag];
    if (range.length == 0) {
        return NO;
    }
    NSString* tmpHtml = [htmlContent substringFromIndex:range.location + range.length];
    
    range = [tmpHtml rangeOfString:blogData.endFlag];
    if (range.length == 0) {
        return NO;
    }
    tmpHtml = [tmpHtml substringToIndex:range.location];
    
    NSData* dataHtml = [tmpHtml dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple* xpathParser = [[TFHpple alloc] initWithHTMLData:dataHtml];
    NSArray* elements = [xpathParser searchWithXPathQuery:blogData.parseDom];
    NSMutableArray* resultAry = [[NSMutableArray alloc] init];
    
    for (TFHppleElement* element in elements) {
        
        FWBlogItemEntity *data = [[FWBlogItemEntity alloc] init];
        data.title = element.content;
        
        NSDictionary* elementContent = [element attributes];
        data.url = [blogData.baseURL stringByAppendingString:[elementContent objectForKey:@"href"]];
        
        [resultAry addObject:data];
    }
    
    NSLog(@"%s, resultAry:%@", __FUNCTION__, resultAry);
    blogData.itemAry = resultAry;
    return YES;
}

- (BOOL)parsePageData:(FWBlogEntity *) blogData
{
    return NO;
}

@end
