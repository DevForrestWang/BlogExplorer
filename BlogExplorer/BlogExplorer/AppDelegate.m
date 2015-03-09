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

@interface AppDelegate () <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, assign) BOOL showBlogView;
@property (nonatomic, strong) NSMutableArray* blogDataAry;
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
    
    _blogTableView.delegate = self;
    _blogTableView.dataSource = self;
    
    _showBlogView = YES;
    _blogDataAry = [NSMutableArray array];
    _blogManager = [[FWBlogDataManager alloc] init];
    [_blogManager initURLData];
    
    __weak AppDelegate *weekThis = self;
    [_blogManager parseData:YES block:^(NSArray *blogAry) {
        [weekThis.blogDataAry removeAllObjects];
        [weekThis.blogDataAry addObjectsFromArray:blogAry];
        
        if ([weekThis.blogDataAry count] > 0) {
            [weekThis.blogTableView reloadData];
        }
    }];
}

- (IBAction)enterToGo:(id)sender
{
    [self loadRequest];
}

- (IBAction)clickTogo:(id)sender
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
- (NSView*)tableView:(NSTableView*)tableView viewForTableColumn:(NSTableColumn*)tableColumn row:(NSInteger)row
{
    NSTableCellView* cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    FWBlogEntity *data = [_blogDataAry objectAtIndex:row];
    cellView.textField.stringValue = data.author;
    return cellView;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView*)tableView
{
    return [_blogDataAry count];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = [_blogTableView selectedRow];
    FWBlogEntity *data = [_blogDataAry objectAtIndex:row];
    
    [_navbar setStringValue:data.archiveURL];
    [self loadRequest];
}

@end
