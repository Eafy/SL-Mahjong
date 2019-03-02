//
//  UIViewController+Category.h
//  Tycam
//
//  Created by lizhijian on 2017/7/19.
//  Copyright © 2017年 Concox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Category)

/**
 获取当前显示的控制器

 @return UIViewController
 */
+ (UIViewController *_Nullable)currentViewController;


/**
 退出所有控制器，直到与window.rootViewController或destVc相等为止

 @param destVc 中止的控制器类
 */
+ (void)exitViewController:(Class _Nonnull )destVc;


/**
 推出所有控制器直到toVc

 @param currentVc 当前控制器
 @param toVc 终止控制器
 */
+ (void)exitViewController:(UIViewController * _Nullable)currentVc toVC:(Class _Nonnull)toVc;

/**
 显示AlertController弹窗

 @param title 标题
 @param msg 内容
 @param firstBtnName 第一个按键名称，若为nil则不显示
 @param firstHandler firstBtnName按键回调响应
 @param secondBtnName 第二个按键名称，若为nil则不显示，若firstBtnName为nil则显示一个按键
 @param secondHandler secondBtnName按键回调响应
 
 Tips:不允许firstBtnName和secondBtnName同时为nil，否则不显示
 */
- (void)showAlertController:(NSString *_Nullable)title message:(NSString *_Nullable)msg firstBtnName:(NSString *_Nonnull)firstBtnName handler:(void (^ __nullable)(UIAlertAction * _Nullable action))firstHandler secondBtnName:(NSString *_Nullable)secondBtnName handler:(void (^ __nullable)(UIAlertAction * _Nullable action))secondHandler;

- (UIAlertController *_Nullable)initAlertController:(NSString *_Nullable)title message:(NSString *_Nullable)msg firstBtnName:(NSString *_Nonnull)firstBtnName handler:(void (^ __nullable)(UIAlertAction * _Nullable action))firstHandler secondBtnName:(NSString *_Nullable)secondBtnName handler:(void (^ __nullable)(UIAlertAction * _Nullable action))secondHandler thirdBtnName:(NSString *_Nullable)thirdBtnName handler:(void (^ __nullable)(UIAlertAction * _Nullable action))thirdHandler;

@end
