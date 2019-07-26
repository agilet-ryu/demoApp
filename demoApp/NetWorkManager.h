//
//  NetWorkManager.h
//  demoApp
//
//  Created by tourituyou on 2019/7/18.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface NetWorkManager : NSObject


/**
 NetWorkManager初期化

 @return NetWorkManager
 */
+ (instancetype)shareNetWorkManager;

/**
 「SF-002：認証」機能を呼び出す。

 @param controller 呼び出す元controller
 */
- (void)getFaceIDSignWithCurrentController:(UIViewController *)controller;


- (void)getOCRMessageWithBase64;

// SF-010：サーバOCR
- (void)getOCRMessageWithFile:(UIImage *)image andCurrentController:(UIViewController *)controller;

- (void)testWithBase64;
- (void)testWithAESFile;
@end

NS_ASSUME_NONNULL_END
