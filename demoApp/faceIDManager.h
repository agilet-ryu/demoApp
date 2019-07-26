//
//  faceIDManager.h
//  demoApp
//
//  Created by agilet on 2019/06/26.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol faceIDManagerDelegate <NSObject>

@optional
- (void)didVerifySuccess:(NSString *)msg;

- (void)didVerifyFailure:(NSString *)msg title:(NSString *)title;

- (void)getBizTokenSuccuss:(NSString *)bizToken;

- (void)startDetectSuccuss:(NSData *)data andBizToken:(NSString *)bizToken;
@end

@interface faceIDManager : NSObject

@property (nonatomic,assign) id<faceIDManagerDelegate>delegate;

+ (instancetype)sharedFaceIDManager;
- (void)getBizTokenWithImage:(UIImage *)image viewController:(UIViewController *)viewController;
- (void)startDetectWithContoller:(UIViewController *)viewController bizToken:(NSString *)bizTokenStr;
- (void)startVerifyWitBizToken:(NSString *)bizTokenStr data:(NSData *)deltaData;
@end

NS_ASSUME_NONNULL_END
