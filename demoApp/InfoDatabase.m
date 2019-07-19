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
@end

@implementation IDENTIFICATION_DATA
@end

@implementation CONFIG_FILE_DATA
@end

@implementation EVENT_LOG
@end
