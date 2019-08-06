//
//  OCRResultViewController.m
//  demoApp
//
//  Created by tourituyou on 2019/7/9.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "OCRResultViewController.h"
#import "UITool.h"
#import "UIColor+hexString.h"
#import "CameraScanManager.h"
#import "getFaceIDToken.h"
#import "fouthViewController.h"
#import "hudView.h"
#import "InfoDatabase.h"
#import "AppComLog.h"

@interface OCRResultViewController ()<UIWebViewDelegate, cameraScanManagerDelegate, getFaceIDTokenDelegate>
@property (nonatomic, strong) UIButton *nextBT;
@property (nonatomic, strong) UIImageView *img1;
@property (nonatomic, strong) CameraScanManager *cameraScanManager;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIScrollView *myScroll;
@property (nonatomic, strong) UIWebView *myWebView;
@property (nonatomic, strong) hudView *myHud;

@end

@implementation OCRResultViewController

- (CameraScanManager *)cameraScanManager{
    if (!_cameraScanManager) {
        
        // 操作ログ編集
        [AppComLog writeEventLog:@"カメラスキャンの初期化処理" viewID:@"G0160-01" LogLevel:LOGLEVELInformation withCallback:^(NSString * _Nonnull resultCode) {
            
        } atController:self];
        _cameraScanManager = [CameraScanManager sharedCameraScanManager];
        _cameraScanManager.delegate = self;
    }
    return _cameraScanManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initScrollView];
    [self initProgressBar];
}

- (void)initProgressBar {
    UIProgressView *p = [[ UIProgressView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 2)];
    p.trackTintColor = [UIColor lightGrayColor];
    p.tintColor = kBaseColor;
    [p setProgress:0.6 animated:NO];
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

    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"読み取り結果の確認";

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

- (void)initScrollView{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 132)];
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    UILabel *sectionL = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, [UIScreen mainScreen].bounds.size.width - 32, 100)];
    sectionL.numberOfLines = 0;
    sectionL.textAlignment = NSTextAlignmentLeft;
    sectionL.text = [NSString stringWithFormat:@"撮影画像から情報を読み取りました。\n読み取り結果が正しいことを確認してください。"];
    sectionL.font = [UIFont systemFontOfSize:[UITool shareUITool].textSizeMedium];
    sectionL.textColor = kBodyTextColor;
    [scrollView addSubview:sectionL];
    
    UILabel *frontTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 100, [UIScreen mainScreen].bounds.size.width - 32, 25)];
    frontTitle.textAlignment = NSTextAlignmentCenter;
    frontTitle.text = [NSString stringWithFormat:@"撮影画像"];
    frontTitle.font = [UIFont systemFontOfSize:[UITool shareUITool].textSizeMedium];
    [scrollView addSubview:frontTitle];
    
    UIImageView *img1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic3"]];
    [img1 setImage:[InfoDatabase shareInfoDatabase].identificationData.OBVERSE_IMG];
    [img1 setFrame:CGRectMake(40, 145, [UIScreen mainScreen].bounds.size.width - 80, 200)];
    [scrollView addSubview:img1];
    self.img1 = img1;
    
    UILabel *backTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 375, [UIScreen mainScreen].bounds.size.width - 32, 25)];
    backTitle.textAlignment = NSTextAlignmentCenter;
    backTitle.text = [NSString stringWithFormat:@"読み取り結果"];
    backTitle.font = [UIFont systemFontOfSize:[UITool shareUITool].textSizeMedium];
    [scrollView addSubview:backTitle];
    
    UIWebView *web = [[UIWebView alloc] initWithFrame:CGRectMake(40, 420, [UIScreen mainScreen].bounds.size.width - 80, 1)];
    web.delegate = self;
    web.scrollView.scrollEnabled = YES;
    web.backgroundColor = [UIColor whiteColor];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:self.currentModel.kbnModel.STM4 ofType:@"html"];
    NSURL *locationURL = [NSURL URLWithString:filePath];
    NSURLRequest *request =[NSURLRequest requestWithURL:locationURL];
    [web setScalesPageToFit:YES];
    web.userInteractionEnabled = NO;
    [web loadRequest:request];
    [scrollView addSubview:web];
    self.myWebView = web;

    UIButton *check = [UIButton buttonWithType:UIButtonTypeCustom];
    [check setFrame:CGRectMake(40, 700, [UIScreen mainScreen].bounds.size.width - 80, 30)];
    [check addTarget:self action:@selector(didChecked:) forControlEvents:UIControlEventTouchUpInside];
    [check setImage:[UIImage imageNamed:@"pic5"] forState:UIControlStateNormal];
    [check setImage:[UIImage imageNamed:@"pic6"] forState:UIControlStateSelected];
    [check setTitleColor:kBodyTextColor forState:UIControlStateNormal];
    [check setTitle:@"確認しました。" forState:UIControlStateNormal];
    check.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [scrollView addSubview:check];
    
    UIButton *BT2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [BT2 setFrame:CGRectMake(40, 640, [UIScreen mainScreen].bounds.size.width - 80, 50)];
    [BT2 setTitle:@"再撮影" forState:UIControlStateNormal];
    [BT2 addTarget:self action:@selector(didBT2Click) forControlEvents:UIControlEventTouchUpInside];
    BT2.backgroundColor = [UIColor whiteColor];
    
    [BT2 setTitleColor:kBaseColor forState:UIControlStateNormal];
    BT2.layer.borderWidth = [UITool shareUITool].lineWidth;
    BT2.layer.cornerRadius = 3.0f;
    BT2.layer.borderColor = kBaseColor.CGColor;
    BT2.layer.masksToBounds = YES;
    
    BT2.userInteractionEnabled = !check.isSelected;
    [scrollView addSubview:BT2];
    self.cameraButton = BT2;
    
    [scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 750)];
    self.myScroll = scrollView;
}

#pragma mark - webview回调
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    CGFloat h = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
    CGFloat w = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollWidth"] floatValue];
    
    float rate = h / w;
    float w1 = [UIScreen mainScreen].bounds.size.width - 80;
    float h1 = rate * w1;
    webView.frame = CGRectMake(40, 420, w1, h1);

    [webView stringByEvaluatingJavaScriptFromString:self.jsStr];
}

#pragma mark - 点击事件
- (void)didChecked:(UIButton *)button{
    button.selected = !button.isSelected;
    
    self.cameraButton.backgroundColor = button.isSelected ? kBaseColorUnEnabled : [UIColor whiteColor];
    self.cameraButton.layer.borderColor = button.isSelected ? [UIColor clearColor].CGColor : kBaseColor.CGColor;
    self.cameraButton.userInteractionEnabled = !button.isSelected;
    button.isSelected ? [self.cameraButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal] : [self.cameraButton setTitleColor:kBaseColor forState:UIControlStateNormal];
    
    self.nextBT.backgroundColor = button.selected ? kBaseColor : kBaseColorUnEnabled;
    self.nextBT.userInteractionEnabled = button.selected;
}

// 再撮影ボタンを押す
- (void)didBT2Click{
    
    // 操作ログ編集
    [AppComLog writeEventLog:@"再撮影ボタン" viewID:@"G0160-01" LogLevel:LOGLEVELInformation withCallback:^(NSString * _Nonnull resultCode) {
        
    } atController:self];
    
    // 再撮影ボタンタップ、カメラスキャンの関数_setConfigメソッドを呼び出し、カメラスキャンの設定を更新する。
    self.cameraScanManager.delegate = self;
}

#pragma mark - cameraScanDelegate

// カメラスキャン初期化（リソース）結果_正常時
- (void)cameraScanPrepareSuccess{
    [self startCamera];
}

// カメラスキャン起動
- (void)startCamera{

    [self.cameraScanManager start];
    for (UIView *v in self.view.subviews) {
        v.hidden = YES;
    }
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.view.backgroundColor = [UIColor blackColor];
}

// 書類の認識成功時に呼び出されます。
- (void)cameraScanSuccessWithImage:(UIImage *)image andCropResult:(NSInteger)cropResult{
    
    // 操作ログ編集
    [AppComLog writeEventLog:@"カメラスキャン終了処理" viewID:@"G0050-01" LogLevel:LOGLEVELInformation withCallback:^(NSString * _Nonnull resultCode) {
        
    } atController:self];
    
    // カメラスキャンの関数_deinitResourceメソッドを呼び出す。
    [self.cameraScanManager deinitResource];
    
    // 再撮影画像を共通領域.本人確認内容データへ格納（更新）する。
    InfoDatabase *db = [InfoDatabase shareInfoDatabase];
    db.identificationData.OBVERSE_IMG = image;
    db.identificationData.IMG_CROPPING1 = cropResult == 0;
    [self.img1 setImage:image];
    
    // 「G0060-01：本人確認書類撮影結果画面」へ遷移する。
    [self.navigationController popViewControllerAnimated:YES];
}

// プレビュー／認識中に何らかのエラーが発生した場合に呼び出されます。
- (void)cameraScanFailure:(NSInteger)errorCode{
    
    // 操作ログ編集
    [AppComLog writeEventLog:@"カメラスキャン終了処理" viewID:@"G0050-01" LogLevel:LOGLEVELInformation withCallback:^(NSString * _Nonnull resultCode) {
        
    } atController:self];
    
    // カメラスキャンの関数_deinitResourceメソッドを呼び出す。
    [self.cameraScanManager deinitResource];
    
    // カメラスキャン初期化またはカメラスキャン起動にてエラーが返却された場合、ポップアップでエラー内容に応じたメッセージを表示する。
    // ポップアップには「はい」ボタンのみ表示し、ライブラリにてエラー発生処理のリトライ等は実施しない。
    if (errorCode == 9100) {
        
        // エラーコード9100、ポップアップにて「メッセージコード：CM-001-04E」を表示する。
        [[ErrorManager shareErrorManager] showWithErrorCode:@"CM-001-04E" atCurrentController:self managerType:errorManagerTypeAlertClose addFirstMsg:@"" addSecondMsg:@""];
    } else {
        
        // エラーコード：9100以外、ポップアップにて「メッセージコード：CM-001-03E（%1：カメラ起動）」を表示する。
        [[ErrorManager shareErrorManager] showWithErrorCode:@"CM-001-03E" atCurrentController:self managerType:errorManagerTypeAlertClose addFirstMsg:@"カメラ起動" addSecondMsg:@""];
    }
}

// キャンセルボタンを押す時に呼び出されます。
- (void)cameraScanCancel{
    
    // 操作ログ編集
    [AppComLog writeEventLog:@"キャンセル" viewID:@"G0050-01" LogLevel:LOGLEVELInformation withCallback:^(NSString * _Nonnull resultCode) {
        
    } atController:self];
    
    // カメラスキャンの関数_deinitResourceメソッドを呼び出す。
    [self.cameraScanManager deinitResource];
}

// カメラスキャン起動成功時に呼び出されます。
- (void)cameraScanStart{
    
    // 操作ログ編集
    [AppComLog writeEventLog:@"カメラスキャン起動" viewID:@"G0160-01" LogLevel:LOGLEVELInformation withCallback:^(NSString * _Nonnull resultCode) {
        
    } atController:self];
    for (UIView *v in self.view.subviews) {
        v.hidden = NO;
    }
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)goNextView {
    
    // 操作ログ編集
    [AppComLog writeEventLog:@"次へボタン" viewID:@"G0020-01" LogLevel:LOGLEVELInformation withCallback:^(NSString * _Nonnull resultCode) {
        
    } atController:self];
    hudView *hud = [[hudView alloc] initWithModel:nil andController:nil];
    [hud show];
    self.myHud = hud;
    
    // 操作ログ編集
    [AppComLog writeEventLog:@"SF-104FaceIDトークン取得" viewID:@"G0160-01" LogLevel:LOGLEVELInformation withCallback:^(NSString * _Nonnull resultCode) {
        
    } atController:self];
    
    // 「SF-104：FaceIDトークン取得」を呼び出す。
    getFaceIDToken *service = [getFaceIDToken initService];
    service.delegate = self;
    [service sendGetFaceIDTokenRequest];
}

#pragma mark - getFaceIDTokenDelegate

/**
 顔照合認証応答
 
 @param resultCode 処理結果
 @param errorCode エラーコード
 */
- (void)getFaceIDResultCode:(NSString *)resultCode errorCode:(NSString *)errorCode{
    if ([resultCode isEqualToString:@"1"]) {
        
        // 処理正常時
        
        // 「G0100-01：自然人検知開始前画面」へ遷移する。
        fouthViewController *f = [[fouthViewController alloc] init];
        [self.myHud hide];
        [self.navigationController pushViewController:f animated:YES];
        
    }else{
        
        //  処理異常時
        if ([errorCode isEqualToString:@"ES00-401"]) {
            
            // 照合画像エラー時、「メッセージコード：CM-001-07E」を表示する
            [[ErrorManager shareErrorManager] showWithErrorCode:@"CM-001-07E" atCurrentController:self managerType:errorManagerTypeAlertClose addFirstMsg:@"" addSecondMsg:@""];
        } else {
            
            // 通信エラー時、「メッセージコード：CM-001-02E」を表示する。
            [[ErrorManager shareErrorManager] showWithErrorCode:@"CM-001-02E" atCurrentController:self managerType:errorManagerTypeAlertClose addFirstMsg:@"" addSecondMsg:@""];
        }
    }
}

- (void)didVerifyFailure:(NSString *)msg title:(NSString *)title{
    [self.myHud hide];
//    [self showAlert:msg title:title];
}

@end
