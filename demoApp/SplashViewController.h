//
//  SplashViewController.h
//  demoApp
//
//  Created by tourituyou on 2019/7/8.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"
NS_ASSUME_NONNULL_BEGIN

@interface SplashViewController : UIViewController
@property (nonatomic, strong) Config *config;  // 呼出元アプリ入力パラメータ
@end

NS_ASSUME_NONNULL_END
