/*
 ******************************************************************************
 * ImageViewController.m -
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

#import "ImageViewController.h"
#import "CollectionCell.h"

// open source
#import "MBProgressHUD.h"
#import "KLCPopup.h"

#import <QuartzCore/QuartzCore.h>


/*
 ******************************************************************************
 *
 * for debug
 *
 ******************************************************************************
 */
#define LOGGING_LEVEL_IMAGEVIEW      1
#include "DbgMsg.h"

#if defined(LOGGING_LEVEL_IMAGEVIEW) && LOGGING_LEVEL_IMAGEVIEW
    #define LogIV(fmt, ...)     LOG_FORMAT(fmt, @"IV", ##__VA_ARGS__)
#else
    #define LogIV(...)
#endif

#define msg(fmt, ...)       LOG_FORMAT(fmt, @"IV", ##__VA_ARGS__)


/*
 ******************************************************************************
 *
 * local variable
 *
 ******************************************************************************
 */
extern NSMutableArray   *connectList;

typedef NS_ENUM(NSInteger, FieldTag)
{
    FieldTagHorizontalLayout = 1001,
    FieldTagVerticalLayout,
    FieldTagMaskType,
    FieldTagShowType,
    FieldTagDismissType,
    FieldTagBackgroundDismiss,
    FieldTagContentDismiss,
    FieldTagTimedDismiss,
};

typedef NS_ENUM(NSInteger, CellType)
{
    CellTypeNormal = 0,
    CellTypeSwitch,
};


/*
 ******************************************************************************
 *
 * @interface
 *
 ******************************************************************************
 */
@interface ImageViewController ()
{
    // Store margins for current setup
    CGFloat _margin, _gutter, _columns;
}

@end


/*
 ******************************************************************************
 *
 * @implementation
 *
 ******************************************************************************
 */
@implementation ImageViewController

/*---------------------------------------------------------------------------*/
#pragma mark - UIView Lifecycle
/*---------------------------------------------------------------------------*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    LogIV(@"viewDidLoad");
    // Do any additional setup after loading the view, typically from a nib.

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.title = @"Pictures";
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.view.backgroundColor = [UIColor colorWithRed:86.0/255.0 green:161.0/255.0 blue:217.0/255.0 alpha:1.0];

    self.collectionView.backgroundColor = [UIColor colorWithRed:59.0/255.0 green:107.0/255.0 blue:159.0/255.0 alpha:1.0];


    // Defaults
    _columns = (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) ? 3 : 4;
    _margin  = (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) ? 0 : 0;
    _gutter  = (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) ? 1 : 1;

    // for pixel perfection...
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // iPad
        _columns = (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) ? 6 : 8;
        _margin  = (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) ? 1 : 1;
        _gutter  = (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) ? 2 : 2;

    } else if ([UIScreen mainScreen].bounds.size.height == 480) {
        // iPhone 3.5 inch
        _columns = (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) ? 3 : 4;
        _margin  = (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) ? 0 : 1;
        _gutter  = (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) ? 1 : 2;

    } else {
        // iPhone 4 inch
        _columns = (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) ? 3 : 5;
        _margin  = (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) ? 0 : 0;
        _gutter  = (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) ? 1 : 2;
    }
    LogIV(@"_columns=%0d, _margin=%0d, _gutter=%0d", (int)_columns, (int)_margin, (int)_gutter);

    // folder path
    docDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentPath = [docDirectory  objectAtIndex:0];
    foldername   = @"wcube";
    folderPath   = [documentPath stringByAppendingPathComponent:foldername];

    // erase button
    erase = (UIButton *)[self.view viewWithTag:130];
    [self setButton:erase title:@"Erase" titleColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor] borderWidth:2.0f borderColor:[UIColor whiteColor]];

    // download button
    download = (UIButton *)[self.view viewWithTag:131];
    [self setButton:download title:@"Download" titleColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor] borderWidth:2.0f borderColor:[UIColor whiteColor]];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    LogIV(@"viewWillAppear:");

    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    LogIV(@"viewDidAppear:");

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    LogIV(@"viewWillDisappear");

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    LogIV(@"viewDidDisappear:");

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    LogIV(@"didReceiveMemoryWarning");
    // Dispose of any resources that can be recreated.

}


/*---------------------------------------------------------------------------*/
#pragma mark - Erase Button Action
/*---------------------------------------------------------------------------*/
- (IBAction)eraseButtonPress:(UIButton *)sender
{
    LogIV(@"eraseButtonPress: - begin");

    MBProgressHUD   *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.dimBackground = YES;
    HUD.labelText = @"erasing...";

    [HUD showAnimated:YES whileExecutingBlock:^{
        LogIV(@"executing block...");

        NSError *error;
        if (![[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error]) {
            if (!error) {
                if ([[NSFileManager defaultManager] removeItemAtPath:folderPath error:nil]) {
                    LogIV(@"%@ - 刪除", foldername);
                }
            }
        } else {
            if ([[NSFileManager defaultManager] removeItemAtPath:folderPath error:nil]) {
                LogIV(@"%@ - 刪除", foldername);
            }
        }
        sleep(2);

    } completionBlock:^{
        LogIV(@"completion block...");
        [HUD removeFromSuperview];

        [self.collectionView reloadData];
    }];


    LogIV(@"eraseButtonPress: - end");
}


/*---------------------------------------------------------------------------*/
#pragma mark - Download Button Action
/*---------------------------------------------------------------------------*/
- (IBAction)downloadButtonPress:(UIButton *)sender
{
    LogIV(@"downloadButtonPress: - begin");

    if (![connectList count]) {
        return;
    }

    //
    [self setButton:download title:@"Download" titleColor:[UIColor redColor]       backgroundColor:[UIColor clearColor] borderWidth:2.0f borderColor:[UIColor redColor]];

    self.ztCube   = (ZTCube *) [connectList objectAtIndex:0];

    MBProgressHUD   *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.dimBackground = YES;
    HUD.labelText = @"connecting...";

    [HUD showAnimated:YES whileExecutingBlock:^{
        LogIV(@"executing block...");
        [[[[self.tabBarController tabBar]items]objectAtIndex:0]setEnabled:FALSE];
        [[[[self.tabBarController tabBar]items]objectAtIndex:2]setEnabled:FALSE];

        [self.ztCube connect];

        HUD.labelText = @"downloading...";
        [self.ztCube download];

        [self.ztCube disconnect];

        HUD.labelText = @"completed!";
        sleep(1);

    } completionBlock:^{
        LogIV(@"completion block...");
        [HUD removeFromSuperview];

        [self setButton:download title:@"Download" titleColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor] borderWidth:2.0f borderColor:[UIColor whiteColor]];

        [self.collectionView reloadData];

        [[[[self.tabBarController tabBar]items]objectAtIndex:0]setEnabled:TRUE];
        [[[[self.tabBarController tabBar]items]objectAtIndex:2]setEnabled:TRUE];
    }];
    
    LogIV(@"downloadButtonPress: - end");
}


/*
 * button style
 */
- (void)setButton:(UIButton *)btnName
            title:(NSString *)title
       titleColor:(UIColor *)tColor
  backgroundColor:(UIColor *)bgColor
      borderWidth:(CGFloat)bWidth
      borderColor:(UIColor *)bColor
{
    [btnName setBackgroundColor:bgColor];
    [btnName setTitleColor:tColor forState:UIControlStateNormal];
    [btnName setTitle:title forState:UIControlStateNormal];
    [[btnName layer] setBorderWidth:bWidth];
    [[btnName layer] setBorderColor:[bColor CGColor]];
    [[btnName layer] setMasksToBounds:YES];
    [[btnName layer] setCornerRadius:15.0f];
}


/*---------------------------------------------------------------------------*/
#pragma mark - Image Resize
/*---------------------------------------------------------------------------*/
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
//    UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}


/*---------------------------------------------------------------------------*/
#pragma mark - UICollectionViewDelegate
/*---------------------------------------------------------------------------*/
/*
 * Managing the Selected Cells
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LogIV(@"collectionView:didSelectItemAtIndexPath:");

    //
    NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:indexPath];
    if (self.selectedItemIndexPath) {
        if ([indexPath compare:self.selectedItemIndexPath] == NSOrderedSame) {
            // nothing to do

        } else {
            [indexPaths addObject:self.selectedItemIndexPath];
            self.selectedItemIndexPath = indexPath;
        }

    } else {
        self.selectedItemIndexPath = indexPath;
    }

    // and now only reload only the cells that need updating
    [collectionView reloadItemsAtIndexPaths:indexPaths];


    // get image source & scale
    NSString *imageToLoad = [folderPath stringByAppendingPathComponent:[fileLst objectAtIndex:indexPath.row]];
    UIImage *orgImage = [UIImage imageNamed:imageToLoad];;
    UIImage *scaleImage = [self imageWithImage:orgImage scaledToSize:CGSizeMake(orgImage.size.width*1.5, orgImage.size.height*1.5)];

    // popup view
    // Generate content view to present
    UIImageView *contentView = [[UIImageView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    contentView.backgroundColor = [UIColor colorWithRed:(184.0/255.0) green:(233.0/255.0) blue:(122.0/255.0) alpha:1.0];
    contentView.layer.cornerRadius = 12.0;
    contentView.image = scaleImage;
    contentView.contentMode = UIViewContentModeScaleAspectFit;
    contentView.frame = CGRectMake(0, 0, contentView.image.size.width, contentView.image.size.height);
    contentView.center = contentView.superview.center;

    UILabel *popLabel = [[UILabel alloc] init];
    popLabel.translatesAutoresizingMaskIntoConstraints = NO;
    popLabel.backgroundColor = [UIColor clearColor];
    popLabel.textColor = [UIColor whiteColor];
    popLabel.font = [UIFont boldSystemFontOfSize:12.0];
    popLabel.text = @"ZealTek";

    [contentView addSubview:popLabel];

    NSDictionary *views = NSDictionaryOfVariableBindings(contentView, popLabel);
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[popLabel]-(2)-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[popLabel]-(2)-|" options:0 metrics:nil views:views]];

    // show in popup
    KLCPopupLayout layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutCenter);
    KLCPopup *popup = [KLCPopup popupWithContentView:contentView
                                            showType:KLCPopupShowTypeShrinkIn
                                         dismissType:KLCPopupDismissTypeShrinkOut
                                            maskType:KLCPopupMaskTypeDimmed
                            dismissOnBackgroundTouch:NO
                               dismissOnContentTouch:YES];
        
    [popup showWithLayout:layout];

    //
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];

}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LogIV(@"collectionView:didDeselectItemAtIndexPath:");

    // TODO: Deselect item
}


/*---------------------------------------------------------------------------*/
#pragma mark - UICollectionViewDataSource
/*---------------------------------------------------------------------------*/
// 傳回幾個 secion
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

// 傳回每個 secion 有多少筆資料
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    LogIV(@"collectionView:numberOfItemsInSection:");

    //檢查資料夾是否存在
    NSError *error;

    fileLst = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error];
    if (!fileLst) {
        if (!error) {
            msg(@"%@ - 資料夾是空的", foldername);
        } else {
            msg(@"%@ - 資料夾不存在", foldername);
        }
    } else {
        for (NSString *s in fileLst) {
            msg(@"%@", s);
        }
    }

    return [fileLst count];
}

// 處理每一筆資料的內容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LogIV(@"collectionView:cellForItemAtIndexPath:");

    CollectionCell  *cell = (CollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CCell" forIndexPath:indexPath];
    if (cell == nil) {
        LogIV(@"alloc new cell");
        cell = [[CollectionCell alloc] init];
    }

    // 取出每一張照片的資料並轉換成 UIImage 格式
    NSString *imageToLoad = [folderPath stringByAppendingPathComponent:[fileLst objectAtIndex:indexPath.row]];
    cell.imageView.image = [UIImage imageNamed:imageToLoad];

    if (self.selectedItemIndexPath != nil && [indexPath compare:self.selectedItemIndexPath] == NSOrderedSame) {
        cell.imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
        cell.imageView.layer.borderWidth = 2.0;
    } else {
        cell.imageView.layer.borderColor = nil;
        cell.imageView.layer.borderWidth = 0.0;
    }

    return cell;
}


/*---------------------------------------------------------------------------*/
#pragma mark – UICollectionViewDelegateFlowLayout
/*---------------------------------------------------------------------------*/
// cell size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat value = floorf(((self.view.bounds.size.width - (_columns - 1) * _gutter - 2 * _margin) / _columns));
    return CGSizeMake(value, value*3/4);
}

// section的邊距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(_margin, _margin, _margin+140, _margin);
}

// cell上下的最小間距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return _gutter;
}

// cell左右的最小間距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return _gutter;
}

// the size of the header view
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(0, 0);
}

// the size of the footer view
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(0, 0);
}

@end
