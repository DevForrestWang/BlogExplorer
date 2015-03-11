//
//  AppDelegate.m
//  BlogExplorer
//
//  Created by Forrest on 15-3-9.
//  Copyright (c) 2015年 Forrest. All rights reserved.
//

#import "AppDelegate.h"
#import "FWBlogDataManager.h"
#import "FWBlogEntity.h"
#import "FWUtility.h"

@interface AppDelegate () <NSOutlineViewDelegate, NSOutlineViewDataSource>

@property (nonatomic, assign) BOOL showBlogView;
@property (nonatomic, strong) NSMutableArray* topLevelItems;
@property (nonatomic, strong) NSMutableDictionary* blogDataDic;
@property (nonatomic, strong) NSMutableDictionary* titleToURLDic;
@property (nonatomic, strong) FWBlogDataManager *blogManager;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification
{
    //设置delegate
    [_webView setFrameLoadDelegate:self];
    [_webView setPolicyDelegate:self];
    
    [[_webView preferences] setPlugInsEnabled:YES];
    NSString* urlString = @"http://objccn.io/";
    [_navbar setStringValue:urlString];
    [self loadRequest];
    
    _showBlogView = YES;
    _topLevelItems = [NSMutableArray array];
    _blogDataDic = [NSMutableDictionary dictionary];
    _titleToURLDic = [NSMutableDictionary dictionary];
    
    _blogManager = [[FWBlogDataManager alloc] init];
    [_blogManager initURLData];
    
    __weak AppDelegate *weekThis = self;
    [_blogManager parseData:YES block:^(NSArray *blogAry) {
        [weekThis refreshData:blogAry];
    }];
}

- (IBAction)enterGo:(id)sender
{
    [self loadRequest];
}

- (IBAction)clickGo:(id)sender
{
    [self loadRequest];
}

- (IBAction)blogButonAction:(NSButton*)sender
{
    _showBlogView = !_showBlogView;
    CGFloat width = _window.frame.size.width;

    if (_showBlogView) {
        [_searchTextField setHidden:NO];
        [_blogListScrollView setHidden:NO];

        CGRect frame = _webView.frame;
        frame.origin.x = 314;
        frame.size.width = width - 314;
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
- (void)loadRequest
{
    NSString* urlString = [_navbar stringValue];
    if (![urlString hasPrefix:@"http://"]) {
        urlString = [NSString stringWithFormat:@"http://%@", urlString];
    }
    [[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

#pragma mark - webview deleage
- (void)webView:(WebView*)sender didStartProvisionalLoadForFrame:(WebFrame*)frame
{
    //开始加载,可以在这里加loading
    NSString* currentURL = [_webView mainFrameURL];
    [_navbar setStringValue:currentURL];
}

- (void)webView:(WebView*)sender didReceiveTitle:(NSString*)title forFrame:(WebFrame*)frame
{
    //收到标题，把标题展示到窗口上面
    if (frame == [sender mainFrame]) {
        [[sender window] setTitle:title];
    }
}

- (void)webView:(WebView*)sender didFinishLoadForFrame:(WebFrame*)frame
{
    //设置前进，后退按钮的状态
    if (frame == [sender mainFrame]) {
        [_btnGoBack setEnabled:[sender canGoBack]];
        [_btnGoForward setEnabled:[sender canGoForward]];
    }
}

- (void)webView:(WebView*)sender didFailProvisionalLoadWithError:(NSError*)error forFrame:(WebFrame*)frame
{
}

- (void)webView:(WebView*)sender didFailLoadWithError:(NSError*)error forFrame:(WebFrame*)frame
{
}

- (void)webView:(WebView*)sender decidePolicyForNewWindowAction:(NSDictionary*)actionInformation request:(NSURLRequest*)request newFrameName:(NSString*)frameName decisionListener:(id<WebPolicyDecisionListener>)listener
{
    //网页里面target=_blank的链接，在这里捕获，并在这里控制对该事件的处理。
    NSURL* URL = [request URL];
    
    //在当前窗口打开
    [[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:URL]];
    //也可以用默认浏览器打开
    //[[NSWorkspace sharedWorkspace] openURL:URL];
    //或者也可以加代码，新建一个tab打开
}

#pragma mark - NSTableViewDelegate
- (void)refreshData:(NSArray *)dataAry
{
    if ((!dataAry) || ([dataAry count] <= 0)) {
        NSLog(@"%s, the dataAry is empty.", __FUNCTION__);
        return;
    }
    
    for (FWBlogEntity *indexEntity in dataAry) {
        [_topLevelItems addObject:indexEntity.author];
        
        NSMutableArray* array = [NSMutableArray array];
        for (FWBlogItemEntity *itemEntity in indexEntity.itemAry) {
            [array addObject:itemEntity.title];
            [_titleToURLDic setObject:itemEntity.url forKey:itemEntity.title];
        }
        
        if ([array count] > 0) {
            [_blogDataDic setObject:array forKey:indexEntity.author];
        }
        else {
            [_titleToURLDic setObject:indexEntity.baseURL forKey:indexEntity.author];
        }
    }
    
    [_blogOutlineView sizeLastColumnToFit];
    [_blogOutlineView reloadData];
    [_blogOutlineView setFloatsGroupRows:YES];
    [_blogOutlineView setRowSizeStyle:NSTableViewRowSizeStyleDefault];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0];
    [_blogOutlineView expandItem:nil expandChildren:NO];
    [NSAnimationContext endGrouping];
}

- (NSArray*)childrenForItem:(id)item
{
    NSArray* tempAry = nil;
    if (item == nil) {
        tempAry = _topLevelItems;
    }
    else {
        tempAry = [_blogDataDic objectForKey:item];
    }
    return tempAry;
}

#pragma mark - NSOutlineViewDelegate NSOutlineViewDataSource
- (NSInteger)outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item
{
    return [[self childrenForItem:item] count];
}

- (BOOL)outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item
{
    if ([outlineView parentForItem:item] == nil) {
        return YES;
    }
    else {
        return NO;
    }
}

- (id)outlineView:(NSOutlineView*)outlineView child:(NSInteger)index ofItem:(id)item
{
    return [[self childrenForItem:item] objectAtIndex:index];
}

- (id)outlineView:(NSOutlineView*)outlineView objectValueForTableColumn:(NSTableColumn*)tableColumn byItem:(id)item
{
    return item;
}

- (void)outlineViewSelectionDidChange:(NSNotification*)notification
{
    if ([_blogOutlineView selectedRow] != -1) {
        NSString* title = [_blogOutlineView itemAtRow:[_blogOutlineView selectedRow]];
        NSString* strURL = [_titleToURLDic objectForKey:title];
        
        if (![FWUtility invalidString:strURL]) {
            [_navbar setStringValue:strURL];
            [self loadRequest];
        }
    }
}

@end
