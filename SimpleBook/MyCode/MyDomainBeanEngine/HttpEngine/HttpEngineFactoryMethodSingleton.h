//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import <Foundation/Foundation.h>

@protocol IHttpEngine;
@interface HttpEngineFactoryMethodSingleton : NSObject {
  
}


+ (HttpEngineFactoryMethodSingleton *) sharedInstance;

@property (nonatomic, readonly, strong) id<IHttpEngine> httpEngine;
@end
