//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "NetRespondDataToNSDictionaryForDreamBook.h"

#import "TBXML.h"
#import "TBXML+NSDictionary.h"

@implementation NetRespondDataToNSDictionaryForDreamBook
- (NSDictionary *) netRespondDataToNSDictionary:(in NSString *)serverRespondDataOfUTF8String {
  do {
    if ([NSString isEmpty:serverRespondDataOfUTF8String]) {
      NSLog(@"入参 serverRespondDataOfUTF8String 为空 !");
      break;
    }
    
    NSError *error = nil;
    NSDictionary *xmlRootNSDictionary = [TBXML dictionaryWithXMLString:serverRespondDataOfUTF8String error:&error];
    
    if (![xmlRootNSDictionary isKindOfClass:[NSDictionary class]]) {
      NSLog(@"xml 解析失败!-->serverRespondDataOfUTF8String = %@ ", serverRespondDataOfUTF8String);
      break;
    }
    
		return xmlRootNSDictionary;
	} while (NO);
  
  return nil;
}
@end
