//
//  NetWorkManager.m
//  demoApp
//
//  Created by tourituyou on 2019/7/18.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "NetWorkManager.h"
#import <AFNetworking/AFNetworking.h>
#import "InfoDatabase.h"
#import "ErrorManager.h"
#define kNetworkHostFaceIDSign @"https://api-sgp.megvii.com"

@implementation NetWorkManager

static NetWorkManager *manager = nil;
static AFHTTPSessionManager* sessionManager = nil;

+(instancetype)shareNetWorkManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NetWorkManager alloc] init];
        sessionManager = [[AFHTTPSessionManager manager] init];
    });
    return manager;
}

- (void)getFaceIDSignWithCurrentController:(UIViewController *)controller{
    InfoDatabase *db = [InfoDatabase shareInfoDatabase];
    NSString *apiSecret = db.startParam.API_SECRET;
    NSString *businessID = db.configFileData.MAIN_ACCOUNT;
    NSDictionary *param = @{@"business_id" : businessID,
                            @"api_secret" : apiSecret
                                   };
    __weak typeof(self) weakSelf = self;
    [sessionManager POST:kNetworkHostFaceIDSign parameters:param headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject[@"error_code"]) {
            
            // エラーコードを共通領域の「本人確認内容データ.エラーコード」へ設定する
            db.identificationData.ERROR_CODE = responseObject[@"error_code"];
            
            // 共通領域の「本人確認内容データ.認証処理結果」へ「異常」を設定する
            db.identificationData.SDK_RESULT = @"異常";
            
            // ポップアップでエラーメッセージ「SF-001-01E」を表示する。
            [[ErrorManager shareErrorManager] showWithErrorCode:@"SF-001-01E" atCurrentController:controller managerType:errorManagerTypeClose];
        } else{
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        // ポップアップでエラーメッセージ「SF-001-01E」を表示する。
        [[ErrorManager shareErrorManager] showWithErrorCode:@"SF-001-01E" atCurrentController:controller managerType:errorManagerTypeClose];
    }];
}

@end
