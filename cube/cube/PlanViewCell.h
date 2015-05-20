/*
 ******************************************************************************
 * PlanViewCell.h -
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
#import "RMSwipeTableViewCell.h"

@interface PlanViewCell : RMSwipeTableViewCell

@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UIImageView *checkmarkGreyImageView;
@property (nonatomic, strong) UIImageView *checkmarkGreenImageView;
@property (nonatomic, strong) UIImageView *checkmarkProfileImageView;
@property (nonatomic, strong) UIImageView *deleteGreyImageView;
@property (nonatomic, strong) UIImageView *deleteRedImageView;
@property (nonatomic, assign, getter=getIsFavourite) BOOL isFavourite;

-(void)setThumbnail:(UIImage *)image;
-(void)setFavourite:(BOOL)favourite animated:(BOOL)animated;

@property (nonatomic, strong, getter=getBeginTime, setter=setBeginTime:) NSDate *beginTime;
@property (nonatomic, strong, getter=getEndTime,   setter=setEndTime:) NSDate *endTime;

@property (nonatomic, strong) UILabel *begin;
@property (nonatomic, strong) UILabel *end;

@property (nonatomic, assign, getter=getIsCamera,  setter=setIsCamera:) BOOL isCamera;

@end
