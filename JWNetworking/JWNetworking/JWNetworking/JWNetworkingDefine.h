//
//  JWNetworkingDefine.h
//  JWNetworking
//
//  Created by wangjun on 2018/6/6.
//  Copyright © 2018年 wangjun. All rights reserved.
//

#ifndef JWNetworkingDefine_h
#define JWNetworkingDefine_h

#pragma mark - Define
/**
 *  设置请求队列同时请求个数
 */
#define JW_REQUEST_QUEUE_MAX_COUNT      3

/**
 *  设置请求超时时间
 */
#define JW_REQUEST_TIME_OUT             30

/**
 *  设置分页时，每页条数
 */
#define JW_REQUEST_PAGE_SIZE            20

/**
 *  响应回调中的input对象对应的key值
 */
#define JW_REQUEST_INPUT                @"JWNetworking_Request_Input_Key"

/**
 *  响应回调中的output对象对应的key值
 */
#define JW_REQUEST_OUTPUT               @"JWNetworking_Request_Output_Key"

/**
 *  完整的请求URL
 */
#define JW_REQUEST_FULL_URL             @"JWNetworking_request_full_url"

/**
 *  请求参数
 */
#define JW_REQUEST_PARAM                @"JWNetworking_request_param"

/**
 *  HTTP 请求返回码
 */
#define JW_RESULT_CODE                  @"JWNetworking_Result_Code_Key"

/**
 *  HTTP 请求返回信息
 */
#define JW_RESULT_MESSAGE               @"JWNetworking_Result_Message_Key"


#pragma mark - Block
/**
 *  定义Block，用于回调网络层数据
 *
 *  @param dic 网络层数据字典
 */
typedef void(^JWNetworkingCallback)(NSDictionary *dic);

/**
 *  定义Block，用于处理通用的错误回调
 *
 *  @param dic 回调内容
 */
typedef void(^JWNetworkingCommonErrorHandler)(NSDictionary *dic);

#pragma mark - Enum
typedef NS_ENUM(NSInteger, JWNetworkingRequestMethod) {
    JWNetworkingRequestGET = 0,
    JWNetworkingRequestPOST,
    JWNetworkingRequestPUT,
    JWNetworkingRequestDELETE
};


#endif /* JWNetworkingDefine_h */