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
 * @interface
 *
 ******************************************************************************
 */
@interface ImageViewController ()
{
    // Store margins for current setup
    CGFloat _margin, _gutter, _marginL, _gutterL, _columns, _columnsL;
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
    self.title = @"Image";
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;


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

    //
    docDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentPath = [docDirectory  objectAtIndex:0];
    foldername   = @"wcube";
    folderPath   = [documentPath stringByAppendingPathComponent:foldername];

/*
     if ([[NSFileManager defaultManager] removeItemAtPath:folderPath error:nil]) {
        LogIV(@"%@ - 刪除", foldername);
     }
*/

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    LogIV(@"viewWillAppear:");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    LogIV(@"viewDidAppear:");

    [self.colView reloadData];
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
#pragma mark - UICollectionViewDelegate
/*---------------------------------------------------------------------------*/
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LogIV(@"collectionView:didSelectItemAtIndexPath:");

    // TODO: Select Item
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

    static NSString *identifier = @"Cell";
    CollectionCell  *cell = (CollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[CollectionCell alloc] init];
    }

    // 取出每一張照片的資料並轉換成 UIImage 格式
    NSString *imageToLoad = [folderPath stringByAppendingPathComponent:[fileLst objectAtIndex:indexPath.row]];
    cell.imageView.image = [UIImage imageNamed:imageToLoad];
//    cell.imageView.image = [UIImage imageWithContentsOfFile:imageToLoad];

    return cell;
}


/*---------------------------------------------------------------------------*/
#pragma mark – UICollectionViewDelegateFlowLayout
/*---------------------------------------------------------------------------*/
// cell size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat value   = floorf(((self.view.bounds.size.width - (_columns - 1) * _gutter - 2 * _margin) / _columns));
    return CGSizeMake(value, value);
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
