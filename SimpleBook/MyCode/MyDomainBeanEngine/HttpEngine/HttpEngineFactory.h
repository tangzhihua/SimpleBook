//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import <Foundation/Foundation.h>

// 用于间接创建一个HTTP引擎
@protocol IHttpEngine;
@interface HttpEngineFactory : NSObject
+ (id<IHttpEngine>) getHttpEngine;
@end
