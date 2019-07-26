//
//  thirdViewController.m
//  demoApp
//
//  Created by agilet on 2019/06/19.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "thirdViewController.h"
#import "UITool.h"
#import "fouthViewController.h"
#import "faceIDManager.h"
#import "CameraScanManager.h"
#import "hudView.h"
#import "OCRResultViewController.h"
#import "InfoDatabase.h"
#import "NetWorkManager.h"

@interface thirdViewController ()<faceIDManagerDelegate, cameraScanManagerDelegate>

@property (nonatomic, strong) UIButton *nextBT;
@property (nonatomic, assign) BOOL isFront;
@property (nonatomic, strong) CameraScanManager *cameraScanManager;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *backTitle;
@property (nonatomic, strong) UIImageView *img1;
@property (nonatomic, strong) UIImageView *img2;
@property (nonatomic, strong) hudView *myHudView;
@property (nonatomic, strong) UIButton *checkbox1;
@property (nonatomic, strong) UIButton *checkbox2;
@property (nonatomic, strong) UIButton *camera1;
@property (nonatomic, strong) UIButton *camera2;
@end

@implementation thirdViewController

- (CameraScanManager *)cameraScanManager{
    if (!_cameraScanManager) {
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.img1 setImage:[InfoDatabase shareInfoDatabase].identificationData.OBVERSE_IMG];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    for (UIView *v in self.view.subviews) {
        v.hidden = NO;
    }
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.view.backgroundColor = [UIColor whiteColor];
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

- (void)initView {
    UIBarButtonItem *back = [[UIBarButtonItem alloc] init];
    back.title = @"";
    self.navigationItem.backBarButtonItem = back;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"撮影結果の確認";
    
    BOOL imgCropping = [[InfoDatabase shareInfoDatabase].identificationData.IMG_CROPPING isEqualToString:@"2"];
    UIButton *footBT = [UIButton buttonWithType:UIButtonTypeCustom];
    [footBT setFrame:CGRectMake(16, [UIScreen mainScreen].bounds.size.height - 68, [UIScreen mainScreen].bounds.size.width - 32, 54)];
    [footBT setTitle:@"次へ" forState:UIControlStateNormal];
    [footBT addTarget:self action:@selector(goNextView) forControlEvents:UIControlEventTouchUpInside];
    footBT.backgroundColor = kBaseColorUnEnabled;
    footBT.layer.cornerRadius = 6.0f;
//    footBT.layer.shadowOpacity = 0.15f;
//    footBT.layer.shadowOffset = CGSizeMake(6, 6);
    footBT.layer.masksToBounds = NO;
    
    // 共通領域.本人確認内容データ.本人確認書類切り出し状態1が「0:切り出し済み」の場合、非活性状態とする、「2:未切り出し」の場合、非表示状態とする。、
    imgCropping ? [footBT setHidden:YES] : [footBT setUserInteractionEnabled:NO];
    [self.view addSubview:footBT];
    self.nextBT = footBT;
}

- (void)initScrollView{
    IDENTIFICATION_DATA *iData = [InfoDatabase shareInfoDatabase].identificationData;
    BOOL imgCropping = [iData.IMG_CROPPING isEqualToString:@"2"];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 132)];
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    UILabel *sectionL = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, [UIScreen mainScreen].bounds.size.width - 32, 100)];
    sectionL.numberOfLines = 0;
    sectionL.textAlignment = NSTextAlignmentLeft;
    
    // 共通領域.本人確認内容データ.本人確認書類切り出し状態1を判断し、撮影結果書類の確認案内メッセージを表示する
    sectionL.text = imgCropping ? @"書類撮影の結果、書類の切り出し範囲が適切でないため、再撮影してください。" : @"撮影画像をご確認いただき、不鮮明な場合や上下反転している場合は再撮影してください。問題がなければ、確認チェックボックスにチェックを入れてください。" ;
    sectionL.font = [UIFont systemFontOfSize:[UITool shareUITool].textSizeMedium];
    sectionL.textColor = kBodyTextColor;
    [scrollView addSubview:sectionL];
    self.detailLabel = sectionL;
    
    UILabel *frontTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 100, [UIScreen mainScreen].bounds.size.width - 32, 25)];
    frontTitle.textAlignment = NSTextAlignmentCenter;
    frontTitle.text = [NSString stringWithFormat:@"表面"];
    frontTitle.font = [UIFont systemFontOfSize:[UITool shareUITool].textSizeMedium];
    [scrollView addSubview:frontTitle];
    
    UIImageView *img1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic3"]];
    
    // 共通領域.本人確認内容データ.本人確認書類画像1を表示する。
    [img1 setImage:iData.OBVERSE_IMG];
    [img1 setFrame:CGRectMake(40, 145, [UIScreen mainScreen].bounds.size.width - 80, 200)];
    [scrollView addSubview:img1];
    self.img1 = img1;
    
    UIButton *check1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [check1 setFrame:CGRectMake(40, 425, [UIScreen mainScreen].bounds.size.width - 80, 30)];
    [check1 addTarget:self action:@selector(didCheck1:) forControlEvents:UIControlEventTouchUpInside];
    [check1 setImage:[UIImage imageNamed:@"pic5"] forState:UIControlStateNormal];
    [check1 setImage:[UIImage imageNamed:@"pic6"] forState:UIControlStateSelected];
    [check1 setTitleColor:kBodyTextColor forState:UIControlStateNormal];
    [check1 setTitle:@"確認しました。" forState:UIControlStateNormal];
    check1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [scrollView addSubview:check1];
    
    // 共通領域.本人確認内容データ.本人確認書類切り出し状態1が「2:未切り出し」の場合、非表示状態とする
    check1.hidden = imgCropping;
    self.checkbox1 = check1;
    
    UIButton *BT1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [BT1 setFrame:CGRectMake(40, 365, [UIScreen mainScreen].bounds.size.width - 80, 50)];
    BT1.backgroundColor = [UIColor whiteColor];
    [BT1 setTitle:@"再撮影" forState:UIControlStateNormal];
    [BT1 addTarget:self action:@selector(didBT1Click) forControlEvents:UIControlEventTouchUpInside];
    
    [BT1 setTitleColor:kBaseColor forState:UIControlStateNormal];
    BT1.layer.borderWidth = [UITool shareUITool].lineWidth;
    BT1.layer.cornerRadius = 3.0f;
    BT1.layer.borderColor = kBaseColor.CGColor;
    BT1.layer.masksToBounds = YES;
    
    BT1.userInteractionEnabled = !check1.isSelected;
    [scrollView addSubview:BT1];
    self.camera1 = BT1;
    
    if ([self.currentModel.kbnModel.STM1 isEqualToString:@"2"]) {
        
        // 共通領域.本人確認内容データ.本人確認書類区分より、システム内コード定義.ID_DOC_KBN.コードと合致する、システム内コード定義.ID_DOC_KBN.補足情報1が 2 の場合、初期値で表示状態とする。
        UILabel *backTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 485, [UIScreen mainScreen].bounds.size.width - 32, 25)];
        backTitle.textAlignment = NSTextAlignmentCenter;
        backTitle.text = [NSString stringWithFormat:@"裏面"];
        backTitle.font = [UIFont systemFontOfSize:[UITool shareUITool].textSizeMedium];
        [scrollView addSubview:backTitle];
        backTitle.hidden = imgCropping;
        self.backTitle = backTitle;
        
        UIImageView *img2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic4"]];
        [img2 setImage:iData.REVERSE_IMG];
        [img2 setFrame:CGRectMake(40, 530, [UIScreen mainScreen].bounds.size.width - 80, 200)];
        [scrollView addSubview:img2];
        img2.hidden = imgCropping;
        self.img2 = img2;
        
        UIButton *check = [UIButton buttonWithType:UIButtonTypeCustom];
        [check setFrame:CGRectMake(40, 810, [UIScreen mainScreen].bounds.size.width - 80, 30)];
        [check addTarget:self action:@selector(didCheck2:) forControlEvents:UIControlEventTouchUpInside];
        [check setImage:[UIImage imageNamed:@"pic5"] forState:UIControlStateNormal];
        [check setImage:[UIImage imageNamed:@"pic6"] forState:UIControlStateSelected];
        [check setTitleColor:kBodyTextColor forState:UIControlStateNormal];
        [check setTitle:@"確認しました。" forState:UIControlStateNormal];
        check.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [scrollView addSubview:check];
        check.hidden = imgCropping;
        self.checkbox2 = check;
        
        UIButton *BT2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [BT2 setFrame:CGRectMake(40, 750, [UIScreen mainScreen].bounds.size.width - 80, 50)];
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
        BT2.hidden = imgCropping;
        self.camera2 = BT2;
    }

    [scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 850)];
}

#pragma mark - 再摄影点击时
- (void)didBT1Click{
    
    // 再撮影ボタンタップ、カメラスキャンの関数_setConfigメソッドを呼び出し、カメラスキャンの設定を更新する。
    self.cameraScanManager.delegate = self;
    self.isFront = YES;
}

- (void)didBT2Click{
    // 再撮影ボタンタップ、カメラスキャンの関数_setConfigメソッドを呼び出し、カメラスキャンの設定を更新する。
    self.cameraScanManager.delegate = self;
    self.isFront = NO;
}

#pragma mark - cameraScanDelegate

// カメラスキャン初期化（リソース）結果_正常時
- (void)cameraScanPrepareSuccess{
    [self startCamera];
}

- (void)cameraScanSuccessWithImage:(UIImage *)image andCropResult:(NSInteger)cropResult{
    
    // カメラスキャンの関数_deinitResourceメソッドを呼び出す。
    [self.cameraScanManager deinitResource];
    
    // 共通領域初期化
    InfoDatabase *db = [InfoDatabase shareInfoDatabase];
    if (self.isFront) {
        
        // 撮影回数＜指定回数分の場合
        // カメラスキャンより返却された撮影結果画像を共通領域へ設定する
        db.identificationData.OBVERSE_IMG = image;
        db.identificationData.IMG_CROPPING = [NSString stringWithFormat:@"%ld", (long)cropResult];
        
        // 書類撮影結果（表面）画像を再撮影画像に差し替える。
        [self.img1 setImage:image];
    } else{
        
        // 撮影回数＝指定回数分の場合
        // カメラスキャンより返却された撮影結果画像を共通領域へ設定する
        db.identificationData.REVERSE_IMG = image;
        db.identificationData.IMG_CROPPING = [NSString stringWithFormat:@"%ld", (long)cropResult];
        
        // 書類撮影結果（裏面）画像を再撮影画像に差し替える。
        [self.img2 setImage:image];
    }
    

#warning TODO 共通領域.本人確認内容データ.本人確認書類切り出し状態1を判断し、撮影結果書類の確認案内メッセージを表示する※ 詳細は「出力編集仕様」参照
    BOOL imgCropping = [[InfoDatabase shareInfoDatabase].identificationData.IMG_CROPPING isEqualToString:@"2"];
    
    // 共通領域.本人確認内容データ.本人確認書類切り出し状態1を判断し、撮影結果書類の確認案内メッセージを表示する
    self.detailLabel.text = imgCropping ? @"書類撮影の結果、書類の切り出し範囲が適切でないため、再撮影してください。" : @"撮影画像をご確認いただき、不鮮明な場合や上下反転している場合は再撮影してください。問題がなければ、確認チェックボックスにチェックを入れてください。" ;
    
    // 共通領域.本人確認内容データ.本人確認書類切り出し状態1が「2:未切り出し」の場合、非表示状態とする
    self.checkbox1.hidden = imgCropping;
    if ([self.currentModel.kbnModel.STM1 isEqualToString:@"2"]) {
        self.backTitle.hidden = imgCropping;
        self.img2.hidden = imgCropping;
        self.checkbox2.hidden = imgCropping;
        self.camera2.hidden = imgCropping;
    }
    
    // 共通領域.本人確認内容データ.本人確認書類切り出し状態1が「0:切り出し済み」の場合、非活性状態とする、「2:未切り出し」の場合、非表示状態とする。、
    imgCropping ? [self.nextBT setHidden:YES] : [self.nextBT setUserInteractionEnabled:NO];
}

// プレビュー／認識中に何らかのエラーが発生した場合に呼び出されます。
- (void)cameraScanFailure:(NSInteger)errorCode{
    
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
    // カメラスキャンの関数_deinitResourceメソッドを呼び出す。
    [self.cameraScanManager deinitResource];
}

- (void)startCamera{
    [self.cameraScanManager start];
    for (UIView *v in self.view.subviews) {
        v.hidden = YES;
    }
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.view.backgroundColor = [UIColor blackColor];
}

#pragma mark - 次処理へ遷移
- (void)goNextView{
    hudView *hud = [[hudView alloc] initWithModel:nil andController:nil];
    [hud show];
    self.myHudView = hud;
    [self performSelector:@selector(doNext) withObject:nil afterDelay:2.0f];
}

- (void)doNext{
    InfoDatabase *db = [InfoDatabase shareInfoDatabase];
    IDENTIFICATION_DATA *iData = db.identificationData;
    CONFIG_FILE_DATA *configData = db.configFileData;
    int enable = [Utils getSystemCode].enable_KBN.ENFORCE.code;
    if (configData.OCR_ENABLE == enable) {
        
        // 共通領域.設定ファイルデータ.OCR機能有効化フラグ＝ 1:有効の場合
        if (iData.OCR_REQUEST >= configData.OCR_LIMIT) {
            
            // 共通領域.本人確認内容データ.OCRリクエスト回数＝共通領域.設定ファイルデータ.サーバOCRre-Try回数の場合、ポップアップにて「メッセージコード：CM-001-05E」を表示する。
            [[ErrorManager shareErrorManager] dealWithErrorCode:@"EC06-001" msg:@"CM-001-05E" andController:self];
            
        } else {
            // 共通領域.本人確認内容データ.OCRリクエスト回数＜共通領域.設定ファイルデータ.サーバOCRre-Try回数の場合、「SF-010：サーバOCR」を呼び出す。
            [[NetWorkManager shareNetWorkManager] getOCRMessageWithFile:iData.OBVERSE_IMG andCurrentController:self];
        }
    } else{
        
        // 共通領域.設定ファイルデータ.OCR機能有効化フラグ＝ 0:無効の場合、
        // 「SF-011：顔画像トリミング」を呼び出す。
        UIImage *face = [Utils getFaceImageWithCameraScanImage:iData.OBVERSE_IMG];
        
        // 「SF-104：FaceIDトークン取得」を呼び出す。
        [[faceIDManager sharedFaceIDManager] getBizTokenWithImage:face viewController:self];
    }
}

- (void)goToOCRView{
    
    // OCR処理が有効時、「SF-010：サーバOCR」機能を呼出し、「G0160-01：OCR結果表示画面」に遷移する。
    OCRResultViewController *ocr = [[OCRResultViewController alloc] init];
    ocr.currentModel = self.currentModel;
    [self.myHudView hide];
    [self.navigationController pushViewController:ocr animated:YES];
    
    // OCR処理が無効時、「SF-011：顔画像トリミング」機能および、「SF-104：FaceIDトークン取得」機能を呼出し、「G0100-01：自然人検知開始前画面」に遷移する。
}

#pragma mark - checkbox点击时
- (void)didCheck1:(UIButton *)button{
    [self checkNextButton:button andCameraButton:self.camera1];
}
- (void)didCheck2:(UIButton *)button{
    [self checkNextButton:button andCameraButton:self.camera2];
}
- (void)checkNextButton:(UIButton *)button andCameraButton:(UIButton *)cameraButton{
    button.selected = !button.isSelected;
    
    cameraButton.backgroundColor = button.isSelected ? kBaseColorUnEnabled : [UIColor whiteColor];
    cameraButton.layer.borderColor = button.isSelected ? [UIColor clearColor].CGColor : kBaseColor.CGColor;
    cameraButton.userInteractionEnabled = !button.isSelected;
    button.isSelected ? [cameraButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal] : [cameraButton setTitleColor:kBaseColor forState:UIControlStateNormal];
    
    self.nextBT.backgroundColor = self.checkbox1.isSelected && self.checkbox2.isSelected ? kBaseColor : kBaseColorUnEnabled;
    self.nextBT.userInteractionEnabled = self.checkbox1.isSelected && self.checkbox2.isSelected;
}

// 閉じる処理
- (void)backTo{
    [[ErrorManager shareErrorManager] dealWithErrorCode:@"" msg:@"CM-001-08E" andController:self];
}

@end
