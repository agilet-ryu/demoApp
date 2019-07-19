//
//  BaseViewController.m
//  demoApp
//
//  Created by agilet on 2019/06/20.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UIButton *footerButton;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self config];
    [self initView];
    [self initProgressBar];
}

- (void)config {
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] init];
    back.title = @"";
    self.navigationItem.backBarButtonItem = back;
    self.navigationController.navigationBar.tintColor = [UIColor clearColor];
}

- (void)initView {
    UILabel *l = [[UILabel alloc] init];
    l.numberOfLines = 0;
    l.font = [UIFont systemFontOfSize:[UITool shareUITool].textSizeMedium];
    l.textColor = [UIColor colorWithHexString:[UITool shareUITool].bodyTextColorHexString alpha:1.0f];
    [self.view addSubview:l];
    self.headerLabel = l;
    
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    [b setFrame:CGRectMake(16, [UIScreen mainScreen].bounds.size.height - 44 - 64, [UIScreen mainScreen].bounds.size.width - 32, 40)];
    [b setTitle:@"次へ" forState:UIControlStateNormal];
    [b addTarget:self action:@selector(didFooterButtonClicked) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:b];
    self.footerButton = b;
}

- (void)initProgressBar {
    if (self.progress) {
        UIProgressView *p = [[ UIProgressView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 2)];
        p.trackTintColor = [UIColor lightGrayColor];
        p.tintColor = [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0];
        [p setProgress:self.progress animated:NO];
        [self.view addSubview:p];
    }
}

- (void)setHeaderlabelString:(NSString *)headerlabelString{
    _headerlabelString = headerlabelString;
    [self.headerLabel setText:headerlabelString];
    CGFloat fontSize = [UITool shareUITool].textSizeMedium;
    CGFloat labelHeight = [[UITool shareUITool] heightWithWidth:SCREEN_WIDTH font:fontSize str:headerlabelString];
    [self.headerLabel setFrame:CGRectMake(16, 30, SCREEN_WIDTH - 32, labelHeight)];
    self.headerLabel.backgroundColor = [UIColor redColor];
    [self.view layoutSubviews];
}

- (void)setButtonInteractionEnabled:(BOOL)buttonInteractionEnabled{
    _buttonInteractionEnabled = buttonInteractionEnabled;
    self.footerButton.backgroundColor = buttonInteractionEnabled ? [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0f] : [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:0.3f];
    self.footerButton.userInteractionEnabled = buttonInteractionEnabled;
}

- (void)didFooterButtonClicked{
    
}



@end
