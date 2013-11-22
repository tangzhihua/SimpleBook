//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "BookSearchParseDomainBeanToDD.h"

#import "BookSearchDatabaseFieldsConstant.h"
#import "BookSearchNetRequestBean.h"




@implementation BookSearchParseDomainBeanToDD

- (id) init {
	
	if ((self = [super init])) {
		PRPLog(@"init [0x%x]", [self hash]);
    
	}
	
	return self;
}

- (NSDictionary *) parseDomainBeanToDataDictionary:(in id) netRequestDomainBean {
  RNAssert(netRequestDomainBean != nil, @"入参为空 !");
  
  do {
    if (! [netRequestDomainBean isMemberOfClass:[BookSearchNetRequestBean class]]) {
      RNAssert(NO, @"传入的业务Bean的类型不符 !");
      break;
    }
    
    const BookSearchNetRequestBean *requestBean = netRequestDomainBean;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
		
		NSString *value = nil;
		
		//
		value = requestBean.search;
		if (![NSString isEmpty:value]) {
      [params setObject:value forKey:k_BookSearch_RequestKey_search];
		}
    
    return params;
  } while (NO);
  
  return nil;
}
@end