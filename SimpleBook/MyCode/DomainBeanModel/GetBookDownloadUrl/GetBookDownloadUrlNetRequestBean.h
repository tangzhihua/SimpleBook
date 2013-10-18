//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import <Foundation/Foundation.h>

@class LogonNetRespondBean;
@interface GetBookDownloadUrlNetRequestBean : NSObject {
  
}

// 要下载的书籍ID 必填
@property (nonatomic, readonly, copy) NSString *contentId;
// 需要付费的书籍, 在付费后得到的收据
@property (nonatomic, copy) NSData *receipt;
// 跟要下载的书籍绑定的账号, 这里是服务器端做的安全策略, 要检测跟目标书籍绑定的账号是否有下载权限.
@property (nonatomic, readonly, strong) LogonNetRespondBean *bindAccount;

#pragma mark -
#pragma mark 构造方法
- (id) initWithContentId:(NSString *)contentId bindAccount:(LogonNetRespondBean *)bindAccount;

@end
