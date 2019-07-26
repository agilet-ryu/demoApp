//
//  OCRResultViewController.h
//  demoApp
//
//  Created by tourituyou on 2019/7/9.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "firstTableModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCRResultViewController : UIViewController
@property (nonatomic, strong) firstTableModel *currentModel;
@property (nonatomic, strong) NSString *jsStr;
@end

NS_ASSUME_NONNULL_END
