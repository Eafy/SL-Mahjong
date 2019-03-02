//
//  Singleton.h
//  IOTCCamera
//
//  Created by lzj<lizhijian_21@163.com> on 2018/5/11.
//  Copyright © 2018年 concox. All rights reserved.
//
//单例模式宏,头文件宏：singleton_h(name)，实现文件宏：singleton_m(name)。
//比如单列类名为：shareAudioTool,头文件加入singleton_h(AudioTool)，实现文件：singleton_m(AudioTool);
//需添加初始化数据接口：-initData方法，如下
/*
 - (void)initData {
 //初始化数据
 }
 */

#ifndef Singleton_h
#define Singleton_h

// ## : 连接字符串和参数
#define singleton_h(name) + (instancetype)shared##name;

#if __has_feature(objc_arc) // ARC

#define singleton_m(name) \
static id _instance; \
+ (instancetype)allocWithZone:(struct _NSZone *)zone \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super allocWithZone:zone]; \
}); \
return _instance; \
} \
+ (instancetype)shared##name \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [[self alloc] init]; \
}); \
return _instance; \
}\
- (id)copy \
{ \
return _instance; \
} \
- (id)mutableCopy \
{ \
return _instance; \
} \
- (instancetype)init \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super init]; \
if ([self respondsToSelector:@selector(initData)]) { \
[self initData]; \
} \
}); \
return _instance; \
}

#else // 非ARC

#define singleton_m(name) \
static id _instance; \
+ (id)allocWithZone:(struct _NSZone *)zone \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super allocWithZone:zone]; \
}); \
return _instance; \
} \
+ (instancetype)shared##name \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [[self alloc] init]; \
}); \
return _instance; \
} \
- (oneway void)release \
{ \
\
} \
- (id)autorelease \
{ \
return _instance; \
} \
- (id)retain \
{ \
return _instance; \
} \
- (NSUInteger)retainCount \
{ \
return 1; \
} \
+ (id)copyWithZone:(struct _NSZone *)zone \
{ \
return _instance; \
}

#endif

#endif /* Singleton_h */
