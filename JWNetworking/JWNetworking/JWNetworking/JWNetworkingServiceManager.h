//
//  JWNetworkingServiceManager.h
//  JWNetworking
//
//  Created by wangjun on 2018/6/6.
//  Copyright © 2018年 wangjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JWNetworkingInput;

@interface JWNetworkingServiceManager : NSObject

/**
 *  发送请求
 *
 *  @param input  请求的输入对象
 *  @param target 关联Target
 */
- (void)sendRequest:(JWNetworkingInput *)input target:(id)target;

/**
 *  取消某个请求或者回调
 *
 *  @param target 需要进行取消动作的对象
 */
-(void)cancelAllServiceRelatedWithTarget:(id)target;

@end
