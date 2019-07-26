//
//  firstTableModel.m
//  demoApp
//
//  Created by agilet on 2019/06/17.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "firstTableModel.h"

@implementation firstTableModel

- (firstTableModel *)initWithKBNModel:(KBNModel *)KBNModel{
    self = [super init];
    if (self) {
        self.kbnModel = KBNModel;
        self.isSelected = NO;
    }
    return self;
}

@end
