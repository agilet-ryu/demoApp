//
//  hudView.h
//  demoApp
//
//  Created by agilet on 2019/06/18.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "firstTableModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface hudView : UIView

-(instancetype)initWithModel:(firstTableModel *)currentModel andController:(UIViewController *)controller;
-(void)show;
-(void)hide;

@end

NS_ASSUME_NONNULL_END
