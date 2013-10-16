//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "NetRequestEntityDataPackageForDreamBook.h"


#import "MacroConstantForThisProject.h"

static const NSString *const TAG = @"<NetRequestEntityDataPackageForDreamBook>";

@implementation NetRequestEntityDataPackageForDreamBook
- (id) init {
	
	if ((self = [super init])) {
		NSLog(@"init %@ [0x%x]", TAG, [self hash]);
    
	}
	
	return self;
}

#pragma mark 实现 INetRequestEntityDataPackage 接口方法
- (NSData *) packageNetRequestEntityDataWithDomainDataDictionary:(in NSDictionary *) domainDD {
  
  if ([domainDD count] <= 0) {
    // 入参为空
    return nil;
  }
  
  // 这里只是演示 NSEnumerator 如何使用, 上面 AFQueryStringFromParameters 方法才是更好的
  NSEnumerator *keyEnumerator = [domainDD keyEnumerator];
  NSString *key = [keyEnumerator nextObject];
  NSMutableString *entityDataString = [NSMutableString string];
  while (key != nil) {
    NSString *value = [domainDD objectForKey:key];
    if ([value length] > 0) {
      [entityDataString appendFormat:@"%@=%@", key, value];
    }
    
    key = [keyEnumerator nextObject];
    if (key != nil) {
      [entityDataString appendString:@"&"];
    }
  }
  
  PRPLog(@"packageNetRequestEntityData-> %@", entityDataString);
  
  return [entityDataString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
  
  
	
	return nil;
}
@end
