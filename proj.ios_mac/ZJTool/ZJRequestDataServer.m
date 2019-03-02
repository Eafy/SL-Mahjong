//
//  ZJRequestDataServer.m
//  
//
//  Created by lizhijian on 15-4-7.
//  Copyright (c) 2015年 concox. All rights reserved.
//

#import "ZJRequestDataServer.h"

NSString *const kApplicationNetworkStateChange = @"kApplicationNetworkStateChange";  //网络状态发生改变
NSString *const kApplicationNotNetwork = @"kApplicationNotNetwork";          //无网状态

@interface ZJRequestDataServer ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) AFHTTPSessionManager *textManager;
@property (nonatomic, strong) AFHTTPSessionManager *downloadManager;
@property (nonatomic, strong) AFHTTPSessionManager *localManager;
@property (nonatomic, strong) AFHTTPSessionManager *cacheManager;

@end

@implementation ZJRequestDataServer
singleton_m(Tool);

- (void)initData
{
    
}

- (AFHTTPSessionManager *)manager
{
    if (!_manager) {
        //操作队列管理
        _manager = [AFHTTPSessionManager manager];
        //允许非权威机构颁发的证书
        _manager.securityPolicy.allowInvalidCertificates = YES;
        //也不验证域名一致性
        _manager.securityPolicy.validatesDomainName = NO;
        //关闭缓存避免干扰测试
        _manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        //申明返回的结果是json类型
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
        _manager.requestSerializer.timeoutInterval = 20.0f;
    }
    
    return _manager;
}

+ (AFHTTPSessionManager *)defaultManager
{
    return [ZJRequestDataServer sharedTool].manager;
}

- (AFHTTPSessionManager *)textManager
{
    if (!_textManager) {
        //操作队列管理
        _textManager = [AFHTTPSessionManager manager];
        //允许非权威机构颁发的证书
        _textManager.securityPolicy.allowInvalidCertificates = YES;
        //也不验证域名一致性
        _textManager.securityPolicy.validatesDomainName = NO;
        //关闭缓存避免干扰测试
        _textManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        //申明返回的结果是json类型
        _textManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _textManager.requestSerializer.timeoutInterval = 20.0f;
    }
    
    return _textManager;
}

+ (AFHTTPSessionManager *)defaultTextManager
{
    return [ZJRequestDataServer sharedTool].textManager;
}

- (AFHTTPSessionManager *)downloadManager
{
    if (!_downloadManager) {
        //操作队列管理
        _downloadManager = [AFHTTPSessionManager manager];
    }
    
    return _downloadManager;
}

+ (AFHTTPSessionManager *)defaultDownloadManager
{
    return [ZJRequestDataServer sharedTool].downloadManager;
}

- (AFHTTPSessionManager *)localManager
{
    if (!_localManager) {
        //操作队列管理
        _localManager = [AFHTTPSessionManager manager];
        //允许非权威机构颁发的证书
        _localManager.securityPolicy.allowInvalidCertificates = YES;
        //也不验证域名一致性
        _localManager.securityPolicy.validatesDomainName = NO;
        //关闭缓存避免干扰测试
        _localManager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataDontLoad;
        //申明返回的结果是json类型
        _localManager.responseSerializer = [AFJSONResponseSerializer serializer];
        _localManager.requestSerializer.timeoutInterval = 20.0f;
    }
    
    return _localManager;
}

+ (AFHTTPSessionManager *)defaultLocalManager
{
    return [ZJRequestDataServer sharedTool].localManager;
}

- (AFHTTPSessionManager *)cacheManager
{
    if (!_cacheManager) {
        //操作队列管理
        _cacheManager = [AFHTTPSessionManager manager];
        //允许非权威机构颁发的证书
        _cacheManager.securityPolicy.allowInvalidCertificates = YES;
        //也不验证域名一致性
        _cacheManager.securityPolicy.validatesDomainName = NO;
        //关闭缓存避免干扰测试
        _cacheManager.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
        //申明返回的结果是json类型
        _cacheManager.responseSerializer = [AFJSONResponseSerializer serializer];
        _cacheManager.requestSerializer.timeoutInterval = 20.0f;
    }
    
    return _cacheManager;
}

+ (AFHTTPSessionManager *)defaultCacheManager
{
    return [ZJRequestDataServer sharedTool].cacheManager;
}

- (void)dealloc
{
    _manager = nil;
    _textManager = nil;
    _downloadManager = nil;
    _localManager = nil;
}

//网络请求
+ (NSURLSessionDataTask *)requestWithURL:(NSString *)url
                                isFormData:(BOOL)isFormData
                                    params:(NSMutableDictionary *)params
                                httpMethod:(NSString *)httpMethod
                            completedBlock:(CompletionBlock)completedBlock
                              failureBlock:(FailureBlock)failureBlock
{
    AFHTTPSessionManager *manager = [ZJRequestDataServer defaultManager];
    NSMutableString *fullUrl = [NSMutableString stringWithFormat:@"%@", url];
    NSURLSessionDataTask *sessionDataTask = nil;
    if ([httpMethod isEqualToString:@"GET"]) {
        sessionDataTask = [manager GET:fullUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (completedBlock) {
                completedBlock(responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failureBlock) {
                failureBlock(error);
            }
        }];
    } else if ([httpMethod isEqualToString:@"POST"]) {
        if (!isFormData) { //没有文件
            sessionDataTask = [manager POST:fullUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (completedBlock) {
                    completedBlock(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            }];
        } else {    //如果参数中有文件
            sessionDataTask = [manager POST:fullUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                NSData *imgData = params[@"pic"];
                if (imgData) {
                    [formData appendPartWithFileData:imgData
                                                name:@"images"
                                            fileName:@"pic.jpg"
                                            mimeType:@"image/jpeg"];
                }
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                NSLog(@"uploadProgress:%@",uploadProgress);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (completedBlock) {
                    completedBlock(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            }];
        }
    }
    
    return sessionDataTask;
}

+ (NSURLSessionDataTask *)requestTextWithURL:(NSString *)url
                                isFormData:(BOOL)isFormData
                                    params:(NSMutableDictionary *)params
                                httpMethod:(NSString *)httpMethod
                            completedBlock:(CompletionBlock)completedBlock
                              failureBlock:(FailureBlock)failureBlock
{
    AFHTTPSessionManager *manager = [ZJRequestDataServer defaultTextManager];
    
    NSMutableString *fullUrl = [NSMutableString stringWithFormat:@"%@", url];
    NSURLSessionDataTask *sessionDataTask = nil;
    if ([httpMethod isEqualToString:@"GET"]) {
        sessionDataTask = [manager GET:fullUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (completedBlock) {
                completedBlock(responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failureBlock) {
                failureBlock(error);
            }
        }];
    } else if ([httpMethod isEqualToString:@"POST"]) {
        if (!isFormData) { //没有文件
            sessionDataTask = [manager POST:fullUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (completedBlock) {
                    completedBlock(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            }];
        } else {    //如果参数中有文件
            sessionDataTask = [manager POST:fullUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                NSData *imgData = params[@"pic"];
                if (imgData) {
                    [formData appendPartWithFileData:imgData
                                                name:@"images"
                                            fileName:@"pic.jpg"
                                            mimeType:@"image/jpeg"];
                }
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                NSLog(@"uploadProgress:%@",uploadProgress);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (completedBlock) {
                    completedBlock(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            }];
        }
    }
    
    return sessionDataTask;
}

/**
 *  @author lizhijian
 *
 *  @brief  下载文件
 *
 *  @param paramDic   附加post参数
 *  @param requestURL 请求地址
 *  @param savedPath  保存 在磁盘的位置
 *  @param success    下载成功回调
 *  @param failure    下载失败回调
 *  @param progress   实时下载进度回调
 */
+ (NSURLSessionDownloadTask *)downloadFileWithOption:(NSDictionary *)paramDic
                                       withInferface:(NSString *)requestURL
                                           savedPath:(NSString *)savedPath
                                     downloadSuccess:(void (^)(NSURLResponse *response, NSURL *filePath))success
                                     downloadFailure:(void (^)(NSURLResponse *response, NSError *error))failure
                                            progress:(void (^)(CGFloat progress))progress
                                           totalSize:(void (^)(unsigned long long))totalSize

{
    AFHTTPSessionManager *manager = [ZJRequestDataServer defaultDownloadManager];
    
    __block unsigned long long totalSizeValue = 0;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (totalSizeValue == 0) {
            totalSizeValue = downloadProgress.totalUnitCount;
            totalSize(totalSizeValue);
        } else {
            CGFloat p = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
            progress(p);
        }
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        if (!savedPath) {
            NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            NSString *path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
            return [NSURL fileURLWithPath:path];
        } else if ([[savedPath substringFromIndex:savedPath.length-1] isEqualToString:@"/"]) {
            NSString *path = [savedPath stringByAppendingPathComponent:response.suggestedFilename];
            return [NSURL fileURLWithPath:path];
        } else {
            return [NSURL fileURLWithPath:savedPath];       //文件保存的路径
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (!error && filePath) {
            success(response, filePath);
        } else {
            failure(response, error);
        }
    }];
    
    [downloadTask resume];
    
    return downloadTask;
}

+ (NSURLSessionDataTask *)requestLocalWithURL:(NSString *)url
                              isFormData:(BOOL)isFormData
                                  params:(NSMutableDictionary *)params
                              httpMethod:(NSString *)httpMethod
                          completedBlock:(CompletionBlock)completedBlock
                            failureBlock:(FailureBlock)failureBlock
{
    AFHTTPSessionManager *manager = [ZJRequestDataServer defaultLocalManager];
    NSMutableString *fullUrl = [NSMutableString stringWithFormat:@"%@", url];
    NSURLSessionDataTask *sessionDataTask = nil;
    if ([httpMethod isEqualToString:@"GET"]) {
        sessionDataTask = [manager GET:fullUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (completedBlock) {
                completedBlock(responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failureBlock) {
                failureBlock(error);
            }
        }];
    } else if ([httpMethod isEqualToString:@"POST"]) {
        if (!isFormData) { //没有文件
            sessionDataTask = [manager POST:fullUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (completedBlock) {
                    completedBlock(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            }];
        } else {    //如果参数中有文件
            sessionDataTask = [manager POST:fullUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                NSData *imgData = params[@"pic"];
                if (imgData) {
                    [formData appendPartWithFileData:imgData
                                                name:@"images"
                                            fileName:@"pic.jpg"
                                            mimeType:@"image/jpeg"];
                }
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                NSLog(@"uploadProgress:%@",uploadProgress);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (completedBlock) {
                    completedBlock(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            }];
        }
    }
    
    return sessionDataTask;
}

+ (NSURLSessionDataTask *)requestCacheWithURL:(NSString *)url
                                   isFormData:(BOOL)isFormData
                                       params:(NSMutableDictionary *)params
                                   httpMethod:(NSString *)httpMethod
                               completedBlock:(CompletionBlock)completedBlock
                                 failureBlock:(FailureBlock)failureBlock
{
    AFHTTPSessionManager *manager = [ZJRequestDataServer defaultCacheManager];
    NSMutableString *fullUrl = [NSMutableString stringWithFormat:@"%@", url];
    NSURLSessionDataTask *sessionDataTask = nil;
    if ([httpMethod isEqualToString:@"GET"]) {
        sessionDataTask = [manager GET:fullUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (completedBlock) {
                completedBlock(responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failureBlock) {
                failureBlock(error);
            }
        }];
    } else if ([httpMethod isEqualToString:@"POST"]) {
        if (!isFormData) { //没有文件
            sessionDataTask = [manager POST:fullUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (completedBlock) {
                    completedBlock(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            }];
        } else {    //如果参数中有文件
            sessionDataTask = [manager POST:fullUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                NSData *imgData = params[@"pic"];
                if (imgData) {
                    [formData appendPartWithFileData:imgData
                                                name:@"images"
                                            fileName:@"pic.jpg"
                                            mimeType:@"image/jpeg"];
                }
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                NSLog(@"uploadProgress:%@",uploadProgress);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (completedBlock) {
                    completedBlock(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            }];
        }
    }
    
    return sessionDataTask;
}

+ (void)requestErrorCode:(NSString *)statusCode withRequestPage:(NSInteger)page
{
    
    switch ([statusCode integerValue]) {
        case 0:
            break;
        default:
            break;
    }
}

/**
 是否有网
 
 @return return 有网返回YES
 */
+ (BOOL)isReachable
{
    return [AFNetworkReachabilityManager sharedManager].isReachable;
}

+ (BOOL)isNetworkReachableViaWWAN
{
    return [AFNetworkReachabilityManager sharedManager].isReachableViaWWAN;
}

+ (BOOL)isNetworkReachableViaWiFi
{
    return [AFNetworkReachabilityManager sharedManager].isReachableViaWiFi;
}

+ (AFNetworkReachabilityStatus)getNetworkReachabilityStatus
{
    switch ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus) {
        case AFNetworkReachabilityStatusNotReachable:
            return kNotReachable;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            return kReachableViaWWAN;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            return kReachableViaWiFi;
        default:
            return kNotReachable;
    }
}

+ (void)checkNetworkReachability
{
    __block ZJNetworkStatus netStatus = kNotReachable;
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown: // 未知网络
                NSLog(@"未知网络");
                netStatus = kNotReachable;
                break;

            case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
                NSLog(@"没有网络(断网)");
                netStatus = kNotReachable;
                [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationNotNetwork object:nil];
                break;

            case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
                NSLog(@"手机自带网络");
                netStatus = kReachableViaWWAN;
                break;

            case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
                NSLog(@"WIFI");
                netStatus = kReachableViaWiFi;
                break;
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationNetworkStateChange object:[NSNumber numberWithInteger:netStatus]];
    }];

    [mgr startMonitoring];
}

@end
