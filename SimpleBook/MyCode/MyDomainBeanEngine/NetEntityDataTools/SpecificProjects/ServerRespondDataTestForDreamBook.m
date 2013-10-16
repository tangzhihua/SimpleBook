//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "ServerRespondDataTestForDreamBook.h"
#import "NetRequestErrorBean.h"
#import "NSDictionary+SafeValue.h"
#import "TBXML.h"
#import "TBXML+NSDictionary.h"
#import "NSDictionary+Helper.h"

@implementation ServerRespondDataTestForDreamBook
#pragma mark 实现 IServerRespondDataTest 接口
- (NetRequestErrorBean *) testServerRespondDataIsValid:(in NSString *)serverRespondDataOfUTF8String {
  NSInteger errorCode = 200;
  NSString *errorMessage = @"OK";
  
  NSError *error = nil;
  
  NSDictionary *xmlDataNSDictionary = [TBXML dictionaryWithXMLString:serverRespondDataOfUTF8String error:&error];
  NSDictionary *response = [xmlDataNSDictionary objectForKey:@"response"];
  if ([response isKindOfClass:[NSDictionary class]]) {
    NSNumber *validate = [response objectForKey:@"validate"];
    if (![validate boolValue]) {
      errorCode = -1;
      errorMessage = [response objectForKey:@"error"];
    }
  }
  

  
  // TODO : 目前后台接口没有统一错误提示, 如出错时, 可以返回 errorCode 和 errorMessage .
  // 暂时这里先不实现, 等后台修改接口时, 在做处理.
  
  NetRequestErrorBean *netError = [[NetRequestErrorBean alloc] init];
  netError.errorCode = errorCode;
  netError.message = errorMessage;
  return netError;
  
}
@end
