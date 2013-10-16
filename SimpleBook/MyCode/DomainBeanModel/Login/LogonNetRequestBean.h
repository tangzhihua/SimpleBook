//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import <Foundation/Foundation.h>

@interface LogonNetRequestBean : NSObject {
  
}

// 用户名 必填
@property (nonatomic, readonly, strong) NSString *username;
// 密码 必填
@property (nonatomic, readonly, strong) NSString *password;

#pragma mark -
#pragma mark 构造方法
- (id) initWithUsername:(NSString *)username password:(NSString *)password;

@end
