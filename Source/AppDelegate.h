//
//  GisterAppDelegate.h
//  Gister
//
//  Created by David Keegan on 12/12/10.
//  Copyright 2010 InScopeApps{+}. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GistManager/GistManager.h>
#import "GistView.h"

@interface AppDelegate : NSObject {
    NSWindow *window;
    NSOutlineView *listView;
    GistView *gistView;
    NSArray *gists;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSOutlineView *listView;
@property (assign) IBOutlet GistView *gistView;
@property (nonatomic, retain) NSArray *gists;

@end

@interface AppDelegate(GistList)

@end
