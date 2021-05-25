# JWTrace 一款自用的日志打印工具

支持pod:-------> pod 'JWTrace'

用法简介：
在AppDelegate里面设置全局的打印级别，设置不同大打印级别，控制台才会打印对应级别的日志。

```
/**
 *  OutputLevelCritical,     关键级别，打印至关重要的信息
 *  OutputLevelError,        错误级别，打印错误
 *  OutputLevelWarn,         警告级别，打印潜在错误信息
 *  OutputLevelInfo,         信息级别，用于发布情况下分析问题，打印重要的信息和跳转
 *  OutputLevelDebug,        调试级别，用于程序调试，可以打印函数的入口，分支的跳转等
 *  OutputLevelALL           打印所有日志信息
 */
[JWTrace shareInstance].outputLevel = OutputLevelDebug;
```
然后在代码中需要打印日志的地方调用打印宏`JW_OUTPUT_LOG`

```
JW_OUTPUT_LOG(OutputLevelDebug, @"打印测试");
```

在App发布的时候，只需要将Appdelegate里面的`outputLevel`设置为`Info`模式即可。
