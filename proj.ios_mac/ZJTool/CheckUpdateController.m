//
//  CheckUpdateController.m
//  MeshLight
//
//  Created by lizhijian on 15/10/9.
//  Copyright © 2015年 Concox. All rights reserved.
//

#import "CheckUpdateController.h"
#import "ZJRequestDataServer.h"
#import <StoreKit/StoreKit.h>
#import "UIViewController+Category.h"

#define kVersionNeedUpdateAlertTag 100
#ifndef kAppVersion
#define kAppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]      //获取项目版本号
#endif
#ifndef kAppBuildVersion
#define kAppBuildVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]      //获取项目build版本
#endif

@interface CheckUpdateController () <SKStoreProductViewControllerDelegate>

@property (nonatomic,assign) BOOL isTips;
@property (nonatomic,copy) CheckAppUpdateBlock updateBlock;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) NSURLSessionDataTask *checkAppTask;
@property (nonatomic,strong) NSString *updateVersion;
@property (nonatomic,assign) NSInteger buildVersion;
@property (nonatomic,strong) NSString *updateLog;
@property (nonatomic,strong) NSURL *updateUrl;
@property (nonatomic,assign) BOOL isShowing;

@end

@implementation CheckUpdateController
singleton_m(CheckUpdate);

- (void)initData
{
}

- (void)dealloc
{
    [self.timer invalidate];
}

- (void)checkAppUpdateFromFir
{
    NSString *bundleId = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
    NSString *idUrlString = [NSString stringWithFormat:@"https://api.fir.im/apps/latest/%@?api_token=%@&type=ios", bundleId,@"302a74e4208715adfad17fd31b6d3eb5"];
    NSURL *requestURL = [NSURL URLWithString:idUrlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];

    self.checkAppTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self.timer invalidate];

        if (error) {
            NSLog(@"%@",error);
            if (self.updateBlock) {
                self.updateBlock(NO, @"", 0, @"");
            }
        } else {
            NSError *jsonError = nil;
            id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            if (!jsonError && [object isKindOfClass:[NSDictionary class]]) {
                NSLog(@"Version:%Ld,kAppVersion:%ld",[object[@"version"] integerValue],[kAppBuildVersion integerValue]);

                self.updateVersion = object[@"versionShort"];
                self.buildVersion = [object[@"version"] integerValue];
                self.updateLog = object[@"changelog"];
                self.updateUrl = [NSURL URLWithString:object[@"update_url"]];

                [self showUpdateAlertViewCtl:self.updateVersion buildVersion:self.buildVersion updateLog:self.updateLog];
            } else {
                if (self.updateBlock) {
                    self.updateBlock(NO, @"", 0, @"");
                }
            }
        }
    }];

    [self.checkAppTask resume];
}

- (void)checkAppUpdateTimeOut:(NSTimer *)timer
{
    [self.timer invalidate];
    _timer = nil;
    [self.checkAppTask cancel];
    
    if ([timer isKindOfClass:[NSTimer class]] && self.updateBlock) {
        self.updateBlock(NO, @"", 0, @"");
    }
}

- (void)showUpdateAlertViewCtl:(NSString *)updateVersion buildVersion:(NSInteger)buildVersion updateLog:(NSString *)log
{
    NSInteger newVersionNum = 0;
    NSArray *array = [self.updateVersion componentsSeparatedByString:@"."];
    if (array.count >= 3) {
        NSString *str1 = [array objectAtIndex:0];
        NSString *str2 = [array objectAtIndex:1];
        NSString *str3 = [array objectAtIndex:2];
        newVersionNum = [str1 intValue]*65536+[str2 intValue]*256+[str3 intValue];
    }
    
    NSInteger localVersionNum = 0;
    array = [kAppVersion componentsSeparatedByString:@"."];
    if (array.count >= 3) {
        NSString *str1 = [array objectAtIndex:0];
        NSString *str2 = [array objectAtIndex:1];
        NSString *str3 = [array objectAtIndex:2];
        localVersionNum = [str1 intValue]*65536+[str2 intValue]*256+[str3 intValue];
    }
    
    if (!self.timer.isValid && (self.buildVersion > [kAppBuildVersion integerValue] || newVersionNum > localVersionNum)) {
        if (self.updateBlock) {       
            self.updateBlock(YES, updateVersion, buildVersion, log);
        }
        
        if (self.isTips && !self.isShowing) {
            NSString *log = [NSString stringWithFormat:@"%@\n%@",[NSString stringWithFormat:NSLocalizedString(@"Your current version is V%@(%ld), found the new version V%@(%ld): ",nil), kAppVersion, [kAppBuildVersion integerValue], self.updateVersion, self.buildVersion], self.updateLog];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Update Content",nil) message:log preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Next Time",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                self.isShowing = NO;
            }];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"To Update",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.isShowing = NO;
                [self jumpUpdateURLWeb];
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            
            if (self.updateLog && ![self.updateLog isEqualToString:@""]) {
                UIView *subView1 = alertController.view.subviews[0];
                UIView *subView2 = subView1.subviews[0];
                UIView *subView3 = subView2.subviews[0];
                UIView *subView4 = subView3.subviews[0];
                UIView *subView5 = subView4.subviews[0];
                UILabel *message = subView5.subviews[1];
                message.textAlignment = NSTextAlignmentLeft;    //内容靠左
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isShowing = YES;
                [[UIViewController currentViewController] presentViewController:alertController animated:YES completion:nil];
            });
        }
    } else {
        if (self.updateBlock) {
            self.updateBlock(NO, updateVersion, buildVersion, log);
        }
    }

}

- (void)jumpUpdateURLWeb
{
    if ([[UIApplication sharedApplication] canOpenURL:self.updateUrl]) {
        if ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0) {
            [[UIApplication sharedApplication] openURL:self.updateUrl options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:self.updateUrl];
        }
    }
}

#pragma mark - PublicAPI

- (void)checkAppUpdate:(BOOL)isTips block:(CheckAppUpdateBlock)updateBlock
{
    self.isTips = isTips;
    self.updateBlock = updateBlock;
    [self checkAppUpdateTimeOut:nil];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(checkAppUpdateTimeOut:) userInfo:nil repeats:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self checkAppUpdateFromFir];
    });
}

- (BOOL)showUpdateContent
{
    if (self.updateVersion && self.buildVersion) {
        self.isTips = YES;
        [self showUpdateAlertViewCtl:self.updateVersion buildVersion:self.buildVersion updateLog:self.updateLog];
        return YES;
    }
    
    return NO;
}

@end
