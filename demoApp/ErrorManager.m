//
//  ErrorManager.m
//  demoApp
//
//  Created by tourituyou on 2019/7/18.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "ErrorManager.h"


@implementation ErrorManager

static ErrorManager *manager = nil;
+ (instancetype)shareErrorManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ErrorManager alloc] init];
    });
    return manager;
}

/**
 エラー処理
 
 @param errorCode エラーコード
 @param msg エラー
 @param controller ポップアップ
 */
- (void)dealWithErrorCode:(NSString *)errorCode msg:(NSString *)msg andController:(UIViewController *)controller{
    
    // 共通領域初期化
    InfoDatabase *db = [InfoDatabase shareInfoDatabase];
    
    // エラーコードを共通領域の「本人確認内容データ.エラーコード」へ設定する
    db.identificationData.ERROR_CODE = errorCode;
    
    // 共通領域の「本人確認内容データ.認証処理結果」へ「異常」を設定する
    db.identificationData.SDK_RESULT = @"異常";
    
    // ポップアップでエラーメッセージ「SF-001-01E」を表示する。
    [self showWithErrorCode:msg atCurrentController:controller managerType:errorManagerTypeSDKClose addFirstMsg:@"" addSecondMsg:@""];
}

/**
 エラー画面を表示する
 
 @param errorCode エラーコード
 @param currentController ポップアップ
 @param type エラー画面の種類
 @param firstMsg エラーメッセージ
 @param secondMsg エラーメッセージ
 */
- (void)showWithErrorCode:(NSString *)errorCode atCurrentController:(UIViewController *)currentController managerType:(errorManagerType)type addFirstMsg:(NSString *)firstMsg addSecondMsg:(NSString *)secondMsg {
    
    NSString *errorString = [NSString stringWithFormat:@"%@", [self getErrorStringWithErrorCode:errorCode]];
    if ([errorString containsString:@"%1"] && firstMsg) {
        [errorString stringByReplacingOccurrencesOfString:@"%1" withString:firstMsg];
    }
    if ([errorString containsString:@"%2"] && secondMsg) {
        [errorString stringByReplacingOccurrencesOfString:@"%2" withString:secondMsg];
    }
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"" message:errorString preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        // 「SF-102:操作ログサーバ送信」、｢SF-017:処理終了｣を呼び出す。
        if (type == errorManagerTypeSDKClose) {
            [currentController.navigationController dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }]];
    [currentController presentViewController:a animated:YES completion:^{
        
    }];
}

- (NSString *)getErrorStringWithErrorCode:(NSString *)errorCode{
    NSString *errorString = [NSString new];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Code.plist" ofType:nil];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSDictionary *errorDic = [NSDictionary dictionaryWithDictionary:dic[@"errorCode"]];
    NSArray *a = [NSArray arrayWithArray:errorDic[errorCode]];
    errorString = [NSString stringWithFormat:@"%@", a[0]];
    return errorString;
}

@end
