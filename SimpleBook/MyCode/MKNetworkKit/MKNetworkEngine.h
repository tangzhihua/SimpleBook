//
//  MKNetworkEngine.h
//  MKNetworkKit
//
//  Created by Mugunth Kumar (@mugunthkumar) on 11/11/11.
//  Copyright (C) 2011-2020 by Steinlogic Consulting and Training Pte Ltd

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "MKNetworkKit.h"
/*!
 @header MKNetworkEngine.h
 @abstract   Represents a subclassable Network Engine for your app
 为你的APP准备一个子类化的网络引擎( 也就是说, 你的app如果要使用MKNetworkEngine就定义一个子类继承MKNetworkEngine)
 */

/*!
 *  @class MKNetworkEngine
 *  @abstract Represents a subclassable Network Engine for your app
 *
 *  @discussion
 *	This class is the heart of MKNetworkEngine 这个类是MKNetworkEngine的核心
 *  You create network operations and enqueue them here 你可以在这里创建网络操作项集合并且将他们加入队列.
 *  MKNetworkEngine encapsulates a Reachability object that relieves you of managing network connectivity losses
 MKNetworkEngine 封装了一个Reachability object来帮你减轻网络连接丢失.
 *  MKNetworkEngine also allows you to provide custom header fields that gets appended automatically to every request
 MKNetworkEngine 还允许您提供一个自定义的header fields, 会自动添加到每个request中.
 */
@interface MKNetworkEngine : NSObject
/*!
 *  @abstract Initializes your network engine with a hostname 使用一个主机名来初始化您的网络引擎.
 *
 *  @discussion
 *	Creates an engine for a given host name 为一个指定的主机名创建一个引擎.
 *  The hostname parameter is optional 主机名参数是可选的.
 *  The hostname, if not null, initializes a Reachability notifier. 主机名, 如果不为null, 会初始化一个Reachability notifier(可达性通知)
 *  Network reachability notifications are automatically taken care of by MKNetworkEngine
 网络可达性通知会在MKNetworkEngine 中被自动照顾.
 *
 */
- (id) initWithHostName:(NSString*) hostName;

/*!
 *  @abstract Initializes your network engine with a hostname and custom header fields
 使用一个主机名和自定义头字段群来初始化您的网络引擎.
 *
 *  @discussion
 *	Creates an engine for a given host name
 *  The default headers you specify here will be appened to every operation created in this engine
 您在这里指定的默认headers, 会被自动添加到您通过这个引擎创建的每个操作项中.
 *  The hostname, if not null, initializes a Reachability notifier.
 *  Network reachability notifications are automatically taken care of by MKNetworkEngine
 *  Both parameters are optional 这两个参数是可选的.
 *
 */
- (id) initWithHostName:(NSString*) hostName customHeaderFields:(NSDictionary*) headers;

/*!
 *  @abstract Initializes your network engine with a hostname
 *
 *  @discussion
 *	Creates an engine for a given host name
 *  The hostname parameter is optional
 *  The apiPath paramter is optional
 *  The apiPath is prefixed to every call to operationWithPath: You can use this method if your server's API location is not at the root (/)
 apiPath会作为每个调用operationWithPath方法入参的前缀:如果您的服务器API地址不在根目录(/)时, 您可以使用这个方法.
 
 *  The hostname, if not null, initializes a Reachability notifier.
 *  Network reachability notifications are automatically taken care of by MKNetworkEngine
 *
 */
- (id) initWithHostName:(NSString*) hostName apiPath:(NSString*) apiPath customHeaderFields:(NSDictionary*) headers;

/*!
 *  @abstract Initializes your network engine with a hostname, port, path, and headers.
 使用 主机名, 端口, 路径, 头 来初始化您的引擎.
 *
 *  @discussion
 *	Creates an engine for a given host name
 *  The hostname parameter is optional
 *  The port parameter can be 0, which means to use the appropriate default port (80 or 443 for HTTP or HTTPS respectively).
 端口参数可以传入 0 ,这意味着要使用相应的默认端口(80和443分别对应HTTP和HTTPS)
 *  The apiPath paramter is optional
 *  The apiPath is prefixed to every call to operationWithPath: You can use this method if your server's API location is not at the root (/)
 *  The hostname, if not null, initializes a Reachability notifier.
 *  Network reachability notifications are automatically taken care of by MKNetworkEngine
 *
 */
- (id) initWithHostName:(NSString*) hostName portNumber:(int)portNumber apiPath:(NSString*) apiPath customHeaderFields:(NSDictionary*) headers;

/*!
 *  @abstract Creates a simple GET Operation with a request URL
 使用一个请求URL来创建一个简单的GET操作.
 *
 *  @discussion
 *	Creates an operation with the given URL path.
 *  The default headers you specified in your MKNetworkEngine subclass gets added to the headers
    您在您的MKNetworkEngine子类中指定的默认headers, 会被添加到headers中.
 *  The HTTP Method is implicitly assumed to be GET
    HTTP Method隐式假定为GET
 *
 */

-(MKNetworkOperation*) operationWithPath:(NSString*) path;

/*!
 *  @abstract Creates a simple GET Operation with a request URL and parameters
 *
 *  @discussion
 *	Creates an operation with the given URL path.
 *  The default headers you specified in your MKNetworkEngine subclass gets added to the headers
 *  The body dictionary in this method gets attached to the URL as query parameters
    body字典会在这个方法中, 被作为查询参数添加到URL中.
 *  The HTTP Method is implicitly assumed to be GET
    
 *
 */
-(MKNetworkOperation*) operationWithPath:(NSString*) path
                                  params:(NSDictionary*) body;

/*!
 *  @abstract Creates a simple GET Operation with a request URL, parameters and HTTP Method
 *
 *  @discussion
 *	Creates an operation with the given URL path.
 *  The default headers you specified in your MKNetworkEngine subclass gets added to the headers
 *  The params dictionary in this method gets attached to the URL as query parameters if the HTTP Method is GET/DELETE
 *  The params dictionary is attached to the body if the HTTP Method is POST/PUT
 *  The HTTP Method is implicitly assumed to be GET
 */
-(MKNetworkOperation*) operationWithPath:(NSString*) path
                                  params:(NSDictionary*) body
                              httpMethod:(NSString*)method;

/*!
 *  @abstract Creates a simple GET Operation with a request URL, parameters, HTTP Method and the SSL switch
 *
 *  @discussion
 *	Creates an operation with the given URL path.
 *  The ssl option when true changes the URL to https. ssl选项为true时, URL会变成https
 *  The ssl option when false changes the URL to http. ssl选项为false时, URL会变成http
 *  The default headers you specified in your MKNetworkEngine subclass gets added to the headers
 *  The params dictionary in this method gets attached to the URL as query parameters if the HTTP Method is GET/DELETE
 *  The params dictionary is attached to the body if the HTTP Method is POST/PUT
 *  The previously mentioned methods operationWithPath: and operationWithPath:params: call this internally
    前面提到的方法 operationWithPath: 和 operationWithPath:params: 内部调用的是这个方法.
 */
-(MKNetworkOperation*) operationWithPath:(NSString*) path
                                  params:(NSDictionary*) body
                              httpMethod:(NSString*)method
                                     ssl:(BOOL) useSSL;

/*!
 *  @abstract Creates a simple GET Operation with a request URL
    使用一个 请求URL来创建一个简单的GET操作.
 *
 *  @discussion
 *	Creates an operation with the given absolute URL. 使用一个给定的绝对URL来创建一个操作.
 *  The hostname of the engine is *NOT* prefixed , 不把当前引擎的主机名作为前缀了.
 *  The default headers you specified in your MKNetworkEngine subclass gets added to the headers
 *  The HTTP method is implicitly assumed to be GET.
 */
-(MKNetworkOperation*) operationWithURLString:(NSString*) urlString;

/*!
 *  @abstract Creates a simple GET Operation with a request URL and parameters
 *
 *  @discussion
 *	Creates an operation with the given absolute URL.
 *  The hostname of the engine is *NOT* prefixed
 *  The default headers you specified in your MKNetworkEngine subclass gets added to the headers
 *  The body dictionary in this method gets attached to the URL as query parameters
 *  The HTTP method is implicitly assumed to be GET.
 */
-(MKNetworkOperation*) operationWithURLString:(NSString*) urlString
                                       params:(NSDictionary*) body;

/*!
 *  @abstract Creates a simple Operation with a request URL, parameters and HTTP Method
 *
 *  @discussion
 *	Creates an operation with the given absolute URL.
 *  The hostname of the engine is *NOT* prefixed
 *  The default headers you specified in your MKNetworkEngine subclass gets added to the headers
 *  The params dictionary in this method gets attached to the URL as query parameters if the HTTP Method is GET/DELETE
 *  The params dictionary is attached to the body if the HTTP Method is POST/PUT
 *	This method can be over-ridden by subclasses to tweak the operation creation mechanism.
 *  You would typically over-ride this method to create a subclass of MKNetworkOperation (if you have one). After you create it, you should call [super prepareHeaders:operation] to attach any custom headers from super class.
   这个方法可以由子类覆盖, 用来调整操作创建机制.
   您通常会覆盖这个方法, 用来创建MKNetworkOperation的一个子类(如果你有一个的话).
   创建后, 你应该调用 [super prepareHeaders:operation] 用来从超类中添加所有的自定义头.
 *  @seealso
 *  prepareHeaders:
 */
-(MKNetworkOperation*) operationWithURLString:(NSString*) urlString
                                       params:(NSDictionary*) body
                                   httpMethod:(NSString*) method;

/*!
 *  @abstract adds the custom default headers 添加自定义默认头
 *
 *  @discussion
 *	This method adds custom default headers to the factory created MKNetworkOperation.
    此方法添加自定义头到创建MKNetworkOperation工厂中.
 *	This method can be over-ridden by subclasses to add more default headers if necessary.
    这个方法可以被子类覆盖, 用于添加更多默认的头, 如果你需要的话.
 *  You would typically over-ride this method if you have over-ridden operationWithURLString:params:httpMethod:.
    您通常会在您已经覆盖operationWithURLString:params:httpMethod:的时候, 覆盖本方法.
 *  @seealso
 *  operationWithURLString:params:httpMethod:
 */
-(void) prepareHeaders:(MKNetworkOperation*) operation;

#if TARGET_OS_IPHONE

// 下面两个方法, 已经不建议使用了
/*!
 *  @abstract Handy helper method for fetching images asynchronously in the background
    用于在后台异步的获取图片的辅助方法.
 *
 *  @discussion
 *	Creates an operation with the given image URL.
 *  The hostname of the engine is *NOT* prefixed.
 *  The image is returned to the caller via MKNKImageBlock callback block. This image is resized as per the size and decompressed in background.
    图像通过MKNKImageBlock回调块, 返回给调用者.该图片会在后台按照给定的尺寸进行调整和解压.
 *  @seealso
 *  imageAtUrl:onCompletion:
 */
- (MKNetworkOperation*)imageAtURL:(NSURL *)url size:(CGSize) size onCompletion:(MKNKImageBlock) imageFetchedBlock DEPRECATED_ATTRIBUTE;

/*!
 *  @abstract Handy helper method for fetching images
    用于截图图像的辅助方法.
 *
 *  @discussion
 *	Creates an operation with the given image URL.
 *  The hostname of the engine is *NOT* prefixed.
 *  The image is returned to the caller via MKNKImageBlock callback block.
 */
- (MKNetworkOperation*)imageAtURL:(NSURL *)url onCompletion:(MKNKImageBlock) imageFetchedBlock DEPRECATED_ATTRIBUTE;

// 下面两个是新方法.
/*!
 *  @abstract Handy helper method for fetching images in the background
    
 *
 *  @discussion
 *	Creates an operation with the given image URL.
 *  The hostname of the engine is *NOT* prefixed.
 *  The image is returned to the caller via MKNKImageBlock callback block. This image is resized as per the size and decompressed in background.
 *  @seealso
 *  imageAtUrl:onCompletion:
 */
- (MKNetworkOperation*)imageAtURL:(NSURL *)url completionHandler:(MKNKImageBlock) imageFetchedBlock errorHandler:(MKNKResponseErrorBlock) errorBlock;

/*!
 *  @abstract Handy helper method for fetching images asynchronously in the background
 *
 *  @discussion
 *	Creates an operation with the given image URL.
 *  The hostname of the engine is *NOT* prefixed.
 *  The image is returned to the caller via MKNKImageBlock callback block. This image is resized as per the size and decompressed in background.
 *  @seealso
 *  imageAtUrl:onCompletion:
 */
- (MKNetworkOperation*)imageAtURL:(NSURL *)url size:(CGSize) size completionHandler:(MKNKImageBlock) imageFetchedBlock errorHandler:(MKNKResponseErrorBlock) errorBlock;
#endif

/*!
 *  @abstract Enqueues your operation into the shared queue
    将您的操作加入共享队列中.
 *
 *  @discussion
 *	The operation you created is enqueued to the shared queue. If the response for this operation was previously cached, the cached data will be returned.
    你创建的操作会被加入共享队列中. 如果这个操作对应的应答以前缓存过, 缓存的数据会被直接返回.
 *  @seealso
 *  enqueueOperation:forceReload:
 */
-(void) enqueueOperation:(MKNetworkOperation*) request;

/*!
    forceReload : 强制刷新.
 *  @abstract Enqueues your operation into the shared queue.
 *
 *  @discussion
 *	The operation you created is enqueued to the shared queue.
 *  When forceReload is NO, this method behaves like enqueueOperation:
    当forceReload是NO, 这个方法的行为和enqueueOperation:方法一样.
 *  When forceReload is YES, No cached data will be returned even if cached data is available.
    当forceReload是NO, 即使有可用的缓存数据, 也不会返回缓存的数据.
 *  @seealso
 *  enqueueOperation:
 */
-(void) enqueueOperation:(MKNetworkOperation*) operation forceReload:(BOOL) forceReload;

/*!
 *  @abstract Cancels operations matching a given string
    在共享队列中, 取消所有匹配目标字符串的操作(这个字符串可以是 主机名或者路径).
 *
 *  @discussion
 *	Cancels all operations in the shared queue that matches a given string. This string could be your host name or a path
 *
 */
+(void) cancelOperationsContainingURLString:(NSString*) string;

/*!
 *  @abstract Cancels operations matching the given block.
    在共享队列中, 取消所有匹配目标块的操作.

 *
 *  @discussion
 *	Cancels all operations in the shared queue for which the given block returns YES.
    在共享队列中取消所有的操作, 当给定的块返回YES时
 *
 */
+(void) cancelOperationsMatchingBlock:(BOOL (^)(MKNetworkOperation*))block;

/*!
 *  @abstract Cancels all operations created by this engine
    取消当前引擎创建的所有操作.
 *
 *  @discussion
 *	Cancels all operations that matches this engine's host name
 *  This method is a no-op if the engine's host name was not set.
    取消和当前引擎主机名匹配的所有操作, 如果当前引擎的主机名未设置的话, 本方法将不做任何操作.
 *
 */
- (void) cancelAllOperations;

/*!
 *  @abstract HostName of the engine 当前引擎的主机名
 *  @property readonlyHostName
 *
 *  @discussion
 *	Returns the host name of the engine
 *  This property is readonly cannot be updated.
 *  You normally initialize an engine with its hostname using the initWithHostName:customHeaders: method
    你通常使用 initWithHostName:customHeaders: 方法来初始化引擎的主机名.
 */
@property (readonly, copy, nonatomic) NSString *readonlyHostName;

/*!
 *  @abstract Port Number that should be used by URL creating factory methods
    
 *  @property portNumber
 *
 *  @discussion
 *	Set a port number for your engine if your remote URL mandates it.
 *  This property is optional and you DON'T have to specify the default HTTP port 80
    为你的引擎设置端口号, 如果你的远程URL授权给它的话.
    这个属性是可选的, 你如果没有指定缺省值的话, 默认HTTP端口是80.
 */
@property (assign, nonatomic) int portNumber;

/*!
 *  @abstract WiFi only mode , 是否只在Wifi模式下使用网络.
 *  @property wifiOnlyMode
 *
 *  @discussion
 *	When you set this property to YES, MKNetworkEngine will not run operations on mobile data network.
    当你设置这个属性为YES时, MKNetworkEngine将不会在移动数据网络状态下运行操作.
 */
@property (assign, nonatomic) BOOL wifiOnlyMode;

/*!
 *  @abstract Sets an api path if it is different from root URL
 *  @property apiPath
 *
 *  @discussion
 *	You can use this method to set a custom path to the API location if your server's API path is different from root (/)
 *  This property is optional
 */
@property (copy, nonatomic) NSString* apiPath;

/*!
 *  @abstract Handler that you implement to monitor reachability changes
    可达性变化时的处理块.
 *  @property reachabilityChangedHandler
 *
 *  @discussion
 *	The framework calls this handler whenever the reachability of the host changes.
    每当主机变化可达性发生变化时, 框架会调用这个处理块.
 *  The default implementation freezes the queued operations and stops network activity
    默认实现是, 冻结正在排队的操作, 并且停止网络活动.
 *  You normally don't have to implement this unless you need to show a HUD notifying the user of connectivity loss
    您通常没有实现它, 除非你需要显示一个HUD来通知用户连接中断.
 */
@property (copy, nonatomic) void (^reachabilityChangedHandler)(NetworkStatus ns);

/*!
 *  @abstract Registers an associated operation subclass
    注册一个关联的操作子类
 *
 *  @discussion
 *	When you override both MKNetworkEngine and MKNetworkOperation, you might want the engine's factory method to prepare operations of your MKNetworkOperation subclass. To create your own MKNetworkOperation subclasses from the factory method, you can register your MKNetworkOperation subclass using this method.
    当你同时重写MKNetworkEngine 和 MKNetworkOperation时, 你可能希望引擎的工厂方法提供的是你的MKNetworkOperation子类对象.
    要从工厂方法创建你自己的MKNetworkOperation子类, 你可以使用这个方法注册你的MKNetworkOperation子类.
 
 *  This method is optional. If you don't use, factory methods in MKNetworkEngine creates MKNetworkOperation objects.
    这个方法可选的. 如果你不使用, 在MKNetworkEngine中的工厂方法, 就会创建MKNetworkOperation对象.
 */
-(void) registerOperationSubclass:(Class) aClass;

/*!
 *  @abstract Cache Directory Name , 缓存目录名称
 *
 *  @discussion
 *	This method can be over-ridden by subclasses to provide an alternative cache directory.
    这个方法可以被子类覆盖, 用于提供一个替代的缓存目录.
 *  The default directory (MKNetworkKitCache) within the NSCaches directory will be used otherwise.
    否则默认的目录名称是 MKNetworkKitCache, 在NSCaches目录中, 将被使用.
 *  Overriding this method is optional
    重写此方法是可选的.
 */
-(NSString*) cacheDirectoryName;

/*!
 *  @abstract Cache Directory In Memory Cost,  
 *
 *  @discussion
 *	This method can be over-ridden by subclasses to provide an alternative in memory cache size.
    这个方法可以被子类覆盖, 用于提供一个内存缓存大小的新尺寸.
 *  By default, MKNetworkKit caches 10 recent requests in memory.
    默认的, MKNetworkKit将在内存中缓存最近的10条请求.
 *  The default size is 10
 *  Overriding this method is optional
 */
-(int) cacheMemoryCost;

/*!
 *  @abstract Enable Caching , 启动缓存.
 *
 *  @discussion
 *	This method should be called explicitly to enable caching for this engine.
    如果要启动当前引擎的缓存, 需要显式调用此方法.
 *  By default, MKNetworkKit doens't cache your requests.
    默认的, MKNetworkKit不缓存你的请求.
 *  The cacheMemoryCost and cacheDirectoryName will be used when you turn caching on using this method.
    cacheMemoryCost 和 cacheDirectoryName方法会在你使用本方法打开缓存时, 被调用.
 */
-(void) useCache;

/*!
 *  @abstract Empties previously cached data, 清空以前的缓存数据.
 *
 *  @discussion
 *	This method is a handy helper that you can use to clear cached data.
    这个辅助方法, 可以帮助你清空缓存的数据.
 *  By default, MKNetworkKit doens't cache your requests. Use this only when you enabled caching
    默认的, MKNetworkKit不缓存你的请求, 仅在当你启动缓存时, 才使用本方法.
 *  @seealso
 *  useCache
 */
-(void) emptyCache;

/*!
 *  @abstract Checks current reachable status , 检查当前可达性状态.
 *
 *  @discussion
 *	This method is a handy helper that you can use to check for network reachability.
    这个辅助方法, 可以帮你检查网络可达性.
 */
-(BOOL) isReachable;

/*!
 *  @abstract Boolean variable that states whether the request should automatically include an Accept-Language header.
    标识请求是否应该自动包含一个 Accept-Language 头的布尔变量.
 *  @property shouldSendAcceptLanguageHeader
 *
 *  @discussion
 *	The default value is YES. MKNetworkKit will generate an Accept-Language header using [NSLocale preferredLanguages] + "en-US".
    默认值是YES.MKNetworkKit将生成一个使用 [NSLocale preferredLanguages] + "en-US" 的 Accept-Language 头.
 */
@property (nonatomic, assign) BOOL shouldSendAcceptLanguageHeader;

@end
