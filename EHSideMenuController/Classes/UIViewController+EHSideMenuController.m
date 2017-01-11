//
//  UIViewController+EHSideMenuController.m
//  WFEDemo
//
//  Created by Eric Huang on 17/1/5.
//  Copyright © 2017年 Eric Huang. All rights reserved.
//

#import "UIViewController+EHSideMenuController.h"
#import "EHSideMenuController.h"

@implementation UIViewController (EHSideMenuController)

- (EHSideMenuController *)eh_sideMenuController {
    UIViewController *controller = self.parentViewController;
    while (controller) {
        if ([controller isKindOfClass:[EHSideMenuController class]]) {
            break;
        } else {
            controller = controller.parentViewController;
        }
    }

    return (EHSideMenuController *)controller;
}

@end
