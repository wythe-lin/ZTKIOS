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

#import "PlanViewController.h"
#import "ZTColor.h"
#import "KLCPopup.h"

#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>


extern NSMutableArray   *connectList;

/*
 ******************************************************************************
 *
 * for debug
 *
 ******************************************************************************
 */
#define LOGGING_LEVEL_PLANVIEW  1
#define LOGGING_LEVEL_RMSCELL   0
#include "DbgMsg.h"

#if defined(LOGGING_LEVEL_PLANVIEW) && LOGGING_LEVEL_PLANVIEW
#define dmsg(fmt, ...)      LOG_FORMAT(fmt, @"PV", ##__VA_ARGS__)
#else
#define dmsg(...)
#endif

#if defined(LOGGING_LEVEL_RMSCELL) && LOGGING_LEVEL_RMSCELL
#define rmsg(fmt, ...)      LOG_FORMAT(fmt, @"PV", ##__VA_ARGS__)
#else
#define rmsg(...)
#endif



/*
 ******************************************************************************
 *
 * @interface
 *
 ******************************************************************************
 */
@interface PlanViewController ()

@end


/*
 ******************************************************************************
 *
 * @implementation
 *
 ******************************************************************************
 */
@implementation PlanViewController

/*---------------------------------------------------------------------------*/
#pragma mark - TableView Lifecycle
/*---------------------------------------------------------------------------*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    dmsg(@"viewDidLoad");

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.title = @"Plan";
    self.navigationItem.title = @"Planning";
//    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationController.navigationBar.barTintColor = [ZTColor lightBlueColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    // register tableview cell
    [self.tableView registerClass:[PlanViewCell class] forCellReuseIdentifier:@"PlanCell"];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.tableView setRowHeight:64];
    [self.tableView setSeparatorColor:[UIColor whiteColor]];

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 200)];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [view setBackgroundColor:[ZTColor darkBlueColor]];
    self.tableView.tableFooterView = view;
    [self.tableView setBackgroundColor:view.backgroundColor];
    self.tableView.contentInset = self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, - CGRectGetHeight(view.frame), 0);

    //
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sendPlanView)];
    [self.navigationItem setRightBarButtonItem:sendButton];

    UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(resetPlanView)];
    [self.navigationItem setLeftBarButtonItem:resetButton];


    //
    _hourLst = [NSMutableArray arrayWithObjects:@"00", @"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11",
                                                @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", nil];

    _minLst  = [NSMutableArray arrayWithObjects:@"00", @"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09",
                                                @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19",
                                                @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29",
                                                @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39",
                                                @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49",
                                                @"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59", nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)array
{
    if (!_array) {
        _array = [@[[@{@"isEnabled" : @NO, @"isCamera" : @YES} mutableCopy],
                    [@{@"isEnabled" : @NO, @"isCamera" : @NO } mutableCopy],
                    [@{@"isEnabled" : @NO, @"isCamera" : @YES} mutableCopy],
                    [@{@"isEnabled" : @NO, @"isCamera" : @NO } mutableCopy],
                    [@{@"isEnabled" : @NO, @"isCamera" : @YES} mutableCopy]] mutableCopy];
    }
    return _array;
}


/*---------------------------------------------------------------------------*/
#pragma mark -
/*---------------------------------------------------------------------------*/
- (void)resetPlanView
{
    dmsg(@"resetPlanView - begin");

    [_array removeAllObjects];
    _array = nil;
    [self.tableView reloadData];

    dmsg(@"resetPlanView - end");
}

- (void)sendPlanView
{
    dmsg(@"sendPlanView - begin");

    if (![connectList count]) {
        return;
    }

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setDateFormat:@"HH:mm:ss"];

    self.ztCube = (ZTCube *) [connectList objectAtIndex:0];

    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.dimBackground = YES;
    HUD.labelText = @"connecting...";

    [HUD showAnimated:YES whileExecutingBlock:^{
        dmsg(@"executing block...");
        [UIApplication sharedApplication].idleTimerDisabled = YES;

        [self maskTabBar:4 except:2];

        [self.ztCube connect];
        [self.ztCube setDate];

#if 1
        for (NSUInteger i=0; i<5; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            PlanViewCell *cell = (PlanViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];

            dmsg(@"cell(%0lu) - isEnabled=%@, isCamera=%@, begin=%@, end=%@",
                 (unsigned long)i,
                 [cell getIsFavourite] ? @"YES" : @"NO ",
                 [cell getIsCamera] ? @"YES" : @"NO ",
                 [dateFormatter stringFromDate:[cell getBeginTime]],
                 [dateFormatter stringFromDate:[cell getEndTime]]);

            HUD.labelText = [NSString stringWithFormat:@"send %0d/5 plan...", i+1];
            [self.ztCube writePlan:i enable:[cell getIsFavourite] type:[cell getIsCamera] beginTime:[cell getBeginTime] endTime:[cell getEndTime] repeat:0x01];
            sleep(1);
        }
#else
        [self.ztCube powerManager:0];
#endif

        [self.ztCube disconnect];

        HUD.labelText = @"completed!";
        sleep(1);

    } completionBlock:^{
        dmsg(@"completion block...");

        [self unmaskTabBar:4 except:2];
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [HUD removeFromSuperview];
    }];

    dmsg(@"sendPlanView - end");
}


- (void)maskTabBar:(NSInteger)total except:(NSInteger)n
{
    for (NSInteger i=0; i<total; i++) {
        if (i != n) {
            [[[[self.tabBarController tabBar]items]objectAtIndex:i]setEnabled:NO];
        }
    }
}

- (void)unmaskTabBar:(NSInteger)total except:(NSInteger)n
{
    for (NSInteger i=0; i<total; i++) {
        if (i != n) {
            [[[[self.tabBarController tabBar]items]objectAtIndex:i]setEnabled:YES];
        }
    }
}


/*---------------------------------------------------------------------------*/
#pragma mark - Table view data source
/*---------------------------------------------------------------------------*/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.array count];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
    // Return NO if you do not want the specified item to be editable.
    return YES;
 }

 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
 }

 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {

 }

 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
 }
 */


/*---------------------------------------------------------------------------*/
#pragma mark - TableView Delegate
/*---------------------------------------------------------------------------*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlanViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlanCell" forIndexPath:indexPath];

    cell.textLabel.text = @"Begin";
    cell.detailTextLabel.text = @"End";

    NSDate  *beginTime = [cell getBeginTime];
    NSDate  *endTime   = [cell getEndTime];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setDateFormat:@"HH:mm:ss"];

    cell.begin.text = [dateFormatter stringFromDate:beginTime];

    if ([(self.array)[indexPath.row][@"isCamera"] boolValue]) {
        cell.end.text = nil;
        cell.detailTextLabel.textColor = [UIColor grayColor];
        [cell setThumbnail:[UIImage imageNamed:@"camera"]];
    } else {
        cell.detailTextLabel.textColor = [UIColor blackColor];
        cell.end.text = [dateFormatter stringFromDate:endTime];
        [cell setThumbnail:[UIImage imageNamed:@"recorder"]];
    }

    [cell setFavourite:[(self.array)[indexPath.row][@"isEnabled"] boolValue] animated:NO];
    [cell setIsCamera:[(self.array)[indexPath.row][@"isCamera"] boolValue]];
    cell.delegate = self;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    select = (PlanViewCell *)[tableView cellForRowAtIndexPath:indexPath];

    // Generate content view to present
    UIView *contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    contentView.layer.borderWidth = 1;
    contentView.layer.borderColor = [[UIColor whiteColor] CGColor];
    contentView.layer.cornerRadius = 8.0;
    contentView.layer.masksToBounds = YES;

    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectView.frame = self.view.frame;
    [contentView addSubview:effectView];

    UIPickerView *datePicker = [[UIPickerView alloc] init];
    datePicker.translatesAutoresizingMaskIntoConstraints = NO;
    datePicker.backgroundColor = [UIColor clearColor];
    datePicker.dataSource = self;
    datePicker.delegate = self;

    NSDate  *begin = [select getBeginTime];
    NSCalendar  *calendar = [NSCalendar currentCalendar];
    NSDateComponents *bc = [calendar components:PLANCELL_UNIT_FLAGS fromDate:begin];
    [datePicker selectRow:[bc hour] inComponent:0  animated:NO];
    [datePicker selectRow:[bc minute] inComponent:1 animated:NO];
    [self setHour:[bc hour]];
    [self setMin:[bc minute]];

    UIButton *beginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    beginButton.translatesAutoresizingMaskIntoConstraints = NO;
    beginButton.layer.borderWidth = 1;
    beginButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    beginButton.backgroundColor = [UIColor clearColor];
    [beginButton setTitle:@"Begin" forState:UIControlStateNormal];
    [beginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [beginButton setTitleColor:[[beginButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [beginButton addTarget:self action:@selector(beginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *endButton = [UIButton buttonWithType:UIButtonTypeCustom];
    endButton.translatesAutoresizingMaskIntoConstraints = NO;
    endButton.layer.borderWidth = 1;
    endButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    endButton.backgroundColor = [UIColor clearColor];
    [endButton setTitle:@"End" forState:UIControlStateNormal];
    if ([(self.array)[indexPath.row][@"isCamera"] boolValue]) {
        endButton.userInteractionEnabled = NO;
        [endButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    } else {
        endButton.userInteractionEnabled = YES;
        [endButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    [endButton setTitleColor:[[endButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [endButton addTarget:self action:@selector(endButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    backButton.layer.borderWidth = 1;
    backButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton setTitleColor:[[backButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    [contentView addSubview:datePicker];
    [contentView addSubview:beginButton];
    [contentView addSubview:endButton];
    [contentView addSubview:backButton];

    NSDictionary *views = NSDictionaryOfVariableBindings(contentView, beginButton, endButton, backButton, datePicker);
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[datePicker]-(2)-[beginButton]-(0)-|"
                                                                        options:NSLayoutFormatAlignAllCenterX
                                                                        metrics:nil
                                                                          views:views]];

    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[backButton(100)][beginButton(100)][endButton(100)]-(0)-|"
                                                                        options:NSLayoutFormatAlignAllBottom
                                                                        metrics:nil
                                                                          views:views]];


    // show in popup
    KLCPopupLayout layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutCenter);
    KLCPopup *popup = [KLCPopup popupWithContentView:contentView
                                            showType:KLCPopupShowTypeShrinkIn
                                         dismissType:KLCPopupDismissTypeShrinkOut
                                            maskType:KLCPopupMaskTypeDimmed
                            dismissOnBackgroundTouch:NO
                               dismissOnContentTouch:NO];

    [popup showWithLayout:layout];
}



/*---------------------------------------------------------------------------*/
#pragma mark -
/*---------------------------------------------------------------------------*/
- (void)beginButtonPressed:(UIButton *)sender
{
    if ([sender isKindOfClass:[UIView class]]) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

        NSDate *beginTime = [select getBeginTime];
        NSDateComponents *bc = [[NSCalendar currentCalendar] components:PLANCELL_UNIT_FLAGS fromDate:beginTime];
        [bc setHour:[self getHour]];
        [bc setMinute:[self getMin]];
        [select setBeginTime:[gregorian dateFromComponents:bc]];
        dmsg(@"beginButtonPressed: - begin time:%@", [select getBeginTime]);

        if ([select getIsCamera]) {
            NSDate *endTime = [[select getBeginTime] dateByAddingTimeInterval:60*1];
            NSDateComponents *ec = [[NSCalendar currentCalendar] components:PLANCELL_UNIT_FLAGS fromDate:endTime];
            [select setEndTime:[gregorian dateFromComponents:ec]];
            dmsg(@"beginButtonPressed: - end   time:%@", [select getEndTime]);
        }
    }
}

- (void)endButtonPressed:(UIButton *)sender
{
    if ([sender isKindOfClass:[UIView class]]) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

        NSDate *endTime = [select getEndTime];
        NSDateComponents *component = [[NSCalendar currentCalendar] components:PLANCELL_UNIT_FLAGS fromDate:endTime];
        [component setHour:[self getHour]];
        [component setMinute:[self getMin]];

        [select setEndTime:[gregorian dateFromComponents:component]];
        dmsg(@"endButtonPressed: - end   time:%@", [select getEndTime]);
    }
}

- (void)backButtonPressed:(UIButton *)sender
{
    if ([sender isKindOfClass:[UIView class]]) {
        dmsg(@"backButtonPressed:");

        [(UIView *)sender dismissPresentingPopup];
        [self.tableView reloadData];
    }
}



/*---------------------------------------------------------------------------*/
#pragma mark -  PickerView Delegate
/*---------------------------------------------------------------------------*/
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:     return [_hourLst count];
        case 1:     return [_minLst count];
        default:    return 0;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0:     [self setHour:[[_hourLst objectAtIndex:row] intValue]]; dmsg(@"hour -> %@", [_hourLst objectAtIndex:row]);  break;
        case 1:     [self setMin:[[_minLst objectAtIndex:row] intValue]];   dmsg(@"min  -> %@", [_minLst objectAtIndex:row]);   break;
        default:    break;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] init];

    label.textAlignment = NSTextAlignmentCenter;
    switch (component) {
        case 0: label.text = [_hourLst objectAtIndex:row];  break;
        case 1: label.text = [_minLst objectAtIndex:row];   break;
    }

    label.textColor = [UIColor whiteColor];
    label.font      = [UIFont fontWithName:@"Helvetica" size:24.0];
    return label;
}


/*---------------------------------------------------------------------------*/
#pragma mark - Swipe Table View Cell Delegate
/*---------------------------------------------------------------------------*/
- (void)swipeTableViewCellDidStartSwiping:(RMSwipeTableViewCell *)swipeTableViewCell
{
    rmsg(@"swipeTableViewCellDidStartSwiping:%@", swipeTableViewCell);
}

- (void)swipeTableViewCell:(RMSwipeTableViewCell *)swipeTableViewCell didSwipeToPoint:(CGPoint)point velocity:(CGPoint)velocity
{
    rmsg(@"swipeTableViewCell:%@ didSwipeToPoint:%@ velocity:%@", swipeTableViewCell, NSStringFromCGPoint(point), NSStringFromCGPoint(velocity));
}

- (void)swipeTableViewCellWillResetState:(RMSwipeTableViewCell *)swipeTableViewCell fromPoint:(CGPoint)point animation:(RMSwipeTableViewCellAnimationType)animation velocity:(CGPoint)velocity
{
    rmsg(@"swipeTableViewCellWillResetState:%@ fromPoint:%@ animation:%d, velocity:%@", swipeTableViewCell, NSStringFromCGPoint(point), animation, NSStringFromCGPoint(velocity));

    PlanViewCell    *cell      = (PlanViewCell *)swipeTableViewCell;
    NSIndexPath     *indexPath = [self.tableView indexPathForCell:cell];

    if (point.x >= CGRectGetHeight(swipeTableViewCell.frame)) {
        if ((cell.revealDirection != RMSwipeTableViewCellRevealDirectionNone) && (cell.revealDirection != RMSwipeTableViewCellRevealDirectionRight)) {
            if ([(self.array)[indexPath.row][@"isEnabled"] boolValue]) {
                (self.array)[indexPath.row][@"isEnabled"] = @NO;
            } else {
                (self.array)[indexPath.row][@"isEnabled"] = @YES;
            }
            [cell setFavourite:[(self.array)[indexPath.row][@"isEnabled"] boolValue] animated:YES];
        }

    } else if (point.x < 0 && -point.x >= CGRectGetHeight(swipeTableViewCell.frame)) {
        if ((cell.revealDirection != RMSwipeTableViewCellRevealDirectionNone) && (cell.revealDirection != RMSwipeTableViewCellRevealDirectionLeft)) {
            if ([(self.array)[indexPath.row][@"isCamera"] boolValue]) {
                (self.array)[indexPath.row][@"isCamera"] = @NO;
            } else {
                (self.array)[indexPath.row][@"isCamera"] = @YES;
            }
            [cell setIsCamera:[(self.array)[indexPath.row][@"isCamera"] boolValue]];

            NSDate *t = [cell getEndTime];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [dateFormatter setDateFormat:@"HH:mm:ss"];
            if ([(self.array)[indexPath.row][@"isCamera"] boolValue]) {
                cell.detailTextLabel.textColor = [UIColor grayColor];
                cell.end.text = nil;
                [cell setThumbnail:[UIImage imageNamed:@"camera"]];
            } else {
                cell.detailTextLabel.textColor = [UIColor blackColor];
                cell.end.text = [dateFormatter stringFromDate:t];
                [cell setThumbnail:[UIImage imageNamed:@"recorder"]];
            }
        }
    }
}

- (void)swipeTableViewCellDidResetState:(RMSwipeTableViewCell *)swipeTableViewCell fromPoint:(CGPoint)point animation:(RMSwipeTableViewCellAnimationType)animation velocity:(CGPoint)velocity
{
    rmsg(@"swipeTableViewCellDidResetState:%@ fromPoint:%@ animation:%d, velocity:%@", swipeTableViewCell, NSStringFromCGPoint(point), animation, NSStringFromCGPoint(velocity));
}


/*---------------------------------------------------------------------------*/
#pragma mark - Navigation
/*---------------------------------------------------------------------------*/
/*
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
 }
 */

@end
