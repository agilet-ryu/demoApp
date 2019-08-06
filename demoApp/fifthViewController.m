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
#import "InfoDatabase.h"
#import <AFNetworking/AFNetworking.h>
#import "urlConfig.h"
#import "service/SF-101/AppComLog.h"

@interface fifthViewController ()<faceIDManagerDelegate, ErrorManagerDelegate>
@property (nonatomic, strong) hudView *myHudView;
@property (nonatomic, strong) UIButton *footBt;
@property (nonatomic, strong) UILabel *detailLabel;
@end

@implementation fifthViewController

static InfoDatabase *db = nil;
- (void)viewDidLoad {
    db = [InfoDatabase shareInfoDatabase];
    [super viewDidLoad];
    self.title = @"顔照合";
    self.view.backgroundColor = [UIColor whiteColor];
    [self initView];
    [self initProgressBar];
    [self performSelector:@selector(goNextView) withObject:nil afterDelay:3.0f];
}

// 顔照合（自然人検知）要求(App-Verify)の送信
- (void)sendVerifyRequest{
    
    // 操作ログ編集
    [AppComLog writeEventLog:@"顔照合（自然人検知）要求(App-Verify)" viewID:@"G0120-01" LogLevel:LOGLEVELInformation withCallback:^(NSString * _Nonnull resultCode) {
        
    } atController:self];
    
    ErrorManager *manager = [ErrorManager shareErrorManager];
    manager.delegate = self;
    
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager manager] init];
    [sessionManager.requestSerializer setValue:@"multipart/form-data; charset=utf-8; boundary=__X_PAW_BOUNDARY__" forHTTPHeaderField:@"Content-Type"];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithDictionary:@{@"sign" : db.identificationData.FACEID_SIGNATURE,
                                                                                    @"sign_version" : @"hmac_sha1",
                                                                                    @"biz_token" : db.identificationData.BIZ_TOKEN,
                                                                                    }];
    __weak typeof(self) weakSelf = self;
    [sessionManager POST:[NSString stringWithFormat:@"%@/faceid/v3/sdk/verify", kMGFaceIDNetworkHost]
              parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    [formData appendPartWithFileData:db.identificationData.CAMERA_IMG name:@"meglive_data" fileName:@"meglive_data" mimeType:@"text/html"];
}
                progress:nil
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                     if (responseObject[@"error"]) {
                         
                         // API処理異常時、ポップアップにて「メッセージコード：SF-014-01E」を表示する。
                         [manager showWithErrorCode:@"SF-014-01E" atCurrentController:self managerType:errorManagerTypeCustom buttonTitle:@"はい" andTag:2000];
                     }else{
                         
                         // API処理正常時
                         // 顔照合（自然人検知）応答(App-Verify)内容を共通領域.本人確認内容データに編集
                         [weakSelf dealWithResponseDic:responseObject];
                         if (db.configFileData.SHOOT_THICKNESS_ENABLE == 1) {
                             
                             // 厚み撮影有効時
                             if ([db.identificationData.RESULT isEqualToString:@"1"]) {
                                 
                                 // 照合結果OKの場合
                                 if (db.identificationData.GAIN_TYPE == 1) {
                                     
                                     // 読取方法が「1:カメラ撮影」の場合、「G0130-01：厚み撮影開始前画面」へ遷移する。
#warning TODO 厚み撮影開始前画面
                                 }else{
                                     
                                     // 読取方法が「2:NFC読取」の場合
                                     if (db.configFileData.MANGEMENT_CONSOL_USE == 1) {
                                         
                                         // 管理コンソール利用、「SF-016:取得情報サーバ送信」を呼び出す。
                                         
                                     }else{
                                         
                                         // 管理コンソール未利用、「SF-102：操作ログサーバ送信」および「SF-017：処理終了」を呼び出す。
                                     }
                                 }
                             }else{
                                 
                                 // 照合結果NGの場合、ポップアップにて「メッセージコード：SF-014-01E」を表示する
                                 [manager showWithErrorCode:@"SF-014-01E" atCurrentController:self managerType:errorManagerTypeCustom buttonTitle:@"はい" andTag:2000];
                             }
                         }else{
                             
                             // 厚み撮影無効時
                             if (db.configFileData.MANGEMENT_CONSOL_USE == 1) {
                                 
                                 // 管理コンソール利用
                                 // 「SF-016:取得情報サーバ送信」を呼び出す。
                                 
                             }else{
                                 
                                 // 管理コンソール未利用
                                 // 「SF-102：操作ログサーバ送信」および「SF-017：処理終了」を呼び出す
                                 
                             }
                         }
                     }
                 }
                 failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     
                     // 通信エラー場合、ポップアップにて「メッセージコード：CM-001-02E」を表示する。
                     [manager showWithErrorCode:@"CM-001-02E" atCurrentController:self managerType:errorManagerTypeCustom buttonTitle:@"再試行" andTag:1000];
                 }];
}


/**
 顔照合（自然人検知）応答(App-Verify)内容を共通領域.本人確認内容データに編集

 @param responseDic 取得するレスポンス
 */
- (void)dealWithResponseDic:(NSDictionary *)responseDic{
    db.identificationData.REQUEST_ID = responseDic[@"request_id"];
    db.identificationData.SCORE = responseDic[@"verification"][@"idcard"][@"confidence"];
    NSDictionary *thresholds = responseDic[@"verification"][@"idcard"][@"thresholds"];
    float score = [db.identificationData.SCORE floatValue];
    if(db.startParam.THREHOLDS_LEVEL == FARTypeLevelOne){db.identificationData.FAR = thresholds[@"1e-3"];}
    if(db.startParam.THREHOLDS_LEVEL == FARTypeLevelTwo){db.identificationData.FAR = thresholds[@"1e-4"];}
    if(db.startParam.THREHOLDS_LEVEL == FARTypeLevelThree){db.identificationData.FAR = thresholds[@"1e-5"];}
    if(db.startParam.THREHOLDS_LEVEL == FARTypeLevelFour){db.identificationData.FAR = thresholds[@"1e-6"];}
    float level = [db.identificationData.FAR floatValue];
    if (score > level) {
        db.identificationData.RESULT = @"1";
    }else{
        db.identificationData.RESULT = @"9";
    }
    db.identificationData.FRR = db.identificationData.FAR;
}

#pragma mark - ErrorManagerDelegate
- (void)buttonDidClickedWithTag:(NSInteger)tag{
    if (tag == 1000) {
        
        //「再試行ボタン」を押す、顔照合（自然人検知）要求(App-Verify)の再送信
        [self sendVerifyRequest];
    }
    if (tag == 2000) {
        
        // 「はい」ボタンタップにより、「SF-013：自然人検知」を呼び出す。
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)initProgressBar {
    UIProgressView *p = [[ UIProgressView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 2)];
    p.trackTintColor = [UIColor lightGrayColor];
    p.tintColor = kBaseColor;
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
    sectionL.textColor = kBodyTextColor;
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
