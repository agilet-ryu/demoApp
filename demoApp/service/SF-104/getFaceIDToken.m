//
//  getFaceIDToken.m
//  demoApp
//
//  Created by agilet-ryu on 2019/7/31.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "getFaceIDToken.h"
#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import "urlConfig.h"
#import "InfoDatabase.h"

@implementation getFaceIDToken

static getFaceIDToken *manager = nil;
static AFHTTPSessionManager* sessionManager = nil;

/**
 認証トークン取得機能初期化

 @return 認証トークン取得機能
 */
+ (instancetype)initService{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[getFaceIDToken alloc] init];
        sessionManager = [[AFHTTPSessionManager manager] init];
        [sessionManager.requestSerializer setValue:@"multipart/form-data; charset=utf-8; boundary=__X_PAW_BOUNDARY__" forHTTPHeaderField:@"Content-Type"];
    });
    return manager;
}

/**
 「顔照合認証要求(App-GetBizToken)」のREST APIを利用しリクエスト発行。
 */
- (void)sendGetFaceIDTokenRequest{
    
    // 共通領域初期化
    InfoDatabase *db = [InfoDatabase shareInfoDatabase];
    
    // 顔照合用画像を取得する
    NSData *data = UIImageJPEGRepresentation(db.identificationData.OBVERSE_IMG, 0.7);

    // パラメーターパラメーターを設定する
    NSDictionary* params = @{@"sign" : db.identificationData.FACEID_SIGNATURE,
                             @"sign_version" : @"hmac_sha1",
                             @"comparison_type" : @"0" ,
                             @"liveness_type" : @"meglive",
                             @"uuid" : @"1"};
    __weak typeof(self) weakSelf = self;
    
    // リクエストを行う
    [sessionManager POST:kURLGetFaceIDToken
              parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {[formData appendPartWithFileData:data name:@"image_ref1" fileName:@"head" mimeType:@"image/jpeg"];}
                progress:nil
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                     
                     // エラーコードを判定する。
                     NSString *errorCode = [NSString stringWithFormat:@"%@", responseObject[@"error"]];
                     if (errorCode.length) {
                         
                         // エラーコード（error）が設定されている場合
                         if ([weakSelf.delegate respondsToSelector:@selector(getFaceIDResultCode:errorCode:)]) {
                             
                             // ES00-401(照合画像エラー)を設定し呼出元機能へ返却する。
                             [weakSelf.delegate getFaceIDResultCode:@"" errorCode:@""];
                         }
                     }else{
                         
                         // エラーコード（error）が設定されていない場合
                         
                         // 顔照合認証応答(App-GetBizToken)から取得したレスポンス内容を共通領域定義.本人確認内容データに設定する。
                         db.identificationData.REQUEST_ID = responseObject[@"request_id"];
                         db.identificationData.BIZ_TOKEN = responseObject[@"biz_token"];
                         
                         // 「処理結果」に1を設定し返却する。
                         if ([weakSelf.delegate respondsToSelector:@selector(getFaceIDResultCode:errorCode:)]) {
                             [weakSelf.delegate getFaceIDResultCode:@"" errorCode:@""];
                         }
                     }
                 }
                 failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     
                     // 通信エラーの場合
                     if ([weakSelf.delegate respondsToSelector:@selector(getFaceIDResultCode:errorCode:)]) {
                         [weakSelf.delegate getFaceIDResultCode:@"" errorCode:@""];
                     }
                 }];
}
@end
