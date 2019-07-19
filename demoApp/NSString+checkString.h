//
//  NSString+checkString.h
//  demoApp
//
//  Created by tourituyou on 2019/7/8.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (checkString)
+ (BOOL)isBlankString:(NSString *)aStr;
/**< 加密方法 */
- (NSString*)aci_encryptWithAES;

/**< 解密方法 */
- (NSString*)aci_decryptWithAES;
@end

NS_ASSUME_NONNULL_END
