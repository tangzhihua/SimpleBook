//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

// 只针对 企业用户, 公共账户 不会需要创建当前模型
@interface LogonNetRespondBean : BaseModel
 
// 用户名
@property (nonatomic, copy) NSString *username;
// 密码
@property (nonatomic, copy) NSString *password;


@end
