//
//  UIViewController+EHSideMenuController.h
//  WFEDemo
//
//  Created by Eric Huang on 17/1/5.
//  Copyright © 2017年 Eric Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EHSideMenuController;

@interface UIViewController (EHSideMenuController)

@property (nonatomic, strong, readonly) EHSideMenuController *eh_sideMenuController;

@end
