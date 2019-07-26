//
//  InfoDatabase.m
//  demoApp
//
//  Created by tourituyou on 2019/7/16.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "InfoDatabase.h"

@implementation InfoDatabase
static InfoDatabase *infoDB = nil;

/**
 InfoDatabase初期化

 @return InfoDatabase
 */
+ (instancetype)shareInfoDatabase{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        infoDB = [[InfoDatabase alloc] init];
    });
    return infoDB;
}

// 
- (NSString *)getErrorStringWithErrorCode:(NSString *)errorCode{
    NSString *errorString = [NSString new];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Code.plist" ofType:nil];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSDictionary *errorDic = [NSDictionary dictionaryWithDictionary:dic[@"errorCode"]];
    NSArray *a = [NSArray arrayWithArray:errorDic[errorCode]];
    errorString = [NSString stringWithFormat:@"%@", a[0]];
    return errorString;
}
@end

@implementation IDENTIFICATION_DATA
@end

@implementation CONFIG_FILE_DATA
@end

@implementation EVENT_LOG
@end
