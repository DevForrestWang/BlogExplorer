//
//  AppDelegate.m
//  BlogExplorer
//
//  Created by Forrest on 15-3-9.
//  Copyright (c) 2015年 Forrest. All rights reserved.
//

#import "AppDelegate.h"
#import "TFHpple.h"

#import "FWBlogEntity.h"

@interface AppDelegate () <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, assign) BOOL showBlogView;
@property (nonatomic, strong) NSMutableArray* titleAry;
@property (nonatomic, strong) NSMutableArray *blogURLAry;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)awakeFromNib
{
    //设置delegate
    [_webView setFrameLoadDelegate:self];
    [_webView setPolicyDelegate:self];

    [[_webView preferences] setPlugInsEnabled:YES];
    NSString* urlString = @"http://www.baidu.com";
    [_navbar setStringValue:urlString];
    [self onGo];

    _showBlogView = YES;
    _titleAry = [NSMutableArray array];
    _blogURLAry = [NSMutableArray array];
    
    _blogTableView.delegate = self;
    _blogTableView.dataSource = self;
    
    [self initBlogData];
    
    [_titleAry removeAllObjects];
    for (FWBlogEntity *blogIndex in _blogURLAry) {
        NSArray *array = [self analyticalTitle:blogIndex];
        [_titleAry addObjectsFromArray:array];
    }
    
    if ([_titleAry count] >0) {
        [_blogTableView reloadData];
    }
}

//回车访问网站
- (IBAction)enterToGo:(id)sender
{
    [self onGo];
}

//点击Go按钮访问网站
- (IBAction)clickTogo:(id)sender
{
    [self onGo];
}

- (IBAction)blogButonAction:(NSButton*)sender
{
    _showBlogView = !_showBlogView;
    CGFloat width = _window.frame.size.width;

    if (_showBlogView) {
        [_searchTextField setHidden:NO];
        [_blogListScrollView setHidden:NO];

        CGRect frame = _webView.frame;
        frame.origin.x = 270;
        frame.size.width = width - 270;
        _webView.frame = frame;
    }
    else {
        [_searchTextField setHidden:YES];
        [_blogListScrollView setHidden:YES];

        CGRect frame = _webView.frame;
        frame.origin.x = 0;
        frame.size.width = width;
        _webView.frame = frame;
    }
}

#pragma mark - Private method
//加载网站
- (void)onGo
{
    NSString* urlString = [_navbar stringValue];
    if (![urlString hasPrefix:@"http://"]) {
        urlString = [NSString stringWithFormat:@"http://%@", urlString];
    }
    [[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

-(void)initBlogData
{
//    FWBlogEntity *devtang = [[FWBlogEntity alloc] init];
//    devtang.author = @"唐乔";
//    devtang.baseURL = @"http://www.devtang.com";
//    devtang.archiveURL = @"http://www.devtang.com/blog/archives/";
//    devtang.startFlag = @"<div id=\"blog-archives\">";
//    devtang.endFlag = @"<aside class=\"sidebar\">";
//    devtang.parseDom = @"//h1/a";
//    [_blogURLAry addObject:devtang];
    
    
//    FWBlogEntity *tony = [[FWBlogEntity alloc] init];
//    tony.author = @"Tony";
//    tony.baseURL = @"";
//    tony.archiveURL = @"http://itony.me/archives";
//    tony.startFlag = @"<div class=\"pta-postarchives\">";
//    tony.endFlag = @"<footer class=\"entry-meta\">";
//    tony.parseDom = @"//li/a";
//    [_blogURLAry addObject:tony];
    
    FWBlogEntity *beyondvincent = [[FWBlogEntity alloc] init];
    beyondvincent.author = @"破船之家";
    beyondvincent.baseURL = @"http://beyondvincent.com";
    beyondvincent.archiveURL = @"http://beyondvincent.com/archives/";
    beyondvincent.startFlag = @"<div class=\"mid-col\">";
    beyondvincent.endFlag = @"<footer id=\"footer\">";
    beyondvincent.parseDom = @"//h1/a";
    [_blogURLAry addObject:beyondvincent];
    
}

- (NSMutableArray*)analyticalTitle:(FWBlogEntity *) blogData
{
    NSMutableArray* resultAry = [[NSMutableArray alloc] init];
    NSString* htmlContent = [NSString stringWithContentsOfURL:[NSURL URLWithString:blogData.archiveURL]
                                                     encoding:NSUTF8StringEncoding error:nil];
    NSRange range = [htmlContent rangeOfString:blogData.startFlag];
    if (range.length == 0) {
        return resultAry;
    }
    NSString* tmpHtml = [htmlContent substringFromIndex:range.location + range.length];
    
    range = [tmpHtml rangeOfString:blogData.endFlag];
    if (range.length == 0) {
        return resultAry;
    }
    tmpHtml = [tmpHtml substringToIndex:range.location];

    NSData* dataHtml = [tmpHtml dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple* xpathParser = [[TFHpple alloc] initWithHTMLData:dataHtml];
    NSArray* elements = [xpathParser searchWithXPathQuery:blogData.parseDom];

    for (TFHppleElement* element in elements) {
        
        FWBlogItemEntity *data = [[FWBlogItemEntity alloc] init];
        data.title = element.content;
        
        NSDictionary* elementContent = [element attributes];
        data.url = [blogData.baseURL stringByAppendingString:[elementContent objectForKey:@"href"]];
        
        [resultAry addObject:data];
    }

    NSLog(@"%s, resultAry:%@", __FUNCTION__, resultAry);
    return resultAry;
}

#pragma mark - webview deleage
//开始加载,可以在这里加loading
- (void)webView:(WebView*)sender didStartProvisionalLoadForFrame:(WebFrame*)frame
{
    NSString* currentURL = [_webView mainFrameURL];
    [_navbar setStringValue:currentURL];
}

//收到标题，把标题展示到窗口上面
- (void)webView:(WebView*)sender didReceiveTitle:(NSString*)title forFrame:(WebFrame*)frame
{
    // Report feedback only for the main frame.
    if (frame == [sender mainFrame]) {
        [[sender window] setTitle:title];
    }
}

//加载完成
- (void)webView:(WebView*)sender didFinishLoadForFrame:(WebFrame*)frame
{
    //设置前进，后退按钮的状态
    if (frame == [sender mainFrame]) {
        [_btnGoBack setEnabled:[sender canGoBack]];
        [_btnGoForward setEnabled:[sender canGoForward]];
    }
}

//错误处理
- (void)webView:(WebView*)sender didFailProvisionalLoadWithError:(NSError*)error forFrame:(WebFrame*)frame
{
}

//错误处理
- (void)webView:(WebView*)sender didFailLoadWithError:(NSError*)error forFrame:(WebFrame*)frame
{
}

//网页里面target=_blank的链接，在这里捕获，并在这里控制对该事件的处理。
- (void)webView:(WebView*)sender decidePolicyForNewWindowAction:(NSDictionary*)actionInformation request:(NSURLRequest*)request newFrameName:(NSString*)frameName decisionListener:(id<WebPolicyDecisionListener>)listener
{
    NSURL* URL = [request URL];
    //在当前窗口打开
    [[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:URL]];
    //也可以用默认浏览器打开
    //[[NSWorkspace sharedWorkspace] openURL:URL];
    //或者也可以加代码，新建一个tab打开
}

#pragma mark - Table deleage
- (NSView*)tableView:(NSTableView*)tableView viewForTableColumn:(NSTableColumn*)tableColumn row:(NSInteger)row
{
    NSTableCellView* cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    FWBlogItemEntity *data = [_titleAry objectAtIndex:row];
    cellView.textField.stringValue = data.title;
    return cellView;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView*)tableView
{
    return [_titleAry count];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = [_blogTableView selectedRow];
    FWBlogItemEntity *data = [_titleAry objectAtIndex:row];
    
    [_navbar setStringValue:data.url];
    [self onGo];
}

@end
