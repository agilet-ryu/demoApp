//
//  BaseViewController.h
//  demoApp
//
//  Created by agilet on 2019/06/20.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITool.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

@property (nonatomic, copy) NSString *headerlabelString;
@property (nonatomic, assign) BOOL buttonInteractionEnabled;
@property (nonatomic, assign) float progress;

- (void)didFooterButtonClicked;

@end

NS_ASSUME_NONNULL_END
