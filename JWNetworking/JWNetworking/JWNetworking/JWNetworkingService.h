//
//  JWNetworkingService.h
//  JWNetworking
//
//  Created by wangjun on 2018/6/6.
//  Copyright © 2018年 wangjun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JWNetworkingDefine.h"

@class JWNetworkingRequest;

@interface JWNetworkingService : NSObject

/**
 *  单例模式
 *
 *  @return 返回当前类的实例
 */
+ (JWNetworkingService *)shareInstance;

/**
 *  发送请求的方法
 *
 *  @param object 请求的对象
 *  @param target target，用于回调与取消请求
 */
- (void)requestWithObject:(id)object
                   terget:(id)target;

/**
 *  添加一个通用的错误处理流程
 *
 *  @param errorHandler 错误处理流程
 *  @param errorCode    该错误对应的错误码
 */
- (void)registerCommonErrorHandler:(JWNetworkingCommonErrorHandler)errorHandler
                         errorCode:(NSString *)errorCode;

/**
 *  取消所有请求
 */
- (void)cancelAllRequest;

/**
 *  取消特定Target的所有请求
 *
 *  @param target 被取消请求的Target
 */
- (void)cancelRequestWithTarget:(id)target;

/**
 取消某个请求
 
 @param request 需要被取消的请求
 */
- (void)cancelRequestWithRequest:(JWNetworkingRequest *)request;

@end

@interface JWNetworkingRequest : NSObject

@end
