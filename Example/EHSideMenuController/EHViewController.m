//
//  EHViewController.m
//  EHSideMenuController
//
//  Created by Eric Huang on 01/08/2017.
//  Copyright (c) 2017 Eric Huang. All rights reserved.
//

#import "EHViewController.h"
#import <Masonry/Masonry.h>
#import <EHSideMenuController/UIViewController+EHSideMenuController.h>
#import <EHSideMenuController/EHSideMenuController.h>

@interface EHViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *button;

@end

@implementation EHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self configureForNavigationBar];
    [self configureForViews];
}

#pragma mark - event response

- (void)buttonPressed {
    UIViewController *controller = [[UIViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.view.backgroundColor = [UIColor whiteColor];
    controller.title = @"awayFromHome";
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - private methods

- (void)configureForNavigationBar {
    self.navigationItem.title = @"Home";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self.eh_sideMenuController action:@selector(showMenu)];
}

- (void)configureForViews {
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    // if navigationController is nil, don't show button
    if (!self.navigationController) {
        return;
    }
    
    [self.view addSubview:self.button];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-60.0f);
        make.size.mas_equalTo(CGSizeMake(160.0f, 30.0f));
    }];
}

#pragma mark - getters & setters

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flowers"]];
    }
    
    return _imageView;
}

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.backgroundColor = [UIColor whiteColor];
        
        [_button setTitle:@"Push Controller" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        _button.clipsToBounds = YES;
        _button.layer.borderWidth = 1.0f;
        _button.layer.borderColor = [UIColor darkGrayColor].CGColor;
        _button.layer.cornerRadius = 15.0f;
        
        [_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _button;
}

@end
