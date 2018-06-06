//
//  JWTrace.h
//  JWTraceDemo
//
//  Created by wangjun on 15/12/7.
//  Copyright © 2015年 wangjun. All rights reserved.
//

#import <Foundation/Foundation.h>

#define JW_OUTPUT_LOG(level,frmt,...) outputLog((level), __func__, __LINE__, (frmt), ##__VA_ARGS__)

typedef NS_ENUM(NSInteger, OutputLevel)
{
    OutputLevelCritical,        // 关键级别，打印至关重要的信息
    OutputLevelError,           // 错误级别，打印错误
    OutputLevelWarn,            // 警告级别，打印潜在错误信息
    OutputLevelInfo,            // 信息级别，用于发布情况下分析问题，打印重要的信息和跳转
    OutputLevelDebug,           // 调试级别，用于程序调试，可以打印函数的入口，分支的跳转等
    OutputLevelALL              // 打印所有日志信息
};

@interface JWTrace : NSObject

/**
 *  单利模式
 *
 *  @return 返回当前类的实例
 */
+ (JWTrace *)shareInstance;

/**
 *  是否输出日志到控制台
 */
@property (nonatomic, assign) BOOL outputConsole;

/**
 *  是否输出日志到日志文件
 */
@property (nonatomic, assign) BOOL outputFile;

/**
 *  日志打印输出级别
 */
@property (nonatomic, assign) OutputLevel outputLevel;

/**
 *  是否捕获异常
 */
@property (nonatomic, assign) BOOL catchUncatchedException;

/**
 *  打印语句
 *
 *  @param logLevel 此次打印级别
 *  @param file     文件
 *  @param line     行数
 *  @param function 方法名
 *  @param format   打印内容
 *  @param ...      其他
 */
void outputLog(OutputLevel logLevel,
               const char *function,
               NSInteger line,
               NSString *format, ...);

@end
