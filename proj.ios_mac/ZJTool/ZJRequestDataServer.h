//
//  ZJRequestDataServer.h
//  
//
//  Created by lizhijian on 15-4-7.
//  Copyright (c) 2015年 concox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "Singleton.h"

typedef enum : NSUInteger {
    kNotReachable = 0, // Apple's code depends upon 'NotReachable' being the same value as 'NO'.
    kReachableViaWiFi,
    kReachableViaWWAN, // Switched order from Apple's enum. WWAN is active before WiFi.
} ZJNetworkStatus;

extern NSString *const kApplicationNetworkStateChange;  //网络状态发生改变
extern NSString *const kApplicationNotNetwork;          //无网状态

typedef void (^StateCodeBlock)(NSInteger result);
typedef void (^CompletionBlock)(id result);
typedef void (^FailureBlock)(NSError *error);

@interface ZJRequestDataServer : NSObject
singleton_h(Tool);

//请求服务器数据
+ (AFHTTPSessionManager *)defaultManager;

//访问服务器文本数据
+ (AFHTTPSessionManager *)defaultTextManager;

//文件下载
+ (AFHTTPSessionManager *)defaultDownloadManager;

//访问本地缓存，若不存在则不加载
+ (AFHTTPSessionManager *)defaultLocalManager;

//访问本地缓存。若不存在则访问原始地址
+ (AFHTTPSessionManager *)defaultCacheManager;

/**
 只访问原始地址，忽略缓存

 @param url <#url description#>
 @param isFormData <#isFormData description#>
 @param params <#params description#>
 @param httpMethod <#httpMethod description#>
 @param completedBlock <#completedBlock description#>
 @param failureBlock <#failureBlock description#>
 @return <#return value description#>
 */
+ (NSURLSessionDataTask *)requestWithURL:(NSString *)url
                                isFormData:(BOOL)isFormData
                                    params:(NSMutableDictionary *)params
                                httpMethod:(NSString *)httpMethod
                            completedBlock:(CompletionBlock)completedBlock
                              failureBlock:(FailureBlock)failureBlock;


/**
 Text文本访问

 @param url <#url description#>
 @param isFormData <#isFormData description#>
 @param params <#params description#>
 @param httpMethod <#httpMethod description#>
 @param completedBlock <#completedBlock description#>
 @param failureBlock <#failureBlock description#>
 @return <#return value description#>
 */
+ (NSURLSessionDataTask *)requestTextWithURL:(NSString *)url
                                    isFormData:(BOOL)isFormData
                                        params:(NSMutableDictionary *)params
                                    httpMethod:(NSString *)httpMethod
                                completedBlock:(CompletionBlock)completedBlock
                                  failureBlock:(FailureBlock)failureBlock;

//文件下载
+ (NSURLSessionDownloadTask *)downloadFileWithOption:(NSDictionary *)paramDic
                                       withInferface:(NSString *)requestURL
                                           savedPath:(NSString *)savedPath
                                     downloadSuccess:(void (^)(NSURLResponse *response, NSURL *filePath))success
                                     downloadFailure:(void (^)(NSURLResponse *response, NSError *error))failure
                                            progress:(void (^)(CGFloat progress))progress
                                           totalSize:(void (^)(unsigned long long))totalSize;


/**
 只访问本地缓存，若不存在本地缓存，则不请求

 @param url <#url description#>
 @param isFormData <#isFormData description#>
 @param params <#params description#>
 @param httpMethod <#httpMethod description#>
 @param completedBlock <#completedBlock description#>
 @param failureBlock <#failureBlock description#>
 @return <#return value description#>
 */
+ (NSURLSessionDataTask *)requestLocalWithURL:(NSString *)url
                              isFormData:(BOOL)isFormData
                                  params:(NSMutableDictionary *)params
                              httpMethod:(NSString *)httpMethod
                          completedBlock:(CompletionBlock)completedBlock
                            failureBlock:(FailureBlock)failureBlock;


/**
 优先访问本地缓存，若不存在则访问原始地址

 @param url <#url description#>
 @param isFormData <#isFormData description#>
 @param params <#params description#>
 @param httpMethod <#httpMethod description#>
 @param completedBlock <#completedBlock description#>
 @param failureBlock <#failureBlock description#>
 @return <#return value description#>
 */
+ (NSURLSessionDataTask *)requestCacheWithURL:(NSString *)url
                                   isFormData:(BOOL)isFormData
                                       params:(NSMutableDictionary *)params
                                   httpMethod:(NSString *)httpMethod
                               completedBlock:(CompletionBlock)completedBlock
                                 failureBlock:(FailureBlock)failureBlock;

//网络请求错误提示
+ (void)requestErrorCode:(NSString *)statusCode  withRequestPage:(NSInteger)page;

//联网状态
+ (BOOL)isReachable;

+ (BOOL)isNetworkReachableViaWWAN;

+ (BOOL)isNetworkReachableViaWiFi;

//网络状态类型
//+ (NetworkStatus)getNetworkReachabilityStatus;

//检测网络变化
+ (void)checkNetworkReachability;

@end
