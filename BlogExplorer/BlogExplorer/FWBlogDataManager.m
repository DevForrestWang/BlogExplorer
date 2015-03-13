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

@property (nonatomic, strong) NSMutableArray* urlAry;
@property (nonatomic, strong) NSMutableArray* parseDataAry;
@property (nonatomic, strong) NSString* filePath;

@end

@implementation FWBlogDataManager

- (id)init
{
    self = [super init];
    if (self) {
        _urlAry = [NSMutableArray array];
        _parseDataAry = [NSMutableArray array];

        NSString* documentDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        _filePath = [NSString stringWithFormat:@"%@/BlogExplorerData.plist", documentDir];
    }

    return self;
}

- (void)dealloc
{
}

- (void)initURLData
{
    [_urlAry removeAllObjects];
    [self makeWholePage:_urlAry];
    [self makeBaseData:_urlAry];
    [self makePageData:_urlAry];
}

- (void)loadLocalData:(void (^)(NSArray* blogAry))block
{
    if (!block) {
        NSLog(@"%s, the block is empty.", __FUNCTION__);
        return;
    }

    NSData* data = [[NSData alloc] initWithContentsOfFile:_filePath];
    NSArray* dataAry = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ([dataAry count] > 0) {
        block(dataAry);
    }
}

- (void)parseData:(BOOL)forceParse block:(void (^)(NSArray* blogAry))block
{
    if (!block) {
        NSLog(@"%s, the block is empty.", __FUNCTION__);
        return;
    }

    [_parseDataAry removeAllObjects];

    NSMutableArray* baseAry = [NSMutableArray array];
    NSMutableArray* pageAry = [NSMutableArray array];

    for (FWBlogEntity* data in _urlAry) {
        if (data.dataType == FWDataType_WholePage) {
            [_parseDataAry addObject:data];
        }
        else if (data.dataType == FWDataType_BaseData) {
            [baseAry addObject:data];
        }
        else if (data.dataType == FWDataType_PageData) {
            [pageAry addObject:data];
        }
    }

    __weak FWBlogDataManager* weekThis = self;
    [self startThreadToParse:baseAry pageAry:pageAry blok:^(NSArray* resultAry) {
        [weekThis.parseDataAry addObjectsFromArray:resultAry];
        
        if ([weekThis.parseDataAry count] > 0) {
            // 保存全部数据
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:weekThis.parseDataAry];
            BOOL restlt = [data writeToFile:_filePath atomically:NO];
            NSLog(@"%s, result:%d, doc:%@", __FUNCTION__, restlt, _filePath);
            
            block(_parseDataAry);
        }
    }];
}

- (void)saveData
{
}

#pragma mark - Private method
- (void)makeWholePage:(NSMutableArray*)array
{
    [self makeWholeEntity:array
                   author:@"objc中国"
                  baseURL:@"http://objccn.io/"
               archiveURL:@"http://objccn.io/"];

    [self makeWholeEntity:array
                   author:@"Raywenderlich"
                  baseURL:@"http://www.raywenderlich.com/tutorials"
               archiveURL:@"http://www.raywenderlich.com/tutorials"];

    [self makeWholeEntity:array
                   author:@"Nshipster"
                  baseURL:@"http://nshipster.com/"
               archiveURL:@"http://nshipster.com/"];

    [self makeWholeEntity:array
                   author:@"objc"
                  baseURL:@"http://www.objc.io/"
               archiveURL:@"http://www.objc.io/"];

    [self makeWholeEntity:array
                   author:@"拾光流"
                  baseURL:@"http://www.jianshu.com/collection/6d967bc213dd"
               archiveURL:@"http://www.jianshu.com/collection/6d967bc213dd"];

    [self makeWholeEntity:array
                   author:@"大澎湃"
                  baseURL:@"http://www.jianshu.com/collection/e62c0b71606b"
               archiveURL:@"http://www.jianshu.com/collection/e62c0b71606b"];

    [self makeWholeEntity:array
                   author:@"JanzTam"
                  baseURL:@"http://www.jianshu.com/collection/19dbe28002a3"
               archiveURL:@"http://www.jianshu.com/collection/19dbe28002a3"];

    [self makeWholeEntity:array
                   author:@"Davi_choise凡UP"
                  baseURL:@"http://www.jianshu.com/collection/27e6fb9b84f7"
               archiveURL:@"http://www.jianshu.com/collection/27e6fb9b84f7"];

    [self makeWholeEntity:array
                   author:@"RobinChao"
                  baseURL:@"http://www.jianshu.com/collection/2a6ff924a333"
               archiveURL:@"http://www.jianshu.com/collection/2a6ff924a333"];

    [self makeWholeEntity:array
                   author:@"23Years"
                  baseURL:@"http://www.jianshu.com/collection/8beb0140cf67"
               archiveURL:@"http://www.jianshu.com/collection/8beb0140cf67"];

    [self makeWholeEntity:array
                   author:@"JasonWu"
                  baseURL:@"http://www.jianshu.com/collection/fec73bf35ed3"
               archiveURL:@"http://www.jianshu.com/collection/fec73bf35ed3"];

    [self makeWholeEntity:array
                   author:@"季真"
                  baseURL:@"http://www.jianshu.com/collection/505442c4ef96"
               archiveURL:@"http://www.jianshu.com/collection/505442c4ef96"];

    [self makeWholeEntity:array
                   author:@"Azen"
                  baseURL:@"http://www.jianshu.com/collection/8a0602419a76"
               archiveURL:@"http://www.jianshu.com/collection/8a0602419a76"];
}

- (void)makeBaseData:(NSMutableArray*)array
{
    [self makeBaseBlogEntity:array
                      author:@"Forrest Wang"
                     baseURL:@"http://devforrestwang.github.io"
                  archiveURL:@"http://devforrestwang.github.io/blog/archives/"
                   startFlag:@"<section class=\"archives\">"
                     endFlag:@"<footer id=\"footer\""
                    parseDom:@"//h1/a"];

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
                      author:@"Limboy"
                     baseURL:@"http://limboy.me/"
                  archiveURL:@"http://limboy.me/"
                   startFlag:@"<ul class=\"posts\">"
                     endFlag:@"<div id=\"footer\">"
                    parseDom:@"//li/a"];

    [self makeBaseBlogEntity:array
                      author:@"亚庆的Blog"
                     baseURL:@"http://billwang1990.github.io/"
                  archiveURL:@"http://billwang1990.github.io/blog/archives/"
                   startFlag:@"<div id=\"blog-archives\">"
                     endFlag:@"<aside class=\"sidebar\">"
                    parseDom:@"//h1/a"];

    [self makeBaseBlogEntity:array
                      author:@"Nonomori"
                     baseURL:@"http://nonomori.farbox.com/"
                  archiveURL:@"http://nonomori.farbox.com/archive"
                   startFlag:@"<ul class=\"list_with_title container\">"
                     endFlag:@"<div id=\"footer\">"
                    parseDom:@"//li/a"];

    [self makeBaseBlogEntity:array
                      author:@"不会开机的男孩"
                     baseURL:@"http://studentdeng.github.io"
                  archiveURL:@"http://studentdeng.github.io/blog/archives/"
                   startFlag:@"<article role=\"article\">"
                     endFlag:@"<aside class=\"sidebar\">"
                    parseDom:@"//h1/a"];

    [self makeBaseBlogEntity:array
                      author:@"代码手工艺人"
                     baseURL:@"http://joeyio.com"
                  archiveURL:@"http://joeyio.com/archive.html"
                   startFlag:@"<div class=\"row-fluid\">"
                     endFlag:@"<footer>"
                    parseDom:@"//li/a"];

    [self makeBaseBlogEntity:array
                      author:@"NICO"
                     baseURL:@"http://blog.inico.me"
                  archiveURL:@"http://blog.inico.me/"
                   startFlag:@"<div class=\"span12\">"
                     endFlag:@"<footer>"
                    parseDom:@"//li/a"];

    [self makeBaseBlogEntity:array
                      author:@"王中周的技术博客"
                     baseURL:@"http://foggry.com"
                  archiveURL:@"http://foggry.com/blog/archives/"
                   startFlag:@"<div id=\"blog-archives\">"
                     endFlag:@"<aside class=\"sidebar\">"
                    parseDom:@"//h1/a"];

    [self makeBaseBlogEntity:array
                      author:@"码农人生"
                     baseURL:@"http://msching.github.io"
                  archiveURL:@"http://msching.github.io/blog/archives/"
                   startFlag:@"<section class=\"archives\">"
                     endFlag:@"<footer id=\"footer\" class=\"inner\">"
                    parseDom:@"//h1/a"];

    [self makeBaseBlogEntity:array
                      author:@"煲仔饭"
                     baseURL:@"http://ivoryxiong.org"
                  archiveURL:@"http://ivoryxiong.org/categories/"
                   startFlag:@"<ul class=\"listing\">"
                     endFlag:@"<div class=\"footer-wrap\">"
                    parseDom:@"//li/a"];

    [self makeBaseBlogEntity:array
                      author:@"猫·仁波切"
                     baseURL:@"http://andelf.github.io"
                  archiveURL:@"http://andelf.github.io/blog/archives/"
                   startFlag:@"<div id=\"blog-archives\">"
                     endFlag:@"<aside class=\"sidebar\">"
                    parseDom:@"//h1/a"];

    [self makeBaseBlogEntity:array
                      author:@"Itty Bitty Labs"
                     baseURL:@"http://blog.ittybittyapps.com"
                  archiveURL:@"http://blog.ittybittyapps.com/blog/archives/"
                   startFlag:@"<div id=\"blog-archives\">"
                     endFlag:@"<aside class=\"sidebar\">"
                    parseDom:@"//h1/a"];

    [self makeBaseBlogEntity:array
                      author:@"Adoption Curve Dot Net"
                     baseURL:@"http://adoptioncurve.net"
                  archiveURL:@"http://adoptioncurve.net/blog/archives/"
                   startFlag:@"<div id=\"blog-archives\">"
                     endFlag:@"<aside class=\"sidebar\">"
                    parseDom:@"//h1/a"];

    [self makeBaseBlogEntity:array
                      author:@"txx's blog"
                     baseURL:@"http://blog.txx.im"
                  archiveURL:@"http://blog.txx.im/blog/archives"
                   startFlag:@"<div id=\"content\" class=\"inner\">"
                     endFlag:@"<footer id=\"footer\" class=\"inner\">"
                    parseDom:@"//h2/a"];

    [self makeBaseBlogEntity:array
                      author:@"hSATAC"
                     baseURL:@"http://blog.hsatac.net"
                  archiveURL:@"http://blog.hsatac.net/blog/archives/"
                   startFlag:@"<div id=\"content\" class=\"inner\">"
                     endFlag:@"<footer id=\"footer\" class=\"inner\"><p>"
                    parseDom:@"//h1/a"];

    [self makeBaseBlogEntity:array
                      author:@"里脊串的开发随笔"
                     baseURL:@"http://adad184.com"
                  archiveURL:@"http://adad184.com/archives/"
                   startFlag:@"<section id=\"main\">"
                     endFlag:@"<aside id=\"sidebar\">"
                    parseDom:@"//h1/a"];

    [self makeBaseBlogEntity:array
                      author:@"成长的路上(Moonlight)"
                     baseURL:@""
                  archiveURL:@"http://www.cnblogs.com/zhw511006/category/189553.html"
                   startFlag:@"<div class=\"entrylist\">"
                     endFlag:@"<div id=\"sideBar\">"
                    parseDom:@"//div[@class='entrylistPosttitle']//a"];

    [self makeBaseBlogEntity:array
                      author:@"wayne23"
                     baseURL:@""
                  archiveURL:@"http://www.cnblogs.com/wayne23/category/429228.html"
                   startFlag:@"<div class=\"entrylist\">"
                     endFlag:@"<div id=\"sideBar\">"
                    parseDom:@"//div[@class='entrylistPosttitle']//a"];

    [self makeBaseBlogEntity:array
                      author:@"念茜的博客"
                     baseURL:@""
                  archiveURL:@"http://nianxi.net/"
                   startFlag:@"<div class=\"page-body\" itemprop=\"description\">"
                     endFlag:@"<footer id=\"footer\""
                    parseDom:@"//h2/a"];

    [self makeBaseBlogEntity:array
                      author:@"言无不尽"
                     baseURL:@"http://tang3w.com"
                  archiveURL:@"http://tang3w.com/"
                   startFlag:@"<ul class=\"posts\">"
                     endFlag:@"<div id=\"foot\">"
                    parseDom:@"//li/a"];

    [self makeBaseBlogEntity:array
                      author:@"webfrogs' Homepage"
                     baseURL:@""
                  archiveURL:@"http://blog.nswebfrog.com/categories/"
                   startFlag:@"<ul class=\"listing\">"
                     endFlag:@"<footer>"
                    parseDom:@"//li/a"];

    [self makeBaseBlogEntity:array
                      author:@"Travis' Blog"
                     baseURL:@"http://imi.im"
                  archiveURL:@"http://imi.im/"
                   startFlag:@"<div class=\"mp-scroll\">"
                     endFlag:@"</div>"
                    parseDom:@"//li/a"];

    [self makeBaseBlogEntity:array
                      author:@"萧宸宇"
                     baseURL:@"http://iiiyu.com"
                  archiveURL:@"http://iiiyu.com/archives/"
                   startFlag:@"<section id=\"main\">"
                     endFlag:@"<aside id=\"sidebar\">"
                    parseDom:@"//h1/a"];

    [self makeBaseBlogEntity:array
                      author:@"Chun Tips"
                     baseURL:@"http://chun.tips"
                  archiveURL:@"http://chun.tips/blog/archives/"
                   startFlag:@"<div id=\"blog-archives\">"
                     endFlag:@"<footer role=\"contentinfo\">"
                    parseDom:@"//li/a"];
}

- (void)makeWholeEntity:(NSMutableArray*)array
                 author:(NSString*)author
                baseURL:(NSString*)baseURL
             archiveURL:(NSString*)archiveURL
{
    FWBlogEntity* data = [[FWBlogEntity alloc] init];
    data.dataType = FWDataType_WholePage;
    data.author = author;
    data.baseURL = baseURL;
    data.archiveURL = archiveURL;
    [array addObject:data];
}

- (void)makeBaseBlogEntity:(NSMutableArray*)array
                    author:(NSString*)author
                   baseURL:(NSString*)baseURL
                archiveURL:(NSString*)archiveURL
                 startFlag:(NSString*)startFlag
                   endFlag:(NSString*)endFlag
                  parseDom:(NSString*)parseDom
{
    FWBlogEntity* data = [[FWBlogEntity alloc] init];
    data.dataType = FWDataType_BaseData;
    data.author = author;
    data.baseURL = baseURL;
    data.archiveURL = archiveURL;
    data.startFlag = startFlag;
    data.endFlag = endFlag;
    data.parseDom = parseDom;
    [array addObject:data];
}

- (void)makePageData:(NSMutableArray*)array
{
}

- (void)startThreadToParse:(NSArray*)baseAry
                   pageAry:(NSArray*)pageAry
                      blok:(void (^)(NSArray* resultAry))blok
{
    if (!blok) {
        NSLog(@"%s, the block is empty", __FUNCTION__);
        return;
    }

    NSMutableArray* resultAry = [NSMutableArray array];
    dispatch_queue_t dispatchQueue = dispatch_queue_create("devforrestwang.com.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t dispatchGroup = dispatch_group_create();
    __weak FWBlogDataManager* weekThis = self;

    // 计算每组解析数目，最少5个
    NSInteger aryCount = [baseAry count];
    NSInteger maxNum = MAX(aryCount / 10, 5);
    NSInteger count = (aryCount % maxNum == 0) ? (aryCount / maxNum) : ((aryCount / maxNum) + 1);

    for (NSInteger index = 0; index < count; index++) {

        NSRange range;
        range.location = index * maxNum;
        range.length = MIN(maxNum, (aryCount - index * maxNum));
        NSMutableArray* tempAry = [NSMutableArray arrayWithArray:[baseAry subarrayWithRange:range]];

        if ([tempAry count] <= 0) {
            continue;
        }

        dispatch_group_async(dispatchGroup, dispatchQueue, ^() {
            for (FWBlogEntity *data in tempAry) {
                if ([weekThis parseBaseData:data]) {
                    [resultAry addObject:data];
                }
            }
        });
    }

    // 界面page类型
    NSInteger pageAryCount = [pageAry count];
    NSInteger pageMaxNum = MAX(pageAryCount / 10, 5);
    NSInteger pageCount = (pageAryCount % pageMaxNum == 0) ? (pageAryCount / pageMaxNum) : ((pageAryCount / pageMaxNum) + 1);
    for (NSInteger index = 0; index < pageCount; index++) {

        NSRange range;
        range.location = index * pageMaxNum;
        range.length = MIN(pageMaxNum, (pageAryCount - index * pageMaxNum));
        NSMutableArray* tempAry = [NSMutableArray arrayWithArray:[pageAry subarrayWithRange:range]];

        if ([tempAry count] <= 0) {
            continue;
        }

        dispatch_group_async(dispatchGroup, dispatchQueue, ^() {
            for (FWBlogEntity *data in tempAry) {
                if ([weekThis parsePageData:data]) {
                    [resultAry addObject:data];
                }
            }
        });
    }

    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^() {
        blok(resultAry);
    });
}

- (BOOL)parseBaseData:(FWBlogEntity*)blogData
{
    NSString* htmlContent = [NSString stringWithContentsOfURL:[NSURL URLWithString:blogData.archiveURL]
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
    NSString* tmpHtml = htmlContent;
    NSRange range = [htmlContent rangeOfString:blogData.startFlag];
    if (range.length > 0) {
        tmpHtml = [htmlContent substringFromIndex:range.location + range.length];
    }

    range = [tmpHtml rangeOfString:blogData.endFlag];
    if (range.length > 0) {
        tmpHtml = [tmpHtml substringToIndex:range.location];
    }

    NSData* dataHtml = [tmpHtml dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple* xpathParser = [[TFHpple alloc] initWithHTMLData:dataHtml];
    NSArray* elements = [xpathParser searchWithXPathQuery:blogData.parseDom];
    NSMutableArray* resultAry = [[NSMutableArray alloc] init];

    for (TFHppleElement* element in elements) {

        FWBlogItemEntity* data = [[FWBlogItemEntity alloc] init];
        data.title = element.content;

        NSDictionary* elementContent = [element attributes];
        data.url = [blogData.baseURL stringByAppendingString:[elementContent objectForKey:@"href"]];

        [resultAry addObject:data];
    }

    blogData.itemAry = resultAry;
    return YES;
}

- (BOOL)parsePageData:(FWBlogEntity*)blogData
{
    return NO;
}

@end
