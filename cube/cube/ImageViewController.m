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
    _columns = 3, _columnsL = 4;
    _margin  = 0, _marginL  = 0;
    _gutter  = 1, _gutterL  = 1;

    // for pixel perfection...
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // iPad
        _columns = 6, _columnsL = 8;
        _margin  = 1, _marginL  = 1;
        _gutter  = 2, _gutterL  = 2;

    } else if ([UIScreen mainScreen].bounds.size.height == 480) {
        // iPhone 3.5 inch
        _columns = 3, _columnsL = 4;
        _margin  = 0, _marginL  = 1;
        _gutter  = 1, _gutterL  = 2;

    } else {
        // iPhone 4 inch
        _columns = 3, _columnsL = 5;
        _margin  = 0, _marginL  = 0;
        _gutter  = 1, _gutterL  = 2;
    }


    lib = [[ALAssetsLibrary alloc] init];

    // 使用參數 ALAssetsGroupSavedPhotos 取出所有存檔照片
    [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        NSMutableArray  *tempArray = [[NSMutableArray alloc] init];
        if (group != nil) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result != nil) {
                    [tempArray addObject:result];
                }
            }];

            // 保存結果
            imageArray = [tempArray copy];
            NSLog(@"取出照片共 %0d 張", [imageArray count]);
            // 要求 Collection View 重新載入資料
            [self.colView reloadData];
        }

    } failureBlock:^(NSError *error) {
        // 讀取照片失敗

    }];
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
#pragma mark - Layout
/*---------------------------------------------------------------------------*/
- (CGFloat)getColumns
{
    if ((UIInterfaceOrientationIsPortrait(self.interfaceOrientation))) {
        return _columns;
    } else {
        return _columnsL;
    }
}

- (CGFloat)getMargin
{
    if ((UIInterfaceOrientationIsPortrait(self.interfaceOrientation))) {
        return _margin;
    } else {
        return _marginL;
    }
}

- (CGFloat)getGutter
{
    if ((UIInterfaceOrientationIsPortrait(self.interfaceOrientation))) {
        return _gutter;
    } else {
        return _gutterL;
    }
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
    LogIV(@"numberOfSectionsInCollectionView:");

    return 1;
}

// 傳回每個 secion 有多少筆資料
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    LogIV(@"collectionView:numberOfItemsInSection:");

    return [imageArray count];
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
    CGImageRef img = [[imageArray objectAtIndex:indexPath.row] thumbnail];
    cell.imageView.image = [UIImage imageWithCGImage:img];

    return cell;
}


/*---------------------------------------------------------------------------*/
#pragma mark – UICollectionViewDelegateFlowLayout
/*---------------------------------------------------------------------------*/
// cell size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat margin  = [self getMargin];
    CGFloat gutter  = [self getGutter];
    CGFloat columns = [self getColumns];
    CGFloat value   = floorf(((self.view.bounds.size.width - (columns - 1) * gutter - 2 * margin) / columns));
    return CGSizeMake(value, value);
}

// section的邊距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat margin = [self getMargin];
    return UIEdgeInsetsMake(margin, margin, margin+140, margin);
}

// headview size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(0, 0);
}

// cell上下的最小間距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return [self getGutter];
}

// cell左右的最小間距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return [self getGutter];
}


@end
