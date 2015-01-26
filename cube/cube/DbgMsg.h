/*
 ******************************************************************************
 * DbgMsg.h -
 *
 * Copyright (c) 2015-2016 by ZealTek Electronic Co., Ltd.
 *
 * This software is copyrighted by and is the property of ZealTek
 * Electronic Co., Ltd. All rights are reserved by ZealTek Electronic
 * Co., Ltd. This software may only be used in accordance with the
 * corresponding license agreement. Any unauthorized use, duplication,
 * distribution, or disclosure of this software is expressly forbidden.
 *
 * This Copyright notice MUST not be removed or modified without prior
 * written consent of ZealTek Electronic Co., Ltd.
 *
 * ZealTek Electronic Co., Ltd. reserves the right to modify this
 * software without notice.
 *
 * History:
 *	2015.01.16	T.C. Chiu	frist edition
 *
 ******************************************************************************
 */

/**
 * Set this switch to  enable or disable logging capabilities.
 * This can be set either here or via the compiler build setting GCC_PREPROCESSOR_DEFINITIONS
 * in your build configuration. Using the compiler build setting is preferred for this to
 * ensure that logging is not accidentally left enabled by accident in release builds.
 */
#ifndef LOGGING_ENABLED
    #define LOGGING_ENABLED                 1
#endif

/**
 * Set this switch to indicate whether or not to include class, method and line information
 * in the log entries. This can be set either here or as a compiler build setting.
 */
#ifndef LOGGING_INCLUDE_CODE_LOCATION
    #define LOGGING_INCLUDE_CODE_LOCATION   0
#endif

/**
 * Set any or all of these switches to enable or disable logging at specific levels.
 * These can be set either here or as a compiler build settings.
 * For these settings to be effective, LOGGING_ENABLED must also be defined and non-zero.
 */
#ifndef LOGGING_LEVEL_TRACE
    #define LOGGING_LEVEL_TRACE             1
#endif
#ifndef LOGGING_LEVEL_INFO
    #define LOGGING_LEVEL_INFO              1
#endif
#ifndef LOGGING_LEVEL_ERROR
    #define LOGGING_LEVEL_ERROR             1
#endif
#ifndef LOGGING_LEVEL_DEBUG
    #define LOGGING_LEVEL_DEBUG             1
#endif
#ifndef LOGGING_LEVEL_BLE
    #define LOGGING_LEVEL_BLE               1
#endif



// *********** END OF USER SETTINGS  - Do not change anything below this line ***********
#if !(defined(LOGGING_ENABLED) && LOGGING_ENABLED)
	#undef LOGGING_LEVEL_TRACE
	#undef LOGGING_LEVEL_INFO
	#undef LOGGING_LEVEL_ERROR
	#undef LOGGING_LEVEL_DEBUG
#endif

// Logging format
#define LOG_FORMAT_NO_LOCATION(fmt, lvl, ...)       NSLog((@"[%@] " fmt), lvl, ##__VA_ARGS__)
#define LOG_FORMAT_WITH_LOCATION(fmt, lvl, ...)     NSLog((@"%s[Line %d] [%@] " fmt), __PRETTY_FUNCTION__, __LINE__, lvl, ##__VA_ARGS__)


#if defined(LOGGING_INCLUDE_CODE_LOCATION) && LOGGING_INCLUDE_CODE_LOCATION
    #define LOG_FORMAT(fmt, lvl, ...)               LOG_FORMAT_WITH_LOCATION(fmt, lvl, ##__VA_ARGS__)
#else
    #define LOG_FORMAT(fmt, lvl, ...)               LOG_FORMAT_NO_LOCATION(fmt, lvl, ##__VA_ARGS__)
#endif


// BLE logging -
#if defined(LOGGING_LEVEL_BLE) && LOGGING_LEVEL_BLE
    #define LogBLE(fmt, ...)            LOG_FORMAT(fmt, @"BLE", ##__VA_ARGS__)
#else
    #define LogBLE(...)
#endif

// Trace logging - for detailed tracing
#if defined(LOGGING_LEVEL_TRACE) && LOGGING_LEVEL_TRACE
	#define LogTrace(fmt, ...)          LOG_FORMAT(fmt, @"TRACE", ##__VA_ARGS__)
#else
	#define LogTrace(...)
#endif

// Info logging - for general, non-performance affecting information messages
#if defined(LOGGING_LEVEL_INFO) && LOGGING_LEVEL_INFO
	#define LogInfo(fmt, ...)           LOG_FORMAT(fmt, @"info", ##__VA_ARGS__)
#else
	#define LogInfo(...)
#endif

// Error logging - only when there is an error to be logged
#if defined(LOGGING_LEVEL_ERROR) && LOGGING_LEVEL_ERROR
	#define LogError(fmt, ...)          LOG_FORMAT(fmt, @"***ERROR***", ##__VA_ARGS__)
#else
	#define LogError(...)
 #endif

// Debug logging - use only temporarily for highlighting and tracking down problems
#if defined(LOGGING_LEVEL_DEBUG) && LOGGING_LEVEL_DEBUG
	#define LogDebug(fmt, ...)          LOG_FORMAT(fmt, @"DEBUG", ##__VA_ARGS__)
#else
	#define LogDebug(...)
#endif

