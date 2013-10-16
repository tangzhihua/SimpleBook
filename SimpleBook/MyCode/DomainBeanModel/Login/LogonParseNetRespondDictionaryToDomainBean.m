//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "LogonParseNetRespondDictionaryToDomainBean.h"

#import "LogonDatabaseFieldsConstant.h"
#import "LogonNetRespondBean.h"

#import "NSString+isEmpty.h"
#import "NSDictionary+SafeValue.h"
#import "NSDictionary+Helper.h"

#import "TBXML.h"
#import "TBXML+NSDictionary.h"

static const NSString *const TAG = @"<LogonParseNetRespondStringToDomainBean>";

@implementation LogonParseNetRespondDictionaryToDomainBean
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
   	
    NSDictionary *response = [netRespondDictionary objectForKey:k_Login_RespondKey_response];
    if (![response isKindOfClass:[NSDictionary class]]) {
      break;
    }
    NSNumber *validate = [response objectForKey:k_Login_RespondKey_validate];
    if ([validate boolValue]) {
      return [[LogonNetRespondBean alloc] init];
    } else {
      NetRequestErrorBean *serverRespondDataError = [[NetRequestErrorBean alloc] init];
      serverRespondDataError.errorCode = -1;
      
      NSString *errorMessage = [response objectForKey:k_Login_RespondKey_error];
      serverRespondDataError.message = errorMessage;
      return serverRespondDataError;
    }
  } while (NO);
  
  return nil;
}

@end