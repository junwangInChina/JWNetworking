//
//  JWNetworkingAccessorDefine.h
//  JWNetworking
//
//  Created by wangjun on 2018/6/6.
//  Copyright © 2018年 wangjun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JWNetworkingDefine.h"

@interface JWNetworkingInput : NSObject

/**
 *  回调网络层数据的Block
 */
@property (nonatomic, copy) JWNetworkingCallback callback;

/**
 *  服务器地址类型
 */
@property (nonatomic, copy) NSString *requestService;

/**
 *  请求接口名
 */
@property (nonatomic, copy) NSString *requestAction;

/**
 *  请求方式
 */
@property (nonatomic, assign) JWNetworkingRequestMethod requestMethod;

/**
 *  解析类，Output
 */
@property (nonatomic, assign) Class responseClass;

/**
 *  请求开始时间戳
 */
@property (nonatomic, assign) NSTimeInterval requestStartTimeInterval;

/**
 *  传参，子类复写
 *
 *  @return 返回参数字典
 */
- (NSMutableDictionary *)paramDicForRequest;

/**
 *  头域，子类复写
 *
 *  @return 返回头域字典
 */
- (NSMutableDictionary *)paramDicForHeader;

/**
 *  上传图片的Data数据
 *
 *  @return 返回该数据
 */
- (NSData *)paramForImageData;

/**
 *  上传图片的字段名
 *
 *  @return 返回该字段名
 */
- (NSString *)paramForImageName;

/**
 描述方法
 
 @return 返回描述信息
 */
- (NSString *)inputDescribution;

@end

@interface JWNetworkingOutput : NSObject

/**
 *  返回码
 */
@property (nonatomic, copy) NSString *resultCode;

/**
 *  返回信息
 */
@property (nonatomic, copy) NSString *resultMessage;

/**
 *  请求返回的Dic
 */
@property (nonatomic, strong) NSDictionary *responseDic;


/**
 *  解析，子类重载
 *
 *  @param responseObject 需要解析的对象，字典
 *
 *  @return 返回解析好的对象
 */
- (instancetype)parseResponseObject:(id)responseObject;

@end
