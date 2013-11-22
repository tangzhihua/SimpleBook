//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "BookListInBookstoresParseNetRespondDictionaryToDomainBean.h"

#import "BookListInBookstoresDatabaseFieldsConstant.h"
#import "BookListInBookstoresNetRespondBean.h"

#import "NSString+isEmpty.h"

#import "TBXML.h"
#import "TBXML+NSDictionary.h"

static const NSString *const TAG = @"<BookListInBookstoresParseNetRespondStringToDomainBean>";

@implementation BookListInBookstoresParseNetRespondDictionaryToDomainBean
- (id) init {
	
	if ((self = [super init])) {
		PRPLog(@"init %@ [0x%x]", TAG, [self hash]);
    
	}
	
	return self;
}

#pragma mark 实现 IParseNetRespondStringToDomainBean 接口
- (id) parseNetRespondDictionaryToDomainBean:(in NSDictionary *) netRespondDictionary {
  do {
    if (![netRespondDictionary isKindOfClass:[NSDictionary class]]) {
      RNAssert(NO, @"入参 netRespondDictionary 类型不正确.");
      break;
    }
   	
    BookListInBookstoresNetRespondBean *netRespondBean = [[BookListInBookstoresNetRespondBean alloc] initWithDictionary:netRespondDictionary];
    if (netRespondBean.bookInfoList.count <= 0) {
      PRPLog(@"服务器没有返回任何有效的书籍.");
      break;
    }
    
    return netRespondBean;
  } while (NO);
  
  return nil;
}

@end