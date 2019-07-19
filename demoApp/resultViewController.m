//
//  resultViewController.m
//  demoApp
//
//  Created by agilet on 2019/06/19.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "resultViewController.h"
#import "UITool.h"

@interface resultViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation resultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];
    self.title = @"処理結果送信";
    self.view.backgroundColor = [UIColor whiteColor];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self initView];
}
- (void)initView {
    UIActivityIndicatorView *v = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    v.frame= CGRectMake(([UIScreen mainScreen].bounds.size.width - 200) * 0.5, ([UIScreen mainScreen].bounds.size.height - 200) * 0.5, 200, 200);
    v.color = [UIColor lightGrayColor];
    [self.view addSubview:v];
    [v startAnimating];
    self.indicatorView = v;
    [self performSelector:@selector(delayMethod) withObject:nil afterDelay:5.0];
    
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height * 0.5 + 125, [UIScreen mainScreen].bounds.size.width, 30)];
    l.text = @"処理結果送信中・・・";
    l.textColor = [UIColor colorWithHexString:[UITool shareUITool].bodyTextColorHexString alpha:1.0f];
    l.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:l];
}

- (void)delayMethod {
    [self.indicatorView stopAnimating];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
