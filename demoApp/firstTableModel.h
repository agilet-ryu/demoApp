//
//  firstTableModel.h
//  demoApp
//
//  Created by agilet on 2019/06/17.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface firstTableModel : NSObject
@property (copy, nonatomic) NSString *buttonTitle;
@property (assign, nonatomic) BOOL isSelected;
@property (copy, nonatomic) NSString *frontImagePath;
@property (copy, nonatomic) NSString *behindImagePath;
@property (copy, nonatomic) NSString *htmlPath;
@property (nonatomic, strong) UIImage *frontImage;
@property (nonatomic, strong) UIImage *behindImage;

-(firstTableModel *)initWithTitle:(NSString *)title frontImagePath:(NSString *)frontImagePath behindImagePath:(NSString *)behindImagePath isSelected:(BOOL)isSelected;

@end

NS_ASSUME_NONNULL_END
