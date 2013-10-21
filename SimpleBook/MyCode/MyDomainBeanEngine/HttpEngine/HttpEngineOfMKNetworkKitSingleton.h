//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import <Foundation/Foundation.h>
#import "IHttpEngine.h"


@interface HttpEngineOfMKNetworkKitSingleton : NSObject <IHttpEngine> {
  
}


+ (id<IHttpEngine>) sharedInstance;

@end
