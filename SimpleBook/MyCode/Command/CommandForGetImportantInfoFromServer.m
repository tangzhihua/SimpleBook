//
//  CommandForGetImportantInfoFromServer.m
//  ruyicai
//
//  Created by 熊猫 on 13-4-29.
//
//

#import "CommandForGetImportantInfoFromServer.h"

#import "GlobalDataCacheForMemorySingleton.h"
#import "GlobalDataCacheForNeedSaveToFileSystem.h"


#import "MKNetworkKit.h"
#import "MKNetworkEngineSingletonForUpAndDownLoadFile.h"

#import "LocalCacheDataPathConstant.h"




@interface CommandForGetImportantInfoFromServer ()
// 这个命令只能执行一次
@property (nonatomic, assign) BOOL isExecuted;

@end










@implementation CommandForGetImportantInfoFromServer {
  MKNetworkOperation *_testServerURL;
}

/**
 
 * 执行命令对应的操作
 
 */
-(void)execute {
  if (!self.isExecuted) {
		self.isExecuted = YES;
		
    if (![kUrlConstant_MainUrl isEqualToString:[GlobalDataCacheForMemorySingleton sharedInstance].hostName]) {
      _testServerURL = [[MKNetworkEngineSingletonForUpAndDownLoadFile sharedInstance] operationWithURLString:@"https://dreambook.retechcorp.com/dreambook/testcon.txt"];
      [_testServerURL setShouldContinueWithInvalidCertificate:YES];
      [_testServerURL addHeaders:@{@"User-Agent": [ToolsFunctionForThisProgect getUserAgent]}];
      
      NSString *filePath = [NSString stringWithFormat:@"%@/%@", [LocalCacheDataPathConstant importantDataCachePath], @"testcon.txt"];
      [_testServerURL addDownloadStream:[NSOutputStream outputStreamToFileAtPath:filePath append:NO]];
      [_testServerURL addCompletionHandler:^(MKNetworkOperation* completedRequest) {
        NSString *responseString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
        if ([responseString isEqualToString:@"dreambook"]) {
          // 服务器域名 http://dreambook.retechcorp.com/dreambook 有效
          [GlobalDataCacheForMemorySingleton sharedInstance].hostName = kUrlConstant_MainUrl;
        }
      } errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
        
        
      }];
      [[MKNetworkEngineSingletonForUpAndDownLoadFile sharedInstance] enqueueOperation:_testServerURL];
    }
  }
}

#pragma mark -
#pragma mark 单例方法群

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
    _isExecuted = NO;
		_testServerURL = nil;
  }
  
  return self;
}

+(id)commandForGetImportantInfoFromServer {
	
  static CommandForGetImportantInfoFromServer *singletonInstance = nil;
  static dispatch_once_t pred;
  dispatch_once(&pred, ^{singletonInstance = [[self alloc] initSingleton];});
  return singletonInstance;
}

@end