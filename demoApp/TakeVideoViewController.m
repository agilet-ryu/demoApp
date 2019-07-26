//
//  TakeVideoViewController.m
//  demoApp
//
//  Created by tourituyou on 2019/7/11.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "TakeVideoViewController.h"
#import "UITool.h"
#import "hudView.h"
#import "resultViewController.h"
#import <WebKit/WebKit.h>

@interface TakeVideoViewController ()
@property (nonatomic, strong) hudView *myHudView;
@end

@implementation TakeVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"厚みの撮影開始";
    self.view.backgroundColor = [UIColor whiteColor];
    [self initView];
    [self initProgressBar];
    [self.navigationItem setHidesBackButton:YES];
}

- (void)initProgressBar {
    UIProgressView *p = [[ UIProgressView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 2)];
    p.trackTintColor = [UIColor lightGrayColor];
    p.tintColor = kBaseColor;
    [p setProgress:0.9 animated:NO];
    [self.view addSubview:p];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(backTo)];
    self.navigationItem.rightBarButtonItem = back;
}

- (void)initView {
    UIBarButtonItem *back = [[UIBarButtonItem alloc] init];
    back.title = @"";
    self.navigationItem.backBarButtonItem = back;
    
    UILabel *sectionL = [[UILabel alloc] initWithFrame:CGRectMake(16, 64, [UIScreen mainScreen].bounds.size.width - 32, 100)];
    sectionL.numberOfLines = 0;
    sectionL.textAlignment = NSTextAlignmentLeft;
    sectionL.text = @"スマートフォンのカメラで、本人確認書類の厚みを撮影します。";
    sectionL.font = [UIFont systemFontOfSize:[UITool shareUITool].textSizeMedium];
    sectionL.textColor = kBodyTextColor;
    [self.view addSubview:sectionL];
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0,200,[UIScreen mainScreen].bounds.size.width,250)];
    [self.view addSubview:webView];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"verify" ofType:@"gif"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [webView loadFileURL:url allowingReadAccessToURL:url];
    self.automaticallyAdjustsScrollViewInsets=NO;
    webView.userInteractionEnabled = NO;
    
//    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(16, 200, [UIScreen mainScreen].bounds.size.width - 32, 200)];
//    l.text = @"※撮影方法をイラストで説明";
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
    
    UIButton *footBT = [UIButton buttonWithType:UIButtonTypeCustom];
    [footBT setFrame:CGRectMake(16, [UIScreen mainScreen].bounds.size.height - 68, [UIScreen mainScreen].bounds.size.width - 32, 54)];
    [footBT setTitle:@"次へ" forState:UIControlStateNormal];
    [footBT addTarget:self action:@selector(goToNext) forControlEvents:UIControlEventTouchUpInside];
    footBT.backgroundColor = kBaseColor;
    footBT.layer.cornerRadius = 6.0f;
//    footBT.layer.shadowOpacity = 0.15f;
//    footBT.layer.shadowOffset = CGSizeMake(6, 6);
    footBT.layer.masksToBounds = NO;
    [self.view addSubview:footBT];
}

- (void)backTo{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)goToNext{
    resultViewController *r = [[resultViewController alloc] init];
    [self.navigationController pushViewController:r animated:YES];
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
