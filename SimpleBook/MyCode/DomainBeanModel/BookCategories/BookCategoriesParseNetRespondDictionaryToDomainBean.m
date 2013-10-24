//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "BookCategoriesParseNetRespondDictionaryToDomainBean.h"

#import "BookCategoriesDatabaseFieldsConstant.h"
#import "BookCategoriesNetRespondBean.h"

#import "NSString+isEmpty.h"

#import "TBXML.h"
#import "TBXML+NSDictionary.h"

static const NSString *const TAG = @"<BookCategoriesParseNetRespondDictionaryToDomainBean>";

@implementation BookCategoriesParseNetRespondDictionaryToDomainBean
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
   	
    return [[BookCategoriesNetRespondBean alloc] initWithDictionary:netRespondDictionary];
  } while (NO);
  
  return nil;
}

@end