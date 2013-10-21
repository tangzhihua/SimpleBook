//
//  IHttpEngine.h
//  SimpleBook
//
//  Created by 唐志华 on 13-10-21.
//  Copyright (c) 2013年 唐志华. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^IHttpEngineNetRespondHandleInUIThreadSuccessedBlock)(NSOperation *operation, NSData *responseData);
typedef void (^IHttpEngineNetRespondHandleInUIThreadFailedBlock)(NSOperation *operation, NSError *error);

@protocol IHttpEngine <NSObject>
@required
- (NSOperation *) operationWithURLString:(in NSString *)urlString
                    netRequestDomainBean:(in id)netRequestDomainBean
                                 headers:(in NSDictionary *)headers
                                  params:(in NSDictionary *)body
                              httpMethod:(in NSString *)method
                          successedBlock:(in IHttpEngineNetRespondHandleInUIThreadSuccessedBlock)successedBlock
                             failedBlock:(in IHttpEngineNetRespondHandleInUIThreadFailedBlock)failedBlock;
@end
