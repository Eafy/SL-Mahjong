//
//  CheckUpdateController.h
//  MeshLight
//
//  Created by lizhijian on 15/10/9.
//  Copyright © 2015年 Concox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

typedef void (^CheckAppUpdateBlock)(BOOL isHadUpdate, NSString *version, NSInteger buildVersion, NSString *updateLog);

@interface CheckUpdateController : NSObject
singleton_h(CheckUpdate);

- (void)checkAppUpdate:(BOOL)isTips block:(CheckAppUpdateBlock)updateBlock;     //若获取失败或超时，buildVersion为0

- (BOOL)showUpdateContent;

@end
