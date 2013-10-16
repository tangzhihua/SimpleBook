//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import <Foundation/Foundation.h>
#import "INetEntityDataTools.h"

@interface NetEntityDataToolsFactoryMethodSingleton : NSObject <INetEntityDataTools> {
  
}

+ (NetEntityDataToolsFactoryMethodSingleton *) sharedInstance;

@end
