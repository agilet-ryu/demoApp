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

- (void)showWithErrorCode:(NSString *)errorCode atCurrentController:(UIViewController *)currentController managerType:(errorManagerType)type {
    NSString *errorString = [NSString stringWithFormat:@"%@", [self getErrorStringWithErrorCode:errorCode]];
    
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"エラー" message:errorString preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        // ポップアップのOKボタンタップで｢SF-017:処理終了｣を呼び出す。
        [currentController.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
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
