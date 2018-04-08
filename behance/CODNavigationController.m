//
//  CODNavigationController.m
//  OSXNavigationController
//
//  Created by David Santana Molina on 23/10/14.
//  Copyright (c) 2014 2Coders Studio. All rights reserved.
//

#import "CODNavigationController.h"
#import "AppDelegate.h"

@implementation CODBaseViewController

@end

@interface CODNavigationController (){
    
    BOOL isAnimating;
}


@end

@implementation CODNavigationController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}


- (instancetype)initWithRootViewController:(NSViewController *)controller{
    
    if (self = [super init]) {
        
        CGSize size = controller.view.bounds.size;
        self.view = [[NSView alloc]initWithFrame:CGRectMake(0, 0, size.width, size.width)];
        self.contentView = [[NSView alloc]initWithFrame:self.view.frame];
        [self.view addSubview:self.contentView];
        [self addViewOfControllerToTheMainView:controller];
        [self addChildViewController:controller];
        ((CODBaseViewController*)controller).navigationController = self;
    }
    
    return self;
}

- (void)pushViewController:(NSViewController *)controller animated:(BOOL)animated{
    
    if (isAnimating) {
        return;
    }
    
    isAnimating = YES;
    if ([controller isKindOfClass:[CODBaseViewController class]]) {
        
        //1 Check if there already exist this in the pipe
        
        if([self.childViewControllers containsObject:controller]){
            
            NSLog(@"Warning: this controller :%@ already exist in the pipe",controller);
            return;
        }
        
        ((CODBaseViewController*)controller).navigationController = self;
        
        
        if (animated) {//Animated
            
            // calcule frames & positions
            NSViewController * actualVc = self.childViewControllers.lastObject;
            
            CGFloat xPositionNewVc = self.view.bounds.size.width;
            CGFloat xPositionOldVc = actualVc.view.frame.size.width * (-1);
            
            CGRect originalFrameNewController = CGRectMake(xPositionNewVc, controller.view.frame.origin.y, controller.view.frame.size.width, controller.view.frame.size.width);
            
            CGRect newFrameActualViewController = CGRectMake(xPositionOldVc, actualVc.view.frame.origin.y, actualVc.view.frame.size.width, actualVc.view.frame.size.height);
            
            CGRect finalFrameNewController = CGRectMake(0, controller.view.frame.origin.y, controller.view.frame.size.width, controller.view.frame.size.width);
            
            [controller.view setFrame:originalFrameNewController];
            
            
            //manage pre view add
            [super addChildViewController:controller];
            [self addViewOfControllerToTheMainView:controller];
            
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
                context.duration = 0.5f;
                actualVc.view.animator.frame = newFrameActualViewController;
                controller.view.animator.frame = finalFrameNewController;
            } completionHandler:^{
                //remove the last view
                if (self.childViewControllers.count >= 1) {
                    [self removeViewOfControllerFromTheMainView:actualVc];
                }
                isAnimating = NO;
            }];
            
        }else{ //STATIC
            
            
            //2 the controller is only 1
            if (self.childViewControllers.count >= 1) {
                [self hidePreviousControllerView];
            }
            
            [super addChildViewController:controller];
            [self addViewOfControllerToTheMainView:controller];
            
            
        }
        
        
    }else{
        
        NSLog(@"Error: the controller %@ should be CODBaseViewControllar class or subclass ",controller);
    }
}

- (void)popViewControllerAnimated:(BOOL)animated{
    
    if (self.childViewControllers.count == 1) {
        NSLog(@"Error: Can't pop this is the first view controller");
        return;
    }
    
    if (isAnimating) {
        return;
    }
    
    isAnimating = YES;
    if (animated) {
        
        // get the controllers to manage
        
        __block NSViewController * actualVc = self.childViewControllers.lastObject;
        
        NSUInteger controllerToPopIndex =  self.childViewControllers.count - 2;
        
        NSViewController * controllerToPop = self.childViewControllers[controllerToPopIndex];
        
        
        
        // calcule the frames
        
        CGRect finalActualVc = CGRectMake(self.view.bounds.size.
                                          width, actualVc.view.frame.origin.y, actualVc.view.frame.size.width, actualVc.view.frame.size.height);
        CGRect originalNewController = CGRectMake(self.view.bounds.size.width * (-1), controllerToPop.view.frame.origin.y, controllerToPop.view.frame.size.width, controllerToPop.view.frame.size.height);
        
        CGRect finalNewController = CGRectMake(0, controllerToPop.view.frame.origin.y, controllerToPop.view.frame.size.width, controllerToPop.view.frame.size.height);
        
        
        //manage pre view & add
        controllerToPop.view.frame = originalNewController;
        [self.contentView addSubview:controllerToPop.view];
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.duration = 0.5f;
            controllerToPop.view.animator.frame = finalNewController;
            actualVc.view.animator.frame = finalActualVc;
            
        } completionHandler:^{
            //remove the last view
            if (self.childViewControllers.count >= 1) {
                
                [self removeViewOfControllerFromTheMainView:actualVc];
                [actualVc removeFromParentViewController];
                actualVc = nil;
                isAnimating = NO;
                
            }
        }];
        
        
    }else{
        
        NSViewController * controllerToPop =  self.childViewControllers.lastObject;
        [self removeViewOfControllerFromTheMainView:controllerToPop];
        [controllerToPop removeFromParentViewController];
        controllerToPop = nil;
        
        [self addViewOfControllerToTheMainView:self.childViewControllers.lastObject];
        
        
        
    }
    
}

- (void)removeViewOfControllerFromTheMainView:(NSViewController*)controller{
    
    [controller.view removeFromSuperview];
    
}
- (void)addViewOfControllerToTheMainView:(NSViewController*)controller{
    
    [self.contentView addSubview:controller.view];
    
}

- (void)hidePreviousControllerView{
    
    NSViewController * actualController = self.childViewControllers.lastObject;
    if (actualController) {
        [self removeViewOfControllerFromTheMainView:actualController];
    }
    
    
}

@end
