//
//  JWNetworkingAccessorDefine.m
//  JWNetworking
//
//  Created by wangjun on 2018/6/6.
//  Copyright © 2018年 wangjun. All rights reserved.
//

#import "JWNetworkingAccessorDefine.h"

@implementation JWNetworkingInput

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.requestService = @"";
        self.requestMethod = JWNetworkingRequestGET;
        self.responseClass = [JWNetworkingOutput class];
        
        NSTimeInterval tempTime = [[NSDate date] timeIntervalSince1970];
        self.requestStartTimeInterval = tempTime;
    }
    return self;
}

- (NSMutableDictionary *)paramDicForHeader
{
    __autoreleasing NSMutableDictionary *headDic = [NSMutableDictionary dictionary];
    [headDic setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forKey:@"Content-Type"];
    [headDic setValue:@"application/json" forKey:@"Accept"];
    
    return headDic;
}

- (NSMutableDictionary *)paramDicForRequest
{
    return nil;
}

- (NSData *)paramForImageData
{
    return nil;
}

- (NSString *)inputDescribution
{
    NSMutableString *tempStr = [[NSMutableString alloc] initWithString:self.requestAction];
    NSDictionary *tempDic = [self paramDicForRequest];
    if ([[tempDic allKeys] count] > 0)
    {
        [tempStr appendString:@"?"];
    }
    for (NSString *tempKey in [tempDic allKeys])
    {
        [tempStr appendString:[NSString stringWithFormat:@"%@=%@&",tempKey,tempDic[tempKey]]];
    }
    if ([[tempDic allKeys] count] > 0)
    {
        [tempStr replaceCharactersInRange:NSMakeRange(tempStr.length - 1, 1) withString:@""];
    }
    
    return tempStr;
}

@end

@implementation JWNetworkingOutput

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.resultCode = @"";
        self.resultMessage = @"";
    }
    return self;
}

- (instancetype)parseResponseObject:(id)responseObject
{
    if ([responseObject isKindOfClass:[NSDictionary class]])
    {
        self.responseDic = (NSDictionary *)responseObject;
        if (_responseDic[@"code"] && _responseDic[@"code"] != [NSNull null])
        {
            self.resultCode = [NSString stringWithFormat:@"%@",_responseDic[@"code"]];
        }
        if (_responseDic[@"message"] && _responseDic[@"message"] != [NSNull null])
        {
            self.resultMessage = [NSString stringWithFormat:@"%@",_responseDic[@"message"]];
        }
    }
    return self;
}

@end
