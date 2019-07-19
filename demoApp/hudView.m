//
//  hudView.m
//  demoApp
//
//  Created by agilet on 2019/06/18.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "hudView.h"
#import "UITool.h"

@interface hudView()

@property (strong, nonatomic) firstTableModel *currentModel;
@property (nonatomic, assign) BOOL isFront;

@end

@implementation hudView

- (instancetype)initWithModel:(firstTableModel *)currentModel isFront:(BOOL)isFront{
    self = [super init];
    if (self) {
        [self setFrame:[UIScreen mainScreen].bounds];
        self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.7f];
        self.currentModel = currentModel;
        self.isFront = isFront;
    }
    return self;
}

-(void)show {
    UIWindow *keyWin = [UIApplication sharedApplication].keyWindow;
    [keyWin addSubview:self];
    
    float x = [UIScreen mainScreen].bounds.size.width * 0.1;
    float w = [UIScreen mainScreen].bounds.size.width * 0.8;
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(x, 190, w, [UIScreen mainScreen].bounds.size.height - 370)];
    backView.backgroundColor = [UIColor whiteColor];
//    backView.layer.borderColor = [UIColor colorWithHexString:[UITool shareUITool].lineColorHexString alpha:1.0f].CGColor;
    backView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    backView.layer.borderWidth = [UITool shareUITool].lineWidth;
    backView.layer.masksToBounds = YES;
    [self addSubview:backView];
    
    if (self.currentModel) {
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, w - 32, 90)];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont systemFontOfSize:18.0f];
        title.textColor = [UIColor colorWithHexString:[UITool shareUITool].bodyTextColorHexString alpha:1.0f];
        NSString *tint = self.isFront ? @"（表面）" : @"（裏面）";
        title.text = [NSString stringWithFormat:@"%@%@を撮影します。\nよろしいですか？", self.currentModel.buttonTitle, tint];
        title.numberOfLines = 0;
        [backView addSubview:title];
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(55, 90, backView.frame.size.width - 110, 120)];
        self.isFront ? [image setImage:[UIImage imageNamed:@"pic3"]] : [image setImage:[UIImage imageNamed:@"pic4"]];
        [backView addSubview:image];
        
        UIButton *backBT = [UIButton buttonWithType:UIButtonTypeCustom];
        backBT.backgroundColor = [UIColor whiteColor];
        [backBT addTarget:self action:@selector(goBackBT) forControlEvents:UIControlEventTouchUpInside];
        [backBT setFrame:CGRectMake(16, 230, (backView.frame.size.width - 64) * 0.5, 50)];
        [backBT setTitle:@"いいえ" forState:UIControlStateNormal];
        [backBT setTitleColor:[UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0] forState:UIControlStateNormal];
        backBT.layer.borderWidth = [UITool shareUITool].lineWidth;
        backBT.layer.borderColor = [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0].CGColor;
        backBT.layer.cornerRadius = 3.0f;
//        backBT.layer.shadowOpacity = 0.15f;
//        backBT.layer.shadowOffset = CGSizeMake(4, 4);
        backBT.layer.masksToBounds = NO;
        [backView addSubview:backBT];
        
        UIButton *nextBT = [UIButton buttonWithType:UIButtonTypeCustom];
        [nextBT addTarget:self action:@selector(goNextBT) forControlEvents:UIControlEventTouchUpInside];
        [nextBT setTitle:@"はい" forState:UIControlStateNormal];
        nextBT.backgroundColor = [UIColor colorWithHexString:[UITool shareUITool].lineColorHexString alpha:1.0];
//        nextBT.layer.shadowOpacity = 0.15f;
//        nextBT.layer.shadowOffset = CGSizeMake(4, 4);
        nextBT.layer.cornerRadius = 3.0f;
        nextBT.layer.masksToBounds = NO;
        [nextBT setFrame:CGRectMake((backView.frame.size.width - 64) * 0.5 + 48, 230, (backView.frame.size.width - 64) * 0.5, 50)];
        [backView addSubview:nextBT];
    } else{
        float x = [UIScreen mainScreen].bounds.size.width * 0.2;
        float w = [UIScreen mainScreen].bounds.size.width * 0.6;
        [backView setFrame:CGRectMake(x, 250, w, w - 50)];
        UIActivityIndicatorView *v = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
         [backView addSubview:v];
        CGRect frame = v.frame;
        frame.size = CGSizeMake(100, 100);
        v.frame = frame;
        v.center = CGPointMake(backView.frame.size.width * 0.5, backView.frame.size.height * 0.5);
        v.color = [UIColor lightGrayColor];
        [v startAnimating];
    }
}

-(void)hide{
    [self goBackBT];
}

-(void)goBackBT{
    UIWindow *keyWin = [UIApplication sharedApplication].keyWindow;
    for (UIView *view in keyWin.subviews) {
        if ([view isKindOfClass:[hudView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (void)goNextBT{
    [self goBackBT];
    if ([self.delegate respondsToSelector:@selector(didNextClicked)]) {
        [self.delegate didNextClicked];
    }
}


@end
