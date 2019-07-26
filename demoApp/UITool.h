//
//  UITool.h
//  demoApp
//
//  Created by agilet on 2019/06/18.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIColor+hexString.h"
#import "ShadowButton.h"
#define kBaseColor [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0f]
#define kBaseColorUnEnabled [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:0.3f]
#define kBodyTextColor [UIColor colorWithHexString:[UITool shareUITool].bodyTextColorHexString alpha:1.0f]
#define kLineColor [UIColor colorWithHexString:[UITool shareUITool].lineColorHexString alpha:1.0f]
NS_ASSUME_NONNULL_BEGIN

@interface UITool : NSObject

+ (instancetype)shareUITool;

@property (nonatomic, copy) NSString *baseColorHexString;
@property (nonatomic, copy) NSString *baseTextColorHexString;
@property (nonatomic, copy) NSString *headerColorHexString;
@property (nonatomic, copy) NSString *bodyColorHexString;
@property (nonatomic, copy) NSString *headerTextColorHexString;
@property (nonatomic, copy, readonly) NSString *lineColorHexString;
@property (nonatomic, copy, readonly) NSString *bodyTextColorHexString;
@property (nonatomic, copy, readonly) NSString *inputTextColorHexString;
@property (nonatomic, assign, readonly) CGFloat textSizeLarge;
@property (nonatomic, assign, readonly) CGFloat textSizeMedium;
@property (nonatomic, assign, readonly) CGFloat textSizeSmall;
@property (nonatomic, assign, readonly) CGFloat textSizeMicro;
@property (nonatomic, assign, readonly) CGFloat lineWidth;

-(CGFloat)heightWithWidth:(CGFloat)width font:(CGFloat)font str:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
