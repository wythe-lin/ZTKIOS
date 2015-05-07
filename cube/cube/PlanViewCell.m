/*
 ******************************************************************************
 * PlanViewCell.m -
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
#import "PlanViewCell.h"
#import "ZTColor.h"

#import <QuartzCore/QuartzCore.h>

/*
 ******************************************************************************
 *
 * for debug
 *
 ******************************************************************************
 */
#define LOGGING_LEVEL_PLANCELL  0
#include "DbgMsg.h"

#if defined(LOGGING_LEVEL_PLANCELL) && LOGGING_LEVEL_PLANCELL
#define dmsg(fmt, ...)      LOG_FORMAT(fmt, @"CELL", ##__VA_ARGS__)
#else
#define dmsg(...)
#endif


/*
 ******************************************************************************
 *
 * @interface
 *
 ******************************************************************************
 */
@interface PlanViewCell ()
{

}

@end


/*
 ******************************************************************************
 *
 * @implementation
 *
 ******************************************************************************
 */
@implementation PlanViewCell
/*---------------------------------------------------------------------------*/
#pragma mark -
/*---------------------------------------------------------------------------*/
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    dmsg(@"initWithStyle:reuseIdentifier:");

    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView setBackgroundColor:[ZTColor lightBlueColor]];

        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        self.detailTextLabel.textColor = [UIColor blackColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];

        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 54, 54)];
        [self.profileImageView setBackgroundColor:[UIColor clearColor]];
        [self.profileImageView setClipsToBounds:YES];
        [self.profileImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.profileImageView.layer setBorderColor:[UIColor colorWithWhite:0 alpha:0.3].CGColor];
        [self.profileImageView.layer setBorderWidth:0];
        [self.profileImageView.layer setCornerRadius:2];
        [self.contentView addSubview:self.profileImageView];

        self.begin = [[UILabel alloc] initWithFrame:CGRectMake(120, 13, 185, 18)];
        self.begin.backgroundColor = [UIColor clearColor];
        self.begin.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        self.begin.text = nil;
        self.begin.textColor = [UIColor whiteColor];
        self.begin.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.begin];

        self.end = [[UILabel alloc] initWithFrame:CGRectMake(120, 33, 185, 18)];
        self.end.backgroundColor = [UIColor clearColor];
        self.end.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        self.end.text = nil;
        self.end.textColor = [UIColor whiteColor];
        self.end.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.end];

        [self setBeginTime:[NSDate date]];
        [self setEndTime:[NSDate date]];

        self.revealDirection = RMSwipeTableViewCellRevealDirectionBoth;
    }
    return self;
}

- (void)prepareForReuse
{
    dmsg(@"prepareForReuse");

    [super prepareForReuse];
    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;

    self.begin.text = nil;
    self.end.text = nil;

    [self setUserInteractionEnabled:YES];
    self.imageView.alpha = 1;
    self.accessoryView = nil;
    self.accessoryType = UITableViewCellAccessoryNone;

    [self.contentView setHidden:NO];
    [_checkmarkProfileImageView removeFromSuperview];
    _checkmarkProfileImageView = nil;
    [self cleanupBackView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(CGRectGetMaxX(self.profileImageView.frame) + 10,
                                      CGRectGetMinY(self.textLabel.frame),
                                      CGRectGetWidth(self.textLabel.frame),
                                      CGRectGetHeight(self.textLabel.frame));
    self.detailTextLabel.frame = CGRectMake(CGRectGetMaxX(self.profileImageView.frame) + 10,
                                            CGRectGetMinY(self.detailTextLabel.frame),
                                            CGRectGetWidth(self.detailTextLabel.frame),
                                            CGRectGetHeight(self.detailTextLabel.frame));
}


/*---------------------------------------------------------------------------*/
#pragma mark -
/*---------------------------------------------------------------------------*/
- (UIImageView *)checkmarkGreyImageView
{
    if (!_checkmarkGreyImageView) {
        _checkmarkGreyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.frame), CGRectGetHeight(self.frame))];
        [_checkmarkGreyImageView setImage:[UIImage imageNamed:@"CheckmarkGrey"]];
        [_checkmarkGreyImageView setContentMode:UIViewContentModeCenter];
        [self.backView addSubview:_checkmarkGreyImageView];
    }
    return _checkmarkGreyImageView;
}

- (UIImageView *)checkmarkGreenImageView
{
    if (!_checkmarkGreenImageView) {
        _checkmarkGreenImageView = [[UIImageView alloc] initWithFrame:self.checkmarkGreyImageView.bounds];
        [_checkmarkGreenImageView setImage:[UIImage imageNamed:@"CheckmarkGreen"]];
        [_checkmarkGreenImageView setContentMode:UIViewContentModeCenter];
        [self.checkmarkGreyImageView addSubview:_checkmarkGreenImageView];
    }
    return _checkmarkGreenImageView;
}

- (UIImageView *)checkmarkProfileImageView
{
    if (!_checkmarkProfileImageView) {
        _checkmarkProfileImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckmarkProfileImage"]];
        [_checkmarkProfileImageView setFrame:CGRectMake(CGRectGetMaxX(self.profileImageView.frame) - 10 - CGRectGetWidth(_checkmarkProfileImageView.frame),
                                                        CGRectGetMaxY(self.profileImageView.frame) - 10 - CGRectGetHeight(_checkmarkProfileImageView.frame),
                                                        CGRectGetWidth(_checkmarkProfileImageView.frame),
                                                        CGRectGetHeight(_checkmarkProfileImageView.frame))];
    }
    return _checkmarkProfileImageView;
}

- (UIImageView *)deleteGreyImageView
{
    if (!_deleteGreyImageView) {
        _deleteGreyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.contentView.frame), 0, CGRectGetHeight(self.frame), CGRectGetHeight(self.frame))];
        [_deleteGreyImageView setImage:[UIImage imageNamed:@"DeleteGrey"]];
        [_deleteGreyImageView setContentMode:UIViewContentModeCenter];
        [self.backView addSubview:_deleteGreyImageView];
    }
    return _deleteGreyImageView;
}

- (UIImageView *)deleteRedImageView
{
    if (!_deleteRedImageView) {
        _deleteRedImageView = [[UIImageView alloc] initWithFrame:self.deleteGreyImageView.bounds];
        [_deleteRedImageView setImage:[UIImage imageNamed:@"DeleteRed"]];
        [_deleteRedImageView setContentMode:UIViewContentModeCenter];
        [self.deleteGreyImageView addSubview:_deleteRedImageView];
    }
    return _deleteRedImageView;
}


/*---------------------------------------------------------------------------*/
#pragma mark -
/*---------------------------------------------------------------------------*/
-(void)setThumbnail:(UIImage*)image
{
    [self.profileImageView setImage:image];
}

-(void)setFavourite:(BOOL)favourite animated:(BOOL)animated
{
    self.isFavourite = favourite;

    if (animated) {
        if (favourite) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
            animation.toValue = (id)[UIColor colorWithRed:0.149 green:0.784 blue:0.424 alpha:0.750].CGColor;
            animation.fromValue = (id)[UIColor colorWithWhite:0 alpha:0.3].CGColor;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.duration = 0.25;
            [self.profileImageView.layer addAnimation:animation forKey:@"animateBorderColor"];
            [self.profileImageView.layer setBorderColor:[UIColor colorWithRed:0.149 green:0.784 blue:0.424 alpha:0.750].CGColor];
            [self.checkmarkProfileImageView setAlpha:0];
            [self.profileImageView addSubview:_checkmarkProfileImageView];
            [UIView animateWithDuration:0.25
                             animations:^{
                                 [self.checkmarkProfileImageView setAlpha:1];
                             }];

        } else {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
            animation.toValue = (id)[UIColor colorWithWhite:0 alpha:0.3].CGColor;
            animation.fromValue = (id)[UIColor colorWithRed:0.149 green:0.784 blue:0.424 alpha:0.750].CGColor;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.duration = 0.25;
            [self.profileImageView.layer addAnimation:animation forKey:@"animateBorderColor"];
            [self.profileImageView.layer setBorderColor:[UIColor colorWithWhite:0 alpha:0.3].CGColor];
            [UIView animateWithDuration:0.25
                             animations:^{
                                 [self.checkmarkProfileImageView setAlpha:0];
                             }
                             completion:^(BOOL finished) {
                                 [_checkmarkProfileImageView removeFromSuperview];
                             }];
        }

    } else {
        if (favourite) {
            [self.checkmarkProfileImageView setAlpha:1];
            [self.profileImageView addSubview:_checkmarkProfileImageView];
            [self.profileImageView.layer setBorderColor:[UIColor colorWithRed:0.149 green:0.784 blue:0.424 alpha:0.750].CGColor];
        } else {
            [self.checkmarkProfileImageView setAlpha:0];
            [_checkmarkProfileImageView removeFromSuperview];
            [self.profileImageView.layer setBorderColor:[UIColor colorWithWhite:0 alpha:0.3].CGColor];
        }
    }
}


/*---------------------------------------------------------------------------*/
#pragma mark -
/*---------------------------------------------------------------------------*/
-(void)animateContentViewForPoint:(CGPoint)point velocity:(CGPoint)velocity
{
    [super animateContentViewForPoint:point velocity:velocity];
    if (point.x > 0) {
        // set the checkmark's frame to match the contentView
        [self.checkmarkGreyImageView setFrame:CGRectMake(MIN(CGRectGetMinX(self.contentView.frame) - CGRectGetWidth(self.checkmarkGreyImageView.frame), 0), CGRectGetMinY(self.checkmarkGreyImageView.frame), CGRectGetWidth(self.checkmarkGreyImageView.frame), CGRectGetHeight(self.checkmarkGreyImageView.frame))];
        if (point.x >= CGRectGetHeight(self.frame) && self.isFavourite == NO) {
            [self.checkmarkGreenImageView setAlpha:1];

        } else if (self.isFavourite == NO) {
            [self.checkmarkGreenImageView setAlpha:0];

        } else if (point.x >= CGRectGetHeight(self.frame) && self.isFavourite == YES) {
            // already a favourite; animate the green checkmark drop when swiped far enough for the action to kick in when user lets go
            if (self.checkmarkGreyImageView.alpha == 1) {
                [UIView animateWithDuration:0.25
                                 animations:^{
                                     CATransform3D rotate = CATransform3DMakeRotation(-0.4, 0, 0, 1);
                                     [self.checkmarkGreenImageView.layer setTransform:CATransform3DTranslate(rotate, -10, 20, 0)];
                                     [self.checkmarkGreenImageView setAlpha:0];
                                 }];
            }

        } else if (self.isFavourite == YES) {
            // already a favourite; but user panned back to a lower value than the action point
            CATransform3D rotate = CATransform3DMakeRotation(0, 0, 0, 1);
            [self.checkmarkGreenImageView.layer setTransform:CATransform3DTranslate(rotate, 0, 0, 0)];
            [self.checkmarkGreenImageView setAlpha:1];
        }

    } else if (point.x < 0) {
        // set the X's frame to match the contentView
        [self.deleteGreyImageView setFrame:CGRectMake(MAX(CGRectGetMaxX(self.frame) - CGRectGetWidth(self.deleteGreyImageView.frame), CGRectGetMaxX(self.contentView.frame)), CGRectGetMinY(self.deleteGreyImageView.frame), CGRectGetWidth(self.deleteGreyImageView.frame), CGRectGetHeight(self.deleteGreyImageView.frame))];
        if (-point.x >= CGRectGetHeight(self.frame)) {
            [self.deleteRedImageView setAlpha:1];
        } else {
            [self.deleteRedImageView setAlpha:0];
        }
    }
}

-(void)resetCellFromPoint:(CGPoint)point velocity:(CGPoint)velocity
{
    [super resetCellFromPoint:point velocity:velocity];
    if (point.x > 0 && point.x <= CGRectGetHeight(self.frame)) {
        // user did not swipe far enough, animate the checkmark back with the contentView animation
        [UIView animateWithDuration:self.animationDuration
                         animations:^{
                             [self.checkmarkGreyImageView setFrame:CGRectMake(-CGRectGetWidth(self.checkmarkGreyImageView.frame), CGRectGetMinY(self.checkmarkGreyImageView.frame), CGRectGetWidth(self.checkmarkGreyImageView.frame), CGRectGetHeight(self.checkmarkGreyImageView.frame))];
                         }];
    } else if (point.x < 0) {
        if (-point.x <= CGRectGetHeight(self.frame)) {
            // user did not swipe far enough, animate the grey X back with the contentView animation
            [UIView animateWithDuration:self.animationDuration
                             animations:^{
                                 [self.deleteGreyImageView setFrame:CGRectMake(CGRectGetMaxX(self.frame), CGRectGetMinY(self.deleteGreyImageView.frame), CGRectGetWidth(self.deleteGreyImageView.frame), CGRectGetHeight(self.deleteGreyImageView.frame))];
                             }];
        } else {
            // user did swipe far enough to meet the delete action requirement, animate the Xs to show selection
            [UIView animateWithDuration:self.animationDuration
                             animations:^{
                                 [self.deleteGreyImageView.layer setTransform:CATransform3DMakeScale(2, 2, 2)];
                                 [self.deleteGreyImageView setAlpha:0];
                                 [self.deleteRedImageView.layer setTransform:CATransform3DMakeScale(2, 2, 2)];
                                 [self.deleteRedImageView setAlpha:0];
                             }];
        }
    }
}

-(void)cleanupBackView
{
    [super cleanupBackView];
    [_checkmarkGreyImageView removeFromSuperview];
    _checkmarkGreyImageView = nil;
    [_checkmarkGreenImageView removeFromSuperview];
    _checkmarkGreenImageView = nil;
    [_deleteGreyImageView removeFromSuperview];
    _deleteGreyImageView = nil;
    [_deleteRedImageView removeFromSuperview];
    _deleteRedImageView = nil;
}

@end