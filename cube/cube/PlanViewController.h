/*
 ******************************************************************************
 * PlanViewController.h -
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
 *	2015.05.07	T.C. Chiu	frist edition
 *
 ******************************************************************************
 */

#import <UIKit/UIKit.h>
#import "PlanViewCell.h"

#import "ZTCube.h"

@interface PlanViewController : UITableViewController <RMSwipeTableViewCellDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    PlanViewCell   *select;
}

@property (nonatomic, strong) NSMutableArray    *array;
@property (nonatomic, strong) NSMutableArray    *hourLst;
@property (nonatomic, strong) NSMutableArray    *minLst;

@property (nonatomic, assign, getter=getHour, setter=setHour:) NSInteger hour;
@property (nonatomic, assign, getter=getMin,  setter=setMin:)  NSInteger min;


/// Instance of ZTCube.
@property (strong, nonatomic) ZTCube            *ztCube;

@end
