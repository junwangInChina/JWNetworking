//
//  JWNetworkingServiceManager.m
//  JWNetworking
//
//  Created by wangjun on 2018/6/6.
//  Copyright © 2018年 wangjun. All rights reserved.
//

#import "JWNetworkingServiceManager.h"

#import "JWNetworkingService.h"

@implementation JWNetworkingServiceManager

- (void)sendRequest:(JWNetworkingInput *)input target:(id)target
{
    /*
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[JWNetworkingService shareInstance] requestWithObject:input terget:target];
    });
     */
    [[JWNetworkingService shareInstance] requestWithObject:input terget:target];
}

- (void)cancelAllServiceRelatedWithTarget:(id)target
{
    [[JWNetworkingService shareInstance] cancelRequestWithTarget:target];
}

@end
