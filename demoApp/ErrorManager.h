//
//  ErrorManager.h
//  demoApp
//
//  Created by tourituyou on 2019/7/18.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 エラー画面の種類

 - errorManagerTypeClose: 「はい」ボタンのみ、押す時、ライブラリーを終了する
 */
typedef NS_ENUM(NSInteger, errorManagerType) {
    errorManagerTypeClose,
};

NS_ASSUME_NONNULL_BEGIN

@interface ErrorManager : NSObject

/**
 エラー画面初期化

 @return ErrorManager
 */
+ (instancetype)shareErrorManager;

/**
 エラー画面を表示する

 @param errorCode エラーコード
 @param currentController ポップアップ
 @param type <#type description#>
 */
- (void)showWithErrorCode:(NSString *)errorCode atCurrentController:(UIViewController *)currentController managerType:(errorManagerType)type;

@end

NS_ASSUME_NONNULL_END
