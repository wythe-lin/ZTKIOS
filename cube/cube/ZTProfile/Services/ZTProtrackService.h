/*
 ******************************************************************************
 * ZTProtrack.h -
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

#import "YMSCoreBluetooth.h"


#define kCUUID_PROTRACK_WRITE       0xFFE9


/**
 ProTrack Profile
 */
@interface ZTProtrackService : YMSCBService



- (void)write;

/**
 Read Device Time
 */
- (void)setDate;
- (void)recordStart:(NSInteger)resolution speed:(NSInteger)speed power:(NSInteger)power;
- (void)recordStop;
- (void)snapshot:(NSInteger)resolution power:(NSInteger)power;
- (void)readStatus;
- (void)powerManage:(NSUInteger)option;
- (void)inquiryPic;
- (void)inquiryBlock:(NSInteger)pic;
- (void)getPic:(NSInteger)pic block:(NSInteger)blk;
- (void)readGPIO:(NSInteger)num;
- (void)writeGPIO:(NSInteger)num level:(NSInteger)lvl;
- (void)writePlan:(NSUInteger)planid enable:(BOOL)en type:(NSUInteger)mode beginTime:(NSDate *)begin endTime:(NSDate *)end repeat:(NSUInteger)cycle;



@end
