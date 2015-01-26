/*
 ******************************************************************************
 * RecordViewController.m -
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

#import "RecordViewController.h"

@interface RecordViewController ()

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    lstResolution = [[NSMutableArray alloc] init];
    [lstResolution addObject:@"full HD"];
    [lstResolution addObject:@"HD"];
    [lstResolution addObject:@"VGA"];
    [lstResolution addObject:@"QVGA"];
    [lstResolution addObject:@"CIF"];
    [lstResolution addObject:@"QCIF"];

    lstSpeed = [[NSMutableArray alloc] init];
    [lstSpeed addObject:@"1x"];
    [lstSpeed addObject:@"2x"];
    [lstSpeed addObject:@"3x"];
    [lstSpeed addObject:@"4x"];

    lstPower = [[NSMutableArray alloc] init];
    [lstPower addObject:@"50Hz"];
    [lstPower addObject:@"60Hz"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:     return [lstResolution count];
        case 1:     return [lstSpeed count];
        case 2:     return [lstPower count];
        default:    return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0:     return [lstResolution objectAtIndex:row];
        case 1:     return [lstSpeed objectAtIndex:row];
        case 2:     return [lstPower objectAtIndex:row];
        default:    return nil;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {
        case 0:     NSLog(@"resolution -> %@", [lstResolution objectAtIndex:row]); break;
        case 1:     NSLog(@"speed      -> %@", [lstSpeed objectAtIndex:row]);      break;
        case 2:     NSLog(@"power      -> %@", [lstPower objectAtIndex:row]);      break;
        default:    break;
    }
}


@end
