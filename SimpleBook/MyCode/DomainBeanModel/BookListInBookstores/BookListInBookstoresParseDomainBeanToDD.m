//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "BookListInBookstoresParseDomainBeanToDD.h"

#import "BookListInBookstoresDatabaseFieldsConstant.h"
#import "BookListInBookstoresNetRequestBean.h"




@implementation BookListInBookstoresParseDomainBeanToDD

- (id) init {
	
	if ((self = [super init])) {
		PRPLog(@"init [0x%x]", [self hash]);
    
	}
	
	return self;
}

- (NSDictionary *) parseDomainBeanToDataDictionary:(in id) netRequestDomainBean {
  RNAssert(netRequestDomainBean != nil, @"入参为空 !");
  
  do {
    if (! [netRequestDomainBean isMemberOfClass:[BookListInBookstoresNetRequestBean class]]) {
      RNAssert(NO, @"传入的业务Bean的类型不符 !");
      break;
    }
    
    const BookListInBookstoresNetRequestBean *requestBean = netRequestDomainBean;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
		
		NSString *value = nil;
		
		//
		value = requestBean.category_id;
		if (![NSString isEmpty:value]) {
      [params setObject:value forKey:k_BookListInBookstores_RequestKey_category_id];
		}
    
    return params;
  } while (NO);
  
  return nil;
}
@end