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

@protocol hudViewDelegate <NSObject>

-(void)didNextClicked;

@end

@interface hudView : UIView

@property(nonatomic, weak) id<hudViewDelegate>delegate;

-(instancetype)initWithModel:(firstTableModel *)currentModel isFront:(BOOL)isFront;
-(void)show;
-(void)hide;

@end

NS_ASSUME_NONNULL_END
