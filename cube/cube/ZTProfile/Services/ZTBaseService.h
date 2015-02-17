/*
 ******************************************************************************
 * ZTBaseService.h -
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

#import "YMSCBService.h"
#include "TISensorTag.h"



/**
 Base class for defining a CoreBluetooth service for a TI SensorTag. 
 */
@interface ZTBaseService : YMSCBService


/**
 Dictionary containing the values measured by the sensor.
 
 This is an abstract propery.
 */
@property (nonatomic, readonly) NSDictionary *sensorValues;

/**
 Turn on CoreBluetooth peripheral service.
 
 This method turns on the service by:
 
 *  writing to *config* characteristic to enable service.
 *  writing to *data* characteristic to enable notification.
 
 */
- (void)turnOn;


/**
 Turn off CoreBluetooth peripheral service.
 
 This method turns off the service by:
 
 *  writing to *config* characteristic to disable service.
 *  writing to *data* characteristic to disable notification.
 
 */
- (void)turnOff;


@end
