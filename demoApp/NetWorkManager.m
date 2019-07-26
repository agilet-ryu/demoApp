//
//  NetWorkManager.m
//  demoApp
//
//  Created by tourituyou on 2019/7/18.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "NetWorkManager.h"
#import <AFNetworking/AFNetworking.h>
#import "InfoDatabase.h"
#import "Utils.h"
#define kNetworkHostFaceIDSign @"http://192.168.3.28:8080/generateSign?requestParam="
#define kNetworkHostOcrService @"http://111.171.206.102:8081/api/cardinfo"
#define kNetworkHostOcrServiceWithBase64 @"http://111.171.206.102:8081/OcrService.asmx/GetOcrInfoFromBase64"
#define kTest @"http://192.168.3.28:8080/saveData?dataInfo="

@implementation NetWorkManager

static NetWorkManager *manager = nil;
static AFHTTPSessionManager* sessionManager = nil;
static InfoDatabase *db = nil;

/**
 NetWorkManager初期化
 
 @return NetWorkManager
 */
+(instancetype)shareNetWorkManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NetWorkManager alloc] init];
        
        // 共通領域の初期化
        db = [InfoDatabase shareInfoDatabase];
        
        // AFHTTPSessionManager初期化
        sessionManager = [[AFHTTPSessionManager manager] init];
        sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json", @"text/json", @"text/javascript",@"text/html",nil];
        sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    return manager;
}

/**
 「SF-002：認証」機能を呼び出す。
 
 @param controller 呼び出す元controller
 */
- (void)getFaceIDSignWithCurrentController:(UIViewController *)controller{
    
    // パラメーターを取得する
    NSString *apiSecret = db.startParam.API_SECRET;
    NSString *businessID = db.configFileData.MAIN_ACCOUNT;
    NSDictionary *param = @{@"business_id" : apiSecret,
                            @"api_secret" : businessID};
    
    // パラメーターはJSON文字列になります。
    NSString *paramStr = [Utils convertToJsonData:param];
    
    // 文字列をAES暗号化する
    NSString *aesParamStr = [Utils aes_encryptWithString:paramStr];
    
    // URLを作成する
    NSString *url = [NSString stringWithFormat:@"%@%@", kNetworkHostFaceIDSign,aesParamStr];
    
    // FaceID電子署名取得要求を送信する。
    __weak typeof(self) weakSelf = self;
    [sessionManager POST:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        // FaceID電子署名取得応答受信
        NSLog(@"kNetworkHostFaceIDSign.responseObject = %@", responseObject);
        int status = [responseObject[@"status"] intValue];
        if (status == 0) {
            
            // FaceID電子署名取得成功時
            // 応答内のFaceID電子署名、有効期限判定用日付、設定値情報、CallIDを共通領域へ設定する。
            [weakSelf dealWithResponse:responseObject];
        } else{
            
            // FaceID電子署名取得でエラーが返却された場合
            // エラーコードを共通領域の「本人確認内容データ.エラーコード」へ設定する
            // 共通領域の「本人確認内容データ.認証処理結果」へ「異常」を設定する
            // ポップアップでエラーメッセージ「SF-001-01E」を表示する。
            [[ErrorManager shareErrorManager] dealWithErrorCode:responseObject[@"error_code"] msg:@"SF-001-01E" andController:controller];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        // FaceID電子署名取得で通信エラーの場合
        // エラーコードを共通領域の「本人確認内容データ.エラーコード」へ設定する
        // 共通領域の「本人確認内容データ.認証処理結果」へ「異常」を設定する
        // ポップアップでエラーメッセージ「SF-001-01E」を表示する。
        [[ErrorManager shareErrorManager] dealWithErrorCode:@"ES02-2001" msg:@"SF-001-01E" andController:controller];
    }];
}

// FaceID電子署名、有効期限判定用日付、設定値情報、CallIDを共通領域へ設定する。
- (void)dealWithResponse:(id)responseObject {
    NSDictionary *dic = [NSDictionary dictionaryWithDictionary:responseObject];
    
    // 共通領域から、本人確認内容データと設定ファイルデータを取得する
    CONFIG_FILE_DATA *configFileData = db.configFileData;
    IDENTIFICATION_DATA *identificationData = db.identificationData;

    // 設定ファイルデータを設定する
    configFileData.IDENTIFICATION_DOCUMENT_DRIVERS_LICENCE = [dic[@"identification_document_drivers_licence"] intValue];  // 本人確認書類（運転免許証）フラグ
    configFileData.IDENTIFICATION_DOCUMENT_MYNUMBER = [dic[@"identification_document_mynumber"] intValue];  // 本人確認書類（マイナンバーカード）フラグ
    configFileData.IDENTIFICATION_DOCUMENT_PASSPORT = [dic[@"identification_document_passport"] intValue];  // 本人確認書類（パスポート）フラグ
    configFileData.IDENTIFICATION_DOCUMENT_RESIDENCE = [dic[@"identification_document_residence"] intValue];  // 本人確認書類（在留カード）フラグ
    configFileData.IDENTIFICATION_DOCUMENT_SPECIAL_PERMANENT_RESIDENT_CERTIFICATE = [dic[@"identification_document_special_permanent_resident_certificate"] intValue];  // 本人確認書類（特別永住者証明書）フラグ
    configFileData.CAMERA_ENABLE = [dic[@"camera_enable"] intValue];  // カメラ撮影有効化フラグ
    configFileData.OCR_ENABLE = [dic[@"ocr_enable"] intValue];  // OCR機能有効化フラグ
    configFileData.CHECK_OCR_STATUS_1 = [dic[@"check_ocr_status_1"] intValue];  // 氏名の妥当性確認
    configFileData.CHECK_OCR_STATUS_2 = [dic[@"check_ocr_status_2"] intValue];  // 氏名（カナ）の妥当性確認
    configFileData.CHECK_OCR_STATUS_3 = [dic[@"check_ocr_status_3"] intValue];  // 住所の妥当性確認
    configFileData.CHECK_OCR_STATUS_4 = [dic[@"check_ocr_status_4"] intValue];  // 生年月日の妥当性確認
    configFileData.CHECK_OCR_STATUS_5 = [dic[@"check_ocr_status_5"] intValue];  // 本籍地の妥当性確認
    configFileData.CHECK_OCR_STATUS_6 = [dic[@"check_ocr_status_6"] intValue];  // 運転免許種類の妥当性確認
    configFileData.CHECK_OCR_STATUS_7 = [dic[@"check_ocr_status_7"] intValue];  // 有効期限帯色の妥当性確認
    configFileData.CHECK_OCR_STATUS_8 = [dic[@"check_ocr_status_8"] intValue];  // 性別の妥当性確認
    configFileData.CHECK_OCR_STATUS_9 = [dic[@"check_ocr_status_9"] intValue];  // 交付日の妥当性確認
    configFileData.CHECK_OCR_STATUS_10 = [dic[@"check_ocr_status_10"] intValue];  // 免許種類の枠数の妥当性確認
    configFileData.CHECK_OCR_STATUS_11 = [dic[@"check_ocr_status_11"] intValue];  // 免許の条件等1の妥当性確認
    configFileData.CHECK_OCR_STATUS_12 = [dic[@"check_ocr_status_12"] intValue];  // 免許の条件等2の妥当性確認
    configFileData.CHECK_OCR_STATUS_13 = [dic[@"check_ocr_status_13"] intValue];  // 免許の条件等3の妥当性確認
    configFileData.CHECK_OCR_STATUS_14 = [dic[@"check_ocr_status_14"] intValue];  // 免許の条件等4の妥当性確認
    configFileData.CHECK_OCR_STATUS_15 = [dic[@"check_ocr_status_15"] intValue];  // 取得日（二・小・原）の妥当性確認
    configFileData.CHECK_OCR_STATUS_16 = [dic[@"check_ocr_status_16"] intValue];  // 取得日（他）の妥当性確認
    configFileData.CHECK_OCR_STATUS_17 = [dic[@"check_ocr_status_17"] intValue];  // 取得日（二種）の妥当性確認
    configFileData.CHECK_OCR_STATUS_18 = [dic[@"check_ocr_status_18"] intValue];  // 公安委員会の妥当性確認
    configFileData.CHECK_OCR_STATUS_19 = [dic[@"check_ocr_status_19"] intValue];  // 運転免許証番号の妥当性確認
    configFileData.NFC_ENABLE = [dic[@"nfc_enable"] intValue];  // NFC機能有効化フラグ
    configFileData.SHOOT_THICKNESS_ENABLE = [dic[@"shoot_thickness_enable"] intValue];  // 厚み撮影機能有効化フラグ
    configFileData.MANGEMENT_CONSOL_USE = [dic[@"mangement_consol_use"] intValue];  // 管理コンソール利用フラグ
//    configFileData.LIVENESS_ACTION_LIMIT = [dic[@"liveness_action_limit"] intValue];  // 顔モーションre-Try回数
    configFileData.SHOOT_THICKNESS_LIMIT = [dic[@"shoot_thickness_limit"] intValue];  // 厚み撮影re-Try回数
    configFileData.OCR_LIMIT = [dic[@"ocr_limit"] intValue];  // サーバOCRre-Try回数
    configFileData.LIVENESS_TYPE = dic[@"liveness_type"];  // モーションタイプ
    configFileData.LIVENESS_TIMEOUT = dic[@"liveness_timeout"];  // タイムアウト設定時間
    configFileData.LIVENESS_ACTION_COUNT = dic[@"liveness_action_count"];  // モーションパターン回数
    configFileData.LOG_OUTPUT_LIMIT = [dic[@"log_output_limit"] intValue];  // 操作ログ書出回数上限
    configFileData.IMG_MASK = [dic[@"img_mask"] intValue];  // 本人確認書類画像マスクフラグ
    configFileData.SAVE_IMAGE_FLG = [dic[@"save_image_flg"] intValue];  // 画像保存フラグ
    
    // 本人確認内容データを設定する
    identificationData.FACEID_SIGNATURE = dic[@"faceid_signature"];
   // identificationData.CALL_ID = dic[@""];
    identificationData.EXPIRATION_DATE = dic[@"expiration_date"];
    
    // 共通領域へデータを格納する
    [db setConfigFileData:configFileData];
    [db setIdentificationData:identificationData];
}









#pragma mark - TODO
// SF-010：サーバOCR
- (void)getOCRMessageWithFile:(UIImage *)image andCurrentController:(UIViewController *)controller{
    NSLog(@"getOCRMessageWithFile startTime = %@", [Utils getCurrentTime]);
    
    //「本人確認書類画像」はオンライン本人確認ライブラリ内の共通鍵（ライブラリ内で定数管理）を使用して暗号化する
    NSData *AESData = [Utils aes_encryptWithImage:[UIImage imageNamed:@"OCR.jpg"]];
    
    // リクエストをオンライン本人確認サーバへ送信する。
    [sessionManager POST:kNetworkHostOcrService parameters:nil headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:AESData name:@"image_ref1" fileName:@"head" mimeType:@"image/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"getOCRMessageWithFile size = %lu endTime = %@", (unsigned long)AESData.length,[Utils getCurrentTime]);
        NSString *decStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        // OCR結果値をオンライン本人確認ライブラリ内の共通鍵（ライブラリ内で定数管理）を使用して復号化する。
        NSString *str = [Utils aes_decryptWithBase64String:decStr];
        NSLog(@"responseObject  = %@ aes_decryptWithBase64String = %@", decStr, str);
        NSDictionary *responseDic = [NSDictionary dictionaryWithDictionary:[Utils dictionaryWithJsonString:str]];
        
        NSString *errorCode = [NSString stringWithFormat:@"%@", responseDic[@"ERROR"]];
        if (errorCode.length) {
            if ([errorCode isEqualToString:@"EC10-002"]) {
                
                // 「SF-010：サーバOCR」返却結果「エラーコード」が「EC10-002」有効期限切れの場合、ポップアップにて「メッセージコード：SF-008-5E」を表示する。
                [[ErrorManager shareErrorManager] dealWithErrorCode:@"EC10-002" msg:@"SF-008-5E" andController:controller];
            } else {
                
                // 共通領域.本人確認内容データ.OCRリクエスト回数を1カウントアップする。
                db.identificationData.OCR_REQUEST++;
                
                if (db.identificationData.OCR_REQUEST >= db.configFileData.OCR_LIMIT) {
                    
                    // 共通領域.本人確認内容データ.OCRリクエスト回数＝共通領域.設定ファイルデータ.サーバOCRre-Try回数の場合、ポップアップにて「メッセージコード：CM-001-05E」を表示する。
                    [[ErrorManager shareErrorManager] dealWithErrorCode:@"EC06-001" msg:@"CM-001-05E" andController:controller];
                } else {
                    
                    // 共通領域.本人確認内容データ.OCRリクエスト回数＜共通領域.設定ファイルデータ.サーバOCRre-Try回数の場合、ポップアップにて「メッセージコード：SF-006-01E」を表示する
                    [[ErrorManager shareErrorManager] showWithErrorCode:@"SF-006-01E" atCurrentController:controller managerType:errorManagerTypeAlertClose addFirstMsg:@"" addSecondMsg:@""];
                }
            }
        } else {
            
            // 「SF-010：サーバOCR」返却結果「エラーコード」が未設定の場合、 共通領域.本人確認内容データ.OCRリクエスト回数を1カウントアップする。
            db.identificationData.OCR_REQUEST++;
            
            // 「SF-011：顔画像トリミング」を呼び出す
            [Utils getFaceImageWithOCRImage:image positionX1:responseDic[@"POSITION_IMAGE_X1"] positionX2:responseDic[@"POSITION_IMAGE_X2"] positionY1:responseDic[@"POSITION_IMAGE_Y1"] positionY2:responseDic[@"POSITION_IMAGE_Y2"]];
            
            // 「G0160-01：OCR結果表示画面」へ遷移する。
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        // 「SF-010：サーバOCR」返却結果「エラーコード」が通信エラーの場合、ポップアップにて「メッセージコード：CM-001-05E」を表示する。
        [[ErrorManager shareErrorManager] showWithErrorCode:@"CM-001-05E" atCurrentController:controller managerType:errorManagerTypeAlertClose addFirstMsg:@"" addSecondMsg:@""];
    }];
}

- (void)getOCRMessageWithBase64{
    NSLog(@"getOCRMessageWithBase64 startTime = %@", [Utils getCurrentTime]);
    
    NSString *dataStr = [[Utils aes_encryptWithImage:[UIImage imageNamed:@"OCR.jpg"]] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSDictionary *param = @{@"requestImage" : dataStr};
    
    [sessionManager POST:kNetworkHostOcrServiceWithBase64 parameters:param headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *decStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString *str = [Utils aes_decryptWithBase64String:decStr];
        NSLog(@"responseObject  = %@", str);
        NSLog(@"getOCRMessageWithBase64 size = %lu endTime = %@", (unsigned long)dataStr.length,[Utils getCurrentTime]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
        NSLog(@"%@  -^-^-^^-  %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], error);
    }];
}
















- (void)testWithBase64{
    NSLog(@"getOCRMessageWithBase64 startTime = %@", [Utils getCurrentTime]);
    
    NSString *dataStr = [[Utils aes_encryptWithImage:[UIImage imageNamed:@"OCR.jpg"]] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *url = [NSString stringWithFormat:@"%@%@&imgFile1=%@", kTest,@"", dataStr];
    [sessionManager POST:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *decStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString *str = [Utils aes_decryptWithBase64String:decStr];
        NSLog(@"getOCRMessageWithBase64 size = %lu endTime = %@", (unsigned long)dataStr.length,[Utils getCurrentTime]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
        NSLog(@"%@  -^-^-^^-  %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], error);
    }];
}

- (void)testWithAESFile{
    NSLog(@"testWithAESFile startTime = %@", [Utils getCurrentTime]);
    NSString *dataStr = [[Utils aes_encryptWithImage:[UIImage imageNamed:@"OCR.jpg"]] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *temp = [dataStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *url = [NSString stringWithFormat:@"%@%@&imgFile1=%@", kTest, [self testParam], temp];
  //  NSString *url = [NSString stringWithFormat:@"%@%@&imgFile1=", kTest, [self testParam]];
    NSLog(@"aes_decryptWithBase64String  -= %@", [Utils aes_decryptWithBase64String:[self testParam]]);
    [sessionManager POST:url parameters:nil headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:[NSData new] name:@"imgFile2" fileName:@"imgFile2" mimeType:@"image/jpeg"];
        [formData appendPartWithFileData:[NSData new] name:@"videoFile" fileName:@"videoFile" mimeType:@"video/mp4"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *decStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString *str = [Utils aes_decryptWithBase64String:decStr];
        NSLog(@"testWithAESFile size = %lu endTime = %@, %@", (unsigned long)dataStr.length,[Utils getCurrentTime], decStr);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
        NSLog(@"%@  -^-^-^^-  %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], error);
    }];
}

- (NSString *)testParam{
    NSDictionary *dic = @{@"callID": @"1",@"process_id": @"1",@"business_id": @"1",@"identification_document": @"1",@"read_method": @"1",@"result": @"1",@"score": @"1",@"far": @"1",@"frr": @"1",@"photo_img": @"1",@"camera_img": @"1",@"obverse_img": @"1",@"reverse_img": @"1",@"name": @"1",@"kana": @"1",@"address": @"1",@"birth": @"1",@"number": @"1",@"permanent_address": @"1",@"type": @"1",@"band_color": @"1",@"gender": @"1",@"expiration": @"1",@"issuance_date": @"1",@"type_num": @"1",@"condition_1": @"1",@"condition_2": @"1",@"condition_3": @"1",@"condition_4": @"1",@"date_nikogen": @"1",@"date_other": @"1",@"date_second": @"1",@"commission": @"1",@"common_name": @"1",@"unify_name": @"1",@"reference_number": @"1",@"date_ogata": @"1",@"date_futsu": @"1",@"date_otoku": @"1",@"date_daijini": @"1",@"date_fujini": @"1",@"date_kotoku": @"1",@"date_gen": @"1",@"date_kein": @"1",@"date_daini": @"1",@"date_funi": @"1",@"date_daitokuni": @"1",@"date_keinni": @"1",@"date_chugata": @"1",@"date_chuni": @"1",@"date_junchugata": @"1",@"jis_x_0208_num": @"1",@"new_commission_1": @"1",@"new_commission_2": @"1",@"new_commission_3": @"1",@"new_commission_4": @"1",@"new_commission_5": @"1",@"new_commission_6": @"1",@"new_commission_7": @"1",@"new_commission_8": @"1",@"new_commission_9": @"1",@"new_commission_10": @"1",@"new_commission_11": @"1",@"new_commission_12": @"1",@"new_commission_13": @"1",@"new_commission_14": @"1",@"new_commission_15": @"1",@"new_name_1": @"1",@"new_name_2": @"1",@"new_name_3": @"1",@"new_name_4": @"1",@"new_name_5": @"1",@"new_name_6": @"1",@"new_name_7": @"1",@"new_name_8": @"1",@"new_kana_1": @"1",@"new_kana_2": @"1",@"new_kana_3": @"1",@"new_kana_4": @"1",@"new_kana_5": @"1",@"new_kana_6": @"1",@"new_kana_7": @"1",@"new_kana_8": @"1",@"new_address_1": @"1",@"new_address_2": @"1",@"new_address_3": @"1",@"new_address_4": @"1",@"new_address_5": @"1",@"new_address_6": @"1",@"new_address_7": @"1",@"new_address_8": @"1",@"new_condition_1": @"1",@"new_condition_2": @"1",@"new_condition_3": @"1",@"new_condition_4": @"1",@"new_condition_5": @"1",@"new_condition_6": @"1",@"new_condition_7": @"1",@"new_condition_8": @"1",@"condition_cancel_1": @"1",@"condition_cancel_2": @"1",@"condition_cancel_3": @"1",@"condition_cancel_4": @"1",@"condition_cancel_5": @"1",@"condition_cancel_6": @"1",@"condition_cancel_7": @"1",@"condition_cancel_8": @"1",@"remarks_1": @"1",@"remarks_2": @"1",@"remarks_3": @"1",@"remarks_4": @"1",@"remarks_5": @"1",@"remarks_6": @"1",@"remarks_7": @"1",@"remarks_8": @"1",@"reserve_1": @"1",@"reserve_2": @"1",@"reserve_3": @"1",@"reserve_4": @"1",@"reserve_5": @"1",@"reserve_6": @"1",@"reserve_7": @"1",@"reserve_8": @"1",@"new_permanent_address_1": @"1",@"new_permanent_address_2": @"1",@"new_permanent_address_3": @"1",@"new_permanent_address_4": @"1",@"new_permanent_address_5": @"1",@"serial_num": @"1",@"issuer": @"1",@"main_person": @"1",@"main_person_id": @"1",@"latitude": @"1",@"longitude": @"1",@"error_code": @"1",@"img_cropping": @"1",@"photo_position": @"1",@"thickness_video": @"1",@"faceid_signature": @"1",@"log_id": @"1",@"expiration_date": @"1",@"biz_token": @"1",@"request_id": @"1",@"gw_api_token": @"1",@"log_output": @"1",@"ocr_request": @"1",@"uuid": @"1"};
    NSString *s = [Utils convertToJsonData:dic];
    return [Utils aes_encryptWithString:s];
}
@end
