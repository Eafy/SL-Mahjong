//
//  UIViewController+Category.m
//  Tycam
//
//  Created by lizhijian on 2017/7/19.
//  Copyright © 2017年 Concox. All rights reserved.
//

#import "UIViewController+Category.h"

@implementation UIViewController (Category)

+ (UIViewController *)currentViewController
{
    NSInteger searchCount = 0;
    UIViewController *currentVC = nil;
    UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
    do {
        searchCount ++;
        if ([rootVC isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)rootVC;
            UIViewController *vc = [nav.viewControllers lastObject];
            currentVC = vc;
            rootVC = vc.presentedViewController;
            continue;
        } else if ([rootVC isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabVC = (UITabBarController *)rootVC;
            currentVC = tabVC;
            rootVC = [tabVC.viewControllers objectAtIndex:tabVC.selectedIndex];
            continue;
        }
    } while (rootVC != nil && searchCount < 512);
    
    if (rootVC && [rootVC isKindOfClass:[UIViewController class]]) {
        currentVC = rootVC;
    }
    
    return currentVC;
}


/**
 查找destVc的上一个控制器

 @param destVc 索引控制器
 @return 目标控制器
 */
+ (UIViewController *)findPresentedViewController:(UIViewController *)destVc
{
    BOOL isFind = NO;
    NSInteger searchCount = 0;
    UIViewController *presentedVC = nil;
    UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
    do {
        searchCount ++;
        if ([rootVC isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)rootVC;
            for (UIViewController *vc in nav.viewControllers) {
                if (vc == destVc) {
                    isFind = YES;
                    break;
                }
                presentedVC = vc;
            }
            
            if (!isFind) {
                UIViewController *vc = [nav.viewControllers lastObject];
                rootVC = vc.presentedViewController;
                presentedVC = vc;
            }
        } else if ([rootVC isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabVC = (UITabBarController *)rootVC;
            rootVC = [tabVC.viewControllers objectAtIndex:tabVC.selectedIndex];
            if (rootVC == destVc) {
                isFind = YES;
                break;
            }
            presentedVC = tabVC;
        }
    } while (!isFind && rootVC != nil && searchCount < 128);
    
    return isFind?presentedVC:nil;
}

+ (void)exitViewController:(Class)destVc
{
    NSInteger searchCount = 0;
    UIViewController *vc = [UIViewController currentViewController];
    
    do {
        if ([vc isKindOfClass:destVc]) {
            break;
        } else {
            searchCount ++;
            UIViewController *vcTemp = nil;
            if ([vc isKindOfClass:[UINavigationController class]]) {
                vcTemp = [self findPresentedViewController:vc];
                [vc dismissViewControllerAnimated:NO completion:nil];
            } else if ([vc isKindOfClass:[UIViewController class]]) {
                vcTemp = [[vc.navigationController viewControllers] objectAtIndex:0];
                if (vcTemp == vc) {
                    vcTemp = [self findPresentedViewController:vc];
                    [vc dismissViewControllerAnimated:NO completion:nil];
                } else {
                    [vc.navigationController popToRootViewControllerAnimated:NO];
                }
                
                vc = vcTemp;
            }
        }
    } while (vc && searchCount < 128);
}

+ (void)exitViewController:(UIViewController *)currentVc toVC:(Class)toVc
{
    NSInteger searchCount = 0;
    UIViewController *vc = currentVc;
    
    do {
        if (!vc || [vc isKindOfClass:toVc]) {
            break;
        } else {
            searchCount ++;
            UIViewController *vcTemp = nil;
            if ([vc isKindOfClass:[UINavigationController class]]) {
                vcTemp = [self findPresentedViewController:vc];
                [vc dismissViewControllerAnimated:NO completion:nil];
            } else if ([vc isKindOfClass:[UIViewController class]]) {
                vcTemp = [[vc.navigationController viewControllers] objectAtIndex:0];
                if (vcTemp == vc) {
                    vcTemp = [self findPresentedViewController:vc];
                    [vc dismissViewControllerAnimated:NO completion:nil];
                } else {
                    [vc.navigationController popToRootViewControllerAnimated:NO];
                }
                
                vc = vcTemp;
            }
        }
    } while (vc && searchCount < 128);
}

- (void)showAlertController:(NSString *_Nullable)title message:(NSString *_Nullable)msg firstBtnName:(NSString *_Nonnull)firstBtnName handler:(void (^ __nullable)(UIAlertAction * _Nullable action))firstHandler secondBtnName:(NSString *_Nullable)secondBtnName handler:(void (^ __nullable)(UIAlertAction * _Nullable action))secondHandler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (firstBtnName || secondBtnName) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
            
            if (firstBtnName) {
                UIAlertAction *firstBtnAction = [UIAlertAction actionWithTitle:firstBtnName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    if (firstHandler) {
                        firstHandler(action);
                    }
                    [alertController dismissViewControllerAnimated:YES completion:nil];
                }];
                [alertController addAction:firstBtnAction];
            }
            
            if (secondBtnName) {
                UIAlertAction *secondBtnAction = [UIAlertAction actionWithTitle:secondBtnName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    if (secondHandler) {
                        secondHandler(action);
                    }
                    [alertController dismissViewControllerAnimated:YES completion:nil];
                }];
                [alertController addAction:secondBtnAction];
            }
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    });
}

- (UIAlertController *_Nullable)initAlertController:(NSString *_Nullable)title message:(NSString *_Nullable)msg firstBtnName:(NSString *_Nonnull)firstBtnName handler:(void (^ __nullable)(UIAlertAction * _Nullable action))firstHandler secondBtnName:(NSString *_Nullable)secondBtnName handler:(void (^ __nullable)(UIAlertAction * _Nullable action))secondHandler thirdBtnName:(NSString *_Nullable)thirdBtnName handler:(void (^ __nullable)(UIAlertAction * _Nullable action))thirdHandler
{
    UIAlertController *alertController = nil;
    if (firstBtnName || secondBtnName || thirdBtnName) {
        alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        
        if (title && alertController.preferredStyle == UIAlertControllerStyleActionSheet) {
            NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:title];
            [hogan addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:20.0] range:NSMakeRange(0, title.length)];
            [alertController setValue:hogan forKey:@"attributedTitle"];
        }
        
        if (msg && alertController.preferredStyle == UIAlertControllerStyleActionSheet) {
            NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:msg];
            [hogan addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18.0] range:NSMakeRange(0, msg.length)];
            [alertController setValue:hogan forKey:@"attributedMessage"];
        }
        
        if (firstBtnName) {
            UIAlertAction *firstBtnAction = [UIAlertAction actionWithTitle:firstBtnName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (firstHandler) {
                    firstHandler(action);
                }
                [alertController dismissViewControllerAnimated:YES completion:nil];
            }];
            [alertController addAction:firstBtnAction];
            
//            if (alertController.preferredStyle == UIAlertControllerStyleActionSheet) {
//                NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:firstBtnName];
//                [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0] range:NSMakeRange(0, firstBtnName.length)];
//                if ([firstBtnAction valueForKey:@"title"]) {
//                    [firstBtnAction setValue:alertControllerMessageStr forKey:@"title"];
//                }
//            }
        }
        
        if (secondBtnName) {
            UIAlertAction *secondBtnAction = [UIAlertAction actionWithTitle:secondBtnName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (secondHandler) {
                    secondHandler(action);
                }
                
                [alertController dismissViewControllerAnimated:YES completion:nil];
            }];
            [alertController addAction:secondBtnAction];
            
//            if (alertController.preferredStyle == UIAlertControllerStyleActionSheet) {
//                NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:secondBtnName];
//                [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0] range:NSMakeRange(0, secondBtnName.length)];
//                if ([secondBtnAction valueForKey:@"title"]) {
//                    [secondBtnAction setValue:alertControllerMessageStr forKey:@"title"];
//                }
//            }
        }
        
        if (thirdBtnName) {
            UIAlertAction *thirdBtnAction = [UIAlertAction actionWithTitle:thirdBtnName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (thirdHandler) {
                    thirdHandler(action);
                }
                
                [alertController dismissViewControllerAnimated:YES completion:nil];
            }];
            [alertController addAction:thirdBtnAction];
            
//            if (alertController.preferredStyle == UIAlertControllerStyleActionSheet) {
//                NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:thirdBtnName];
//                [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0] range:NSMakeRange(0, thirdBtnName.length)];
//                if ([thirdBtnAction valueForKey:@"title"]) {
//                    [thirdBtnAction setValue:alertControllerMessageStr forKey:@"title"];
//                }
//            }
        }
    }

    return alertController;
}

@end
