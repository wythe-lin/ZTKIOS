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

//    cell.imageView.image = [self imageWithImage:[UIImage imageWithCGImage:img] scaledToSize:CGSizeMake(20, 20)];
    cell.imageView.image = [UIImage imageWithCGImage:img];

    return cell;
}


-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


/*---------------------------------------------------------------------------*/
#pragma mark – UICollectionViewDelegateFlowLayout
/*---------------------------------------------------------------------------*/
// cell size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LogIV(@"collectionView:layout:sizeForItemAtIndexPath:");

    return CGSizeMake(72, 72);
}

// section的邊距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    LogIV(@"collectionView:layout:insetForSectionAtIndex:");

    return UIEdgeInsetsMake(0, 0, 140, 0);
}

// headview size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(0, 0);
}

// cell上下的最小間距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 4.0;
}

// cell左右的最小間距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    CGRect  screenBound  = [[UIScreen mainScreen] bounds];
    CGSize  screenSize   = screenBound.size;
    CGFloat screenWidth  = screenSize.width;
    CGFloat screenHeight = screenSize.height;

    screenWidth = ceil((screenWidth - ((9) * 2.0)) / 4);

    LogIV(@"SW = %0f, IW = %0f", screenSize.width, screenWidth);
//    return CGSizeMake(screenWidth, screenWidth);

    return 3.4;
}


@end
