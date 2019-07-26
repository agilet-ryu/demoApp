//
//  fouthViewController.m
//  demoApp
//
//  Created by agilet on 2019/06/19.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "fouthViewController.h"
#import "UITool.h"
#import "fifthViewController.h"
#import "faceIDManager.h"
#import <WebKit/WebKit.h>
//#import "hudView.h"

@interface fouthViewController ()<faceIDManagerDelegate>
//@property (nonatomic, strong) hudView *myHudView;
@property (nonatomic, assign) BOOL verifyFailure;
@property (nonatomic, strong) NSArray *verifyFailureMsg;
@end

@implementation fouthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"顔画像の撮影開始";
    self.view.backgroundColor = [UIColor whiteColor];
    self.verifyFailure = NO;
    [self initView];
    [self initProgressBar];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.verifyFailure = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.verifyFailure) {
        [self showAlert:self.verifyFailureMsg[0] title:self.verifyFailureMsg[1]];
    }
}

- (void)initProgressBar {
    UIProgressView *p = [[ UIProgressView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 2)];
    p.trackTintColor = [UIColor lightGrayColor];
    p.tintColor = kBaseColor;
    [p setProgress:0.7 animated:NO];
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
    
    UILabel *sectionL = [[UILabel alloc] initWithFrame:CGRectMake(16, 64, [UIScreen mainScreen].bounds.size.width - 32, 150)];
    sectionL.numberOfLines = 0;
    sectionL.text = @"スマートフォンのカメラで、顔画像を撮影します。\n背景に他人が写り込んでいない状況で撮影してください。";
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
    
    UIButton *footBT = [UIButton buttonWithType:UIButtonTypeCustom];
    [footBT setFrame:CGRectMake(16, [UIScreen mainScreen].bounds.size.height - 68, [UIScreen mainScreen].bounds.size.width - 32, 54)];
    [footBT setTitle:@"次へ" forState:UIControlStateNormal];
    [footBT addTarget:self action:@selector(goNextView) forControlEvents:UIControlEventTouchUpInside];
    footBT.backgroundColor = kBaseColor;
    footBT.layer.cornerRadius = 6.0f;
//    footBT.layer.shadowOpacity = 0.15f;
//    footBT.layer.shadowOffset = CGSizeMake(6, 6);
    footBT.layer.masksToBounds = NO;
    [self.view addSubview:footBT];
}

- (void)goNextView {
//    hudView *hud = [[hudView alloc] initWithModel:nil isFront:nil];
//    [hud show];
//    self.myHudView = hud;
    faceIDManager *manager = [faceIDManager sharedFaceIDManager];
    manager.delegate = self;
    [manager startDetectWithContoller:self bizToken:self.bizToken];
}

- (void)startDetectSuccuss:(NSData *)data andBizToken:(NSString *)bizToken{
    fifthViewController *f = [[fifthViewController alloc] init];
    f.data = data;
    f.bizToken = bizToken;
//    [self.myHudView hide];
    [self.navigationController pushViewController:f animated:YES];
}

- (void)didVerifyFailure:(NSString *)msg title:(NSString *)title{
//    [self.myHudView hide];
//    self.verifyFailure = YES;
//    self.verifyFailureMsg = @[msg, title];
    
    fifthViewController *f = [[fifthViewController alloc] init];
    //    [self.myHudView hide];
    [self.navigationController pushViewController:f animated:YES];
}

- (void)showAlert:(NSString *)msg title:(NSString *)title{
    UIAlertController *a = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"sure" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [a dismissViewControllerAnimated:YES completion:nil];
    }]];

    [self presentViewController:a animated:YES completion:nil];
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
