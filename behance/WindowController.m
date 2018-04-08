//
//  WindowController.m
//  magnetX
//
//  Created by phlx-mac1 on 16/10/20.
//  Copyright © 2016年 214644496@qq.com. All rights reserved.
//

#import "WindowController.h"
#import "AppDelegate.h"

@interface WindowController ()
@property BOOL mouseDownInTopToolBar;
@property (assign) NSPoint initialLocation;

@end

@implementation WindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    AppDelegate* app =(AppDelegate*)[NSApplication sharedApplication].delegate;
    app.rootWindow = self.window;
//    self.window.titleVisibility = NSWindowTitleHidden;
//    self.window.styleMask |= NSWindowStyleMaskFullSizeContentView;
//    self.window.titlebarAppearsTransparent = YES;
    
    
}


- (void)mouseDown:(NSEvent *)theEvent
{
    self.initialLocation = [theEvent locationInWindow];
    NSRect windowFrame = [self.window frame];
    CGFloat heightOfTitleBarAndTopToolBar = 65;
    NSRect titleFrame = NSMakeRect(0, windowFrame.size.height-heightOfTitleBarAndTopToolBar, windowFrame.size.width, heightOfTitleBarAndTopToolBar);
    
    if(NSPointInRect(self.initialLocation, titleFrame))
    {
        self.mouseDownInTopToolBar = YES;
//        NSLog(@"Mouse IN");
    }
}

-(void)mouseUp:(NSEvent *)theEvent
{
    self.mouseDownInTopToolBar = NO;
//    NSLog(@"Mouse UP");
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if( self.mouseDownInTopToolBar )
    {
        NSRect screenVisibleFrame = [[NSScreen mainScreen] visibleFrame];
        NSRect windowFrame = [self.window frame];
        
        NSPoint newOrigin = windowFrame.origin;
        NSPoint currentLocation = [theEvent locationInWindow];
        
        
        
        // Update the origin with the difference between the new mouse location and the old mouse location.
        newOrigin.x += (currentLocation.x - self.initialLocation.x);
        newOrigin.y += (currentLocation.y - self.initialLocation.y);
        
        // Don't let window get dragged up under the menu bar
        if ((newOrigin.y + windowFrame.size.height) > (screenVisibleFrame.origin.y + screenVisibleFrame.size.height)) {
            newOrigin.y = screenVisibleFrame.origin.y + (screenVisibleFrame.size.height - windowFrame.size.height);
        }
        
        [self.window setFrameOrigin:newOrigin];
    }
}


@end
