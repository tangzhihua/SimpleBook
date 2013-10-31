//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "DomainBeanNetworkEngineSingleton.h"

#import "IDomainBeanAbstractFactory.h"
#import "IParseDomainBeanToDataDictionary.h"
#import "DomainBeanAbstractFactoryCacheSingleton.h"
#import "NetEntityDataToolsFactoryMethodSingleton.h"
#import "INetRequestEntityDataPackage.h"

#import "SimpleCookieSingleton.h"
#import "INetRespondRawEntityDataUnpack.h"
#import "NetEntityDataToolsFactoryMethodSingleton.h"
#import "IServerRespondDataTest.h"
#import "IParseNetRespondDictionaryToDomainBean.h"
#import "INetRespondDataToNSDictionary.h"
#import "BaseModel.h"

#import "UrlConstantForThisProject.h"
#import "NetRequestErrorBean.h"
#import "IHttpEngine.h"
#import "HttpEngineFactory.h"


@interface DomainBeanNetworkEngineSingleton()

// 当前在并发请求的 MKNetworkOperation 队列
@property (atomic, strong) NSMutableDictionary *synchronousNetRequestBuf;
// 网络请求索引 计数器
@property (atomic, assign) NSInteger netRequestIndexCounter;
@end


@implementation DomainBeanNetworkEngineSingleton

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
		_synchronousNetRequestBuf = [NSMutableDictionary dictionary];
		_netRequestIndexCounter = 0;
  }
  
  return self;
}

+ (DomainBeanNetworkEngineSingleton *) sharedInstance {
  static DomainBeanNetworkEngineSingleton *singletonInstance = nil;
  static dispatch_once_t pred;
  dispatch_once(&pred, ^{singletonInstance = [[self alloc] initSingleton];});
  return singletonInstance;
}


#pragma mark -
#pragma mark 对外公开的方法

- (void) requestDomainProtocolWithRequestDomainBean:(in id) netRequestDomainBean
                        currentNetRequestIndexToOut:(out NSInteger *) pCurrentNetRequestIndexToOut
                                     successedBlock:(DomainNetRespondHandleInUIThreadSuccessedBlock) successedBlock
                                        failedBlock:(DomainNetRespondHandleInUIThreadFailedBlock) failedBlock {
  
	const NSInteger netRequestIndex = ++_netRequestIndexCounter;
	
	NSLog(@" ");
	NSLog(@" ");
	NSLog(@" ");
	NSLog(@"%@%i%@", @"<<<<<<<<<<     Request a domain protocol begin (" , netRequestIndex , @")     >>>>>>>>>>");
	NSLog(@" ");
	
	do {
		if (netRequestDomainBean == nil || pCurrentNetRequestIndexToOut == NULL || successedBlock == NULL || failedBlock == NULL) {
			RNAssert(NO, @"入参为空.");
			break;
		}
		
		// 将 "网络请求业务Bean" 的 完整class name 作为和这个业务Bean对应的"业务接口" 绑定的所有相关的处理算法的唯一识别Key
		NSString *abstractFactoryMappingKey = NSStringFromClass([netRequestDomainBean class]);
		NSLog(@"%@%i", @"request index--> ", netRequestIndex);
		NSLog(@"%@%@", @"abstractFactoryMappingKey--> ", abstractFactoryMappingKey);
		
		// 这里的设计使用了 "抽象工厂" 设计模式
		id<IDomainBeanAbstractFactory> domainBeanAbstractFactoryObject = [[DomainBeanAbstractFactoryCacheSingleton sharedInstance] getDomainBeanAbstractFactoryObjectByKey:abstractFactoryMappingKey];
		if (![domainBeanAbstractFactoryObject conformsToProtocol:@protocol(IDomainBeanAbstractFactory)]) {
			RNAssert(NO, @"必须实现 IDomainBeanAbstractFactory 接口");
			break;
		}
		
		// 获取当前业务网络接口, 对应的URL
		// 组成说明 : MainUrl(http://124.65.163.102:819) + MainPtah(/app) + SpecialPath(/....)
		// url = [NSString stringWithFormat:@"%@%@%@", kUrlConstant_MainUrl, kUrlConstant_MainPtah, url];
    // TODO
    // 当前可用的主机名(因为目前https网站还未配置完成, 所以临时还使用 https://61.177.139.215:8443 这个地址, 但是会判断https://dreambook.retechcorp.com 是否可用.
    // 这里的设计是临时存在的, 将来还是要固定使用 https://dreambook.retechcorp.com
		NSString *url = [NSString stringWithFormat:@"%@/%@/%@", kUrlConstant_MainUrl, kUrlConstant_MainPtah, [domainBeanAbstractFactoryObject getSpecialPath]];
		NSLog(@"url-->%@", url);
		
		// HTTP 请求方法类型, 默认是GET
		NSString *httpRequestMethod = @"GET";
		
    // 完整的 "数据字典"
    NSMutableDictionary *fullDataDictionary = nil;
    
		/**
		 * 处理HTTP 请求实体数据, 如果有实体数据的话, 就设置 RequestMethod 为 "POST" 目前POST 和 GET的认定标准是, 有附加参数就使用POST, 没有就使用GET(这里要跟后台开发团队事先约定好)
		 */
		id<IParseDomainBeanToDataDictionary> parseDomainBeanToDataDictionary = [domainBeanAbstractFactoryObject getParseDomainBeanToDDStrategy];
		
		do {
			if (![parseDomainBeanToDataDictionary conformsToProtocol:@protocol(IParseDomainBeanToDataDictionary)]) {
				// 没有额外的数据需要上传服务器
				break;
			}
			
			/**
			 * 如果我们的接口中有固定的参数, 那么我们可以在这里将固定的参数加入
			 */
			NSDictionary *publicDD = nil;//[GlobalDataCacheForDataDictionarySingleton sharedInstance].publicNetRequestParameters;
			
			/**
			 * 首先获取目标 "网络请求业务Bean" 对应的 "业务协议参数字典 domainParams" (字典由K和V组成,K是"终端应用与后台通信接口协议.doc" 文档中的业务协议关键字, V就是具体的值.)
			 */
			NSDictionary *domainDD = [parseDomainBeanToDataDictionary parseDomainBeanToDataDictionary:netRequestDomainBean];
			if (![domainDD isKindOfClass:[NSDictionary class]] || [domainDD count] <= 0) {
				// 没有额外的数据需要上传服务器
				break;
			}
			NSLog(@"domainParams-->%@", [domainDD description]);
			
			// 拼接完整的 "数据字典"
			fullDataDictionary = [NSMutableDictionary dictionaryWithDictionary:publicDD];
			[fullDataDictionary addEntriesFromDictionary:domainDD];
			
			// 最终确认确实需要使用POST方式发送数据
			httpRequestMethod = @"POST";
		} while (NO);
    
    // //////////////////////////////////////////////////////////////////////////////
		// 设置 公用的http header
		NSMutableDictionary *httpHeaders = [NSMutableDictionary dictionary];
    //
    NSString *cookieString = [[SimpleCookieSingleton sharedInstance] cookieString];
    if (![NSString isEmpty:cookieString]) {
      [httpHeaders setObject:cookieString forKey:@"Cookie"];
    }
    //
    [httpHeaders setObject:[ToolsFunctionForThisProgect getUserAgent] forKey:@"User-Agent"];
		// //////////////////////////////////////////////////////////////////////////////
		
		
		// 创建一个 Http Operation
    __weak DomainBeanNetworkEngineSingleton *weakSelf = self;
    id<IHttpEngine> httpEngine = [HttpEngineFactory getHttpEngine];
    if (![httpEngine conformsToProtocol:@protocol(IHttpEngine)]) {
      RNAssert(NO, @"必须实现 IHttpEngine 接口");
      break;
    }
    NSOperation *netRequestOperation = [httpEngine operationWithURLString:url netRequestDomainBean:netRequestDomainBean headers:httpHeaders params:fullDataDictionary httpMethod:httpRequestMethod successedBlock:^(NSOperation *operation, NSData *responseData) {
      // 网络数据正常返回
      
      id netRespondDomainBean = nil;
      NetRequestErrorBean *serverRespondDataError = [[NetRequestErrorBean alloc] init];
      serverRespondDataError.errorCode = 200;
      serverRespondDataError.message = @"OK";
      
			do {
				
        // ------------------------------------- >>>
        if ([operation isCancelled]) {
          // 本次网络请求被取消了
          break;
        }
        // ------------------------------------- >>>
        
				NSData *netRawEntityData = responseData;
			  if (![netRawEntityData isKindOfClass:[NSData class]] || netRawEntityData.length <= 0) {
					NSLog(@"-->从服务器端获得的实体数据为空(EntityData), 这种情况有可能是正常的, 比如 退出登录 接口, 服务器就只是通知客户端访问成功, 而不发送任何实体数据. 也可能是网络超时.");
          serverRespondDataError.errorCode = -1;
					break;
				}
				
        
				// 将具体网络引擎层返回的 "原始未加工数据byte[]" 解包成 "可识别数据字符串(一般是utf-8)".
				// 这里要考虑网络传回的原生数据有加密的情况, 比如MD5加密的数据, 那么在这里先解密成可识别的字符串
				id<INetRespondRawEntityDataUnpack> netRespondRawEntityDataUnpackMethod = [[NetEntityDataToolsFactoryMethodSingleton sharedInstance] getNetRespondEntityDataUnpackStrategyAlgorithm];
				if (![netRespondRawEntityDataUnpackMethod conformsToProtocol:@protocol(INetRespondRawEntityDataUnpack)]) {
          RNAssert(NO, @"-->解析服务器端返回的实体数据的 \"解码算法类(INetRespondRawEntityDataUnpack)\"是必须要实现的.");
          serverRespondDataError.errorCode = -1;
					break;
				}
				NSString *netUnpackedDataOfUTF8String = [netRespondRawEntityDataUnpackMethod unpackNetRespondRawEntityDataToUTF8String:netRawEntityData];
				if ([NSString isEmpty:netUnpackedDataOfUTF8String]) {
					RNAssert(NO, @"-->解析服务器端返回的实体数据失败, 在netRawEntityData不为空的时候, netUnpackedDataOfUTF8String是绝对不能为空的.");
          serverRespondDataError.errorCode = -1;
					break;
				}
        
				// 将 "已经解包的可识别数据字符串" 解析成 "具体的业务响应数据Bean"
				// note : 将服务器返回的数据字符串(已经解密, 解码完成了), 解析成对应的 "网络响应业务Bean"
        // 20130625 : 对于那种单一的项目, 就是不会同时有JSON/XML等多种数据格式的项目, 可以完全使用KVC来生成 NetRespondBean
				id<IDomainBeanAbstractFactory> domainBeanAbstractFactoryObject
        = [[DomainBeanAbstractFactoryCacheSingleton sharedInstance] getDomainBeanAbstractFactoryObjectByKey:abstractFactoryMappingKey];
				if ([domainBeanAbstractFactoryObject conformsToProtocol:@protocol(IDomainBeanAbstractFactory)]) {
          
          id<INetRespondDataToNSDictionary> netRespondDataToNSDictionaryStrategyAlgorithm
          = [[NetEntityDataToolsFactoryMethodSingleton sharedInstance] getNetRespondDataToNSDictionaryStrategyAlgorithm];
					if ([netRespondDataToNSDictionaryStrategyAlgorithm conformsToProtocol:@protocol(INetRespondDataToNSDictionary)]) {
            NSDictionary *netRespondDictionary = [netRespondDataToNSDictionaryStrategyAlgorithm netRespondDataToNSDictionary:netUnpackedDataOfUTF8String];
            
            //
            id<IParseNetRespondDictionaryToDomainBean> parseNetRespondDictionaryToDomainBeanStrategy
            = [domainBeanAbstractFactoryObject getParseNetRespondDictionaryToDomainBeanStrategy];
            if ([parseNetRespondDictionaryToDomainBeanStrategy conformsToProtocol:@protocol(IParseNetRespondDictionaryToDomainBean)]) {
              
              netRespondDomainBean = [parseNetRespondDictionaryToDomainBeanStrategy parseNetRespondDictionaryToDomainBean:netRespondDictionary];
              //netRespondDomainBean = [[[domainBeanAbstractFactoryObject getClassOfNetRespondBean] alloc] initWithDictionary:dic];
              
              
              // TODO : 目前暂时设计成, 不是用KVC的方式来创建 业务Bean, 因为目前后台返回的数据中 正确和失败的字段都混合在一起, 不能分开,
              // 所以暂时设计成, 如果出现 "业务层面的接口请求失败", 就返回一个 NetRequestErrorBean, 正确就返回正确的业务Bean
              // 现在将具体业务层的解析放到每个接口的IParseNetRespondDictionaryToDomainBean策略中, 如果将来服务器进行了重新设计和客户端的通信协议时在修改
              if ([netRespondDomainBean isKindOfClass:[NetRequestErrorBean class]]) {
                //
                serverRespondDataError = netRespondDomainBean;
                break;
              } else if(netRespondDomainBean == nil) {
                // 异常 (NullPointerException)
                RNAssert(NO, @"-->创建 网络响应业务Bean失败, 出现这种情况的业务Bean是:%@", abstractFactoryMappingKey);
                serverRespondDataError.errorCode = -1;
                serverRespondDataError.message = @"网络返回了无效的数据!";
                break;
              } else {
                // 成功
                NSLog(@"%@ -->netRespondDomainBean->", netRespondDomainBean);
              }
            }
					}
				}
        
				// ----------------------------------------------------------------------------
        
				
			} while (NO);
			
      // ------------------------------------- >>>
      if (![operation isCancelled]) {
        // 本次网络请求结束, 设置NetRequestIndex为IDLE状态.
        *pCurrentNetRequestIndexToOut = NETWORK_REQUEST_ID_OF_IDLE;
        
        if (serverRespondDataError.errorCode != 200) {
          failedBlock(serverRespondDataError);
        } else {
          successedBlock(netRespondDomainBean);
        }
        
      }
      // ------------------------------------- >>>
      
      
      // 删除本地缓存的 MKNetworkOperation
      [weakSelf.synchronousNetRequestBuf removeObjectForKey:[NSNumber numberWithInteger:netRequestIndex]];
      NSLog(@"当前网络接口请求队列长度=%i", weakSelf.synchronousNetRequestBuf.count);
    } failedBlock:^(NSOperation *operation, NSError *error) {
      // 发生网络请求错误
      
      // ------------------------------------- >>>
      if (![operation isCancelled]) {
        // 本次网络请求结束, 设置NetRequestIndex为IDLE状态.
        *pCurrentNetRequestIndexToOut = NETWORK_REQUEST_ID_OF_IDLE;
        
        NetRequestErrorBean *serverRespondDataError = [[NetRequestErrorBean alloc] init];
        serverRespondDataError.errorCode = error.code;
        serverRespondDataError.message = [error localizedDescription];
        
        failedBlock(serverRespondDataError);
      }
      // ------------------------------------- >>>
      
      
      // 删除本地缓存的 MKNetworkOperation
      [weakSelf.synchronousNetRequestBuf removeObjectForKey:[NSNumber numberWithInteger:netRequestIndex]];
      NSLog(@"当前网络接口请求队列长度=%i", weakSelf.synchronousNetRequestBuf.count);
    }];
    /**
		 * 将这个 "内部网络请求事件" 缓存到集合synchronousNetRequestEventBuf中
		 */
		[self.synchronousNetRequestBuf setObject:netRequestOperation forKey:[NSNumber numberWithInteger:netRequestIndex]];
		
		NSLog(@"当前网络接口请求队列长度=%i", self.synchronousNetRequestBuf.count);
		
		NSLog(@" ");
		NSLog(@" ");
		NSLog(@" ");
		NSLog(@"%@%i%@", @"<<<<<<<<<<     Request a domain protocol end (" , netRequestIndex , @")     >>>>>>>>>>");
		NSLog(@" ");
		NSLog(@" ");
		NSLog(@" ");
		
		
    // 发起网络请求成功
		*pCurrentNetRequestIndexToOut = netRequestIndex;
    return;
	} while (NO);
	
  // 发起网络请求失败
  *pCurrentNetRequestIndexToOut = NETWORK_REQUEST_ID_OF_IDLE;
  return;
}

/**
 * 取消一个 "网络请求索引" 所对应的 "网络请求命令"
 *
 * @param netRequestIndex : 网络请求命令对应的索引
 */
- (void) cancelNetRequestByRequestIndex:(out NSInteger *) pNetRequestIndex {
  do {
    if (pNetRequestIndex == NULL) {
      RNAssert(NO, @"入参为空.");
      break;
    }
    
    if (*pNetRequestIndex == NETWORK_REQUEST_ID_OF_IDLE) {
      break;
    }
    
    NSNumber *indexOfNSNumber = [NSNumber numberWithInteger:*pNetRequestIndex];
    NSOperation *netRequestOperation = [self.synchronousNetRequestBuf objectForKey:indexOfNSNumber];
    if (nil == netRequestOperation) {
      break;
    }
    
    // 调用 cancel 不会在触发 addCompletionHandler 和 errorHandler, 所以这里直接从请求队列中删除缓存对象.
    [netRequestOperation cancel];
    
    // 复位标签索引
    *pNetRequestIndex = NETWORK_REQUEST_ID_OF_IDLE;
    NSLog(@"当前网络接口请求队列长度=%i", self.synchronousNetRequestBuf.count);
  } while (NO);
  
}

@end
