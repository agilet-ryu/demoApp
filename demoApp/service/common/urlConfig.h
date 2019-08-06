//
//  urlConfig.h
//  demoApp
//
//  Created by agilet-ryu on 2019/7/31.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#ifndef urlConfig_h
#define urlConfig_h

#define kMGFaceIDNetworkHost @"https://api-sgp.megvii.com"
#define kURLGetFaceIDToken [NSString stringWithFormat:@"%@/faceid/v3/sdk/get_biz_token", kMGFaceIDNetworkHost]
#define kURLSendUserInformation @"http://192.168.3.28:8080/saveData?dataInfo="
#define kURLSendLog @"http://192.168.3.28:8080/saveData?dataInfo="

#endif /* urlConfig_h */
