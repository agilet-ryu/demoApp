//
//  SplashViewController.m
//  demoApp
//
//  Created by tourituyou on 2019/7/8.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "SplashViewController.h"
#import "TableViewController.h"
#import "NSString+checkString.h"
#import "NSArray+checkArray.h"
#import "InfoDatabase.h"
#import "ConfigXMLParser.h"
#import "ErrorManager.h"
#import "NetWorkManager.h"

@interface SplashViewController ()
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

@implementation SplashViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    // スプラッシュ画面を初期化する
    [self setIndicator];

#warning TODO
    // 呼出元アプリ入力パラメータを処理する
//    [self dealWithParam];
}


/**
 スプラッシュ画面を初期化する
 */
- (void)setIndicator {
    self.view.backgroundColor = [UIColor whiteColor];
    UIActivityIndicatorView *v = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    v.frame= CGRectMake(([UIScreen mainScreen].bounds.size.width - 200) * 0.5, ([UIScreen mainScreen].bounds.size.height - 200) * 0.5, 200, 200);
    v.color = [UIColor lightGrayColor];
    [self.view addSubview:v];
    [v startAnimating];
    self.indicatorView = v;
    [self performSelector:@selector(delayMethod) withObject:nil afterDelay:3.0];
}

/**
 呼出元アプリ入力パラメータを処理する
 */
- (void)dealWithParam {

    // 呼出元アプリ入力パラメータチェック
    NSMutableArray *errorArray = [NSMutableArray array];
    if ([NSString isBlankString:self.config.API_SECRET]) {
        [errorArray addObject:@"EC01-001"];
    }
    if ([NSString isBlankString:self.config.UUID]) {
        [errorArray addObject:@"EC01-004"];
    }
    if (!self.config.THREHOLDS_LEVEL) {
        [errorArray addObject:@"EC01-002"];
    }
    if (!self.config.IMAGE_TYPE) {
        [errorArray addObject:@"EC01-005"];
    }
    // 共通領域の初期化
    InfoDatabase *infoDB = [InfoDatabase shareInfoDatabase];

    if (![NSArray isBlankArray:errorArray]) {

        // エラーなし時、呼出元アプリ入力パラメータ展開
        infoDB.startParam = self.config;

        // 設定ファイルパラメータ展開
        [[ConfigXMLParser new] start];
#warning TODO
        // 「SF-002：認証」機能を呼び出す。

    } else{

        // エラーあり時
        NSString * errorCode = [errorArray lastObject];

        // エラーコードを共通領域の「本人確認内容データ.エラーコード」へ設定する
        infoDB.identificationData.ERROR_CODE = errorCode;

        // 共通領域の「本人確認内容データ.認証処理結果」へ「異常」を設定する
        infoDB.identificationData.SDK_RESULT = @"異常";

        // ポップアップでエラーメッセージ「SF-001-01E」を表示する。
        [[ErrorManager shareErrorManager] showWithErrorCode:@"SF-001-01E" atCurrentController:self managerType:errorManagerTypeClose];
    }
}

- (void)delayMethod {
    TableViewController *table = [[TableViewController alloc] init];
    [self.navigationController pushViewController:table animated:YES];
    [self.indicatorView stopAnimating];
}

@end
