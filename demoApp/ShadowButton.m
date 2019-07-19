//
//  ShadowButton.m
//  demoApp
//
//  Created by tourituyou on 2019/7/11.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "ShadowButton.h"

@implementation ShadowButton

+ (instancetype)ShadowButtonWithType:(UIButtonType)buttonType{
    UIButton *s = [UIButton buttonWithType:buttonType];
    s.layer.cornerRadius = 6.0f;
    s.layer.shadowOpacity = 0.15f;
    s.layer.shadowOffset = CGSizeMake(4, 4);
    s.layer.masksToBounds = NO;
    return (ShadowButton *)s;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
