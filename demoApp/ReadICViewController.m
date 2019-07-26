//
//  ReadICViewController.m
//  demoApp
//
//  Created by tourituyou on 2019/7/9.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "ReadICViewController.h"
#import "UITool.h"
#import "ICResultViewController.h"
@interface ReadICViewController ()

@end

@implementation ReadICViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"IC情報の読み取り";
    self.view.backgroundColor = [UIColor whiteColor];
    [self initView];
    [self initProgressBar];
}

- (void)viewDidAppear:(BOOL)animated{
    [self performSelector:@selector(goNextView) withObject:nil afterDelay:3.0f];
}

- (void)initProgressBar {
    UIProgressView *p = [[ UIProgressView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 2)];
    p.trackTintColor = [UIColor lightGrayColor];
    p.tintColor = kBaseColor;
    [p setProgress:0.5 animated:NO];
    [self.view addSubview:p];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(backTo)];
    self.navigationItem.rightBarButtonItem = back;
}

- (void)backTo{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)initView {
    UIBarButtonItem *back = [[UIBarButtonItem alloc] init];
    back.title = @"";
    self.navigationItem.backBarButtonItem = back;
    
    UILabel *sectionL = [[UILabel alloc] initWithFrame:CGRectMake(16, 64, [UIScreen mainScreen].bounds.size.width - 32, 100)];
    sectionL.numberOfLines = 0;
    sectionL.text = @"スマートフォンの裏側に、本人確認書類をかざしてください。";
    sectionL.font = [UIFont systemFontOfSize:[UITool shareUITool].textSizeMedium];
    sectionL.textColor = kBodyTextColor;
    [self.view addSubview:sectionL];
    
//    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(16, 200, [UIScreen mainScreen].bounds.size.width - 32, 200)];
//    l.text = @"※撮影方法を、イラストで説明";
//    l.numberOfLines = 0;
//    l.textAlignment = NSTextAlignmentCenter;
//    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
//    layer.frame = CGRectMake(0, 0 , l.frame.size.width, l.frame.size.height);
//    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:layer.frame cornerRadius:4.0f];
//    layer.path = path.CGPath;
//    layer.lineWidth = 2.0f;
//    layer.lineDashPattern = @[@7, @2];
//    layer.fillColor = [UIColor whiteColor].CGColor;
//    layer.cornerRadius = 17;
//    layer.strokeColor = [UIColor colorWithHexString:[UITool shareUITool].lineColorHexString alpha:1.0f].CGColor;
//    [l.layer addSublayer:layer];
//    [self.view addSubview:l];
    
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic9"]];
    [img setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 200) * 0.5, 250, 200, 200)];
    [self.view addSubview:img];
    
    UIButton *footBT = [UIButton buttonWithType:UIButtonTypeCustom];
    footBT.backgroundColor = [UIColor whiteColor];
    [footBT setFrame:CGRectMake(16, [UIScreen mainScreen].bounds.size.height - 68, [UIScreen mainScreen].bounds.size.width - 32, 54)];
    [footBT setTitle:@"キャンセル" forState:UIControlStateNormal];
    [footBT addTarget:self action:@selector(doCancel) forControlEvents:UIControlEventTouchUpInside];
    [footBT setTitleColor:kBaseColor forState:UIControlStateNormal];
    footBT.layer.borderWidth = [UITool shareUITool].lineWidth;
    footBT.layer.borderColor = kBaseColor.CGColor;
    footBT.layer.cornerRadius = 6.0f;
//    footBT.layer.shadowOpacity = 0.15f;
//    footBT.layer.shadowOffset = CGSizeMake(6, 6);
    footBT.layer.masksToBounds = NO;
    [self.view addSubview:footBT];
}

- (void)doCancel{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goNextView{
    ICResultViewController *ic = [[ICResultViewController alloc] init];
    ic.currentModel = self.currentModel;
    [self.navigationController pushViewController:ic animated:YES];
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
