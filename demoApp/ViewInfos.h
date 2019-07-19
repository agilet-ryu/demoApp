//
//  ViewInfos.h
//  demoApp
//
//  Created by tourituyou on 2019/7/16.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ButtonType) {
    buttonTypeBorder,
    buttonTypeNoBorder,
};
@interface ViewInfo : NSObject
@property (nonatomic, strong) NSString *viewID;
@property (nonatomic, assign) float progressValue;
@property (nonatomic, strong) NSString *viewTitle;
@property (nonatomic, strong) NSString *detailString;
@property (nonatomic, assign) BOOL detailHidden;
@property (nonatomic, assign) ButtonType buttonType;
@end

@interface ViewInfos : NSObject
@end

NS_ASSUME_NONNULL_END
