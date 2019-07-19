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

+ (instancetype)shareNetWorkManager;

- (void)getFaceIDSignWithCurrentController:(UIViewController *)controller;
@end

NS_ASSUME_NONNULL_END
