//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "GetBookDownloadUrlParseNetRespondDictionaryToDomainBean.h"

#import "GetBookDownloadUrlDatabaseFieldsConstant.h"
#import "GetBookDownloadUrlNetRespondBean.h"

#import "NSString+isEmpty.h"
#import "NSDictionary+SafeValue.h"
#import "NSDictionary+Helper.h"

#import "TBXML.h"
#import "TBXML+NSDictionary.h"

static const NSString *const TAG = @"<GetBookDownloadUrlParseNetRespondStringToDomainBean>";

@implementation GetBookDownloadUrlParseNetRespondDictionaryToDomainBean
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
   	
    NSDictionary *content = [netRespondDictionary objectForKey:k_GetBookDownloadUrl_RespondKey_content];
    if (![content isKindOfClass:[NSDictionary class]]) {
      break;
    }
    NSNumber *validate = [content objectForKey:k_GetBookDownloadUrl_RespondKey_validate];
    if ([validate boolValue]) {
      NSString *bookDownloadUrl = [content objectForKey:k_GetBookDownloadUrl_RespondKey_url];
      return [[GetBookDownloadUrlNetRespondBean alloc] initWithBookDownloadUrl:bookDownloadUrl];
    } else {
      NetRequestErrorBean *serverRespondDataError = [[NetRequestErrorBean alloc] init];
      serverRespondDataError.errorCode = -1;
      
      NSString *errorMessage = @"URL地址无效.";
      serverRespondDataError.message = errorMessage;
      return serverRespondDataError;
    }
    
  } while (NO);
  
  return nil;
}

@end