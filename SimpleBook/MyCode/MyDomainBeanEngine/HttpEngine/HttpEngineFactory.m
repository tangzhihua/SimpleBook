//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "HttpEngineFactory.h"

#import "HttpEngineOfMKNetworkKitSingleton.h"

@implementation HttpEngineFactory
+ (id<IHttpEngine>) getHttpEngine {
  return [HttpEngineOfMKNetworkKitSingleton sharedInstance];
}
@end
