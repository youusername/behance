//
//  CODNavigationController.h
//  OSXNavigationController
//
//  Created by David Santana Molina on 23/10/14.
//  Copyright (c) 2014 2Coders Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CODNavigationController : NSViewController

@property (nonatomic,strong) NSView * contentView;

- (instancetype)initWithRootViewController:(NSViewController*)controller;
- (void)popViewControllerAnimated:(BOOL)animated;
- (void)pushViewController:(NSViewController*)controller animated:(BOOL)animated;

@end


@interface CODBaseViewController : NSViewController

@property (nonatomic,weak) CODNavigationController * navigationController;


@end


