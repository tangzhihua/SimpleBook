//
//  LocalBook.m
//  MBEnterprise
//
//  Created by 唐志华 on 13-9-22.
//
//

#import "LocalBook.h"
#import "BookInfo.h"
#import "NSObject+DeepCopyingSupport.h"
#import "MKNetworkKit.h"
#import "MKNetworkEngineSingletonForUpAndDownLoadFile.h"
#import "LocalCacheDataPathConstant.h"
#import "MacroConstantForThisProject.h"
#import "LogonNetRespondBean.h"

//
#import "ZipArchive.h"


#define kTmpDownloadBookFileName @"tmp.zip"

#define kNSCodingField_bookInfo         @"bookInfo"
#define kNSCodingField_downloadProgress @"downloadProgress"
#define kNSCodingField_bookStateEnum    @"bookStateEnum"
#define kNSCodingField_bookSaveDirPath  @"bookSaveDirPath"
#define kNSCodingField_bindAccount      @"bindAccount"
#define kNSCodingField_folder           @"folder"

@interface LocalBook ()
//
@property (nonatomic, readwrite, assign) double downloadProgress;
//
@property (nonatomic, strong) MKNetworkOperation *bookDownloadOperation;
// 书籍保存文件夹路径
@property (nonatomic, readwrite, copy) NSString *bookSaveDirPath;
// 书籍临时zip资源包的路径
@property (nonatomic, copy) NSString *bookTmpZipResFilePath;

@end


@implementation LocalBook
-(NSString *)bookSaveDirPath {
  return [NSString stringWithFormat:@"%@/%@", [LocalCacheDataPathConstant localBookCachePath], self.bookInfo.content_id];
}

-(NSString *)bookTmpZipResFilePath {
  return [self.bookSaveDirPath stringByAppendingPathComponent:kTmpDownloadBookFileName];
}

- (id) initWithBookInfo:(BookInfo *)bookInfo {
  if (![bookInfo isKindOfClass:[BookInfo class]] || [NSString isEmpty:bookInfo.content_id]) {
    RNAssert(NO, @"入参异常 bookInfo数据有问题. ");
    return nil;
  }
  
  if ((self = [super init])) {
		PRPLog(@"init [0x%x]", [self hash]);
    
    // 进行 "数据保护"
    _bookInfo = [bookInfo deepCopy];
    
    if ([NSString isEmpty:bookInfo.price] || [bookInfo.price integerValue] <= 0) {
      // 免费的书籍
      _bookStateEnum = kBookStateEnum_Paid;
    } else {
      // 收费的书籍
      _bookStateEnum = kBookStateEnum_Unpaid;
    }
  }
  
  return self;
}

- (NSString *)description {
	return descriptionForDebug(self);
}

#pragma mark -
#pragma mark 实现 NSCoding 接口
- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:_bookInfo forKey:kNSCodingField_bookInfo];
  [aCoder encodeFloat:_downloadProgress forKey:kNSCodingField_downloadProgress];
  if (_bookStateEnum == kBookStateEnum_Unziping) {
    // 如果当前正在解压中, 用户按下home按键, 使app进入后台, 那么此时我们保存到文件系统中得状态不能是 Unziping, 应该是 NotInstalled(未安装).
    // 因为用户可能会前行关闭app. 那我们就设计当用户下一次进入app时, 显示 "未安装" 这个状态, 当用户点下按钮时, 要重新安装书籍
    [aCoder encodeInteger:kBookStateEnum_NotInstalled forKey:kNSCodingField_bookStateEnum];
  } else {
    [aCoder encodeInteger:_bookStateEnum forKey:kNSCodingField_bookStateEnum];
  }
  
  [aCoder encodeObject:_bindAccount forKey:kNSCodingField_bindAccount];
  [aCoder encodeObject:_folder forKey:kNSCodingField_folder];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super init])) {
    
    // 如果有不需要序列化的属性存在时, 可以在这里先进行初始化
    
    //
    if ([aDecoder containsValueForKey:kNSCodingField_bookInfo]) {
      _bookInfo = [aDecoder decodeObjectForKey:kNSCodingField_bookInfo];
    }
    //
    if ([aDecoder containsValueForKey:kNSCodingField_downloadProgress]) {
      _downloadProgress = [aDecoder decodeFloatForKey:kNSCodingField_downloadProgress];
    }
    //
    if ([aDecoder containsValueForKey:kNSCodingField_bookStateEnum]) {
      _bookStateEnum = [aDecoder decodeIntegerForKey:kNSCodingField_bookStateEnum];
      // 如果保存时处于 "Downloading" 状态, 那么重新序列化回来时, 要改成 "Pause" 状态
      if (_bookStateEnum == kBookStateEnum_Downloading) {
        _bookStateEnum = kBookStateEnum_Pause;
      } else if (_bookStateEnum == kBookStateEnum_Unziping) {
        _bookStateEnum = kBookStateEnum_NotInstalled;
      }
    }
    //
    if ([aDecoder containsValueForKey:kNSCodingField_bindAccount]) {
      _bindAccount = [aDecoder decodeObjectForKey:kNSCodingField_bindAccount];
    }
    //
    if ([aDecoder containsValueForKey:kNSCodingField_folder]) {
      _folder = [aDecoder decodeObjectForKey:kNSCodingField_folder];
    }
  }
  
  return self;
}

#pragma mark
#pragma mark 不能使用默认的init方法初始化对象, 而必须使用当前类特定的 "初始化方法" 初始化所有参数
- (id) init {
  RNAssert(NO, @"Can not use the default init method!");
  
  return nil;
}

#pragma mark -
#pragma mark 私有方法

// 删除书籍下载临时文件
- (void) removeBookTmpZipResFile {
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSError *error = nil;
  [fileManager removeItemAtPath:self.bookTmpZipResFilePath error:&error];
  if (error != nil) {
    NSLog(@"删除缓存的未下载完成的书籍数据失败! 错误描述:%@", error.localizedDescription);
  }
}

- (void) cancelDownloadBookNetOperation {
  //
  [self.bookDownloadOperation cancel];
  self.bookDownloadOperation = nil;
}

-(BOOL)unzipBookZipRes {
  BOOL isZipSucceed = NO;
  ZipArchive *zipArchive = nil;
  do {
    zipArchive = [[ZipArchive alloc] init];
    if (zipArchive == nil) {
      break;
    }
    if(![zipArchive UnzipOpenFile:self.bookTmpZipResFilePath]) {
      break;
    }
    if(![zipArchive UnzipFileTo:self.bookSaveDirPath overWrite:YES]) {
      break;
    }
    
    isZipSucceed = YES;
  } while (NO);
  [zipArchive UnzipCloseFile];
  
  return isZipSucceed;
}

// 解压书籍的函数, 运行在后台线程
-(void)unzipBookZipResSelectorInBackground {
  
  if ([self unzipBookZipRes]) {
    NSLog(@"解压成功");
    // 解压成功
    // 更新书籍状态->Installed
    self.bookStateEnum = kBookStateEnum_Installed;
    
    // 发送 "下载完成并且安装成功一本书籍" 的通知.
    NSNotification *userBroadcast
    = [NSNotification notificationWithName:[NSNumber numberWithInteger:kUserNotificationEnum_DownloadAndInstallSucceed].stringValue
                                    object:self
                                  userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:userBroadcast];
  } else {
    // 解压失败
    NSLog(@"解压失败");
    //    if (self.bookDownloadErrorBlock != NULL) {
    //      NSError *error = [NSError errorWithDomain:@"解压失败" code:-1 userInfo:nil];
    //      self.bookDownloadErrorBlock(error);
    //    }
    
    // 出现错误, 复位书籍状态为初始状态.
    self.bookStateEnum = kBookStateEnum_Paid;
  }
  
  // 删除临时文件
  [self removeBookTmpZipResFile];
}

#pragma mark -
#pragma mark 对外接口方法
- (void) setBookVersion:(NSString *)bookLatestVersion {
  
}

- (BOOL) startDownloadBookWithURLString:(NSString *)urlString {
  do {
    
    if ([NSString isEmpty:urlString]) {
      // 参数非法
      RNAssert(NO, @"入参urlString为空!");
      break;
    }
    PRPLog(@"要下载的书籍URL = %@", urlString);
    
    if (kBookStateEnum_Installed == self.bookStateEnum) {
      PRPLog(@"已经安装成功的书籍不能重复下载!");
      break;
    }
    
    [self cancelDownloadBookNetOperation];
    
    // 创建书籍保存路径
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:self.bookSaveDirPath]) {
      BOOL isCreateDirSuccess = [fileManager createDirectoryAtPath:self.bookSaveDirPath
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:nil];
      if (!isCreateDirSuccess) {
        // 创建书籍保存文件夹失败
        RNAssert(NO, @"创建要下载到本地的书籍的保存文件夹失败!");
        break;
      }
    }
    
    self.bookDownloadOperation = [[MKNetworkEngineSingletonForUpAndDownLoadFile sharedInstance] operationWithURLString:urlString];
    [self.bookDownloadOperation setShouldContinueWithInvalidCertificate:YES];
    [self.bookDownloadOperation addHeaders:@{@"User-Agent": [ToolsFunctionForThisProgect getUserAgent]}];
    //
    __weak LocalBook *weakSelf = self;
    
    // 本地缓存的未下载完成的 书籍zip资源包 文件路径
    
    if ([fileManager fileExistsAtPath:self.bookTmpZipResFilePath]) {
      NSError *error = nil;
      if (kBookStateEnum_Paid == self.bookStateEnum) {
        // 如果当前书籍状态是 "已付费" 状态, 证明是还未进行操作/或者下载解压过程中出现失败情况, 此时会被复位成 "Paid"
        // 此时要先删除缓存数据, 然后重新下载.
        error = nil;
        [fileManager removeItemAtPath:self.bookTmpZipResFilePath error:&error];
        if (error != nil) {
          RNAssert(NO, @"删除缓存的未下载完成的书籍数据失败! 错误描述:%@", error.localizedDescription);
          break;
        }
        
      } else {
        
        // 断点续传的支持
        unsigned long long fileSize = [[fileManager attributesOfItemAtPath:self.bookTmpZipResFilePath error:&error] fileSize];
        if (error != nil) {
          // 检索本地缓存的未下载完成的书籍数据失败, 那就删除
          PRPLog(@"检索本地缓存的未下载完成的书籍数据失败, 尝试删除未下载完成的临时文件, 好重新下载! 错误描述:%@", error.localizedDescription);
          error = nil;
          [fileManager removeItemAtPath:self.bookTmpZipResFilePath error:&error];
          if (error != nil) {
            RNAssert(NO, @"删除缓存的未下载完成的书籍数据失败! 错误描述:%@", error.localizedDescription);
            break;
          }
        } else {
          if (fileSize > 0) {
            NSString *headerRange = [NSString stringWithFormat:@"bytes=%llu-", fileSize];
            [self.bookDownloadOperation addHeaders:@{@"Range": headerRange}];
          }
        }
      }
    }
    
    //
    [self.bookDownloadOperation addDownloadStream:[NSOutputStream outputStreamToFileAtPath:self.bookTmpZipResFilePath append:YES]];
    //
    [self.bookDownloadOperation onDownloadProgressChanged:^(double progress) {
      long long expectedContentLength = weakSelf.bookDownloadOperation.readonlyResponse.expectedContentLength;
      weakSelf.downloadProgress = progress;
      NSLog(@"下载进度更新 %lld %f", expectedContentLength, progress * 100);
    }];
    //
    [self.bookDownloadOperation addCompletionHandler:^(MKNetworkOperation* completedRequest) {
      NSLog(@"下载完成");
      
      // 开始解压书籍
      weakSelf.bookStateEnum = kBookStateEnum_Unziping;
      
      // 在后台线程中解压缩书籍zip资源包.
      [weakSelf performSelectorInBackground:@selector(unzipBookZipResSelectorInBackground) withObject:nil];
      
    } errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
      
      NSLog(@"下载失败 %@", error);
      //      if (weakSelf.bookDownloadErrorBlock != NULL) {
      //        weakSelf.bookDownloadErrorBlock(error);
      //      }
      
      // 出现错误, 复位书籍状态为初始状态.
      weakSelf.bookStateEnum = kBookStateEnum_Paid;
      
      // 删除临时文件
      [weakSelf removeBookTmpZipResFile];
    }];
    [[MKNetworkEngineSingletonForUpAndDownLoadFile sharedInstance] enqueueOperation:self.bookDownloadOperation];
    
    // 更新书籍状态->Downloading
    self.bookStateEnum = kBookStateEnum_Downloading;
    
    ///
    return YES;
  } while (NO);
  
  // 出现问题, 下载书籍失败.
  return NO;
}

- (void) stopDownloadBook {
  if (self.bookStateEnum != kBookStateEnum_Downloading) {
    // 只有处于 "Downloading" 状态的书籍, 才能被暂停.
    return;
  }
  
  // 更新书籍状态->Pause
  self.bookStateEnum = kBookStateEnum_Pause;
  
  //
  [self cancelDownloadBookNetOperation];
}

// 解压一本书籍(只有当上次解压一本书籍, 没有完成时, 退出了app, 此时app的状态为 kBookStateEnum_Unziping 时, 这个方法才有意义
- (void) unzipBook {
  do {
    if (_bookStateEnum != kBookStateEnum_NotInstalled) {
      // 如果当前书籍不是 NotInstalled(未安装), 那么这个方法无效
      break;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:self.bookTmpZipResFilePath]) {
      // 如果书籍临时压缩包已经不存在了, 此方法也无效
      break;
    }
    
    // 开始解压书籍
    self.bookStateEnum = kBookStateEnum_Unziping;
    // 在后台线程中解压缩书籍zip资源包.
    [self performSelectorInBackground:@selector(unzipBookZipResSelectorInBackground) withObject:nil];
    return;
  } while (NO);
  
  // 复位书籍状态, 给用户重新下载书籍的机会
  self.bookStateEnum = kBookStateEnum_Paid;
  return;
}
#pragma mark -
#pragma mark - 对于 LocalBook 来说, 判断两个 LocalBook 是否相等的条件就是 content_id
- (BOOL)isEqual:(id)object{
  return [_bookInfo.content_id isEqualToString:((LocalBook *)object).bookInfo.content_id];
}

@end
