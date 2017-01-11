//
//  EHDemoLeftMenuViewController.m
//  EHSideMenuController
//
//  Created by Eric Huang on 17/1/11.
//  Copyright © 2017年 Eric Huang. All rights reserved.
//

#import "EHDemoLeftMenuViewController.h"
#import <Masonry/Masonry.h>
#import <EHSideMenuController/UIViewController+EHSideMenuController.h>
#import <EHSideMenuController/EHSideMenuController.h>
#import "EHViewController.h"

static NSString * const kDefaultCellIdentifier = @"DefaultCell";

@interface EHDemoLeftMenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation EHDemoLeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self configureForViews];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDefaultCellIdentifier];
    }

    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
    
    NSArray *texts = @[
                       @"UINavigationController inside UITabBarController",
                       @"UINavigationController",
                       @"UIViewController"
                       ];
    cell.textLabel.text = texts[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *controller;
    
    if (indexPath.row == 0) {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[EHViewController alloc] init]];
        navController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:0];

        UITabBarController *tabController = [[UITabBarController alloc] init];
        tabController.viewControllers = @[navController];

        controller = tabController;
    } else if (indexPath.row == 1) {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[EHViewController alloc] init]];

        controller = navController;
    } else {
        EHViewController *viewController = [[EHViewController alloc] init];

        controller = viewController;
    }
    
    [self.eh_sideMenuController setContentViewController:controller animated:YES];
    [self.eh_sideMenuController hideMenu];
}

#pragma mark - private methods

- (void)configureForViews {
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset([UIApplication sharedApplication].statusBarFrame.size.height);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width * 0.8);
    }];
}

#pragma mark - getters & setters

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    
    return _tableView;
}

@end
