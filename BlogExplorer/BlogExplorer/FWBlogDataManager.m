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
#import "FWBlogStatisticsEntity.h"

@interface FWBlogDataManager ()

@property (nonatomic, strong) NSMutableArray* urlAry;
@property (nonatomic, strong) NSMutableArray* parseDataAry;
@property (nonatomic, strong) NSString* filePath;
@property (nonatomic, strong) NSString* saveDataPath;
@property (nonatomic, strong) NSMutableDictionary* saveDataDic;
@property (nonatomic, strong) FWBlogStatisticsEntity *statisticEnity;
@property (nonatomic, strong) BlogStatisticsBlock statisticsBlock;
@end

@implementation FWBlogDataManager

- (id)init
{
    self = [super init];
    if (self) {
        _urlAry = [NSMutableArray array];
        _parseDataAry = [NSMutableArray array];
        _statisticEnity = [[FWBlogStatisticsEntity alloc] init];

        NSString* documentDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        _filePath = [NSString stringWithFormat:@"%@/BlogExplorerData.plist", documentDir];
        _saveDataPath = [NSString stringWithFormat:@"%@/BlogExplorerSaveData.plist", documentDir];
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
    [self makeTotlePageData:_urlAry];
}

- (void)loadLocalData:(void (^)(NSArray* blogAry))block
{
    if (!block) {
        NSLog(@"%s, the block is empty.", __FUNCTION__);
        return;
    }

    NSData* saveData = [[NSData alloc] initWithContentsOfFile:_saveDataPath];
    _saveDataDic = [NSKeyedUnarchiver unarchiveObjectWithData:saveData];
    
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

    NSInteger wholePageNumber = [_parseDataAry count];
    __weak FWBlogDataManager* weekThis = self;
    
    [self startThreadToParse:baseAry pageAry:pageAry blok:^(NSArray* resultAry) {
        [weekThis.parseDataAry addObjectsFromArray:resultAry];
        
        if ([weekThis.parseDataAry count] > 0) {
            [weekThis statisticBlogData:resultAry wholePage:wholePageNumber];
            
            // 缓存多页面的数据
            if ([weekThis.saveDataDic count] > 0) {
                NSData *saveData = [NSKeyedArchiver archivedDataWithRootObject:weekThis.saveDataDic];
                BOOL saveResult = [saveData writeToFile:weekThis.saveDataPath atomically:NO];
                NSLog(@"write saveData to file, result:%@, doc:%@", [weekThis printBOOL:saveResult], weekThis.saveDataPath);
            }
            
            // 保存全部数据
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:weekThis.parseDataAry];
            BOOL result = [data writeToFile:weekThis.filePath atomically:NO];
            NSLog(@"%s, result:%@, doc:%@", __FUNCTION__, [weekThis printBOOL:result], weekThis.filePath);
            
            block(weekThis.parseDataAry);
        }
    }];
}

- (void)loadStatusData:(BlogStatisticsBlock)block {
    if (block) {
        self.statisticsBlock = block;
    }
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
    
    [self makeBaseBlogEntity:array
                      author:@"Xcode Dev"
                     baseURL:@"http://blog.xcodev.com/"
                  archiveURL:@"http://blog.xcodev.com/blog/archives/"
                   startFlag:@"<div id=\"blog-archives\">"
                     endFlag:@"<aside class=\"sidebar thirds\">"
                    parseDom:@"//h1/a"];
    
    [self makeBaseBlogEntity:array
                      author:@"Wonderffee's Blog"
                     baseURL:@"http://wonderffee.github.io/"
                  archiveURL:@"http://wonderffee.github.io/blog/archives/"
                   startFlag:@"<div id=\"blog-archives\">"
                     endFlag:@"<aside class=\"sidebar\">"
                    parseDom:@"//h1/a"];
    
    [self makeBaseBlogEntity:array
                      author:@"nixzhu"
                     baseURL:@"http://nixzhu.me/"
                  archiveURL:@"http://nixzhu.me/archive"
                   startFlag:@"<div class=\"blog\">"
                     endFlag:@"<div class=\"scriptogram-link\">"
                    parseDom:@"//h3/a"];
    
    [self makeBaseBlogEntity:array
                      author:@"Lancy's Blog"
                     baseURL:@"http://gracelancy.com/"
                  archiveURL:@"http://gracelancy.com/blog/archives/"
                   startFlag:@"<div id=\"content\" class=\"inner\">"
                     endFlag:@"<footer id=\"footer\" class=\"inner\">"
                    parseDom:@"//h2/a"];

    [self makeBaseBlogEntity:array
                      author:@"Luke's Homepage"
                     baseURL:@""
                  archiveURL:@"http://geeklu.com/categories/"
                   startFlag:@"<ul class=\"listing\">"
                     endFlag:@"<p></p>"
                    parseDom:@"//li/a"];
    
    [self makeBaseBlogEntity:array
                      author:@"不掏蜂窝的熊"
                     baseURL:@""
                  archiveURL:@"http://www.hotobear.com/?page_id=810"
                   startFlag:@"<ul class=\"jaw_widget\">"
                     endFlag:@"<input type=\"hidden\" id=\"widget-jal_widget-1-fx_in\" name=\"widget-jal_widget[1][fx_in]\" class=\"fx_in\" value=\"fadeIn\">"
                    parseDom:@"//ul/li/ul/li/a"];
    
    [self makeBaseBlogEntity:array
                      author:@"土土哥的技术Blog"
                     baseURL:@"http://tutuge.me/"
                  archiveURL:@"http://tutuge.me/archives/"
                   startFlag:@"<div class=\"archives\">"
                     endFlag:@"<aside id=\"sidebar\">"
                    parseDom:@"//h1/a"];
    
    [self makeBaseBlogEntity:array
                      author:@"庞海礁的个人空间"
                     baseURL:@""
                  archiveURL:@"http://www.olinone.com/"
                   startFlag:@"<div id=\"primary\" class=\"site-content\">"
                     endFlag:@"<div id=\"secondary\" class=\"widget-area\" role=\"complementary\">"
                    parseDom:@"//h2/a"];
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

- (void)makeTotlePageData:(NSMutableArray *)array {
    NSArray *oneCatAry = [self totalPageURL:@"http://onevcat.com/#blog"
                              parseTotalDom:@"//nav[@class='pagination']/span[@class='pagination__page-number']"
                                  formatURL:@"http://onevcat.com/page/%ld/#blog"];
    if ([oneCatAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"OneV's Den"
                              baseURL:@"http://onevcat.com"
                        archiveURLAry:oneCatAry
                            startFlag:@"<ol class=\"post-list\">"
                              endFlag:@"<hr class=\"post-list__divider \">"
                             parseDom:@"//li/h2/a"];
    }
    
    NSArray *kooFrankAry = [self totalPageURL:@"http://koofrank.com/#blog"
                                parseTotalDom:@"//nav[@class='pagination']/span[@class='pagination__page-number']"
                                    formatURL:@"http://koofrank.com/page/%ld/#blog"];
    if ([kooFrankAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"KooFrank's Den"
                              baseURL:@"http://koofrank.com"
                        archiveURLAry:kooFrankAry
                            startFlag:@"<ol class=\"post-list\">"
                              endFlag:@"<hr class=\"post-list__divider \">"
                             parseDom:@"//li/h2/a"];
    }
    
    NSArray *biosliAry = [self fixedPageNumberURL:4
                                        formatURL:@"http://www.cnblogs.com/biosli/default.html?page=%ld"];
    if ([biosliAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"摇滚诗人"
                              baseURL:@""
                        archiveURLAry:biosliAry
                            startFlag:@"<div class=\"forFlow\">"
                              endFlag:@"<div class=\"topicListFooter\">"
                             parseDom:@"//div[@class='postTitle']/a"];
    }
    
    
    NSArray *itWorkAry = [self fixedPageNumberURL:7
                                        formatURL:@"http://helloitworks.com/page/%ld"];
    if ([itWorkAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"Hello,it works"
                              baseURL:@""
                        archiveURLAry:itWorkAry
                            startFlag:@"<div id=\"main\">"
                              endFlag:@"<div id=\"sidebar\">"
                             parseDom:@"//div[@class='post']/h2/a"];
    }
    
    NSArray *allenMemosAry = [self fixedPageNumberURL:1
                                            formatURL:@"http://imallen.com/"];
    if ([allenMemosAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"Allen's Memos"
                              baseURL:@"http://imallen.com/"
                        archiveURLAry:allenMemosAry
                            startFlag:@"<main id=\"content\" class=\"content\" role=\"main\">"
                              endFlag:@"<footer class=\"site-footer clearfix\">"
                             parseDom:@"//article/header/h2/a"];
    }

    NSArray *pjk129Ary = [self fixedPageNumberURL:4
                                        formatURL:@"http://blog.csdn.net/pjk1129/article/list/%ld"];
    if ([pjk129Ary count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"pjk1129专栏"
                              baseURL:@"http://blog.csdn.net"
                        archiveURLAry:pjk129Ary
                            startFlag:@"<div id=\"article_list\" class=\"contents\">"
                              endFlag:@"<div id=\"papelist\" class=\"pagelist\">"
                             parseDom:@"//h1/span/a"];
    }
   
    NSArray *xfzlAry = [self fixedPageNumberURL:3
                                      formatURL:@"http://blog.csdn.net/duxinfeng2010/article/list/%ld"];
    if ([xfzlAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"新风作浪"
                              baseURL:@"http://blog.csdn.net"
                        archiveURLAry:xfzlAry
                            startFlag:@"<div id=\"article_list\" class=\"contents\">"
                              endFlag:@"<div id=\"papelist\" class=\"pagelist\">"
                             parseDom:@"//h1/span/a"];
    }
    
    NSArray *fishWaterAry = [self fixedPageNumberURL:3
                                           formatURL:@"http://blog.csdn.net/yujianxiang666/article/list/%ld"];
    if ([fishWaterAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"如鱼得水"
                              baseURL:@"http://blog.csdn.net"
                        archiveURLAry:fishWaterAry
                            startFlag:@"<div id=\"article_list\" class=\"contents\">"
                              endFlag:@"<div id=\"papelist\" class=\"pagelist\">"
                             parseDom:@"//h1/span/a"];
    }
    
    NSArray *liuWeiAry = [self fixedPageNumberURL:2
                                        formatURL:@"http://blog.csdn.net/iukey/article/list/%ld"];
    if ([liuWeiAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"刘伟Derick-IOS"
                              baseURL:@"http://blog.csdn.net"
                        archiveURLAry:liuWeiAry
                            startFlag:@"<div id=\"article_list\" class=\"contents\">"
                              endFlag:@"<div id=\"papelist\" class=\"pagelist\">"
                             parseDom:@"//h1/span/a"];
    }
    
    NSArray *rannieRAry = [self fixedPageNumberURL:2
                                         formatURL:@"http://blog.csdn.net/ran0809/article/list/%ld"];
    if ([rannieRAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"RannieR"
                              baseURL:@"http://blog.csdn.net"
                        archiveURLAry:rannieRAry
                            startFlag:@"<div id=\"article_list\" class=\"contents\">"
                              endFlag:@"<div id=\"papelist\" class=\"pagelist\">"
                             parseDom:@"//h1/span/a"];
    }
    
    NSArray *xcydAry = [self fixedPageNumberURL:11
                                      formatURL:@"http://blog.csdn.net/superchaoxian/article/list/%ld"];
    if ([xcydAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"小菜移动互联网之路"
                              baseURL:@"http://blog.csdn.net"
                        archiveURLAry:xcydAry
                            startFlag:@"<div id=\"article_list\" class=\"contents\">"
                              endFlag:@"<div id=\"papelist\" class=\"pagelist\">"
                             parseDom:@"//h1/span/a"];
    }
    
    NSArray *rzfAry = [self fixedPageNumberURL:3
                                     formatURL:@"http://blog.csdn.net/totogo2010/article/list/%ld"];
    if ([rzfAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"容芳志专栏"
                              baseURL:@"http://blog.csdn.net"
                        archiveURLAry:rzfAry
                            startFlag:@"<div id=\"article_list\" class=\"contents\">"
                              endFlag:@"<div id=\"papelist\" class=\"pagelist\">"
                             parseDom:@"//h1/span/a"];
    }
    
    // http://www.jianshu.com/collection/8a0602419a76/top?page=%ld
    // http://www.jianshu.com/collections/6919/notes?order_by=added_at&page=18
    // <a href="/collections/6919/notes?order_by=likes_count">热门排序</a>
    NSArray *sglAry = [self fixedPageNumberURL:1
                                     formatURL:@"http://www.jianshu.com/collections/4232/notes?order_by=added_at&page=%ld"];
    if ([sglAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"拾光流"
                              baseURL:@"http://www.jianshu.com"
                        archiveURLAry:sglAry
                            startFlag:@"<div id=\"list-container\" class=\"tab-pane active\">"
                              endFlag:@"<div class=\"hidden\">"
                             parseDom:@"//li/div/h4/a"];
    }
    
    NSArray *dppAry = [self fixedPageNumberURL:4
                                     formatURL:@"http://www.jianshu.com/collections/3040/notes?order_by=added_at&page=%ld"];
    if ([dppAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"大澎湃"
                              baseURL:@"http://www.jianshu.com"
                        archiveURLAry:dppAry
                            startFlag:@"<div id=\"list-container\" class=\"tab-pane active\">"
                              endFlag:@"<div class=\"hidden\">"
                             parseDom:@"//li/div/h4/a"];
    }
    
    NSArray *janzTamAry = [self fixedPageNumberURL:20
                                         formatURL:@"http://www.jianshu.com/collections/6919/notes?order_by=added_at&page=%ld"];
    if ([janzTamAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"JanzTam"
                              baseURL:@"http://www.jianshu.com"
                        archiveURLAry:janzTamAry
                            startFlag:@"<div id=\"list-container\" class=\"tab-pane active\">"
                              endFlag:@"<div class=\"hidden\">"
                             parseDom:@"//li/div/h4/a"];
    }
    
    NSArray *daviChoiseAry = [self fixedPageNumberURL:31
                                            formatURL:@"http://www.jianshu.com/collections/6286/notes?order_by=added_at&page=%ld"];
    if ([daviChoiseAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"Davi_choise凡UP"
                              baseURL:@"http://www.jianshu.com"
                        archiveURLAry:daviChoiseAry
                            startFlag:@"<div id=\"list-container\" class=\"tab-pane active\">"
                              endFlag:@"<div class=\"hidden\">"
                             parseDom:@"//li/div/h4/a"];
    }
    
    NSArray *robinChaoAry = [self fixedPageNumberURL:5
                                           formatURL:@"http://www.jianshu.com/collections/5843/notes?order_by=added_at&page=%ld"];
    if ([robinChaoAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"RobinChao"
                              baseURL:@"http://www.jianshu.com"
                        archiveURLAry:robinChaoAry
                            startFlag:@"<div id=\"list-container\" class=\"tab-pane active\">"
                              endFlag:@"<div class=\"hidden\">"
                             parseDom:@"//li/div/h4/a"];
    }
    
    NSArray *yearsAry = [self fixedPageNumberURL:5
                                       formatURL:@"http://www.jianshu.com/collections/9448/notes?order_by=added_at&page=%ld"];
    if ([yearsAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"23Years"
                              baseURL:@"http://www.jianshu.com"
                        archiveURLAry:yearsAry
                            startFlag:@"<div id=\"list-container\" class=\"tab-pane active\">"
                              endFlag:@"<div class=\"hidden\">"
                             parseDom:@"//li/div/h4/a"];
    }
    
    NSArray *jasonWuAry = [self fixedPageNumberURL:3
                                         formatURL:@"http://www.jianshu.com/collections/9986/notes?order_by=added_at&page=%ld"];
    if ([jasonWuAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"JasonWu"
                              baseURL:@"http://www.jianshu.com"
                        archiveURLAry:jasonWuAry
                            startFlag:@"<div id=\"list-container\" class=\"tab-pane active\">"
                              endFlag:@"<div class=\"hidden\">"
                             parseDom:@"//li/div/h4/a"];
    }
    
    NSArray *jzAry = [self fixedPageNumberURL:1
                                    formatURL:@"http://www.jianshu.com/collections/9315/notes?order_by=added_at&page=%ld"];
    if ([jzAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"Ludwig的iOS开发入门"
                              baseURL:@"http://www.jianshu.com"
                        archiveURLAry:jzAry
                            startFlag:@"<div id=\"list-container\" class=\"tab-pane active\">"
                              endFlag:@"<div class=\"hidden\">"
                             parseDom:@"//li/div/h4/a"];
    }
    
    NSArray *aboutIOSAry = [self fixedPageNumberURL:3
                                          formatURL:@"http://www.jianshu.com/collections/11339/notes?order_by=added_at&page=%ld"];
    if ([aboutIOSAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"AboutIOS"
                              baseURL:@"http://www.jianshu.com"
                        archiveURLAry:aboutIOSAry
                            startFlag:@"<div id=\"list-container\" class=\"tab-pane active\">"
                              endFlag:@"<div class=\"hidden\">"
                             parseDom:@"//li/div/h4/a"];
    }

    NSArray *hrchenAry = [self fixedPageNumberURL:4
                                          formatURL:@"http://www.hrchen.com/page/%ld"];
    if ([hrchenAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"hrchen's blogging"
                              baseURL:@"http://www.hrchen.com"
                        archiveURLAry:hrchenAry
                            startFlag:@"<main id=\"content\" class=\"content\" role=\"main\">"
                              endFlag:@"<footer class=\"site-footer clearfix\">"
                             parseDom:@"//header/h2/a"];
    }
     
    NSArray *xwfengAry = [self fixedPageNumberURL:3
                                        formatURL:@"http://xiangwangfeng.com/page%ld"];
    if ([xwfengAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"阿毛的蛋疼地 "
                              baseURL:@"http://xiangwangfeng.com"
                        archiveURLAry:xwfengAry
                            startFlag:@"<ul class=\"listing\">"
                              endFlag:@"<div id=\"post-pagination\" class=\"paginator\">"
                             parseDom:@"//li/a"];
    }
    
    NSMutableArray *yltxBLogAry = [self fixedPageNumberURL:5
                                        formatURL:@"http://yulingtianxia.com/page/%ld/"];
    if ([yltxBLogAry count] > 0) {
        [yltxBLogAry replaceObjectAtIndex:0 withObject:@"http://yulingtianxia.com/"];
        
        [self makeTotalPageBlogEntity:array
                               author:@"玉令天下的博客"
                              baseURL:@"http://yulingtianxia.com"
                        archiveURLAry:yltxBLogAry
                            startFlag:@"<div id=\"main\">"
                              endFlag:@"<div id=\"asidepart\">"
                             parseDom:@"//article/header/h1/a"];
    }
   
    NSMutableArray *wanghaiAry = [self fixedPageNumberURL:3
                                        formatURL:@"http://blog.callmewhy.com/archives/page/%ld/"];
    if ([wanghaiAry count] > 0) {
        [wanghaiAry replaceObjectAtIndex:0 withObject:@"http://blog.callmewhy.com/archives/"];
        [self makeTotalPageBlogEntity:array
                               author:@"汪海的实验室"
                              baseURL:@"http://blog.callmewhy.com"
                        archiveURLAry:wanghaiAry
                            startFlag:@"<div id=\"posts\" class=\"posts-collapse\">"
                              endFlag:@"<div class=\"pagination\">"
                             parseDom:@"//div/div/div/a"];
    }
    
    
    NSMutableArray *jishuBrotherAry = [self fixedPageNumberURL:2
                                               formatURL:@"http://suenblog.duapp.com/?page=%ld"];
    if ([jishuBrotherAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"技术哥"
                              baseURL:@"http://suenblog.duapp.com"
                        archiveURLAry:jishuBrotherAry
                            startFlag:@"<div class=\"blogs\">"
                              endFlag:@"<div id=\"main\">"
                             parseDom:@"//article/header/h2/a"];
    }
     
    NSMutableArray *whjBlogAry = [self fixedPageNumberURL:4
                                               formatURL:@"http://my.oschina.net/w11h22j33?disp=1&catalog=0&sort=time&p=%ld"];
    if ([whjBlogAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"whj的个人空间"
                              baseURL:@""
                        archiveURLAry:whjBlogAry
                            startFlag:@"<div class=\"SpaceList BlogList\">"
                              endFlag:@"<ul class=\"pager\">"
                             parseDom:@"//div/div/h2/a"];
    }
    
    NSMutableArray *answerHuangAry = [self fixedPageNumberURL:3
                                               formatURL:@"http://answerhuang.duapp.com/index.php/page/%ld/"];
    if ([answerHuangAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"answer_huang"
                              baseURL:@""
                        archiveURLAry:answerHuangAry
                            startFlag:@"<div class=\"col-sm-8\" id=\"post-list\">"
                              endFlag:@"<ul id=\"pager\" class=\"pagination\">"
                             parseDom:@"//div/div/h2/a"];
    }
    
    NSMutableArray *kenshinAry = [self fixedPageNumberURL:3
                                               formatURL:@"http://www.cnblogs.com/kenshincui/default.aspx?page=%ld"];
    if ([kenshinAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"Kenshin Cui's Blog"
                              baseURL:@""
                        archiveURLAry:kenshinAry
                            startFlag:@"<div id=\"content\">"
                              endFlag:@"<div id=\"pager\">"
                             parseDom:@"//div[@class='post post-list-item']/h2/a"];
    }
    
    NSMutableArray *sunnyxxAry = [self fixedPageNumberURL:39
                                               formatURL:@"http://blog.sunnyxx.com/archives/page/%ld/"];
    if ([sunnyxxAry count] > 0) {
        [sunnyxxAry replaceObjectAtIndex:0 withObject:@"http://blog.sunnyxx.com/archives/"];
        [self makeTotalPageBlogEntity:array
                               author:@"Sunnyxx的技术博客"
                              baseURL:@"http://blog.sunnyxx.com"
                        archiveURLAry:sunnyxxAry
                            startFlag:@"<div class=\"article-inner\">"
                              endFlag:@"<nav id=\"page-nav\">"
                             parseDom:@"//header/h1/a"];
    }
    
    NSMutableArray *tedHomePahgeAry = [self fixedPageNumberURL:7
                                               formatURL:@"http://wufawei.com/page%ld/"];
    if ([tedHomePahgeAry count] > 0) {
        [tedHomePahgeAry replaceObjectAtIndex:0 withObject:@"http://wufawei.com/"];
        [self makeTotalPageBlogEntity:array
                               author:@"Ted's Homepage"
                              baseURL:@"http://wufawei.com"
                        archiveURLAry:tedHomePahgeAry
                            startFlag:@"<ul class=\"listing\">"
                              endFlag:@"<div id=\"post-pagination\" class=\"paginator\">"
                             parseDom:@"//li/a"];
    }
    
    NSMutableArray *hufengAry = [self fixedPageNumberURL:8
                                               formatURL:@"http://hufeng825.github.io/page/%ld/"];
    if ([hufengAry count] > 0) {
        [hufengAry replaceObjectAtIndex:0 withObject:@"http://hufeng825.github.io/"];
        [self makeTotalPageBlogEntity:array
                               author:@"hufeng825"
                              baseURL:@"http://hufeng825.github.io"
                        archiveURLAry:hufengAry
                            startFlag:@"<div class=\"span9 panel\">"
                              endFlag:@"<div class=\"pagination pagination-centered \" id=\"Pagination\">"
                             parseDom:@"//header/h1/a"];
    }
    
    NSMutableArray *keweiBlogAry = [self fixedPageNumberURL:11
                                               formatURL:@"http://www.cnblogs.com/wangkewei/default.aspx?page=%ld"];
    if ([keweiBlogAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"克伟的博客"
                              baseURL:@""
                        archiveURLAry:keweiBlogAry
                            startFlag:@"<div id=\"content\">"
                              endFlag:@"<div id=\"pager\">"
                             parseDom:@"//div/h2/a"];
    }
    
    NSMutableArray *yuanAry = [self fixedPageNumberURL:47
                                               formatURL:@"http://42.96.192.22/?cat=3&paged=%ld"];
    if ([yuanAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"Yuan博客"
                              baseURL:@""
                        archiveURLAry:yuanAry
                            startFlag:@"<div id=\"content\" role=\"main\">"
                              endFlag:@"<nav id=\"nav-below\" class=\"navigation\" role=\"navigation\">"
                             parseDom:@"//article/header/h1/a"];
    }
    
    NSMutableArray *casaTaloyumAry = [self fixedPageNumberURL:2
                                               formatURL:@"http://casatwy.com/index%ld.html"];
    if ([casaTaloyumAry count] > 0) {
        [casaTaloyumAry replaceObjectAtIndex:0 withObject:@"http://casatwy.com/index.html"];
        [self makeTotalPageBlogEntity:array
                               author:@"Casa Taloyum"
                              baseURL:@""
                        archiveURLAry:casaTaloyumAry
                            startFlag:@"<div class=\"col-sm-9\">"
                              endFlag:@"<div class=\"col-sm-3 well well-sm\" id=\"sidebar\">"
                             parseDom:@"//article/h2/a"];
    }

    NSMutableArray *laotanBlogAry = [self fixedPageNumberURL:15
                                               formatURL:@"http://www.tanhao.me/archives/page/%ld/"];
    if ([laotanBlogAry count] > 0) {
        [laotanBlogAry replaceObjectAtIndex:0 withObject:@"http://www.tanhao.me/archives/"];
        [self makeTotalPageBlogEntity:array
                               author:@"老谭笔记"
                              baseURL:@"http://www.tanhao.me/"
                        archiveURLAry:laotanBlogAry
                            startFlag:@"<div id=\"posts\" class=\"posts-collapse\">"
                              endFlag:@"<div class=\"pagination\">"
                             parseDom:@"//div/div/h1/a"];
    }
    
    NSMutableArray *cocoabitAry = [self fixedPageNumberURL:9
                                               formatURL:@"http://blog.cocoabit.com/page/%ld/"];
    if ([cocoabitAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"Cocoabit"
                              baseURL:@"http://blog.cocoabit.com"
                        archiveURLAry:cocoabitAry
                            startFlag:@"<div class=\"posts\">"
                              endFlag:@"<div class=\"pagination\">"
                             parseDom:@"//div/h1/a"];
    }

    NSMutableArray *xiaoxiaotianAry = [self fixedPageNumberURL:5
                                        formatURL:@"http://justsee.iteye.com/category/223124?page=%ld"];
    if ([xiaoxiaotianAry count] > 0) {
        [self makeTotalPageBlogEntity:array
                               author:@"啸笑天"
                              baseURL:@"http://justsee.iteye.com"
                        archiveURLAry:xiaoxiaotianAry
                            startFlag:@"<div id=\"main\">"
                              endFlag:@"<div id=\"local\">"
                             parseDom:@"//div[@class='blog_title']/h3/a"];
    }
}

- (NSArray *)totalPageURL:(NSString *)basePage
            parseTotalDom:(NSString *)parseTotalDom
                formatURL:(NSString *)formatURL {
    NSString* htmlContent = [NSString stringWithContentsOfURL:[NSURL URLWithString:basePage]
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
    
    NSData* dataHtml = [htmlContent dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple* xpathParser = [[TFHpple alloc] initWithHTMLData:dataHtml];
    NSArray* elements = [xpathParser searchWithXPathQuery:parseTotalDom];
    NSInteger pageNumber = 0;
    
    for (TFHppleElement* element in elements) {
        NSString *content = element.content;
        if (content && [content length] > 0) {
            NSArray *array = [content componentsSeparatedByString:@"/"];
            if ([array count]> 1) {
                pageNumber = [array[1] integerValue];
                break;
            }
        }
    }
    
    return [self fixedPageNumberURL:pageNumber formatURL:formatURL];
}

- (NSMutableArray *)fixedPageNumberURL:(NSInteger)totalNum formatURL:(NSString *)formatURL {
    NSMutableArray *urlAry = [NSMutableArray array];
    for (NSInteger index = 1; index <= totalNum; index++) {
        NSString *pageURL = [NSString stringWithFormat:formatURL, (long)index];
        [urlAry addObject:pageURL];
    }
    
    return urlAry;
}

- (void)makeTotalPageBlogEntity:(NSMutableArray*)array
                         author:(NSString*)author
                        baseURL:(NSString*)baseURL
                  archiveURLAry:(NSArray*)archiveURLAry
                      startFlag:(NSString*)startFlag
                        endFlag:(NSString*)endFlag
                       parseDom:(NSString*)parseDom
{
    FWBlogEntity* data = [[FWBlogEntity alloc] init];
    data.dataType = FWDataType_PageData;
    data.author = author;
    data.baseURL = baseURL;
    data.archiveURLAry = archiveURLAry;
    data.startFlag = startFlag;
    data.endFlag = endFlag;
    data.parseDom = parseDom;
    [array addObject:data];
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
    NSInteger pageMaxNum = MAX(pageAryCount / 10, 2);
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

    NSLog(@"%s, Thread number:%ld", __FUNCTION__, (count + pageCount));
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^() {
        blok(resultAry);
    });
}

- (BOOL)parseBaseData:(FWBlogEntity*)blogData
{
    blogData.itemAry = [self parseSinglePage:blogData url:blogData.archiveURL];
    return YES;
}

- (BOOL)parsePageData:(FWBlogEntity*)blogData
{
    NSMutableArray *itemAry = [NSMutableArray array];
    NSInteger indexNumber = 0;
    NSArray *tmpAry = nil;
    
    for (NSString *indexURL in blogData.archiveURLAry) {
        
        // 多个页面时第一个页面有可能有变化，因此从第二个页面开始使用缓存
        if (indexNumber > 0) {
            if (!_saveDataDic) {
                _saveDataDic = [NSMutableDictionary dictionary];
            }
            
            tmpAry = [_saveDataDic objectForKey:indexURL];
            if (!tmpAry || [tmpAry count] <= 0) {
                tmpAry = [self parseSinglePage:blogData url:indexURL];
                
                if (tmpAry) {
                    [_saveDataDic setObject:tmpAry forKey:indexURL];
                }
            }
        }
        else {
            tmpAry = [self parseSinglePage:blogData url:indexURL];
        }
        
        [itemAry addObjectsFromArray:tmpAry];
        indexNumber++;
    }
    
    blogData.itemAry = itemAry;
    NSLog(@"%s, author:%@, count:%ld", __FUNCTION__, blogData.author, [blogData.itemAry count]);
    return YES;
}

- (NSArray *)parseSinglePage:(FWBlogEntity*)blogData url:(NSString *)url {
    NSMutableArray* resultAry = [[NSMutableArray alloc] init];
    NSError *error = nil;
    NSString* htmlContent = [NSString stringWithContentsOfURL:[NSURL URLWithString:url]
                                                     encoding:NSUTF8StringEncoding
                                                    error:&error];
    if (error) {
        htmlContent = [self parsePageByGBK:url];
    }
    
    if ([htmlContent length]<= 0) {
        NSLog(@"%s, the htmlContent:%@ is empty, error:%@", __FUNCTION__, htmlContent, [error description]);
        return resultAry;
    }
    
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
    
    for (TFHppleElement* element in elements) {
        
        FWBlogItemEntity* data = [[FWBlogItemEntity alloc] init];
        data.title = element.content;
        
        NSDictionary* elementContent = [element attributes];
        
        NSString *url = [blogData.baseURL stringByAppendingString:[elementContent objectForKey:@"href"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        data.url = url;
        
        [resultAry addObject:data];
    }
    
    return resultAry;
}

- (NSString *)parsePageByGBK:(NSString *)url {
    NSURL *urlURL = [NSURL URLWithString:url];
    NSData *data = [NSData dataWithContentsOfURL:urlURL];
    
    NSString *htmlContent = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    if (nil == htmlContent) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        htmlContent = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:enc];
    }
    
    if (nil == htmlContent) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingHZ_GB_2312);
        htmlContent = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:enc];
    }
    
    return htmlContent;
}

- (void) statisticBlogData:(NSArray *)blogArray wholePage:(NSInteger)wholePage {
    _statisticEnity.authorNumber = [blogArray count] + wholePage;
    _statisticEnity.blogNumber += wholePage;
    
    NSInteger sucessedNumber = wholePage;
    NSInteger errorNumber = 0;
    NSMutableArray *errorAry = [NSMutableArray array];
                     
    for (FWBlogEntity *indexData in blogArray) {
        if ([indexData.itemAry count] <= 0) {
            errorNumber++;
            [errorAry addObject:indexData.author];
            continue;
        }
        
        sucessedNumber++;
        _statisticEnity.blogNumber += [indexData.itemAry count];
    }
    
    _statisticEnity.sucessedNumber = sucessedNumber;
    _statisticEnity.errorNumber = errorNumber;
    _statisticEnity.errorAuthor = errorAry;
    
    if (self.statisticsBlock) {
        self.statisticsBlock(_statisticEnity);
    }
    NSLog(@"%s, statisticEnity:%@", __FUNCTION__, _statisticEnity);
}

- (NSString *)printBOOL:(BOOL)result {
    return result ? @"YES" : @"NO";
}

@end
