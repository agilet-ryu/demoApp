//
//  fifthViewController.m
//  demoApp
//
//  Created by agilet on 2019/06/19.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "fifthViewController.h"
#import "UITool.h"
#import "hudView.h"
#import "faceIDManager.h"
#import "TakeVideoViewController.h"
#import <WebKit/WebKit.h>

@interface fifthViewController ()<faceIDManagerDelegate>
@property (nonatomic, strong) hudView *myHudView;
@property (nonatomic, strong) UIButton *footBt;
@property (nonatomic, strong) UILabel *detailLabel;
@end

@implementation fifthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"顔照合";
    self.view.backgroundColor = [UIColor whiteColor];
    [self initView];
//    hudView *hud = [[hudView alloc] initWithModel:nil isFront:nil];
//    [hud show];
//    self.myHudView = hud;
//    faceIDManager *manager = [faceIDManager sharedFaceIDManager];
//    manager.delegate = self;
//    [manager startVerifyWitBizToken:self.bizToken data:self.data];
    [self initProgressBar];
    [self performSelector:@selector(goNextView) withObject:nil afterDelay:3.0f];
}

- (void)initProgressBar {
    UIProgressView *p = [[ UIProgressView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 2)];
    p.trackTintColor = [UIColor lightGrayColor];
    p.tintColor = [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0];
    [p setProgress:0.8 animated:NO];
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
    sectionL.textAlignment = NSTextAlignmentCenter;
    sectionL.text = @"顔照合中・・・・";
    sectionL.font = [UIFont systemFontOfSize:[UITool shareUITool].textSizeMedium];
    sectionL.textColor = [UIColor colorWithHexString:[UITool shareUITool].bodyTextColorHexString alpha:1.0f];
    [self.view addSubview:sectionL];
    self.detailLabel = sectionL;
    
//    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(16, 200, [UIScreen mainScreen].bounds.size.width - 32, 200)];
//    l.text = @"※顔照合中であることを表現できるようなアニメーション";
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
//    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic8"]];
//    [img setFrame:CGRectMake(32, 250, [UIScreen mainScreen].bounds.size.width - 64, 200)];
//    [self.view addSubview:img];
//
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0,200,[UIScreen mainScreen].bounds.size.width,250)];
    [self.view addSubview:webView];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"verify" ofType:@"gif"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [webView loadFileURL:url allowingReadAccessToURL:url];
    self.automaticallyAdjustsScrollViewInsets=NO;
    webView.userInteractionEnabled = NO;
    
//    UIButton *footBT = [UIButton buttonWithType:UIButtonTypeCustom];
//    [footBT setFrame:CGRectMake(16, [UIScreen mainScreen].bounds.size.height - 68, [UIScreen mainScreen].bounds.size.width - 32, 54)];
//    [footBT setTitle:@"次へ" forState:UIControlStateNormal];
//    [footBT addTarget:self action:@selector(goNextView) forControlEvents:UIControlEventTouchUpInside];
//    footBT.backgroundColor = [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:0.3f];
//    footBT.layer.cornerRadius = 6.0f;
//    footBT.layer.shadowOpacity = 0.15f;
//    footBT.layer.shadowOffset = CGSizeMake(6, 6);
//    footBT.layer.masksToBounds = NO;
//    footBT.userInteractionEnabled = NO;
//    [self.view addSubview:footBT];
//    self.footBt = footBT;
}

- (void)goNextView {
    TakeVideoViewController *t = [[TakeVideoViewController alloc] init];
    [self.navigationController pushViewController:t animated:YES];
}

- (void)didVerifySuccess:(NSString *)msg{
//    [self.myHudView hide];
//    self.detailLabel.text = @"顔照合完了";
//    self.footBt.userInteractionEnabled = YES;
//    self.footBt.backgroundColor = [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0f];
//    [self showAlert:msg title:@"VerifyEnd"];
}

- (void)didVerifyFailure:(NSString *)msg title:(NSString *)title{
//    [self.myHudView hide];
//    self.detailLabel.text = @"顔照合完了";
//    self.footBt.userInteractionEnabled = YES;
//    self.footBt.backgroundColor = [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0f];
//    [self showAlert:msg title:title];
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
