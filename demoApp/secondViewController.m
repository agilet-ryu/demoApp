//
//  secondViewController.m
//  demoApp
//
//  Created by agilet on 2019/06/18.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "secondViewController.h"
#import "UITool.h"
#import "Utils.h"
#import "hudView.h"
#import "loginViewController.h"
#import "InfoDatabase.h"
#import "service/SF-101/AppComLog.h"

@interface secondViewController ()
@property (nonatomic, strong) UIButton *nextBT; // 「次へ」ボタン
@property (nonatomic, assign) BOOL openCamera;  // ccameraScan又はNFC

@end

@implementation secondViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 画面初期化
    [self initView];
    
    // プログレスバーを表示する
    [self initProgressBar];
}

// 画面初期化
- (void)initView{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"読み取り方法の選択";
    UIBarButtonItem *back = [[UIBarButtonItem alloc] init];
    back.title = @"";
    self.navigationItem.backBarButtonItem = back;
    
    UILabel *sectionL = [[UILabel alloc] initWithFrame:CGRectMake(16, 64, [UIScreen mainScreen].bounds.size.width - 32, 100)];
    sectionL.numberOfLines = 0;
    sectionL.text = [NSString stringWithFormat:@"%@の読み取り方法を選択してください。", self.currentModel.kbnModel.name];
    sectionL.font = [UIFont systemFontOfSize:[UITool shareUITool].textSizeMedium];
    sectionL.textColor = kBodyTextColor;
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
    footBT.backgroundColor = kBaseColorUnEnabled;
    footBT.userInteractionEnabled = false;
    footBT.layer.cornerRadius = 6.0f;
//    footBT.layer.shadowOpacity = 0.15f;
//    footBT.layer.shadowOffset = CGSizeMake(6, 6);
    footBT.layer.masksToBounds = NO;
    [self.view addSubview:footBT];
    self.nextBT = footBT;
}

// 次へボタンタップ時
- (void)goNextView {
    
    // 操作ログ編集
    [AppComLog writeEventLog:@"次へボタン" viewID:@"G0030-01" LogLevel:LOGLEVELInformation withCallback:^(NSString * _Nonnull resultCode) {
        
    } atController:self];
    
    // 共通領域初期化
    InfoDatabase *db = [InfoDatabase shareInfoDatabase];
    SystemCode *sysCode = [Utils getSystemCode];
    int camera = sysCode.read_method_KBN.CAMERA.code;
    int nfc = sysCode.read_method_KBN.NFC.code;
    
    if (self.openCamera) {
        
        // 本人確認内容データの読取方法「1:カメラ撮影」を設定する。
        db.identificationData.GAIN_TYPE = camera;
        
        // 「カメラ撮影」を選択済の場合、「G0040-01：本人確認書類撮影開始前画面」へ遷移する。
        hudView *hud = [[hudView alloc] initWithModel:self.currentModel andController:self];
        [hud show];
    } else {
        
        // 本人確認内容データの読取方法「2:NFC読取」を設定する。
        db.identificationData.GAIN_TYPE = nfc;
        
        // 「NFC読み取り」を選択済の場合、「G0070-01：暗証番号入力画面」へ遷移する。
        loginViewController *logVC = [[loginViewController alloc] init];
        logVC.currentModel = self.currentModel;
        [self.navigationController pushViewController:logVC animated:YES];
    }
    
    int tmpDoc = db.identificationData.DOC_TYPE;
    int tmpRead = db.identificationData.GAIN_TYPE;
    db.identificationData = [IDENTIFICATION_DATA new];
    db.identificationData.DOC_TYPE = tmpDoc;
    db.identificationData.GAIN_TYPE = tmpRead;
}

// 「カメラ撮影」ボタンタップ時
- (void)didBt1Clicked:(UIButton *)button{
    [self controlNextButton:YES];
}

// 「NFC読み取り」ボタンタップ時
- (void)didBt2Clicked:(UIButton *)button{
    [self controlNextButton:NO];
}

// ボタンを制御する
- (void)controlNextButton:(BOOL)isOpenCamera{
    self.openCamera = isOpenCamera;
    self.nextBT.userInteractionEnabled = YES;
    self.nextBT.backgroundColor = kBaseColor;
    self.bt1.layer.borderColor = isOpenCamera ? kBaseColor.CGColor : kLineColor.CGColor;
    self.bt2.layer.borderColor = isOpenCamera ? kLineColor.CGColor : kBaseColor.CGColor;
}

// プログレスバーを表示する
- (void)initProgressBar {
    UIProgressView *p = [[ UIProgressView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 2)];
    p.trackTintColor = [UIColor lightGrayColor];
    p.tintColor = kBaseColor;
    [p setProgress:0.2 animated:NO];
    [self.view addSubview:p];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(backTo)];
    self.navigationItem.rightBarButtonItem = back;
}

// 閉じるボタン
- (void)backTo{
    
    // 操作ログ編集
    [AppComLog writeEventLog:@"閉じるボタン" viewID:@"G0030-01" LogLevel:LOGLEVELInformation withCallback:^(NSString * _Nonnull resultCode) {
        
    } atController:self];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
