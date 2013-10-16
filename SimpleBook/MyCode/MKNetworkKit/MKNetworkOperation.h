//
//  MKNetwork.h
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

@class MKNetworkOperation;

typedef enum {
  MKNetworkOperationStateReady = 1,     // 已经准备好
  MKNetworkOperationStateExecuting = 2, // 正在执行
  MKNetworkOperationStateFinished = 3   // 已经完成
} MKNetworkOperationState;

typedef void (^MKNKVoidBlock)(void);
typedef void (^MKNKIDBlock)(void);
typedef void (^MKNKProgressBlock)(double progress);
typedef void (^MKNKResponseBlock)(MKNetworkOperation* completedOperation);
#if TARGET_OS_IPHONE
typedef void (^MKNKImageBlock) (UIImage* fetchedImage, NSURL* url, BOOL isInCache);
#elif TARGET_OS_MAC
typedef void (^MKNKImageBlock) (NSImage* fetchedImage, NSURL* url, BOOL isInCache);
#endif
typedef void (^MKNKResponseErrorBlock)(MKNetworkOperation* completedOperation, NSError* error);
typedef void (^MKNKErrorBlock)(NSError* error);

typedef void (^MKNKAuthBlock)(NSURLAuthenticationChallenge* challenge);

typedef NSString* (^MKNKEncodingBlock) (NSDictionary* postDataDict);

typedef enum {
  
  MKNKPostDataEncodingTypeURL = 0, // default
  MKNKPostDataEncodingTypeJSON,
  MKNKPostDataEncodingTypePlist,
  MKNKPostDataEncodingTypeCustom
} MKNKPostDataEncodingType;
/*!
 @header MKNetworkOperation.h
 @abstract   Represents a single unique network operation. 代表一个唯一的网络操作.
 */

/*!
 *  @class MKNetworkOperation
 *  @abstract Represents a single unique network operation.
 *  
 *  @discussion
 *	You normally create an instance of this class using the methods exposed by MKNetworkEngine
    通常使用MKNetworkEngine公开的方法创建本类的一个实例.
 *  Created operations are enqueued into the shared queue on MKNetworkEngine
    创建的操作对象, 被插入MKNetworkEngine的共享对象.
 *  MKNetworkOperation encapsulates both request and response
    MKNetworkOperation同时封装了 request 和 response
 *  Printing a MKNetworkOperation prints out a cURL command that can be copied and pasted directly on terminal
    打印一个 MKNetworkOperation , 将在终端上输出一个 cURL命令, 可以直接复制和粘贴.
 *  Freezable operations are serialized when network connectivity is lost and performed when connection is restored
    冻结的操作对象, 当网络中断时, 会被序列化, 当网络恢复时, 重新执行.
 */
@interface MKNetworkOperation : NSOperation <NSURLConnectionDataDelegate> {
  
@private
  int _state;
  BOOL _freezable;
  MKNKPostDataEncodingType _postDataEncoding;
}

/*!
 *  @abstract Request URL Property, 请求URL属性.
 *  @property url
 *  
 *  @discussion
 *	Returns the operation's URL
    返回操作项的URL
 *  This property is readonly cannot be updated. 
    这个属性是只读的, 不能被更新.
 *  To create an operation with a specific URL, use the operationWithURLString:params:httpMethod: 
    如果要使用一个指定的URL创建一个操作对象, 可以使用 operationWithURLString:params:httpMethod:方法.
 */
@property (nonatomic, copy, readonly) NSString *url;

/*!
 *  @abstract The internal request object, 内部HTTP请求对象.
 *  @property readonlyRequest
 *  
 *  @discussion
 *	Returns the operation's actual request object
    返回操作对象的实际请求对象.
 *  This property is readonly cannot be modified. 
 *  To create an operation with a new request, use the operationWithURLString:params:httpMethod: 
    如果要使用一个新的request创建一个操作对象, 可以使用 operationWithURLString:params:httpMethod: 方法.
 */
@property (nonatomic, strong, readonly) NSURLRequest *readonlyRequest;

/*!
 *  @abstract The internal HTTP Response Object, 内部HTTP响应对象.
 *  @property readonlyResponse
 *  
 *  @discussion
 *	Returns the operation's actual response object
 *  This property is readonly cannot be updated. 
 */
@property (nonatomic, strong, readonly) NSHTTPURLResponse *readonlyResponse;

/*!
 *  @abstract The internal HTTP Post data values
    内部 HTTP POST 数据
 *  @property readonlyPostDictionary
 *  
 *  @discussion
 *	Returns the operation's post data dictionary
    返回操作对象的POST数据字典
 *  This property is readonly cannot be updated.
 *  Rather, updating this post dictionary doesn't have any effect on the MKNetworkOperation.
    当然, 更新这个POST字典, 对于 MKNetworkOperation 也没有任何影响.
 *  Use the addHeaders method to add post data parameters to the operation.
 *  使用 addHeaders 方法来添加POST数据参数到操作项.
    另外, 此参数是在使用 operationWithURLString:params:(NSDictionary*)body httpMethod: 方法时, 通过body被设置的.
 
 *  @seealso
 *   addHeaders:
 */
@property (nonatomic, copy, readonly) NSDictionary *readonlyPostDictionary;

/*!
 *  @abstract The internal request object's method type, 内部HTTP请求对象的方法类型
 *  @property HTTPMethod
 *  
 *  @discussion
 *	Returns the operation's method type
 *  This property is readonly cannot be modified. 
 *  To create an operation with a new method type, use the operationWithURLString:params:httpMethod: 
    如果要使用一个新的方法类型创建一个操作对象, 可以使用 operationWithURLString:params:httpMethod: 方法.
 */
@property (nonatomic, copy, readonly) NSString *HTTPMethod;

/*!
 *  @abstract The internal response object's status code, 内部HTTP响应对象的状态码.
 *  @property HTTPStatusCode
 *  
 *  @discussion
 *	Returns the operation's response's status code. 返回操作对象的响应对象的状态码.
 *  Returns 0 when the operation has not yet started and the response is not available.
    当操作对象还未开始, 并且response是不可利用时, 返回 0
 *  This property is readonly cannot be modified. 
 */
@property (nonatomic, assign, readonly) NSInteger HTTPStatusCode;

/*!
 *  @abstract Post Data Encoding Type Property, POST数据编码类型.
 *  @property postDataEncoding
 *  
 *  @discussion
 *  Specifies which type of encoding should be used to encode post data.
    指定应该选择哪种编码方式, 来对POST数据进行编码.
 *  MKNKPostDataEncodingTypeURL is the default which defaults to application/x-www-form-urlencoded
    MKNKPostDataEncodingTypeURL 是默认项, 其默认type是  application/x-www-form-urlencoded
 *  MKNKPostDataEncodingTypeJSON uses JSON encoding. 
 *  JSON Encoding is supported only in iOS 5 or Mac OS X 10.7 and above.
    JSON编码, 仅在iOS5或者Mac10.7以上才支持.
 *  On older operating systems, JSON Encoding reverts back to URL Encoding
    在旧的操作系统中(低于iOS5或者Mac10.7), JSON Encoding将被还原成URL Encoding
 *  You can use the postDataEncodingHandler to provide a custom postDataEncoding 
    你可以使用postDataEncodingHandler来提供一个自定义的postDataEncoding
 *  For example, JSON encoding using a third party library.
    例如, JSON编码, 要使用一个第三方的库.
 *
 *  @seealso
 *  setCustomPostDataEncodingHandler:forType:
 *
 */
@property (nonatomic, assign) MKNKPostDataEncodingType postDataEncoding;

/*!
 *  @abstract Set a customized Post Data Encoding Handler for a given HTTP Content Type
    为给定的HTTP Content Type 设置一个自定义POST 数据编码处理Handler
 *  
 *  @discussion
 *  If you need customized post data encoding support, provide a block method here.
    如果你需要支持一个自定义的POST数据编码, 可以在这里提供一个块方法.
 *  This block method will be invoked only when your HTTP Method is POST or PUT
    这个方法只有当你的HTTP Method 设置成 POST 或者 PUT时 被调用.
 *  For default URL encoding or JSON encoding, use the property postDataEncoding
 *  If you change the postData format, it's your responsiblity to provide a correct Content-Type.
    如果你要更改postData格式, 你有责任提供一个正确的Content-Type.
 *
 *  @seealso
 *  postDataEncoding
 */
-(void) setCustomPostDataEncodingHandler:(MKNKEncodingBlock) postDataEncodingHandler forType:(NSString*) contentType;

/*!
 *  @abstract String Encoding Property, 字符串编码属性.
 *  @property stringEncoding
 *  
 *  @discussion
 *  Specifies which type of encoding should be used to encode URL strings
    指定使用哪种编码方式, 来编码URL字符串.
 */
@property (nonatomic, assign) NSStringEncoding stringEncoding;

/*!
 *  @abstract Freezable request, 标记当前网络操作 "可被冻结".
 *  @property freezable
 *  
 *  @discussion
 *	Freezable operations are serialized when the network goes down and restored when the connectivity is up again.
    "可被冻结" 的操作对象, 当网络中断时会被序列化保存, 并在网络连通时, 被恢复.
 *  Only POST, PUT and DELETE operations are freezable.
    仅 POST/PUT/DELETE 类型的操作对象 可以被冻结.
 *  In short, any operation that changes the state of the server are freezable, creating a tweet, checking into a new location etc., 
    简而言之, ......, 创建一个tweet, 检查到一个新的位置等..
    Operations like fetching a list of tweets (think readonly GET operations) are not freezable.
    像抓取一个tweets列表(这是只读的GET操作对象)这样的操作对象是不能被冻结.
 *  MKNetworkKit doesn't freeze (readonly) GET operations even if they are marked as freezable
    MKNetworkKit不会冻结(只读的)GET操作对象, 即使它们被标记成 "可被冻结"
 */
@property (nonatomic, assign) BOOL freezable;

/*!
 *  @abstract Error object
 *  @property error
 *  
 *  @discussion
 *	If the network operation results in an error, this will hold the response error, otherwise it will be nil
    如果网络操作得到了一个错误, 会在这里进行保存, 否则这个属性将为nil.
 */
@property (nonatomic, readonly, strong) NSError *error;

/*!
 *  @abstract Boolean variable that states whether the operation's response should be cached despite coming from a secured source
    标识是否应该缓存操作对象的response, 即使是来至一个受保护的源.
    标记当是HTTPS时, 也会缓存响应数据的布尔变量.
 *  @property shouldCacheEvenIfProtocolIsHTTPS
 *
 *  @discussion
 *	If you set this property to YES, the operation's data will be cached even if the source is secure (HTTPS)
 *  The default value is NO. MKNetworkKit will not cache responses from secure servers
    如果你设置属性为YES, 那么即使是HTTPS时, 操作对象的数据也会被缓存.
    默认值是NO.
 */
@property (nonatomic, assign) BOOL shouldCacheResponseEvenIfProtocolIsHTTPS;

/*!
 *  @abstract Boolean variable that states whether the operation's response should be cached
    标记是否不要缓存操作对象的response的布尔变量.
 *  @property shouldNotCacheResponse
 *
 *  @discussion
 *	If you set this property to YES, the operation's data will not be cached even if the engine's useCache is enabled
    如果你设置这个属性为YES, 操作对象的数据就不会被缓存, 即使引擎的 useCache 被激活了.
 *  The default value is NO. MKNetworkKit will cache responses based on the engine setting.
    默认值是NO.
 *  This property should be used sparingly if your backend isn't written adhering to HTTP 1.1 caching standards
    如果你的后台不是遵守HTTP1.1缓存标准写成的, 这个属性应谨慎使用.
 */
@property (nonatomic, assign) BOOL shouldNotCacheResponse;

/*!
 *  @abstract Boolean variable that states whether the operation should continue if the certificate is invalid.
    标志当证书无效时, 是否要继续操作对象.
 *  @property shouldContinueWithInvalidCertificate
 *
 *  @discussion
 *	If you set this property to YES, the operation will continue as if the certificate was valid (if you use Server Trust Auth)
    如果你设置这个属性为YES, 操作对象会在证书无效时继续运行(如果你使用 服务器信托认证)
 *  The default value is NO. MKNetworkKit will not run an operation with a server that is not trusted.
    默认值是NO, MKNetworkKit不会运行一个服务器不信任的操作对象.
 */
@property (nonatomic, assign) BOOL shouldContinueWithInvalidCertificate;

/*!
 *  @abstract Boolean variable that states whether the request should automatically include an Accept-Language header.
    标志是否一个请求应该自动包含一个 Accept-Language 头.
 *  @property shouldSendAcceptLanguageHeader
 *
 *  @discussion
 *	If set to YES, then MKNetworkKit will generate an Accept-Language header using [NSLocale preferredLanguages] + "en-us".
    如果设置成 YES, MKNetworkKit将使用 [NSLocale preferredLanguages] + "en-us" 生成一个 Accept-Language 头.
 *  This is set by MKNetworkEngine when it creates the MKNetworkOperation instance, so it gets its default from there.
    这个属性是由 MKNetworkEngine 设置的, 当MKNetworkEngine创建 MKNetworkOperation 实例的时候, 所以MKNetworkEngine会从这里得到默认值.
 */
@property (nonatomic, assign) BOOL shouldSendAcceptLanguageHeader;

/*!
 *  @abstract Cache headers of the response
 *  @property cacheHeaders
 *  
 *  @discussion
 *	If the network operation is a GET, this dictionary will be populated with relevant cache related headers
 *	MKNetworkKit assumes a 7 day cache for images and 1 minute cache for all requests with no-cache set
 *	This property is internal to MKNetworkKit. Modifying this is not recommended and will result in unexpected behaviour
    这个属性是 MKNetworkKit 内部使用的. 不建议修改这个属性, 这样会导致意外的情况发生.
 */
@property (strong, nonatomic) NSMutableDictionary *cacheHeaders;

/*!
 *  @abstract Authentication methods, 身份验证方法.
 *  
 *  @discussion
 *	If your request needs to be authenticated, set your username and password using this method.
    如果你的请求需要身份验证, 可以使用这个方法设置 username 和 password.
 */
-(void) setUsername:(NSString*) name password:(NSString*) password;

/*!
 *  @abstract Authentication methods
 *  
 *  @discussion
 *	If your request needs to be authenticated using HTTP Basic, use this method to set your username and password.
    如果你的请求需要使用HTTP基本验证, ....
 *  Calling this method with basicAuth:NO is same as calling setUserName:password:
    如果basicAuth:参数为NO, 和调用setUserName:password:方法作用相同.
 *  @seealso
 *  setUserName:password:
 */
-(void) setUsername:(NSString*) username password:(NSString*) password basicAuth:(BOOL) bYesOrNo;

/*!
 *  @abstract Authentication methods (Client Certificate), 身份验证方法(客户端证书).
 *  @property clientCertificate
 *  
 *  @discussion
 *	If your request needs to be authenticated using a client certificate, set the certificate path here
    如果你的请求需要使用一个客户端证书来进行身份验证, 请在这里设置证书路径.
 */
@property (copy, nonatomic) NSString *clientCertificate;

/*!
 *  @abstract Authentication methods (Password for the Client Certificate), 身份验证方法(客户端证书的密码).
 *  @property clientCertificatePassword
 *
 *  @discussion
 *	If your client certificate is encrypted with a password, specify it here
    如果你的客户端证书, 使用一个密码进行加密了, 请在这里指定.
 */
@property (copy, nonatomic) NSString *clientCertificatePassword;

/*!
 *  @abstract Custom authentication handler, 自定义身份验证handler.
 *  @property authHandler
 *  
 *  @discussion
 *	If your request needs to be authenticated using a custom method (like a Web page/HTML Form), add a block method here
 *  and process the NSURLAuthenticationChallenge
  
    如果你的请求, 需要一个自定义的方法来进行身份验证(比如一个 Web page/HTML Form), 就在这里添加一个块方法.
    并且处理 NSURLAuthenticationChallenge
 */
@property (nonatomic, copy) MKNKAuthBlock authHandler;

/*!
 *  @abstract Handler that you implement to monitor reachability changes
    你自己实现的监听操作对象状态改变的 handler 方法.
 *  @property operationStateChangedHandler
 *  
 *  @discussion
 *	The framework calls this handler whenever the operation state changes
    当操作对象状态变化时, 框架会调用这个handler
 */
@property (copy, nonatomic) void (^operationStateChangedHandler)(MKNetworkOperationState newState);

/*!
 *  @abstract controls persistence of authentication credentials
 *  @property credentialPersistence
 *  
 *  @discussion
 *  The default value is set to NSURLCredentialPersistenceForSession, change it to NSURLCredentialPersistenceNone to avoid caching issues (isse #35)
 */
@property (nonatomic, assign) NSURLCredentialPersistence credentialPersistence;
#if TARGET_OS_IPHONE

/*!
 *  @abstract notification that has to be shown when an error occurs and the app is in background
    当app运行在后台时, 当发生一个错误时, 可以发送本属性设置的通知对象.
 *  @property localNotification
 *  
 *  @discussion
 *  The default value nil. No notification is shown when an error occurs.
    默认值为nil. 当一个错误发生时, 不发送任务通知对象.
 *  To show a notification when the app is in background and the network operation running in background fails,
 *  set this parameter to a UILocalNotification object
 
    如果想 app运行在后台, 并且网络操作对象运行在后台失败的时候得到一个通知对象, 可以给当前属性设置一个 UILocalNotification 对象
 */
@property (nonatomic, strong) UILocalNotification *localNotification;

/*!
 *  @abstract Shows a local notification when an error occurs, 当一个错误发生时, 是否显示一个本地通知.
 *  @property shouldShowLocalNotificationOnError
 *  
 *  @discussion
 *  The default value NO. No notification is shown when an error occurs.
    默认值是NO. 当发生一个错误时, 不会显示任何通知.
 *  When set to YES, MKNetworkKit shows the NSError localizedDescription text as a notification when the app is in background and the network operation ended in error.
    当设置YES时, MKNetworkKit将以一个通知的形式展示NSError 的 localizedDescription.
 *  To customize the local notification text, use the property localNotification
    如果想自定义通知文本, 请使用 localNotification 属性.
 
 *  @seealso
 *  localNotification
 */
@property (nonatomic, assign) BOOL shouldShowLocalNotificationOnError;
#endif

/*!
 *  @abstract Add additional POST/GET parameters to your request, 添加额外的 POST/GET参数到你的请求中.
 *
 *  @discussion
 *	If you ever need to set additional params after creating your operation, you this method.
    如果你需要在创建你的操作对象之后, 添加额外的参数, 可以使用这个方法.
 *  You normally set default parameters to the params parameter when you create a operation.
    你通过在你创建一个操作对象时, 设置默认参数.
 *  On specific cases where you need to add a new parameter for a call, you can use this
    如果在特殊的情况下, 你需要为一个调用添加一个新的参数时, 你可以使用这个方法.
 */
-(void) addParams:(NSDictionary*) paramsDictionary;

/*!
 *  @abstract Add additional header
 *
 *  @discussion Add a single additional header.  See addHeaders for a full discussion.
 */
-(void) addHeader:(NSString*)key withValue:(NSString*)value;

/*!
 *  @abstract Add additional header parameters
 *  
 *  @discussion
 *	If you ever need to set additional headers after creating your operation, you this method.
 *  You normally set default headers to the engine and they get added to every request you create.
 *  On specific cases where you need to set a new header parameter for just a single API call, you can use this
 */
-(void) addHeaders:(NSDictionary*) headersDictionary;

/*!
 *  @abstract Set a header, overwriting any value already set.
 *
 *  @discussion addHeader will append the value to any header already set.  If you want to overwrite
 *  that value, then use setHeader instead.
 */
-(void) setHeader:(NSString*)key withValue:(NSString*)value;

/*!
 *  @abstract Sets the authorization header after prefixing it with a given auth type
 *  
 *  @discussion
 *	If you need to set the HTTP Authorization header, you can use this convinience method.
    如果你需要设置HTTP授权头, 你可以使用这个方法.
 *  This method internally calls addHeaders:
    这个方法内部调用 addHeaders:
 *  The authType parameter is a string that you can prefix to your auth token to tell your server what kind of authentication scheme you want to use. 
    HTTP Basic Authentication uses the string "Basic" for authType
 *  To use HTTP Basic Authentication, consider using the method setUsername:password:basicAuth: instead.
 *
 *  Example
 *  [op setAuthorizationHeaderValue:@"abracadabra" forAuthType:@"Token"] will set the header value to
 *  "Authorization: Token abracadabra"
 * 
 *  @seealso
 *  setUsername:password:basicAuth:
 *  addHeaders:
 */
-(void) setAuthorizationHeaderValue:(NSString*) token forAuthType:(NSString*) authType;

/*!
 *  @abstract Attaches a file to the request, 附加一个文件到一个请求中.
 *  
 *  @discussion
 *	This method lets you attach a file to the request
    这个方法可以让你附加一个文件到请求中.
 *  The method has a side effect. It changes the HTTPMethod to "POST" regardless of what it was before.
    该方法有个副作用. 它会更改HTTPMethod为"POST",而不管在这之前HTTPMethod是什么.
 *  It also changes the post format to multipart/form-data
    它也会更改post格式 为 multipart/form-data
 *  The mime-type is assumed to be application/octet-stream
    mime-type 将被假定为 application/octet-stream
 */
-(void) addFile:(NSString*) filePath forKey:(NSString*) key;

/*!
 *  @abstract Attaches a file to the request and allows you to specify a mime-type
 *  
 *  @discussion
 *	This method lets you attach a file to the request
 *  The method has a side effect. It changes the HTTPMethod to "POST" regardless of what it was before.
 *  It also changes the post format to multipart/form-data
 */
-(void) addFile:(NSString*) filePath forKey:(NSString*) key mimeType:(NSString*) mimeType;

/*!
 *  @abstract Attaches a resource to the request from a NSData pointer
    从NSData指针中添加一个资源到请求中.
 *  
 *  @discussion
 *	This method lets you attach a NSData object to the request. The behaviour is exactly similar to addFile:forKey:
    这个方法让你追加一个NSData对象到请求中. 该行为完全类似于 addFile:forKey: 方法.
 *  The method has a side effect. It changes the HTTPMethod to "POST" regardless of what it was before.
 *  It also changes the post format to multipart/form-data
 *  The mime-type is assumed to be application/octet-stream
 */
-(void) addData:(NSData*) data forKey:(NSString*) key;

/*!
 *  @abstract Attaches a resource to the request from a NSData pointer and allows you to specify a mime-type
 *  
 *  @discussion
 *	This method lets you attach a NSData object to the request. The behaviour is exactly similar to addFile:forKey:mimeType:
 *  The method has a side effect. It changes the HTTPMethod to "POST" regardless of what it was before.
 *  It also changes the post format to multipart/form-data
 */
-(void) addData:(NSData*) data forKey:(NSString*) key mimeType:(NSString*) mimeType fileName:(NSString*) fileName;

/*!
 *  @abstract Block Handler for completion and error, 为完成和错误时, 准备的处理块(已经不建议使用)
 *  
 *  @discussion
 *	This method sets your completion and error blocks. If your operation's response data was previously called,
 *  the completion block will be called almost immediately with the cached response. You can check if the completion 
 *  handler was invoked with a cached data or with real data by calling the isCachedResponse method.
 *  This method is deprecated in favour of addCompletionHandler:errorHandler: that returns the completedOperation in the error block as well.
 *  While I will still continue to support this method, I'll remove it completely in a future release.
 *
 *  @seealso
 *  isCachedResponse
 *  addCompletionHandler:errorHandler:
 */
-(void) onCompletion:(MKNKResponseBlock) response onError:(MKNKErrorBlock) error DEPRECATED_ATTRIBUTE;

/*!
 *  @abstract adds a block Handler for completion and error
 *
 *  @discussion
 *	This method sets your completion and error blocks. If your operation's response data was previously called,
 *  the completion block will be called almost immediately with the cached response. You can check if the completion
 *  handler was invoked with a cached data or with real data by calling the isCachedResponse method.
    这个方法用于设置你的完成和错误处理块.如果你的操作对象的响应数据之前调用过, 完成块几乎被立刻调用, 并且返回的是缓存的response.
    你可以通过 isCachedResponse 来检测完成块处理的是 缓存数据还是真实数据.
 *
 *  @seealso
 *  onCompletion:onError:
 */
-(void) addCompletionHandler:(MKNKResponseBlock) response errorHandler:(MKNKResponseErrorBlock) error;

/*
 对 HTTP 304 的理解
 
 最近和同事一起看Web的Cache问题，又进一步理解了 HTTP 中的 304 又有了一些了解。
 
 304 的标准解释是：Not Modified 客户端有缓冲的文档并发出了一个条件性的请求（一般是提供If-Modified-Since头表示客户只想比指定日期更新的文档）。服务器告诉客户，原来缓冲的文档还可以继续使用。
 
 如果客户端在请求一个文件的时候，发现自己缓存的文件有 Last Modified ，那么在请求中会包含 If Modified Since ，
 这个时间就是缓存文件的 Last Modified 。因此，如果请求中包含 If Modified Since，就说明已经有缓存在客户端。
 只要判断这个时间和当前请求的文件的修改时间就可以确定是返回 304 还是 200 。对于静态文件，例如：CSS、图片，
 服务器会自动完成 Last Modified 和 If Modified Since 的比较，完成缓存或者更新。但是对于动态页面，
 就是动态产生的页面，往往没有包含 Last Modified 信息，这样浏览器、网关等都不会做缓存，也就是在每次请求的时候都完成一个 200 的请求。
 因此，对于动态页面做缓存加速，首先要在 Response 的 HTTP Header 中增加 Last Modified 定义，
 其次根据 Request 中的 If Modified Since 和被请求内容的更新时间来返回 200 或者 304 。
 虽然在返回 304 的时候已经做了一次数据库查询，但是可以避免接下来更多的数据库查询，
 并且没有返回页面内容而只是一个 HTTP Header，从而大大的降低带宽的消耗，对于用户的感觉也是提高。
 当这些缓存有效的时候，通过 HttpWatch 查看一个请求会得到这样的结果：
 第一次访问 200
 鼠标点击二次访问 (Cache)
 按F5刷新 304
 按Ctrl+F5强制刷新 200
 如果是这样的就说明缓存真正有效了。以上就是我对 HTTP 304 的一个理解。
 */
/*!
 *  @abstract Block Handler for tracking 304 not modified state
 *
 *  @discussion
 *	This method will be called if the server sends a 304 HTTP status for your request.
 *
 */
-(void) onNotModified:(MKNKVoidBlock) notModifiedBlock;

/*!
 *  @abstract Block Handler for tracking upload progress, 用于跟踪上传进度的处理块.
 *  
 *  @discussion
 *	This method can be used to update your progress bars when an upload is in progress. 
 *  The value range of the progress is 0 to 1.
    取值范围是 0 ~ 1.
 *
 */
-(void) onUploadProgressChanged:(MKNKProgressBlock) uploadProgressBlock;

/*!
 *  @abstract Block Handler for tracking download progress
 *  
 *  @discussion
 *	This method can be used to update your progress bars when a download is in progress. 
 *  The value range of the progress is 0 to 1.
 *
 */
-(void) onDownloadProgressChanged:(MKNKProgressBlock) downloadProgressBlock;

/*!
 *  @abstract Uploads a resource from a stream, 通过一个流上传一个资源.
 *  
 *  @discussion
 *	This method can be used to upload a resource for a post body directly from a stream.
    这个方法可以被用于直接把一个流作为http post body上传一个资源.
 *
 */
-(void) setUploadStream:(NSInputStream*) inputStream;

/*!
 *  @abstract Downloads a resource directly to a file or any output stream
    下载一个资源, 直接到一个文件中或者任何输出流中.
 *  
 *  @discussion
 *	This method can be used to download a resource directly to a stream (It's normally a file in most cases).
    这个方法被用于下载一个资源, 直接到一个流中(在大多数情况下, 这通常是这个文件).
 *  Calling this method multiple times adds new streams to the same operation.
    多次调用这个方法, 会增加新的流到相同的操作对象中.
 *  A stream cannot be removed after it is added.
    一个流被添加后, 不能被移除.
 *
 */
-(void) addDownloadStream:(NSOutputStream*) outputStream;

/*!
 *  @abstract Helper method to check if the response is from cache, 该辅助方法用于检测response是否来至缓存.
 *  
 *  @discussion
 *	This method should be used to check if your response is cached.
 *  When you enable caching on MKNetworkEngine, your completionHandler will be called with cached data first and then
 *  with real data, later after fetching. In your handler, you can call this method to check if it is from cache or not
    当你在MKNetworkEngine激活缓存时, 你的completionHandler会优先使用缓存数据进行响应, 其次才是抓取真实数据.
    在你的handler中, 你可以调用这个方法来检测response是否来自缓存.
 *
 */
-(BOOL) isCachedResponse;

/*!
 *  @abstract Helper method to retrieve the contents, 辅助方法用于取回内容.
 *  
 *  @discussion
 *	This method is used for accessing the downloaded data. If the operation is still in progress, the method returns nil instead of partial data. To access partial data, use a downloadStream.
 *  这个方法用于访问下载过的数据. 如果操作对象仍然还在进行中, 该方法将返回nil,而不是局部数据.
    如要访问局部数据, 可以使用 downloadStream.
 *  @seealso
 *  addDownloadStream:
 */
-(NSData*) responseData;

/*!
 *  @abstract Helper method to retrieve the contents as a NSString
 *  
 *  @discussion
 *	This method is used for accessing the downloaded data. If the operation is still in progress, the method returns nil instead of partial data. To access partial data, use a downloadStream. 
    The method also converts the responseData to a NSString using the stringEncoding specified in the operation
    该方法会使用在操作中指定的stringEncoding, 来将responseData转换成一个字符串.
 *
 *  @seealso
 *  addDownloadStream:
 *  stringEncoding
 */
-(NSString*)responseString;

/*!
 *  @abstract Helper method to print the request as a cURL command, 辅助方法, 用于打印 一个请求作为cURL命令.
 *  
 *  @discussion
 *	This method is used for displaying the request you created as a cURL command
 *
 */
-(NSString*) curlCommandLineString;

/*!
 *  @abstract Helper method to retrieve the contents as a NSString encoded using a specific string encoding
 *  
 *  @discussion
 *	This method is used for accessing the downloaded data. If the operation is still in progress, the method returns nil instead of partial data. To access partial data, use a downloadStream. The method also converts the responseData to a NSString using the stringEncoding specified in the parameter
 *
 *  @seealso
 *  addDownloadStream:
 *  stringEncoding
 */
-(NSString*) responseStringWithEncoding:(NSStringEncoding) encoding;

/*!
 *  @abstract Helper method to retrieve the contents as a UIImage
 *  
 *  @discussion
 *	This method is used for accessing the downloaded data as a UIImage. If the operation is still in progress, the method returns nil instead of a partial image. To access partial data, use a downloadStream. If the response is not a valid image, this method returns nil. This method doesn't obey the response mime type property. If the server response with a proper image data but set the mime type incorrectly, this method will still be able access the response as an image.
 *
 *  @seealso
 *  addDownloadStream:
 */
#if TARGET_OS_IPHONE
-(UIImage*) responseImage;
-(void) decompressedResponseImageOfSize:(CGSize) size completionHandler:(void (^)(UIImage *decompressedImage)) imageDecompressionHandler;
#elif TARGET_OS_MAC
-(NSImage*) responseImage;
-(NSXMLDocument*) responseXML;
#endif

/*!
 *  @abstract Helper method to retrieve the contents as a NSDictionary or NSArray depending on the JSON contents
 *  
 *  @discussion
 *	This method is used for accessing the downloaded data as a NSDictionary or an NSArray. If the operation is still in progress, the method returns nil. 
    If the response is not a valid JSON, this method returns nil.
    如果response不是一个有效的JSON, 这个方法会返回nil.
 *
 *  @seealso
 *  responseJSONWithCompletionHandler:

 *  @availability
 *  iOS 5 and above or Mac OS 10.7 and above
 */
-(id) responseJSON;

/*!
 *  @abstract Helper method to retrieve the contents as a NSDictionary or NSArray depending on the JSON contents in the background
 *
 *  @discussion
 *	This method is used for accessing the downloaded data as a NSDictionary or an NSArray. 
    If the operation is still in progress, the method returns nil. 
    If the response is not a valid JSON, this method returns nil.
    The difference between this and responseJSON is that, this method decodes JSON in the background.
    这个方法和responseJSON的不同点是, 这个方法会在后台, 解码JSON.
 *
 *  @see also
 *  responseJSON
 *  responseJSONWithOptions:completionHandler:
 *
 *  @availability
 *  iOS 5 and above or Mac OS 10.7 and above
 */
-(void) responseJSONWithCompletionHandler:(void (^)(id jsonObject)) jsonDecompressionHandler;

/*!
 *  @abstract Helper method to retrieve the contents as a NSDictionary or NSArray depending on the JSON contents in the background
 *
 *  @discussion
 *	This method is used for accessing the downloaded data as a NSDictionary or an NSArray. If the operation is still in progress, the method returns nil. If the response is not a valid JSON, this method returns nil. The difference between this and responseJSON is that, this method decodes JSON in the background and allows passing JSON reading options like parsing JSON fragments.
 *
 *  @see also
 *  responseJSON
 *  responseJSONWithCompletionHandler:
 *
 *  @availability
 *  iOS 5 and above or Mac OS 10.7 and above
 */
-(void) responseJSONWithOptions:(NSJSONReadingOptions) options completionHandler:(void (^)(id jsonObject)) jsonDecompressionHandler;

/*!
 *  @abstract Overridable custom method where you can add your custom business logic error handling
    可以被覆盖的自定义方法, 你可以在这里添加你自定义业务逻辑 错误处理.
 *  
 *  @discussion
 *	This optional method can be overridden to do custom error handling. Be sure to call [super operationSucceeded] at the last.
 *  For example, a valid HTTP response (200) like "Item not found in database" might have a custom business error code
 *  You can override this method and called [super failWithError:customError]; to notify that HTTP call was successful but the method
 *  ended as a failed call
 *
 */
-(void) operationSucceeded;

/*!
 *  @abstract Overridable custom method where you can add your custom business logic error handling
 *  
 *  @discussion
 *	This optional method can be overridden to do custom error handling. Be sure to call [super operationSucceeded] at the last.
 *  For example, a invalid HTTP response (401) like "Unauthorized" might be a valid case in your app.
 *  You can override this method and called [super operationSucceeded]; to notify that HTTP call failed but the method
 *  ended as a success call. For example, Facebook login failed, but to your business implementation, it's not a problem as you
 *  are going to try alternative login mechanisms.
 *
 */
-(void) operationFailedWithError:(NSError*) error;

/*!
 *  @abstract Copy this MKNetworkOperation, with the intention of retrying the call.
 *
 *  @discussion This means that the request parameters and callbacks are all preserved, but anything related
 *  to an ongoing request is discarded, so that a new request with the same configuration can be made.
 */
-(instancetype) copyForRetry;

// 下面是仅在 MKNetworkEngine 内部使用的方法, 不要动.
// internal methods called by MKNetworkEngine only.
// Don't touch
-(BOOL) isCacheable;
-(void) setCachedData:(NSData*) cachedData;
-(void) setCacheHandler:(MKNKResponseBlock) cacheHandler;
-(void) updateHandlersFromOperation:(MKNetworkOperation*) operation;
-(void) updateOperationBasedOnPreviousHeaders:(NSMutableDictionary*) headers;
-(NSString*) uniqueIdentifier;

- (instancetype)initWithURLString:(NSString *)aURLString
                 params:(NSDictionary *)params
             httpMethod:(NSString *)method;
@end
