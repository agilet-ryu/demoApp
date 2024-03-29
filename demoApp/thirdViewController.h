//
//  thirdViewController.h
//  demoApp
//
//  Created by agilet on 2019/06/19.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "firstTableModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface thirdViewController : UIViewController

@property (nonatomic, strong) UIImage *frontImage;
@property (nonatomic, strong) firstTableModel *currentModel;

@end

NS_ASSUME_NONNULL_END
