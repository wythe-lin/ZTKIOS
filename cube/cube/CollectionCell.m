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
    self = [super initWithFrame:frameRect];
    if (self) {
        // Grey background
        self.backgroundColor = [UIColor colorWithWhite:0.12 alpha:1];




    }
    return self;
}


- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}


@end
