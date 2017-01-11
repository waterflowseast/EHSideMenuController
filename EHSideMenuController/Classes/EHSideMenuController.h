//
//  EHSideMenuController.h
//  WFEDemo
//
//  Created by Eric Huang on 17/1/5.
//  Copyright © 2017年 Eric Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EHSideMenuController;

@protocol EHSideMenuControllerDelegate <NSObject>

@optional
- (void)sideMenuController:(EHSideMenuController *)sideMenuController willShowMenu:(UIViewController *)menu;
- (void)sideMenuController:(EHSideMenuController *)sideMenuController didShowMenu:(UIViewController *)menu;
- (void)sideMenuController:(EHSideMenuController *)sideMenuController willHideMenu:(UIViewController *)menu;
- (void)sideMenuController:(EHSideMenuController *)sideMenuController didHideMenu:(UIViewController *)menu;

@end

@interface EHSideMenuController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGFloat contentViewTranslationX;
@property (nonatomic, assign) CGFloat contentViewFadeOutAlpha;
@property (nonatomic, assign) id<EHSideMenuControllerDelegate> delegate;

- (instancetype)initWithContentViewController:(UIViewController *)contentViewController menuViewController:(UIViewController *)menuViewController;
- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated;
- (void)showMenu;
- (void)hideMenu;

@end
