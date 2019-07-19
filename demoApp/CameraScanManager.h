//
//  CameraScanManager.h
//  demoApp
//
//  Created by agilet on 2019/06/20.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol cameraScanManagerDelegate <NSObject>

- (void)cameraScanSuccessWithImage:(UIImage *)image;
- (void)cameraScanFailure;
- (void)cameraScanCancel;

@end

@interface CameraScanManager : NSObject

@property (nonatomic, weak) id<cameraScanManagerDelegate>delegate;
+ (instancetype)sharedCameraScanManager;
- (void)start;

@end

NS_ASSUME_NONNULL_END
