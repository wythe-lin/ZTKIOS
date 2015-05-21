/*
 ******************************************************************************
 * ImageViewController.h -
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

#import <UIKit/UIKit.h>

#import "ZTCube.h"
#import "ZTBatteryService.h"


@interface ImageViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    NSArray         *docDirectory;
    NSString        *documentPath;

    NSString        *foldername;
    NSString        *folderPath;

    NSFileManager   *fileManager;
    NSArray         *fileLst;

    UIButton        *erase;
    UIButton        *download;

}

/// Instance of ZTCube.
@property (strong, nonatomic) ZTCube                    *ztCube;

//
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSIndexPath               *selectedItemIndexPath;

@end

