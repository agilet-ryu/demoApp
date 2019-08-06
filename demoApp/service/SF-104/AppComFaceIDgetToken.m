//
//  AppComFaceIDgetToken.m
//  demoApp
//
//  Created by agilet-ryu on 2019/8/1.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "AppComFaceIDgetToken.h"
#import "AppComServerComm.h"
#import "urlConfig.h"
#import "InfoDatabase.h"
#import <UIKit/UIKit.h>

@interface AppComFaceIDgetToken()<AppComServerCommDelegate>

@end

@implementation AppComFaceIDgetToken

static InfoDatabase *db = nil;
/**
 認証トークン取得機能初期化
 
 @return 認証トークン取得機能
 */
+ (instancetype)initService{
    AppComFaceIDgetToken *service = [[AppComFaceIDgetToken alloc] init];
    db = [InfoDatabase shareInfoDatabase];
    return service;
}

/**
 「顔照合認証要求(App-GetBizToken)」のREST APIを利用しリクエスト発行。
 */
- (void)sendGetFaceIDTokenRequest{
    FormData *data = [FormData initWithFileData:UIImageJPEGRepresentation(db.identificationData.OBVERSE_IMG, 1.0f)
                                       fileName:@"head"
                                           name:@"image_ref1"
                                       mimeType:@"image/jpeg"];
    
    AppComServerComm *commm = [AppComServerComm initService];
    commm.urlPath = kURLGetFaceIDToken;
    commm.delegate = self;
    commm.param = @{@"sign" : db.identificationData.FACEID_SIGNATURE,
                    @"sign_version" : @"hmac_sha1",
                    @"comparison_type" : @"0" ,
                    @"liveness_type" : @"meglive",
                    @"uuid" : @"1"};
    commm.contentType = contentTypeMultipart;
    commm.formDataArray = @[data];
    
    [commm sendRequest];
}

#pragma mark - AppComServerCommDelegate

// 通信成功時
- (void)appComServerCommSuccessWithResponseObject:(id)responseObject{
    
#warning TODO errorCode对应不足，errorcode未定义
    // エラーコードを判定する。
    NSString *errorCode = [NSString stringWithFormat:@"%@", responseObject[@"error"]];
    if (errorCode.length) {
        
        // エラーコード（error）が設定されている場合
        if ([self.delegate respondsToSelector:@selector(getFaceIDResultCode:errorCode:)]) {
            
            // ES00-401(照合画像エラー)を設定し呼出元機能へ返却する。
            [self.delegate getFaceIDResultCode:@"0" errorCode:@"ES00-401"];
        }
    }else{
        
        // エラーコード（error）が設定されていない場合
        
        // 顔照合認証応答(App-GetBizToken)から取得したレスポンス内容を共通領域定義.本人確認内容データに設定する。
        db.identificationData.REQUEST_ID = responseObject[@"request_id"];
        db.identificationData.BIZ_TOKEN = responseObject[@"biz_token"];
        
        // 「処理結果」に1を設定し返却する。
        if ([self.delegate respondsToSelector:@selector(getFaceIDResultCode:errorCode:)]) {
            [self.delegate getFaceIDResultCode:@"1" errorCode:@""];
        }
    }
}

// 通信失敗時
- (void)appComServerCommFailure{
    if ([self.delegate respondsToSelector:@selector(getFaceIDResultCode:errorCode:)]) {
        [self.delegate getFaceIDResultCode:@"0" errorCode:@"ES00-402"];
    }
}
@end
