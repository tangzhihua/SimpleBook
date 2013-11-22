//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "BookSearchDomainBeanToolsFactory.h"

#import "UrlConstantForThisProject.h"
#import "BookListInBookstoresParseNetRespondDictionaryToDomainBean.h"
#import "BookSearchParseDomainBeanToDD.h"
#import "BookListInBookstoresNetRespondBean.h"

@implementation BookSearchDomainBeanToolsFactory
- (id) init {
	
	if ((self = [super init])) {
		NSLog(@"init [0x%x]", [self hash]);
    
	}
	
	return self;
}

/**
 * 将当前业务Bean, 解析成跟后台数据接口对应的数据字典
 * @return
 */
- (id<IParseDomainBeanToDataDictionary>) getParseDomainBeanToDDStrategy {
  return [[BookSearchParseDomainBeanToDD alloc] init];
}

/**
 * 将网络返回的数据字典, 解析成当前业务Bean
 * @return
 */
- (id<IParseNetRespondDictionaryToDomainBean>) getParseNetRespondDictionaryToDomainBeanStrategy {
  return [[BookListInBookstoresParseNetRespondDictionaryToDomainBean alloc] init];
}

/**
 * 当前业务Bean, 对应的URL地址.
 * @return
 */
- (NSString *) getSpecialPath {
  return kUrlConstant_SpecialPath_book_query;
}

/**
 * 当前网络响应业务Bean的Class
 * @return
 */
- (Class) getClassOfNetRespondBean {
  return [BookListInBookstoresNetRespondBean class];
}
@end