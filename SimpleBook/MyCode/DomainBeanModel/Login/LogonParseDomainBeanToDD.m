//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "LogonParseDomainBeanToDD.h"

#import "LogonDatabaseFieldsConstant.h"
#import "LogonNetRequestBean.h"




@implementation LogonParseDomainBeanToDD

- (id) init {
	
	if ((self = [super init])) {
		PRPLog(@"init [0x%x]", [self hash]);
    
	}
	
	return self;
}

- (NSDictionary *) parseDomainBeanToDataDictionary:(in id) netRequestDomainBean {
  RNAssert(netRequestDomainBean != nil, @"入参为空 !");
  
  do {
    if (! [netRequestDomainBean isMemberOfClass:[LogonNetRequestBean class]]) {
      RNAssert(NO, @"传入的业务Bean的类型不符 !");
      break;
    }
    
    const LogonNetRequestBean *requestBean = netRequestDomainBean;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
		
		NSString *value = nil;
		
		//
		value = requestBean.username;
		if ([NSString isEmpty:value]) {
      RNAssert(NO, @"丢失关键参数 : username");
      break;
		}
		[params setObject:value forKey:k_Login_RequestKey_username];
    //
    value = requestBean.password;
		if ([NSString isEmpty:value]) {
      RNAssert(NO, @"丢失关键参数 : password");
      break;
		}
    [params setObject:value forKey:k_Login_RequestKey_password];
    
    return params;
  } while (NO);
  
  return nil;
}
@end