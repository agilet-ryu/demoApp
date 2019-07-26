//
//  firstTableModel.h
//  demoApp
//
//  Created by agilet on 2019/06/17.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Utils.h"
NS_ASSUME_NONNULL_BEGIN

@interface firstTableModel : NSObject
@property (nonatomic, strong) KBNModel *kbnModel;
@property (assign, nonatomic) BOOL isSelected;

- (firstTableModel *)initWithKBNModel:(KBNModel *)KBNModel;

@end

NS_ASSUME_NONNULL_END
