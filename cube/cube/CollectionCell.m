/*
 ******************************************************************************
 * CollectionCell.m -
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

#import "CollectionCell.h"

/*
 ******************************************************************************
 *
 * for debug
 *
 ******************************************************************************
 */
#define LOGGING_LEVEL_COLLECTIONCELL        1
#include "DbgMsg.h"

#if defined(LOGGING_LEVEL_COLLECTIONCELL) && LOGGING_LEVEL_COLLECTIONCELL
#define dmsg(fmt, ...)      LOG_FORMAT(fmt, @"CCELL", ##__VA_ARGS__)
#else
#define dmsg(...)
#endif

#define msg(fmt, ...)       LOG_FORMAT(fmt, @"CCELL", ##__VA_ARGS__)


/*
 ******************************************************************************
 *
 * @interface
 *
 ******************************************************************************
 */
@interface CollectionCell ()


@end


/*
 ******************************************************************************
 *
 * @implementation
 *
 ******************************************************************************
 */
@implementation CollectionCell

- (instancetype)initWithFrame:(CGRect)frameRect
{
    dmsg(@"initWithFrame:");

    self = [super initWithFrame:frameRect];
    if (self) {
        // Grey background
        self.backgroundColor = [UIColor blueColor];




    }
    return self;
}


- (void)setBounds:(CGRect)bounds
{
    dmsg(@"setBounds: x=%0d, y=%0d, w=%0d, h=%0d", (int)bounds.origin.x, (int)bounds.origin.y, (int)bounds.size.width, (int)bounds.size.height);

    [super setBounds:bounds];
    self.contentView.frame = bounds;
}


@end
