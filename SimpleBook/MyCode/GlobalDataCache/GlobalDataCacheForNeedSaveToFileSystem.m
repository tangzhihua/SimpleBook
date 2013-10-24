//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "GlobalDataCacheForNeedSaveToFileSystem.h"

#import "GlobalDataCacheForMemorySingleton.h"
#import "NSObject+Serialization.h"
#import "LocalCacheDataPathConstant.h"
#import "BookInfo.h"
#import "LocalBook.h"
#import "BookListInBookstoresDatabaseFieldsConstant.h"
#import "LogonDatabaseFieldsConstant.h"
#import "LocalBookList.h"
#import "BookCategoriesNetRespondBean.h"
#import "LogonNetRespondBean.h"
#import "NSMutableDictionary+SafeSetObject.h"
#import "ToolsFunctionForThisProgect.h"

static NSString *const TAG = @"<GlobalDataCacheForNeedSaveToFileSystem>";

// 自动登录的标志
static NSString *const kLocalCacheDataName_AutoLoginMark                  = @"AutoLoginMark";
// 用户最后一次成功登录时得到的响应业务Bean
static NSString *const kLocalCacheDataName_LogonNetRespondBean            = @"LogonNetRespondBean";
// 用户是否是首次启动App
static NSString *const kLocalCacheDataName_FirstStartApp                  = @"FirstStartApp";
// 是否需要显示 初学者指南
static NSString *const kLocalCacheDataName_BeginnerGuide                  = @"BeginnerGuide";

// 本地书籍列表
static NSString *const kLocalCacheDataName_LocalBookList                  = @"LocalBookList";
// 本地书籍分类列表
static NSString *const kLocalCacheDataName_LocalBookshelfCategories       = @"LocalBookshelfCategories";

// 服务器主机名
static NSString *const kLocalCacheDataName_HostName                       = @"HostName";

@implementation GlobalDataCacheForNeedSaveToFileSystem

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
  }
  
  return self;
}

+ (GlobalDataCacheForNeedSaveToFileSystem *) privateInstance {
  static GlobalDataCacheForNeedSaveToFileSystem *singletonInstance = nil;
  static dispatch_once_t pred;
  dispatch_once(&pred, ^{singletonInstance = [[self alloc] initSingleton];});
  return singletonInstance;
}

+(void) initialize {
  // 这是为了子类化当前类后, 父类的initialize方法会被调用2次
  if (self == [GlobalDataCacheForNeedSaveToFileSystem class]) {
    [self registerBroadcastReceiver];
  }
}

+(void) dealloc {
  
  if (self == [GlobalDataCacheForNeedSaveToFileSystem class]) {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self unregisterLocalBookListKVO];
    [self unregisterLogonNetRespondBeanKVO];
    [self unregisterBookCategoriesNetRespondBeanKVO];
  }
}

#pragma mark -
#pragma mark 私有方法
+(void)serializeObjectToFileSystemWithObject:(id)object fileName:(NSString *)fileName directoryPath:(NSString *)directoryPath {
  if (object == nil) {
    // 如果入参为空, 就证明要删除本地缓存的该对象的序列化文件
    NSString *serializeObjectPath = [NSString stringWithFormat:@"%@/%@", directoryPath, fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:serializeObjectPath]) {
      NSError *error = nil;
      [fileManager removeItemAtPath:serializeObjectPath error:&error];
      if (error != nil) {
        NSLog(@"删除序列化到本地的对象文件失败! 错误描述:%@", error.localizedDescription);
      }
    }
  } else {
    [object serializeObjectToFileSystemWithFileName:fileName directoryPath:directoryPath];
  }
}

#pragma mark -
#pragma mark 将内存中缓存的数据保存到文件系统中

+ (void)readUserLoginInfoToGlobalDataCacheForMemorySingleton {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  
  // 自动登录的标志
  id autoLoginMark = [userDefaults objectForKey:(NSString *)kLocalCacheDataName_AutoLoginMark];
  if (autoLoginMark == nil) {
    [userDefaults setBool:YES forKey:(NSString *)kLocalCacheDataName_AutoLoginMark];
  }
  BOOL autoLoginMarkBOOL = [userDefaults boolForKey:(NSString *)kLocalCacheDataName_AutoLoginMark];
  [GlobalDataCacheForMemorySingleton sharedInstance].isNeedAutologin = autoLoginMarkBOOL;
  
  // 用户最后一次成功登录时得到的响应业务Bean
	LogonNetRespondBean *logonNetRespondBean = [LogonNetRespondBean deserializeObjectFromFileSystemWithFileName:kLocalCacheDataName_LogonNetRespondBean
                                                                                                directoryPath:[LocalCacheDataPathConstant importantDataCachePath]];
  [GlobalDataCacheForMemorySingleton sharedInstance].privateAccountLogonNetRespondBean = logonNetRespondBean;
  
  //
  [self registerLogonNetRespondBeanKVO];
}

+ (void)readAppConfigInfoToGlobalDataCacheForMemorySingleton {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  
	// 用户是否是第一次启动App
	id isFirstStartAppTest = [userDefaults objectForKey:kLocalCacheDataName_FirstStartApp];
  if (nil == isFirstStartAppTest) {
    [userDefaults setBool:YES forKey:kLocalCacheDataName_FirstStartApp];
  }
  BOOL isFirstStartApp = [userDefaults boolForKey:kLocalCacheDataName_FirstStartApp];
  [GlobalDataCacheForMemorySingleton sharedInstance].isFirstStartApp = isFirstStartApp;
	
  // 是否需要在启动后显示初学者指南界面
  id isNeedShowBeginnerGuideTest = [userDefaults objectForKey:kLocalCacheDataName_BeginnerGuide];
  if (nil == isNeedShowBeginnerGuideTest) {
    [userDefaults setBool:YES forKey:kLocalCacheDataName_BeginnerGuide];
  }
  BOOL isNeedShowBeginnerGuide = [userDefaults boolForKey:kLocalCacheDataName_BeginnerGuide];
  [GlobalDataCacheForMemorySingleton sharedInstance].isNeedShowBeginnerGuide = isNeedShowBeginnerGuide;
  
  // 服务器主机名
  //NSString *hostName = [userDefaults stringForKey:kLocalCacheDataName_HostName];
  //[GlobalDataCacheForMemorySingleton sharedInstance].hostName = hostName;
}

+ (void)readLocalBookListToGlobalDataCacheForMemorySingleton {
  LocalBookList *object = [LocalBookList deserializeObjectFromFileSystemWithFileName:kLocalCacheDataName_LocalBookList
                                                                       directoryPath:[LocalCacheDataPathConstant importantDataCachePath]];
  [GlobalDataCacheForMemorySingleton sharedInstance].localBookList = object;
  
  // 从文件系统中, 读取已经安装好的书籍信息, 这是为了防止 "序列化" 出现问题.
  [self readInstallSucceedBookInfoFromFileSystem];
  
  [self registerLocalBookListKVO];
}

+ (void)readLocalBookshelfCategoriesToGlobalDataCacheForMemorySingleton {
  BookCategoriesNetRespondBean *object
  = [BookCategoriesNetRespondBean deserializeObjectFromFileSystemWithFileName:kLocalCacheDataName_LocalBookshelfCategories
                                                                directoryPath:[LocalCacheDataPathConstant importantDataCachePath]];
  
  [GlobalDataCacheForMemorySingleton sharedInstance].bookCategoriesNetRespondBean = object;
  
  [self registerBookCategoriesNetRespondBeanKVO];
}


#pragma mark -
#pragma mark 从文件系统中读取缓存的数据到内存中

+ (void)writeUserLoginInfoToFileSystem {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  
  // 自动登录的标志
  BOOL autoLoginMark = [[GlobalDataCacheForMemorySingleton sharedInstance] isNeedAutologin];
  [userDefaults setBool:autoLoginMark forKey:(NSString *)kLocalCacheDataName_AutoLoginMark];
  
  // 用户最后一次成功登录时得到的响应业务Bean
  LogonNetRespondBean *logonNetRespondBean = [GlobalDataCacheForMemorySingleton sharedInstance].privateAccountLogonNetRespondBean;
  [self serializeObjectToFileSystemWithObject:logonNetRespondBean fileName:kLocalCacheDataName_LogonNetRespondBean directoryPath:[LocalCacheDataPathConstant importantDataCachePath]];
}

+ (void)writeAppConfigInfoToFileSystem {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  
	// 是否需要显示用户第一次登录时的帮助界面的标志
  BOOL isFirstStartApp = [GlobalDataCacheForMemorySingleton sharedInstance].isFirstStartApp;
  [userDefaults setBool:isFirstStartApp forKey:kLocalCacheDataName_FirstStartApp];
	
  // 是否需要显示用户第一次登录时的帮助界面的标志
  BOOL isNeedShowBeginnerGuide = [GlobalDataCacheForMemorySingleton sharedInstance].isNeedShowBeginnerGuide;
  [userDefaults setBool:isNeedShowBeginnerGuide forKey:kLocalCacheDataName_BeginnerGuide];
  
  // 服务器主机名
  //  NSString *hostName = [GlobalDataCacheForMemorySingleton sharedInstance].hostName;
  //  if ([hostName isEqualToString:kUrlConstant_MainUrl]) {
  //    [userDefaults setObject:hostName forKey:kLocalCacheDataName_HostName];
  //  }
}

+ (void)writeLocalBookshelfCategoriesToFileSystem {
  BookCategoriesNetRespondBean *object = [[GlobalDataCacheForMemorySingleton sharedInstance] bookCategoriesNetRespondBean];
  [self serializeObjectToFileSystemWithObject:object fileName:kLocalCacheDataName_LocalBookshelfCategories directoryPath:[LocalCacheDataPathConstant importantDataCachePath]];
}

+ (void)writeLocalBookListToFileSystem {
  LocalBookList *object = [[GlobalDataCacheForMemorySingleton sharedInstance] localBookList];
  [self serializeObjectToFileSystemWithObject:object fileName:kLocalCacheDataName_LocalBookList directoryPath:[LocalCacheDataPathConstant importantDataCachePath]];
}

#pragma mark -
#pragma mark 将内存级别缓存的数据固化到硬盘中
+ (void)saveMemoryCacheToDisk:(NSNotification *)notification {
  NSLog(@"saveMemoryCacheToDisk:%@", notification);
  
  [GlobalDataCacheForNeedSaveToFileSystem writeUserLoginInfoToFileSystem];
  [GlobalDataCacheForNeedSaveToFileSystem writeAppConfigInfoToFileSystem];
  [GlobalDataCacheForNeedSaveToFileSystem writeLocalBookListToFileSystem];
  [GlobalDataCacheForNeedSaveToFileSystem writeLocalBookshelfCategoriesToFileSystem];
}

#pragma mark -
#pragma mark KVO 监听那些需要实时保存的对象.
-(void)observeValueForKeyPath:(NSString *)keyPath
										 ofObject:(id)object
											 change:(NSDictionary *)change
											context:(void *)context {
  
  if ((__bridge id)context == self) {// Our notification, not our superclass’s
    if ([keyPath isEqualToString:kLocalBookListProperty_localBookList]) {
      // 保存 "本地书籍列表" 本地书籍列表包括 : 下载完/未下载完 的书籍
      [GlobalDataCacheForNeedSaveToFileSystem writeLocalBookListToFileSystem];
    } else if ([keyPath isEqualToString:kGlobalDataCacheForMemorySingletonProperty_privateAccountLogonNetRespondBean]) {
      // 保存 企业用户 登录后的 网络响应业务Bean
      [GlobalDataCacheForNeedSaveToFileSystem writeUserLoginInfoToFileSystem];
    } else if ([keyPath isEqualToString:kGlobalDataCacheForMemorySingletonProperty_bookCategoriesNetRespondBean]) {
      // 保存 新取到的本地书籍分类网络响应业务Bean
      [GlobalDataCacheForNeedSaveToFileSystem writeLocalBookshelfCategoriesToFileSystem];
    }
    
  } else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

#pragma mark -
#pragma mark 注册需要序列化的对象的KVO

/// 本地书籍列表
+ (void)registerLocalBookListKVO {
  LocalBookList *localBookList = [GlobalDataCacheForMemorySingleton sharedInstance].localBookList;
  
  [localBookList addObserver:[GlobalDataCacheForNeedSaveToFileSystem privateInstance]
                  forKeyPath:kLocalBookListProperty_localBookList
                     options:NSKeyValueObservingOptionNew
                     context:(__bridge void *)[GlobalDataCacheForNeedSaveToFileSystem privateInstance]];
}
+ (void)unregisterLocalBookListKVO {
  LocalBookList *localBookList = [GlobalDataCacheForMemorySingleton sharedInstance].localBookList;
  
  [localBookList removeObserver:[GlobalDataCacheForNeedSaveToFileSystem privateInstance]
                     forKeyPath:kLocalBookListProperty_localBookList
                        context:(__bridge void *)[GlobalDataCacheForNeedSaveToFileSystem privateInstance]];
}

/// 企业用户登录后的网络响应业务Bean
+ (void)registerLogonNetRespondBeanKVO {
  [[GlobalDataCacheForMemorySingleton sharedInstance] addObserver:[GlobalDataCacheForNeedSaveToFileSystem privateInstance]
                                                       forKeyPath:kGlobalDataCacheForMemorySingletonProperty_privateAccountLogonNetRespondBean
                                                          options:NSKeyValueObservingOptionNew
                                                          context:(__bridge void *)[GlobalDataCacheForNeedSaveToFileSystem privateInstance]];
}
+ (void)unregisterLogonNetRespondBeanKVO {
  
  [[GlobalDataCacheForMemorySingleton sharedInstance] removeObserver:[GlobalDataCacheForNeedSaveToFileSystem privateInstance]
                                                          forKeyPath:kGlobalDataCacheForMemorySingletonProperty_privateAccountLogonNetRespondBean
                                                             context:(__bridge void *)[GlobalDataCacheForNeedSaveToFileSystem privateInstance]];
}

/// 本地书籍分类 网络响应业务Bean
+ (void)registerBookCategoriesNetRespondBeanKVO {
  [[GlobalDataCacheForMemorySingleton sharedInstance] addObserver:[GlobalDataCacheForNeedSaveToFileSystem privateInstance]
                                                       forKeyPath:kGlobalDataCacheForMemorySingletonProperty_bookCategoriesNetRespondBean
                                                          options:NSKeyValueObservingOptionNew
                                                          context:(__bridge void *)[GlobalDataCacheForNeedSaveToFileSystem privateInstance]];
}
+ (void)unregisterBookCategoriesNetRespondBeanKVO {
  
  [[GlobalDataCacheForMemorySingleton sharedInstance] removeObserver:[GlobalDataCacheForNeedSaveToFileSystem privateInstance]
                                                          forKeyPath:kGlobalDataCacheForMemorySingletonProperty_bookCategoriesNetRespondBean
                                                             context:(__bridge void *)[GlobalDataCacheForNeedSaveToFileSystem privateInstance]];
}

#pragma mark - NSNotification 监听一些对象状态变化时, 发送的通知
//
+ (void)registerBroadcastReceiver {
  // "下载完成并且安装成功一本书籍"
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(onReceiveForBroadcast:)
                                               name:[NSNumber numberWithInteger:kUserNotificationEnum_DownloadAndInstallSucceed].stringValue
                                             object:nil];
  
  // 内存告警
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(saveMemoryCacheToDisk:)
                                               name:UIApplicationDidReceiveMemoryWarningNotification
                                             object:nil];
  // 应用进入后台
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(saveMemoryCacheToDisk:)
                                               name:UIApplicationDidEnterBackgroundNotification
                                             object:nil];
  // 应用退出
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(saveMemoryCacheToDisk:)
                                               name:UIApplicationWillTerminateNotification
                                             object:nil];
}

+ (void)onReceiveForBroadcast:(NSNotification *)notification {
  
  // "下载完成并且安装成功一本书籍"
  if ([notification.name isEqualToString:[NSNumber numberWithInteger:kUserNotificationEnum_DownloadAndInstallSucceed].stringValue]) {
    LocalBook *book = (LocalBook *)notification.object;
    [self saveBookInfoToPListWithInstallSucceedBook:book];
    
    [GlobalDataCacheForNeedSaveToFileSystem writeLocalBookListToFileSystem];
  }
}

#pragma mark -
#pragma mark 保存已经解压成功的书籍

// 图书引擎版本号
#define BOOK_ENGINE_VERSION       @"book_engine_version"
#define BOOK_INFO_PLIST_FILE_NAME @"bookinfo.plist"

+ (void) saveBookInfoToPListWithInstallSucceedBook:(LocalBook *)book {
  NSString *filePath = [NSString stringWithFormat:@"%@/%@", book.bookSaveDirPath, BOOK_INFO_PLIST_FILE_NAME];
  NSMutableDictionary *dicData = [NSMutableDictionary dictionary];
  // BookInfo
  if (book.bookInfo != nil) {
    
    [dicData safeSetObject:book.bookInfo.content_id      forKey:k_BookListInBookstores_RespondKey_content_id];
    [dicData safeSetObject:book.bookInfo.name            forKey:k_BookListInBookstores_RespondKey_name];
    [dicData safeSetObject:book.bookInfo.published       forKey:k_BookListInBookstores_RespondKey_published];
    [dicData safeSetObject:book.bookInfo.expired         forKey:k_BookListInBookstores_RespondKey_expired];
    [dicData safeSetObject:book.bookInfo.author          forKey:k_BookListInBookstores_RespondKey_author];
    [dicData safeSetObject:book.bookInfo.price           forKey:k_BookListInBookstores_RespondKey_price];
    [dicData safeSetObject:book.bookInfo.productid       forKey:k_BookListInBookstores_RespondKey_productid];
    [dicData safeSetObject:book.bookInfo.categoryid      forKey:k_BookListInBookstores_RespondKey_categoryid];
    [dicData safeSetObject:book.bookInfo.publisher       forKey:k_BookListInBookstores_RespondKey_publisher];
    [dicData safeSetObject:book.bookInfo.thumbnail       forKey:k_BookListInBookstores_RespondKey_thumbnail];
    [dicData safeSetObject:book.bookInfo.bookDescription forKey:k_BookListInBookstores_RespondKey_description];
    [dicData safeSetObject:book.bookInfo.size            forKey:k_BookListInBookstores_RespondKey_size];
  }
  
  // bindAccount
  if (book.bindAccount != nil) {
    [dicData safeSetObject:book.bindAccount.username     forKey:kLogonNetRespondBeanProperty_username];
    [dicData safeSetObject:book.bindAccount.password     forKey:kLogonNetRespondBeanProperty_password];
  }
  
  // folder
  [dicData safeSetObject:book.folder                     forKey:kLocalBookProperty_folder];
  
  // 本地App中的 "图书引擎版本号"
  NSString *localBookEngineVersion = [ToolsFunctionForThisProgect localBookEngineVersion];
  [dicData safeSetObject:localBookEngineVersion          forKey:BOOK_ENGINE_VERSION];
  
  // save file
  [dicData writeToFile:filePath atomically:YES];
}

+ (void) readInstallSucceedBookInfoFromFileSystem {
  
  LocalBookList *localBookList = [GlobalDataCacheForMemorySingleton sharedInstance].localBookList;
  
  do {
    NSString *localBookCachePath = [LocalCacheDataPathConstant localBookCachePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:localBookCachePath]) {
      break;
    }
    
    NSArray *folders = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:localBookCachePath error:nil];
    if (folders.count <= 0) {
      break;
    }
    
    for (NSString *folder in folders) {
      NSString *bookInfoPath = [NSString stringWithFormat:@"%@/%@/%@", localBookCachePath, folder, BOOK_INFO_PLIST_FILE_NAME];
      if (![[NSFileManager defaultManager] fileExistsAtPath:bookInfoPath]) {
        // 如果 "书籍文件夹" 中没有 bookinfo.plist 证明书籍没有解压成功, 也就是垃圾文件夹, 可以删除了.
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", localBookCachePath, folder] error:NULL];
        continue;
      }
      
      NSMutableDictionary *bookInfoDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:bookInfoPath];
      if (bookInfoDictionary.count <= 0) {
        // 书籍信息字典, 如果为空, 也是不正常的.
        continue;
      }
      BookInfo *bookInfo = [[BookInfo alloc] initWithDictionary:bookInfoDictionary];
      LocalBook *localBook = [[LocalBook alloc] initWithBookInfo:bookInfo];
      localBook.bookStateEnum = kBookStateEnum_Installed;
      LogonNetRespondBean *bindAccount = [[LogonNetRespondBean alloc] initWithDictionary:bookInfoDictionary];
      localBook.bindAccount = bindAccount;
      localBook.folder = [bookInfoDictionary objectForKey:kLocalBookProperty_folder];
      
      NSString *localBookEngineVersion = [ToolsFunctionForThisProgect localBookEngineVersion];
      NSString *bookEngineVersionOfCurrentlyBook = [bookInfoDictionary objectForKey:kLocalBookProperty_folder];
      // TODO : 这里的处理还没有想好, 一种最简单的解决方案是, 如果发现本地的保存的书籍的 书籍引擎和当前app的书籍引擎版本号是不兼容的, 就直接删除本地已经下载的这本书
      [localBookList addBook:localBook];
      
    }
  } while (NO);
}
@end
