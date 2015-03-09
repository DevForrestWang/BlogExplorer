//
//  AppDelegate.h
//  BlogExplorer
//
//  Created by Forrest on 15-3-9.
//  Copyright (c) 2015年 Forrest. All rights reserved.

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet WebView *webView;
@property (weak) IBOutlet NSButton *blogButton;
@property (weak) IBOutlet NSTextField *navbar;

@property (weak) IBOutlet NSButton *btnGoBack;
@property (weak) IBOutlet NSButton *btnGoForward;

@property (weak) IBOutlet NSSearchField *searchTextField;
@property (weak) IBOutlet NSScrollView *blogListScrollView;
@property (weak) IBOutlet NSTableView *blogTableView;

- (IBAction)enterToGo:(id)sender;
- (IBAction)clickTogo:(id)sender;
- (IBAction)blogButonAction:(NSButton *)sender;

@end
