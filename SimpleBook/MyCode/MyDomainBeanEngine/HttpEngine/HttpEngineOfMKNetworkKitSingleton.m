//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "HttpEngineOfMKNetworkKitSingleton.h"

#import "MKNetworkKit.h"
#import "MKNetworkOperationForDomainBean.h"
//
#import "GetBookDownloadUrlNetRequestBean.h"
//
#import "GTMBase64.h"

@interface HttpEngineOfMKNetworkKitSingleton()

// 网络引擎
@property (nonatomic, strong) MKNetworkEngine *networkEngine;

@end

@implementation HttpEngineOfMKNetworkKitSingleton

#pragma mark -
#pragma mark Singleton Implementation

// 使用 Grand Central Dispatch (GCD) 来实现单例, 这样编写方便, 速度快, 而且线程安全.
-(id)init {
  // 禁止调用 -init 或 +new
  RNAssert(NO, @"Cannot create instance of Singleton");
  
  // 在这里, 你可以返回nil 或 [self initSingleton], 由你来决定是返回 nil还是返回 [self initSingleton]
  return nil;
}

// 真正的(私有)init方法
-(id)initSingleton {
  self = [super init];
  if ((self = [super init])) {
    // 初始化代码
    
    _networkEngine = [[MKNetworkEngine alloc] initWithHostName:kUrlConstant_MainUrl apiPath:kUrlConstant_MainPtah customHeaderFields:nil];
    [_networkEngine registerOperationSubclass:[MKNetworkOperationForDomainBean class]];
    [_networkEngine useCache];
    
  }
  
  return self;
}

+ (id<IHttpEngine>) sharedInstance {
  static HttpEngineOfMKNetworkKitSingleton *singletonInstance = nil;
  static dispatch_once_t pred;
  dispatch_once(&pred, ^{singletonInstance = [[self alloc] initSingleton];});
  return singletonInstance;
}


#pragma mark -
#pragma mark 实现 IHttpEngine 协议
- (NSOperation *) operationWithURLString:(in NSString *)urlString
                    netRequestDomainBean:(in id)netRequestDomainBean
                                 headers:(in NSDictionary *)headers
                                  params:(in NSDictionary *)body
                              httpMethod:(in NSString *)method
                          successedBlock:(in IHttpEngineNetRespondHandleInUIThreadSuccessedBlock)successedBlock
                             failedBlock:(in IHttpEngineNetRespondHandleInUIThreadFailedBlock)failedBlock {
  
  // 为获取要下载的书籍的URL这个接口特殊做的处理, 因为这个接口的URL是直接拼接成的
  {
    if ([netRequestDomainBean isKindOfClass:[GetBookDownloadUrlNetRequestBean class]]) {
      urlString = [NSString stringWithFormat:@"%@%@", urlString, ((GetBookDownloadUrlNetRequestBean *)netRequestDomainBean).contentId];
      if (((GetBookDownloadUrlNetRequestBean *)netRequestDomainBean).receipt != nil) {
        method = @"POST";
        headers = [NSMutableDictionary dictionary];
        [(NSMutableDictionary *)headers setObject:((GetBookDownloadUrlNetRequestBean *)netRequestDomainBean).receipt forKey:@""];
      } else {
        method = @"GET";
      }
    }
  }
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  
  MKNetworkOperationForDomainBean *netRequestOperation
  = (MKNetworkOperationForDomainBean *)[self.networkEngine operationWithURLString:urlString params:body httpMethod:method];
  // 设置 "当证书无效时, 也要继续网络访问" 标志位
  // TODO : 目前服务器就是这样配置的, 否则会发生 401错误, SSL -1202
  [netRequestOperation setShouldContinueWithInvalidCertificate:YES];
  [netRequestOperation addHeaders:headers];
  
  
  
  {
    // 为获取要下载的书籍的URL这个接口特殊做的处理, 因为这个接口的URL是直接拼接成的
    if ([netRequestDomainBean isKindOfClass:[GetBookDownloadUrlNetRequestBean class]]) {
      // 这是对, 需要付费下载的书籍的处理, 这样的书籍在付费过后, 当进行了暂停操作时, 回复下载时, 就不要再走付费检测流程了.
      // 所以这里跟服务器定好协议, 如果服务器收到了有 Paid头的请求, 就证明已经付费了, 就不需要判断 receipt(收据了)
      if (((GetBookDownloadUrlNetRequestBean *)netRequestDomainBean).receipt == nil) {
        // @"Paid" 这个头是支付所必须的.
        [netRequestOperation addHeaders:@{@"Paid": @"Paid"}];
      }
      //
      [netRequestOperation setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
        return [GTMBase64 stringByEncodingData:((GetBookDownloadUrlNetRequestBean *)netRequestDomainBean).receipt];
      } forType:nil];
    }
  }
  
  [netRequestOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
    
    NSData *netRawEntityData = [completedOperation responseData];
    successedBlock(completedOperation, netRawEntityData);
  } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
    
    failedBlock(completedOperation, error);
    
  }];
  
  [self.networkEngine enqueueOperation:netRequestOperation];
  return netRequestOperation;
}

@end
