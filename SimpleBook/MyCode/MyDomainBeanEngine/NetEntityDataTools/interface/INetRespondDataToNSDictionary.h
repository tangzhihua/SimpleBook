//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import <Foundation/Foundation.h>

/**
 * 将网络响应数据转成 NSDictionary 数据
 * @author zhihua.tang
 *
 */
@protocol INetRespondDataToNSDictionary <NSObject>
- (NSDictionary *) netRespondDataToNSDictionary:(in NSString *)serverRespondDataOfUTF8String;
@end
