//
//  AppDelegate.m
//  behance
//
//  Created by zhangjing on 2017/9/25.
//  Copyright © 2017年 214644496@qq.com. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
                    hasVisibleWindows:(BOOL)flag{
    
    [self.rootWindow makeKeyAndOrderFront:self];
    
    return YES;
}

@end
