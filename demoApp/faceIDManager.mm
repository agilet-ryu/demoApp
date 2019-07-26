//
//  faceIDManager.m
//  demoApp
//
//  Created by agilet on 2019/06/26.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "faceIDManager.h"
#import <MGFaceIDLiveDetect/MGFaceIDLiveDetect.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>
#import <math.h>
#import <AFNetworking/AFNetworking.h>
#import "ErrorManager.h"

#define kMGFaceIDNetworkHost @"https://api-sgp.megvii.com"
#define kMGFaceIDNetworkTimeout 30
#define kApiKey @"mvRugQWhO4QUQLUPr9Y0-zDnNl2gtxJz"
#define kApiSecret @"sPdAfXwmto09yQBzqryavjX-zNhV_UzQ"
#define kUserName @"fujitsu"
#define kIdCardNumber @"fujitsu"

@implementation faceIDManager

static faceIDManager *manager = nil;
static AFHTTPSessionManager* sessionManager = nil;
+ (instancetype)sharedFaceIDManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[faceIDManager alloc] init];
        sessionManager = [[AFHTTPSessionManager manager] init];
    });
    return manager;
}

- (void)getBizTokenWithImage:(UIImage *)image viewController:(UIViewController *)viewController{
     NSData *data = UIImageJPEGRepresentation([UIImage imageNamed:@"face"], 0.7);
    [sessionManager.requestSerializer setValue:@"multipart/form-data; charset=utf-8; boundary=__X_PAW_BOUNDARY__" forHTTPHeaderField:@"Content-Type"];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithDictionary:@{@"sign" : [self getFaceIDSignStr],
                                                                                    @"sign_version" : [self getFaceIDSignVersionStr],
                                                                                    @"comparison_type" : @"0" ,
                                                                                    @"liveness_type" : @"meglive",
                                                                                    @"uuid" : @"1"
                                                                                    }];
    __weak typeof(self) weakSelf = self;
    [sessionManager POST:[NSString stringWithFormat:@"%@/faceid/v3/sdk/get_biz_token", kMGFaceIDNetworkHost]
              parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    [formData appendPartWithFileData:data name:@"image_ref1" fileName:@"head" mimeType:@"image/jpeg"];
}
                progress:nil
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                     if (responseObject && [[responseObject allKeys] containsObject:@"biz_token"] && [responseObject objectForKey:@"biz_token"]) {
                         NSString *bizTokenStr = [responseObject objectForKey:@"biz_token"];
                         NSLog(@"getBizTokenWithImage  bizTokenStr bizTokenStr bizTokenStr =~=~=~=~=~=~=~=~=~=~~=~=~=   %@",bizTokenStr);
                         if ([weakSelf.delegate respondsToSelector:@selector(getBizTokenSuccuss:)]) {
                             [weakSelf.delegate getBizTokenSuccuss:bizTokenStr];
                         }
                     } else {
                         
                     }
                 }
                 failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
                     NSDictionary *errdic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                     NSLog(@"%@  -^-^-^^-  %@", errdic, error);
                     
                     // 「SF-104：FaceIDトークン取得」返却結果「エラーコード」が通信エラー/画像エラーの場合
                     [[ErrorManager shareErrorManager] showWithErrorCode:@"CM-001-05E" atCurrentController:viewController managerType:errorManagerTypeAlertClose addFirstMsg:@"" addSecondMsg:@""];
                 }];
}

- (void)startDetectWithContoller:(UIViewController *)viewController bizToken:(NSString *)bizTokenStr{
    MGFaceIDLiveDetectError* error;
    MGFaceIDLiveDetectManager* detectManager = [[MGFaceIDLiveDetectManager alloc] initMGFaceIDLiveDetectManagerWithBizToken:bizTokenStr
                                                                                                                   language:MGFaceIDLiveDetectLanguageEn
                                                                                                                networkHost:kMGFaceIDNetworkHost
                                                                                                                  extraData:nil
                                                                                                                      error:&error];
    if (error || !detectManager) {
        [self setFailureDelegateWithString:error.errorMessageStr withTitle:@"DetectManagerFailure"];
    }
    {
        MGFaceIDLiveDetectCustomConfigItem* customConfigItem = [[MGFaceIDLiveDetectCustomConfigItem alloc] init];
        [detectManager setMGFaceIDLiveDetectCustomUIConfig:customConfigItem];
        [detectManager setMGFaceIDLiveDetectPhoneVertical:MGFaceIDLiveDetectPhoneVerticalFront];
    }
    __weak typeof(self) weakSelf = self;
    [detectManager startMGFaceIDLiveDetectWithCurrentController:viewController
                                                       callback:^(MGFaceIDLiveDetectError *error, NSData *deltaData, NSString *bizTokenStr, NSDictionary *extraOutDataDict) {
                                                           NSLog(@"startMGFaceIDLiveDetectWithCurrentController  bizTokenStr bizTokenStr bizTokenStr =~=~=~=~=~=~=~=~=~=~~=~=~=   %@",bizTokenStr);
                                                           if (error.errorType == MGFaceIDLiveDetectErrorNone) {
                                                               if ([weakSelf.delegate respondsToSelector:@selector(startDetectSuccuss:andBizToken:)]) {
                                                                   [weakSelf.delegate startDetectSuccuss:deltaData andBizToken:bizTokenStr];
                                                               }
                                                           } else {
                                                               [weakSelf setFailureDelegateWithString:error.errorMessageStr withTitle:@"startMGFaceIDFailure"];
                                                           }
                                                       }];
}

- (void)startVerifyWitBizToken:(NSString *)bizTokenStr data:(NSData *)deltaData{
    NSLog(@"startVerifyWitBizToken  bizTokenStr bizTokenStr bizTokenStr =~=~=~=~=~=~=~=~=~=~~=~=~=   %@",bizTokenStr);
    [sessionManager.requestSerializer setValue:@"multipart/form-data; charset=utf-8; boundary=__X_PAW_BOUNDARY__" forHTTPHeaderField:@"Content-Type"];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithDictionary:@{@"sign" : [self getFaceIDSignStr],
                                                                                    @"sign_version" : [self getFaceIDSignVersionStr],
                                                                                    @"biz_token" : bizTokenStr,
                                                                                    }];
    __weak typeof(self) weakSelf = self;
    [sessionManager POST:[NSString stringWithFormat:@"%@/faceid/v3/sdk/verify", kMGFaceIDNetworkHost]
              parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    [formData appendPartWithFileData:deltaData name:@"meglive_data" fileName:@"meglive_data" mimeType:@"text/html"];
}
                progress:nil
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                     NSMutableDictionary *m = [NSMutableDictionary dictionaryWithDictionary:responseObject];
                     [m removeObjectForKey:@"images"];
                   //  NSLog(@"%@",m);
                     if ([weakSelf.delegate respondsToSelector:@selector(didVerifySuccess:)]) {
                         [weakSelf.delegate didVerifySuccess:responseObject[@"result_message"]];
                     }
                 }
                 failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
                     NSDictionary *errdic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                     [weakSelf setFailureDelegateWithString:errdic[@"error"] withTitle:@"VerifyFailure"];
                 }];
}

- (NSString *)getFaceIDSignStr {
    NSAssert(kApiKey.length != 0 && kApiSecret.length != 0, @"Please set `kApiKey` and `kApiSecret`");
    int valid_durtion = 1000;
    long int current_time = [[NSDate date] timeIntervalSince1970];
    long int expire_time = current_time + valid_durtion;
    long random = labs(arc4random() % 100000000000);
    NSString* str = [NSString stringWithFormat:@"a=%@&b=%ld&c=%ld&d=%ld", kApiKey, expire_time, current_time, random];
    const char *cKey  = [kApiSecret cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [str cStringUsingEncoding:NSUTF8StringEncoding];
    char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSData* sign_raw_data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* data = [[NSMutableData alloc] initWithData:HMAC];
    [data appendData:sign_raw_data];
    NSString* signStr = [data base64EncodedStringWithOptions:0];
    NSLog(@"signStr signStr signStr =~=~=~=~=~=~=~=~=~=~~=~=~=   %@",signStr);
    return signStr;
}

- (NSString *)getFaceIDSignVersionStr {
    return @"hmac_sha1";
}

- (void)setFailureDelegateWithString:(NSString *)str withTitle:(NSString *)title{
    if ([self.delegate respondsToSelector:@selector(didVerifyFailure:title:)]) {
        [self.delegate didVerifyFailure:str title:title];
    }
}

@end

