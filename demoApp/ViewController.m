//
//  ViewController.m
//  demoApp
//
//  Created by agilet on 2019/06/17.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "ViewController.h"
#import <UIKit/UIKit.h>
#import "SplashViewController.h"
#import "NSString+checkString.h"
#import "ConfigXMLParser.h"
#import "initManager.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)openLibrary:(id)sender {
//    NSString *a = @"大凧";
//    NSString *b = [a aci_encryptWithAES];
//    NSLog(@"哈或或或或%@", b);
    
    UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:[[SplashViewController alloc] init]];
    [self presentViewController:naVC animated:YES completion:^{
    }];
//    Config *c = [Config new];
//    [initManager startFinplexWithConfig:c Controller:self callback:^(ResultModel * _Nonnull resultModel, NSString * _Nonnull errorCode) {
//
//    }];
//    ConfigXMLParser *p = [[ConfigXMLParser alloc] init];
//    [p start];
}

@end
