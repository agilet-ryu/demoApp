//
//  secondViewController.m
//  demoApp
//
//  Created by agilet on 2019/06/18.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "secondViewController.h"
#import "UITool.h"
#import "hudView.h"
#import "thirdViewController.h"
#import "loginViewController.h"
#import "CameraScanManager.h"

@interface secondViewController ()<hudViewDelegate, cameraScanManagerDelegate>
@property (nonatomic, strong) UIButton *nextBT;
@property (nonatomic, assign) BOOL openCamera;  // ccameraScan或NFC
@property (nonatomic, assign) BOOL isFront;  // 正面还是反面
@property (nonatomic, strong) CameraScanManager *cameraScanManager;
@end

@implementation secondViewController

- (CameraScanManager *)cameraScanManager{
    if (!_cameraScanManager) {
        _cameraScanManager = [CameraScanManager sharedCameraScanManager];
        _cameraScanManager.delegate = self;
    }
    return _cameraScanManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"読み取り方法の選択";
    [self initView];
    [self initProgressBar];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.cameraScanManager.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    for (UIView *v in self.view.subviews) {
        v.hidden = NO;
    }
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)initView{
    UIBarButtonItem *back = [[UIBarButtonItem alloc] init];
    back.title = @"";
    self.navigationItem.backBarButtonItem = back;
    
    UILabel *sectionL = [[UILabel alloc] initWithFrame:CGRectMake(16, 64, [UIScreen mainScreen].bounds.size.width - 32, 100)];
    sectionL.numberOfLines = 0;
    sectionL.text = [NSString stringWithFormat:@"%@の読み取り方法を選択してください。", self.currentModel.buttonTitle];
    sectionL.font = [UIFont systemFontOfSize:[UITool shareUITool].textSizeMedium];
    sectionL.textColor = [UIColor colorWithHexString:[UITool shareUITool].bodyTextColorHexString alpha:1.0f];
    [self.view addSubview:sectionL];
    
    [self.bt1 setFrame:CGRectMake(16, 164, [UIScreen mainScreen].bounds.size.width - 32, 150)];
    [self.bt1 addTarget:self action:@selector(didBt1Clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bt1];
    
    [self.bt2 setFrame:CGRectMake(16, 360, [UIScreen mainScreen].bounds.size.width - 32, 150)];
    [self.bt2 addTarget:self action:@selector(didBt2Clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bt2];
    
    UIButton *footBT = [UIButton buttonWithType:UIButtonTypeCustom];
    [footBT setFrame:CGRectMake(16, [UIScreen mainScreen].bounds.size.height - 68, [UIScreen mainScreen].bounds.size.width - 32, 54)];
    [footBT setTitle:@"次へ" forState:UIControlStateNormal];
    [footBT addTarget:self action:@selector(goNextView) forControlEvents:UIControlEventTouchUpInside];
    footBT.backgroundColor = [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:0.3f];
    footBT.userInteractionEnabled = false;
    footBT.layer.cornerRadius = 6.0f;
//    footBT.layer.shadowOpacity = 0.15f;
//    footBT.layer.shadowOffset = CGSizeMake(6, 6);
    footBT.layer.masksToBounds = NO;
    [self.view addSubview:footBT];
    self.nextBT = footBT;
}

- (void)goNextView {
    if (self.openCamera) {
        self.isFront = YES;
        hudView *hud = [[hudView alloc] initWithModel:self.currentModel isFront:YES];
        hud.delegate = self;
        [hud show];
    } else {
        loginViewController *logVC = [[loginViewController alloc] init];
        logVC.currentModel = self.currentModel;
        [self.navigationController pushViewController:logVC animated:YES];
    }
}

- (void)didBt1Clicked:(UIButton *)button{
    self.openCamera = YES;
    self.nextBT.userInteractionEnabled = YES;
    self.nextBT.backgroundColor = [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0f];
    button.layer.borderColor = [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0f].CGColor;
    self.bt2.layer.borderColor = [UIColor colorWithHexString:[UITool shareUITool].lineColorHexString alpha:1.0f].CGColor;
}

- (void)didBt2Clicked:(UIButton *)button{
    self.openCamera = NO;
    self.nextBT.userInteractionEnabled = YES;
    self.nextBT.backgroundColor = [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0f];
    button.layer.borderColor = [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0f].CGColor;
    self.bt1.layer.borderColor = [UIColor colorWithHexString:[UITool shareUITool].lineColorHexString alpha:1.0f].CGColor;
}

- (void)didNextClicked{
//    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
//    v.backgroundColor = [UIColor blackColor];
//    v.tag = 1000;
//    UIWindow *keyWin = [UIApplication sharedApplication].keyWindow;
//    [keyWin addSubview:v];
    [self.cameraScanManager start];
    for (UIView *v in self.view.subviews) {
        v.hidden = YES;
    }
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)cameraScanSuccessWithImage:(UIImage *)image{
    if (self.isFront) {
        self.currentModel.frontImage = image;
        self.isFront = NO;
        hudView *hud = [[hudView alloc] initWithModel:self.currentModel isFront:NO];
        hud.delegate = self;
        [hud show];
    } else{
        self.currentModel.behindImage = image;
        thirdViewController *th = [[thirdViewController alloc] init];
        th.currentModel = self.currentModel;
        [self.navigationController pushViewController:th animated:YES];
    }
}

- (void)initProgressBar {
    UIProgressView *p = [[ UIProgressView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 2)];
    p.trackTintColor = [UIColor lightGrayColor];
    p.tintColor = [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0];
    [p setProgress:0.2 animated:NO];
    [self.view addSubview:p];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(backTo)];
    self.navigationItem.rightBarButtonItem = back;
}

- (void)backTo{
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
