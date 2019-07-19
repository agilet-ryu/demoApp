//
//  firstTableModel.m
//  demoApp
//
//  Created by agilet on 2019/06/17.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "firstTableModel.h"

@implementation firstTableModel
-(firstTableModel *)initWithTitle:(NSString *)title frontImagePath:(NSString *)frontImagePath behindImagePath:(NSString *)behindImagePath isSelected:(BOOL)isSelected{
    self = [super init];
    if (self) {
        self.buttonTitle = title;
        self.frontImagePath = frontImagePath;
        self.behindImagePath = behindImagePath;
        self.isSelected = isSelected;
        self.htmlPath = [NSString stringWithFormat:@"%@", [self getHtmlPathString:title]];
    }
    return self;
}

- (NSString *)getHtmlPathString: (NSString *)titleStr {
    NSString *pathStr;
    if ([titleStr isEqualToString:@"運転免許証"]) {
        pathStr = [[NSBundle mainBundle] pathForResource:@"dl" ofType:@"html"];;
    } else if ([titleStr isEqualToString:@"マイナンバーカード"]){
        pathStr = [[NSBundle mainBundle] pathForResource:@"cardinfo" ofType:@"html"];
    } else if ([titleStr isEqualToString:@"パスポート"]){
        pathStr = [[NSBundle mainBundle] pathForResource:@"ep" ofType:@"html"];
    } else {
        pathStr = [[NSBundle mainBundle] pathForResource:@"show_cert" ofType:@"html"];
    }
    return pathStr;
}
//-(void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [aCoder encodeObject:self.buttonTitle forKey:@"title"];
//    [aCoder encodeObject:self.frontImagePath forKey:@"frontImagePath"];
//    [aCoder encodeObject:self.behindImagePath forKey:@"behindImagePath"];
//    [aCoder encodeObject:self.isSelected forKey:@"isSelected"];
//}
//
//- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder // NS_DESIGNATED_INITIALIZER
//{
//    if (self = [super init]) {
//        self.buttonTitle = [aDecoder decodeObjectForKey:@"title"] ;
//        self.frontImagePath = [aDecoder decodeObjectForKey:@"frontImagePath"];
//    }
//    return self;
//}

@end
