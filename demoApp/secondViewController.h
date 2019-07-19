//
//  secondViewController.h
//  demoApp
//
//  Created by agilet on 2019/06/18.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "firstTableModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface secondViewController : UIViewController

@property (nonatomic, strong) firstTableModel *currentModel;
@property (nonatomic, strong) UIButton *bt1;
@property (nonatomic, strong) UIButton *bt2;

@end

NS_ASSUME_NONNULL_END
