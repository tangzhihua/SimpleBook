//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "GetBookDownloadUrlParseDomainBeanToDD.h"

#import "GetBookDownloadUrlDatabaseFieldsConstant.h"
#import "GetBookDownloadUrlNetRequestBean.h"
#import "LogonNetRespondBean.h"



@implementation GetBookDownloadUrlParseDomainBeanToDD

- (id) init {
	
	if ((self = [super init])) {
		PRPLog(@"init [0x%x]", [self hash]);
    
	}
	
	return self;
}

- (NSDictionary *) parseDomainBeanToDataDictionary:(in id) netRequestDomainBean {
  RNAssert(netRequestDomainBean != nil, @"入参为空 !");
  
  do {
    if (! [netRequestDomainBean isMemberOfClass:[GetBookDownloadUrlNetRequestBean class]]) {
      RNAssert(NO, @"传入的业务Bean的类型不符 !");
      break;
    }
    
    const GetBookDownloadUrlNetRequestBean *requestBean = netRequestDomainBean;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
		
		NSString *value = nil;
		
		//
		value = requestBean.contentId;
		if ([NSString isEmpty:value]) {
      RNAssert(NO, @"丢失关键参数 : username");
      break;
		}
		[params setObject:value forKey:k_GetBookDownloadUrl_RequestKey_contentId];
    
    // 跟要下载的书籍绑定的账号, 这里是服务器端做的安全策略, 要检测跟目标书籍绑定的账号是否有下载权限.
    LogonNetRespondBean *bindAccount = requestBean.bindAccount;
		if (![bindAccount isKindOfClass:[LogonNetRespondBean class]]) {
      RNAssert(NO, @"丢失关键参数 : bindAccount");
      break;
		}
		[params setObject:bindAccount.username forKey:k_GetBookDownloadUrl_RequestKey_username];
    [params setObject:bindAccount.password forKey:k_GetBookDownloadUrl_RequestKey_password];
    return params;
  } while (NO);
  
  return nil;
}
@end