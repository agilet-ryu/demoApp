//
//  TestViewController.m
//  demoApp
//
//  Created by agilet-ryu on 2019/8/3.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewID = @"G0030-01";
    self.buttonInteractionEnabled = NO;
    self.detailString = [NSString stringWithFormat:@"%@%@", @"没有理想的人不伤心", self.currentViewModel.viewFirstDetail];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.buttonInteractionEnabled = YES;
}

- (void)didFooterButtonClicked{
    [super didFooterButtonClicked];
    NSLog(@"TestViewController");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
