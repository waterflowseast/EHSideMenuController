//
//  EHSideMenuController.m
//  WFEDemo
//
//  Created by Eric Huang on 17/1/5.
//  Copyright © 2017年 Eric Huang. All rights reserved.
//

#import "EHSideMenuController.h"

static NSTimeInterval const kAnimationDuration = 0.35f;
static CGFloat const kContentViewFadeOutAlpha = 0.4f;
static CGFloat const kPanEdgeThreshold = 20.0f;
static CGFloat const kVelocityThreshold = 100.0f;

@interface EHSideMenuController ()

@property (nonatomic, strong) UIViewController *contentViewController;
@property (nonatomic, strong) UIViewController *menuViewController;

@property (nonatomic, strong) UIView *contentWrapperView;
@property (nonatomic, strong) UIView *menuWrapperView;
@property (nonatomic, strong) UIButton *contentButton;

@property (nonatomic, assign) BOOL hasShownMenu;
@property (nonatomic, assign) BOOL hasNotified;

@property (nonatomic, strong) UIPanGestureRecognizer *pan;

@end

@implementation EHSideMenuController

#pragma mark - lifecycle

- (instancetype)initWithContentViewController:(UIViewController *)contentViewController menuViewController:(UIViewController *)menuViewController {
    self = [super init];
    if (self) {
        _contentViewTranslationX = [UIScreen mainScreen].bounds.size.width * 0.8;
        _contentViewFadeOutAlpha = kContentViewFadeOutAlpha;

        _contentViewController = contentViewController;
        _menuViewController = menuViewController;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.menuWrapperView.frame = self.view.bounds;
    [self.view addSubview:self.menuWrapperView];
    [self addViewController:self.menuViewController toView:self.menuWrapperView belowSubview:nil];
    
    self.contentWrapperView.frame = self.view.bounds;
    [self.view addSubview:self.contentWrapperView];
    [self addViewController:self.contentViewController toView:self.contentWrapperView belowSubview:nil];
    
    self.view.multipleTouchEnabled = NO;
    [self.view addGestureRecognizer:self.pan];
}

#pragma mark - public methods

- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated {
    if (!contentViewController || contentViewController == _contentViewController) {
        return;
    }
    
    if (!animated) {
        [self removeViewController:self.contentViewController];
        [self addViewController:contentViewController toView:self.contentWrapperView belowSubview:self.contentButton];
        self.contentViewController = contentViewController;
        return;
    }
    
    // animated
    [self addChildViewController:contentViewController];
    contentViewController.view.alpha = 0;
    contentViewController.view.frame = self.contentWrapperView.bounds;
    [self view:self.contentWrapperView insertSubview:contentViewController.view belowSubview:self.contentButton];
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        contentViewController.view.alpha = 1;
    } completion:^(BOOL finished) {
        [contentViewController didMoveToParentViewController:self];

        [self removeViewController:self.contentViewController];
        self.contentViewController = contentViewController;
    }];
}

- (void)showMenu {
    self.menuWrapperView.transform = CGAffineTransformMakeTranslation(-self.contentViewTranslationX, 0);
    self.contentWrapperView.transform = CGAffineTransformIdentity;
    self.contentButton.alpha = 0;

    [self willShowMenu];
    [self showMenuAnimated];
}

- (void)showMenuAnimated {
    [self addContentButton];
    [self.menuViewController beginAppearanceTransition:YES animated:YES];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.menuWrapperView.transform = CGAffineTransformIdentity;
        self.contentWrapperView.transform = CGAffineTransformMakeTranslation(self.contentViewTranslationX, 0);
        self.contentButton.alpha = self.contentViewFadeOutAlpha;
    } completion:^(BOOL finished) {
        [self.menuViewController endAppearanceTransition];
        [self didShowMenu];
        self.hasShownMenu = YES;
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

- (void)hideMenu {
    [self willHideMenu];
    [self.menuViewController beginAppearanceTransition:NO animated:YES];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.menuWrapperView.transform = CGAffineTransformMakeTranslation(-self.contentViewTranslationX, 0);
        self.contentWrapperView.transform = CGAffineTransformIdentity;
        self.contentButton.alpha = 0;
    } completion:^(BOOL finished) {
        [self.contentButton removeFromSuperview];
        [self.menuViewController endAppearanceTransition];
        [self didHideMenu];
        self.hasShownMenu = NO;
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([self.contentViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)self.contentViewController;
        if (navController.viewControllers.count > 1) {
            return NO;
        }
    }
    
    if ([self.contentViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabController = (UITabBarController *)self.contentViewController;
        
        if ([tabController.selectedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navController = (UINavigationController *)tabController.selectedViewController;
            if (navController.viewControllers.count > 1) {
                return NO;
            }
        }
    }
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && !self.hasShownMenu) {
        CGPoint point = [touch locationInView:gestureRecognizer.view];
        return point.x < kPanEdgeThreshold;
    }
    
    return YES;
}

#pragma mark - event response

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender {
    CGPoint offset = [sender translationInView:sender.view];
    CGFloat x = 0, ratio = 0;

    if (self.hasShownMenu) {
        x = [self makeFloatValue:offset.x betweenZeroAndThreshold:-self.contentViewTranslationX];
    } else {
        x = [self makeFloatValue:offset.x betweenZeroAndThreshold:self.contentViewTranslationX];
    }
    ratio = fabs(x) / self.contentViewTranslationX;

    if (sender.state == UIGestureRecognizerStateBegan) {
        self.hasNotified = NO;
        if (!self.hasShownMenu) {
            self.contentButton.alpha = 0;
            [self addContentButton];
        }

        return;
    }

    if (sender.state == UIGestureRecognizerStateChanged) {
        if (self.hasShownMenu) {
            self.menuWrapperView.transform = CGAffineTransformMakeTranslation(-self.contentViewTranslationX * ratio, 0);
            self.contentWrapperView.transform = CGAffineTransformMakeTranslation(self.contentViewTranslationX * (1 - ratio), 0);
            self.contentButton.alpha = self.contentViewFadeOutAlpha * (1 - ratio);
        } else {
            self.menuWrapperView.transform = CGAffineTransformMakeTranslation(-self.contentViewTranslationX * (1 - ratio), 0);
            self.contentWrapperView.transform = CGAffineTransformMakeTranslation(self.contentViewTranslationX * ratio, 0);
            self.contentButton.alpha = self.contentViewFadeOutAlpha * ratio;
            
            if (!self.hasNotified && x > 0) {
                [self willShowMenu];
                self.hasNotified = YES;
            }
        }

        return;
    }

    if (sender.state == UIGestureRecognizerStateEnded) {
        self.hasNotified = NO;
        CGFloat velocityX = [sender velocityInView:sender.view].x;

        if (velocityX > kVelocityThreshold) {
            [self showMenuAnimated];
            return;
        }

        if (velocityX < -kVelocityThreshold) {
            [self hideMenu];
            return;
        }

        if (self.hasShownMenu) {
            ratio > 0.5 ? [self hideMenu] : [self showMenuAnimated];
        } else {
            ratio > 0.5 ? [self showMenuAnimated] : [self hideMenu];
        }

        return;
    }
}

#pragma mark - private methods

- (void)addViewController:(UIViewController *)controller toView:(UIView *)view belowSubview:(UIView *)subview {
    [self addChildViewController:controller];
    controller.view.frame = view.bounds;
    [self view:view insertSubview:controller.view belowSubview:subview];
    [controller didMoveToParentViewController:self];
}

- (void)view:(UIView *)view insertSubview:(UIView *)subview belowSubview:(UIView *)siblingSubview {
    if (siblingSubview.superview == view) {
        [view insertSubview:subview belowSubview:siblingSubview];
    } else {
        [view addSubview:subview];
    }
}

- (void)removeViewController:(UIViewController *)controller {
    [controller willMoveToParentViewController:nil];
    [controller.view removeFromSuperview];
    [controller removeFromParentViewController];
}

- (void)addContentButton {
    if (self.contentButton.superview) {
        [self.contentButton removeFromSuperview];
    }

    self.contentButton.frame = self.contentWrapperView.bounds;
    [self.contentWrapperView addSubview:self.contentButton];
}

- (void)willShowMenu {
    if ([self.delegate respondsToSelector:@selector(sideMenuController:willShowMenu:)]) {
        [self.delegate sideMenuController:self willShowMenu:self.menuViewController];
    }
}

- (void)didShowMenu {
    if ([self.delegate respondsToSelector:@selector(sideMenuController:didShowMenu:)]) {
        [self.delegate sideMenuController:self didShowMenu:self.menuViewController];
    }
}

- (void)willHideMenu {
    if ([self.delegate respondsToSelector:@selector(sideMenuController:willHideMenu:)]) {
        [self.delegate sideMenuController:self willHideMenu:self.menuViewController];
    }
}

- (void)didHideMenu {
    if ([self.delegate respondsToSelector:@selector(sideMenuController:didHideMenu:)]) {
        [self.delegate sideMenuController:self didHideMenu:self.menuViewController];
    }
}

- (CGFloat)makeFloatValue:(CGFloat)floatValue betweenZeroAndThreshold:(CGFloat)threshold {
    CGFloat min = MIN(0, threshold);
    CGFloat max = MAX(0, threshold);
    
    if (floatValue < min) {
        return min;
    } else if (floatValue > max) {
        return max;
    } else {
        return floatValue;
    }
}

#pragma mark - getters & setters

- (void)setContentViewTranslationX:(CGFloat)contentViewTranslationX {
    CGFloat minTranslation = [UIScreen mainScreen].bounds.size.width * 0.1;
    CGFloat maxTranslation = [UIScreen mainScreen].bounds.size.width * 0.9;
    
    if (contentViewTranslationX < minTranslation) {
        _contentViewTranslationX = minTranslation;
    } else if (contentViewTranslationX > maxTranslation) {
        _contentViewTranslationX = maxTranslation;
    } else {
        _contentViewTranslationX = contentViewTranslationX;
    }
}

- (UIView *)contentWrapperView {
    if (!_contentWrapperView) {
        _contentWrapperView = [[UIView alloc] init];
    }
    
    return _contentWrapperView;
}

- (UIView *)menuWrapperView {
    if (!_menuWrapperView) {
        _menuWrapperView = [[UIView alloc] init];
    }
    
    return _menuWrapperView;
}

- (UIButton *)contentButton {
    if (!_contentButton) {
        _contentButton = [[UIButton alloc] init];
        _contentButton.backgroundColor = [UIColor blackColor];
        [_contentButton addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _contentButton;
}

- (UIPanGestureRecognizer *)pan {
    if (!_pan) {
        _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        _pan.delegate = self;
    }
    
    return _pan;
}

@end
