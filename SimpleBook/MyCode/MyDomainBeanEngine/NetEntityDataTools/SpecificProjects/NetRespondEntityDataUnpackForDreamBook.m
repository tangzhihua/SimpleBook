//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "NetRespondEntityDataUnpackForDreamBook.h"

 
#import "MacroConstantForThisProject.h"


 
static const NSString *const TAG = @"<NetRespondEntityDataUnpackDreamBook>";

@implementation NetRespondEntityDataUnpackForDreamBook
- (id) init {
	
	if ((self = [super init])) {
     
		NSLog(@"init %@ [0x%x]", TAG, [self hash]);
    
	}
	
	return self;
}

#pragma mark 实现 INetRespondRawEntityDataUnpack 接口
- (NSString *) unpackNetRespondRawEntityDataToUTF8String:(in NSData *) rawData {
  do {
    if (![rawData isKindOfClass:[NSData class]] || rawData.length <= 0) {
      // 入参异常
      break;
    }
    
     
    // 将 "原生数据" 转成 "UTF-8字符串"
    NSString *stringOfUTF8 = [[NSString alloc] initWithData:rawData encoding:NSUTF8StringEncoding];
    if (![stringOfUTF8 isKindOfClass:[NSString class]] || stringOfUTF8.length <= 0) {
      // 
      break;
    }
    return stringOfUTF8;
  } while (NO);
  
  
  // 出现错误
  return @"";
}
@end