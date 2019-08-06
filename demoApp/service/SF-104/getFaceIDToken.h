//
//  getFaceIDToken.h
//  demoApp
//
//  Created by agilet-ryu on 2019/7/31.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@protocol getFaceIDTokenDelegate <NSObject>


/**
 顔照合認証応答

 @param resultCode 処理結果
 @param errorCode エラーコード
 */
- (void)getFaceIDResultCode:(NSString *)resultCode errorCode:(NSString *)errorCode;
@end

@interface getFaceIDToken : NSObject
@property (nonatomic, assign) id<getFaceIDTokenDelegate>delegate;

/**
 認証トークン取得機能初期化
 
 @return 認証トークン取得機能
 */
+ (instancetype)initService;
/**
 「顔照合認証要求(App-GetBizToken)」のREST APIを利用しリクエスト発行。
 */
- (void)sendGetFaceIDTokenRequest;
@end

NS_ASSUME_NONNULL_END
