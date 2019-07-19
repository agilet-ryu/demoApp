//
//  CameraScanManager.m
//  demoApp
//
//  Created by agilet on 2019/06/20.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "CameraScanManager.h"
#import <PDLCameraScan/PDLCameraScan.h>

@interface CameraScanManager()<PDLCameraScanDelegate>
@property (strong, nonatomic) PDLCameraScan *scan;
@end

@implementation CameraScanManager

static CameraScanManager *manager;
+ (instancetype)sharedCameraScanManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    manager = [[CameraScanManager alloc] initWithPDLCameraScan];
    });
    return manager;
}

- (instancetype)initWithPDLCameraScan {
    self = [super init];
    if (self) {
        PDLCameraScan *scan = [PDLCameraScan sharedInstance];
        scan.delegate = self;
        // ライブラリの設定の更新
        PDLScanConfig *config = [scan getConfig];
        config.previewParam.previewDirection = PDLScanPreviewDirectionLandscape;
        config.guideParam.visible = YES;
        config.cameraParam.detectedDocSizeThreshold = 0.8;
        PDLCameraScanError *scanError1 = [scan setConfig:config];
        if (scanError1.code != PDLCameraScanErrorCodeOK){
            NSLog(@"setConfig error : %ld", (long)scanError1.code);
        } else {
            // フレームワーク初期化
            PDLCameraScanError *scanError = [scan prepareResource];
            if (scanError.code == PDLCameraScanErrorCodeOK) {
                NSLog(@"prepareResource OK : %ld", (long)scanError.code);
            } else {
                // エラー
                NSLog(@"prepareResource error : %ld", (long)scanError.code);
            }
        }
        self.scan = scan;
    }
    return self;
}

- (void)start{
    UIViewController *RootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIViewController *topVC = RootVC;
    
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    // カメラプレビュー開始
    PDLCameraScanError *scanError = [self.scan captureOnce:topVC];
    if (scanError.code != PDLCameraScanErrorCodeOK) {
        NSLog(@"captureOnce bad: %ld", (long)scanError.code);
    } else {
        NSLog(@"captureOnce ok : %ld", (long)scanError.code);
    }
}

// 書類の認識成功時に呼び出されます。
- (void)didScanSuccess:(PDLDocInfo *)cardInfo {
    UIImage *image = cardInfo.image;
    if ([self.delegate respondsToSelector:@selector(cameraScanSuccessWithImage:)]) {
        [self.delegate cameraScanSuccessWithImage:image];
    }
//    CGFloat h = image.size.height * 0.5;
//    CGFloat w = image.size.width * 0.5;
//    [self.scan convertOcrImage:cardInfo.image docWidth:w docHeight:h toResolution:10 toQuality:10];
    NSLog(@"didScanSuccess");
}

// プレビュー／認識中に何らかのエラーが発生した場合に呼び出されます。
- (void)didScanFailure:(PDLCameraScanError *)error {
    NSLog(@"Preview failed : %ld", (long)error.code);
}

- (void)didScanCancel {
    NSLog(@"Preview didScanCancel");
}
@end
