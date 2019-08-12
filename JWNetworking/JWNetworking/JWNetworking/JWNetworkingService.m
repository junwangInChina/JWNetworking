//
//  JWNetworkingService.m
//  JWNetworking
//
//  Created by wangjun on 2018/6/6.
//  Copyright © 2018年 wangjun. All rights reserved.
//

#import "JWNetworkingService.h"

#import "JWNetworkingAccessorDefine.h"

#import <AFNetworking/AFNetworking.h>
#import <JWTrace/JWTrace.h>

#pragma mark - JWNetworkingRequest ---
@interface JWNetworkingRequest ()

/**
 *  请求的对象，这里指input
 */
@property (nonatomic, strong) id requestInput;

/**
 *  关联对象
 */
@property (nonatomic, strong) id target;

/**
 *  请求Task
 */
@property (nonatomic, strong) NSURLSessionDataTask *requestTask;

@end

@implementation JWNetworkingRequest

@end

#pragma mark - JWNetworkingService ---

static JWNetworkingService *service;

@interface JWNetworkingService ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) NSMutableArray *baseServiceArray;
@property (nonatomic, strong) NSMutableDictionary *errorHandlerDic;
@property (nonatomic, strong) NSDictionary *headerDic;
@property (nonatomic, strong) NSDictionary *paramDic;

@end

@implementation JWNetworkingService

#pragma mark - Once
+ (JWNetworkingService *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[super allocWithZone:nil] init];
    });
    return service;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [JWNetworkingService shareInstance];
}

- (instancetype)copy
{
    return [JWNetworkingService shareInstance];
}

- (instancetype)mutableCopy
{
    return [JWNetworkingService shareInstance];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self defaultConfig];
    }
    return self;
}

- (void)defaultConfig
{
    self.sessionManager = [AFHTTPSessionManager manager];
    _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _sessionManager.requestSerializer.timeoutInterval = JW_REQUEST_TIME_OUT;
    _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    // 上传图片，需要加一个text/html类型 HTTPS，需要加一个text/plain类型
    _sessionManager.responseSerializer.acceptableContentTypes = [_sessionManager.responseSerializer.acceptableContentTypes setByAddingObjectsFromArray:@[@"text/html",@"text/plain"]];

    _sessionManager.operationQueue.maxConcurrentOperationCount = JW_REQUEST_QUEUE_MAX_COUNT;

    self.errorHandlerDic = [NSMutableDictionary dictionary];
    self.baseServiceArray = [NSMutableArray array];
}

#pragma mark - Public Method
- (void)requestWithObject:(id)object terget:(id)target
{
    if (self.baseServiceArray.count > 0)
    {
        NSArray *tempArray = [NSArray arrayWithArray:self.baseServiceArray];
        for (NSInteger i = 0; i < tempArray.count; i++)
        {
            id tempClass = tempArray[i];
            if ([tempClass isKindOfClass:[JWNetworkingRequest class]])
            {
                JWNetworkingInput *tempInput = (JWNetworkingInput *)[(JWNetworkingRequest *)tempClass requestInput];
                if ([tempInput.inputDescribution isEqualToString:[(JWNetworkingInput *)object inputDescribution]] &&
                    [tempInput.requestService isEqualToString:[(JWNetworkingInput *)object requestService]])
                {
                    JW_OUTPUT_LOG(OutputLevelDebug, @"重复请求，已拦截");
                    return;
                }
            }
        }

        /*
        NSArray *tempArray = [NSArray arrayWithArray:self.baseServiceArray];
        for (JWNetworkingRequest *tempRequest in tempArray)
        {
            JWNetworkingInput *tempInput = (JWNetworkingInput *)tempRequest.requestInput;
            if ([tempInput.inputDescribution isEqualToString:[(JWNetworkingInput *)object inputDescribution]] &&
                [tempInput.requestService isEqualToString:[(JWNetworkingInput *)object requestService]])
            {
                JW_OUTPUT_LOG(OutputLevelDebug, @"重复请求，已拦截");
                return;
            }
        }
         */
    }
    
    JWNetworkingRequest *tempRequest = [[JWNetworkingRequest alloc] init];
    // 设置Target，用于取消请求
    tempRequest.target = target;
    // 设置请求Input
    tempRequest.requestInput = object;
    
    // 处理服务器地址
    NSString *tempService = [(JWNetworkingInput *)object requestService];
    tempService = [self urlCheck:tempService];
    // 请求完整的URL
    NSString *tempFullURL = [NSString stringWithFormat:@"%@%@",tempService,[(JWNetworkingInput *)object requestAction]];
    // 请求参数
    NSMutableDictionary *tempParam = [(JWNetworkingInput *)object paramDicForRequest];
    // 拼接通用参数
    if (self.paramDic)
    {
        for (NSString *tempKey in self.paramDic.allKeys)
        {
            // 如果单独接口配置的参数与通用参数重复，以单个接口为主
            if (![[tempParam allKeys] containsObject:tempKey])
            {
                [tempParam setValue:self.paramDic[tempKey] forKey:tempKey];
            }
        }
    }
    // 图片数据
    NSData *tempData = [(JWNetworkingInput *)object paramForImageData];
    
    // 请求头域
    NSMutableDictionary *tempHeader = [(JWNetworkingInput *)object paramDicForHeader];
    // 拼接通用头域
    if (self.headerDic)
    {
        for (NSString *tempKey in self.headerDic.allKeys)
        {
            // 如果单独接口配置的头域与通用头域重复，以单个接口为主
            if (![[tempHeader allKeys] containsObject:tempKey])
            {
                [tempHeader setValue:self.headerDic[tempKey] forKey:tempKey];
            }
        }
    }
    if (tempHeader && tempHeader.count > 0)
    {
        for (NSString *tempHeaderKey in [tempHeader allKeys])
        {
            [self.sessionManager.requestSerializer setValue:tempHeader[tempHeaderKey]
                                         forHTTPHeaderField:tempHeaderKey];
        }
    }
    
    // 请求类型
    JWNetworkingRequestMethod method = [(JWNetworkingInput *)object requestMethod];
    // 每个请求的句柄
    NSURLSessionDataTask *tempTask;
    
    AFNetworkReachabilityStatus status =  [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    BOOL isAvaiable = !(status == AFNetworkReachabilityStatusNotReachable);
    // 无网络时，直接回调
    if (!isAvaiable)
    {
        NSError *tempError = [NSError errorWithDomain:NSNetServicesErrorDomain
                                                 code:300
                                             userInfo:@{NSLocalizedDescriptionKey:@"无网络"}];
        [self requestDidFailed:tempRequest
                           url:tempFullURL
                         param:tempParam
                         error:tempError];
        
        return;
    }
    
    __weak __typeof(self)this = self;
    switch (method) {
        case JWNetworkingRequestGET:
        {
            tempTask = [self.sessionManager GET:tempFullURL parameters:tempParam progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                [this requestDidFinished:tempRequest response:responseObject url:task.currentRequest.URL.absoluteString param:tempParam];
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                [this requestDidFailed:tempRequest url:task.currentRequest.URL.absoluteString param:tempParam error:error];
                
            }];
        }
            break;
        case JWNetworkingRequestPOST:
        {
            if (tempData)
            {
                tempTask = [self.sessionManager POST:tempFullURL parameters:tempParam constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                    
                    [formData appendPartWithFileData:tempData name:@"imgFile" fileName:@"upload.jpg" mimeType:@"image/jpeg"];
                    
                } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    
                    [this requestDidFinished:tempRequest response:responseObject url:task.currentRequest.URL.absoluteString param:tempParam];
                    
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    
                    [this requestDidFailed:tempRequest url:task.currentRequest.URL.absoluteString param:tempParam error:error];
                    
                }];
            }
            else
            {
                tempTask = [self.sessionManager POST:tempFullURL parameters:tempParam progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                   
                    [this requestDidFinished:tempRequest response:responseObject url:task.currentRequest.URL.absoluteString param:tempParam];
                    
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    
                    [this requestDidFailed:tempRequest url:task.currentRequest.URL.absoluteString param:tempParam error:error];
                    
                }];
            }
        }
            break;
        case JWNetworkingRequestPUT:
        {
            tempTask = [self.sessionManager PUT:tempFullURL parameters:tempParam success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
               
                [this requestDidFinished:tempRequest response:responseObject url:task.currentRequest.URL.absoluteString param:tempParam];
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                [this requestDidFailed:tempRequest url:task.currentRequest.URL.absoluteString param:tempParam error:error];
                
            }];
        }
            break;
        case JWNetworkingRequestDELETE:
        {
            tempTask = [self.sessionManager DELETE:tempFullURL parameters:tempParam success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                [this requestDidFinished:tempRequest response:responseObject url:task.currentRequest.URL.absoluteString param:tempParam];
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
               
                [this requestDidFailed:tempRequest url:task.currentRequest.URL.absoluteString param:tempParam error:error];
                
            }];
        }
            break;
        default:
            break;
    }
    
    // 将请求句柄交给CMRequest管理，方便取消请求
    tempRequest.requestTask = tempTask;
    
    // 将CMRequest添加到请求数组
    // 加入数组，方便管理
    [self.baseServiceArray addObject:tempRequest];
}

- (void)registerCommonErrorHandler:(JWNetworkingCommonErrorHandler)errorHandler errorCode:(NSString *)errorCode
{
    if (errorCode.length == 0 || !errorHandler) return;
    
    [self.errorHandlerDic setObject:[errorHandler copy] forKey:errorCode];
}

- (void)configCommonHeader:(NSDictionary *)dic
{
    self.headerDic = dic;
}

- (void)configCommonParam:(NSDictionary *)dic
{
    self.paramDic = dic;
}

- (void)cancelAllRequest
{
    for (JWNetworkingRequest *tempRequest in self.baseServiceArray)
    {
        [tempRequest.requestTask cancel];
        tempRequest.target = nil;
    }
    [self.baseServiceArray removeAllObjects];
}

- (void)cancelRequestWithTarget:(id)target
{
    for (int i = 0; i < [self.baseServiceArray count]; i++)
    {
        JWNetworkingRequest *tempRequest = self.baseServiceArray[i];
        if (![tempRequest isKindOfClass:[JWNetworkingRequest class]])
        {
            JW_OUTPUT_LOG(OutputLevelDebug, @"请求格式不匹配，无法取消");
            continue;
        }
        if (tempRequest.target == target)
        {
            [tempRequest.requestTask cancel];
            tempRequest.target = nil;
            tempRequest.requestInput = nil;
            [self.baseServiceArray removeObject:tempRequest];
        }
    }
}

- (void)cancelRequestWithRequest:(JWNetworkingRequest *)request
{
    for (int i = 0; i < [self.baseServiceArray count]; i++)
    {
        JWNetworkingRequest *tempRequest = self.baseServiceArray[i];
        if (![tempRequest isKindOfClass:[JWNetworkingRequest class]])
        {
            JW_OUTPUT_LOG(OutputLevelDebug, @"请求格式不匹配，无法取消");
            continue;
        }
        if (tempRequest.target == request.target &&
            tempRequest.requestInput == request.requestInput)
        {
            [tempRequest.requestTask cancel];
            tempRequest.target = nil;
            tempRequest.requestInput = nil;
            [self.baseServiceArray removeObject:tempRequest];
        }
    }
}

#pragma mark - Helper
- (void)requestDidFinished:(JWNetworkingRequest *)request response:(id)response url:(NSString *)url param:(NSDictionary *)param
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // 解析
        Class outputClass = [(JWNetworkingInput *)[request requestInput] responseClass];
        JWNetworkingOutput *output = [[outputClass alloc] parseResponseObject:response];
        
        NSDictionary *responseDic;
        if ([response isKindOfClass:[NSDictionary class]])
        {
            responseDic = (NSDictionary *)response;
        }
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:responseDic];
        
        // 填充input
        [tempDic setValue:request.requestInput forKey:JW_REQUEST_INPUT];
        // 填充output
        [tempDic setValue:output forKey:JW_REQUEST_OUTPUT];
        // 填充返回码
        [tempDic setValue:output.resultCode forKey:JW_RESULT_CODE];
        // 填充返回信息
        [tempDic setValue:output.resultMessage forKey:JW_RESULT_MESSAGE];
        // 填充完整请求URL
        [tempDic setValue:url forKey:JW_REQUEST_FULL_URL];
        // 填充请求参数
        [tempDic setValue:param forKey:JW_REQUEST_PARAM];
        
        // 获取结束时间
        NSTimeInterval tempEndTime = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval tempTime = tempEndTime - [(JWNetworkingInput *)request.requestInput requestStartTimeInterval];
        // 填充请求耗时
        [tempDic setValue:[NSString stringWithFormat:@"请求耗时:%.0f毫秒",tempTime*1000] forKey:JW_REQUEST_TIME];
        
        JW_OUTPUT_LOG(OutputLevelDebug, @"请求信息 :%@",tempDic);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 通用的错误处理流程
            JWNetworkingCommonErrorHandler tempErrorHandler = [self.errorHandlerDic objectForKey:output.resultCode];
            if (tempErrorHandler)
            {
                tempErrorHandler(tempDic);
            }
            
            
            // 回调操作
            if ([(JWNetworkingInput *)request.requestInput callback])
            {
                ((JWNetworkingInput *)request.requestInput).callback(tempDic);
            }
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                // 移除请求
                [self cancelRequestWithRequest:request];
            });
        });
    });
}

- (void)requestDidFailed:(JWNetworkingRequest *)request url:(NSString *)url param:(NSDictionary *)param error:(NSError *)error
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        
        // 填充input
        [tempDic setValue:request.requestInput forKey:JW_REQUEST_INPUT];
        // 填充完整请求URL
        [tempDic setValue:url forKey:JW_REQUEST_FULL_URL];
        // 填充请求参数
        [tempDic setValue:param forKey:JW_REQUEST_PARAM];
        
        Class outputClass = [(JWNetworkingInput *)[request requestInput] responseClass];
        JWNetworkingOutput *output = [[outputClass alloc] parseResponseObject:nil];
        if (error)
        {
            // 填充返回码
            [tempDic setValue:[NSString stringWithFormat:@"%ld",(long)error.code] forKey:JW_RESULT_CODE];
            
            // 填充返回提示语
            [tempDic setValue:error forKey:JW_RESULT_MESSAGE];
            
            output.resultCode = [NSString stringWithFormat:@"%ld",(long)error.code];
            output.resultMessage = @"服务器或网络问题，请检查后重试";//[NSString stringWithFormat:@"%@",error.description];
        }
        else
        {
            output.resultCode = @"10010";
            output.resultMessage = @"请求失败，请重试";
        }
        
        // 获取结束时间
        NSTimeInterval tempEndTime = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval tempTime = tempEndTime - [(JWNetworkingInput *)request.requestInput requestStartTimeInterval];
        // 填充请求耗时
        [tempDic setValue:[NSString stringWithFormat:@"请求耗时:%.0f毫秒",tempTime*1000] forKey:JW_REQUEST_TIME];
        
        // 填充Output
        [tempDic setValue:output forKey:JW_REQUEST_OUTPUT];
        
        JW_OUTPUT_LOG(OutputLevelDebug, @"请求信息 :%@",tempDic);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 通用的错误处理流程
            JWNetworkingCommonErrorHandler tempErrorHandler = [self.errorHandlerDic objectForKey:output.resultCode];
            if (tempErrorHandler)
            {
                tempErrorHandler(tempDic);
            }
            
            // 回调操作
            if ([(JWNetworkingInput *)request.requestInput callback])
            {
                ((JWNetworkingInput *)request.requestInput).callback(tempDic);
            }
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                // 移除请求
                [self cancelRequestWithRequest:request];
            });
        });
    });
}

- (NSString *)urlCheck:(NSString *)base
{
    if (!base || base.length <= 0)
    {
        return @"";
    }
    if (![base hasPrefix:@"http://"] && ![base hasPrefix:@"https://"])
    {
        base = [NSString stringWithFormat:@"http://%@",base];
    }
    if (![base hasSuffix:@"/"])
    {
        base = [NSString stringWithFormat:@"%@/",base];
    }
    return base;
}

@end
