//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "ToolsFunctionForThisProgect.h"

#import "NSDictionary+SafeValue.h"
#import "MacroConstantForThisProject.h"
#import "SimpleCookieSingleton.h"
#import "VersionNetRespondBean.h"
#import "LogonNetRespondBean.h"

@implementation ToolsFunctionForThisProgect

#pragma mark
#pragma mark 不能使用默认的init方法初始化对象, 而必须使用当前类特定的 "初始化方法" 初始化所有参数
- (id) init {
  RNAssert(NO, @"Can not use the default init method!");
  
  return nil;
}

// 同步网络请求App最新版本信息(一定要在子线程中调用此方法, 因为使用sendSynchronousRequest发起的网络请求), 并且返回 VersionNetRespondBean
// 今日书院(我们的app id) : 722737021
// 蚂蚁短租(用于测试) : 494520120
#define APP_URL @"http://itunes.apple.com/lookup?id=722737021"
+(VersionNetRespondBean *)synchronousRequestAppNewVersionAndReturnVersionBean {
  VersionNetRespondBean *versionBean = nil;
  
  do {
    
    NSString *URL = APP_URL;
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setURL:[NSURL URLWithString:URL]];
    [urlRequest setHTTPMethod:@"POST"];
    NSHTTPURLResponse *urlResponse = nil;
    NSError *error = nil;
    // 同步请求网络数据
    NSData *recervedData
    = [NSURLConnection sendSynchronousRequest:urlRequest
                            returningResponse:&urlResponse
                                        error:&error];
    if (![recervedData isKindOfClass:[NSData class]]) {
      break;
    }
    if (recervedData.length <= 0) {
      break;
    }
    urlRequest = nil;
    
    NSDictionary *jsonRootNSDictionary = [NSJSONSerialization JSONObjectWithData:recervedData options:0 error:&error];
    
    if (![jsonRootNSDictionary isKindOfClass:[NSDictionary class]]) {
      break;
    }
    //NSString *jsonString = [[NSString alloc] initWithData:recervedData encoding:NSUTF8StringEncoding];
    
    NSArray *infoArray = [jsonRootNSDictionary objectForKey:@"results"];
    if ([infoArray count] > 0) {
      NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
      NSString *lastVersion = [releaseInfo objectForKey:@"version"];
      NSString *trackViewUrl = [releaseInfo objectForKey:@"trackViewUrl"];
      NSString *fileSizeBytes = [releaseInfo objectForKey:@"fileSizeBytes"];
      NSString *releaseNotes = [releaseInfo objectForKey:@"releaseNotes"];
      versionBean = [VersionNetRespondBean versionNetRespondBeanWithNewVersion:lastVersion
                                                                   andFileSize:fileSizeBytes
                                                              andUpdateContent:releaseNotes
                                                            andDownloadAddress:trackViewUrl];
    }
  } while (NO);
  
  return versionBean;
}

/*
 Xcode4有两个版本号，一个是Version,另一个是Build,对应于Info.plist的字段名分别为CFBundleShortVersionString,CFBundleVersion。
 友盟SDK为了兼容Xcode3的工程，默认取的是Build号，如果需要取Xcode4的Version，可以使用下面的方法。
 
 NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
 */
// 使用 Info.plist 中的 "Bundle version" 来保存本地App Version
+(NSString *)localAppVersion {
  NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
  NSString *appVersion = [infoDic objectForKey:@"CFBundleVersion"];
  return appVersion;
}

static NSString *userAgentString = nil;
+(NSString *)getUserAgent {
  if ([NSString isEmpty:userAgentString]) {
    NSString *bundleName = @"DreamBook";
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *model = [[UIDevice currentDevice] model];
    NSArray *aOsVersions = [[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."];
    NSString *modelVersion = [[UIDevice currentDevice] systemVersion];
    NSInteger iOsVersionMajor = [[aOsVersions objectAtIndex:0] intValue];
    NSInteger iOsVersionMinor1 = [[aOsVersions objectAtIndex:1] intValue];
    userAgentString = [NSString stringWithFormat:@"%@_%@_%@%@_iOS%d.%d", bundleName, version, model, modelVersion, iOsVersionMajor, iOsVersionMinor1];
  }
  
  return  userAgentString;
}

// 格式化 书籍zip资源包大小的字符串显示, 服务器传过来的是 byte 为单位的, 我们要进行格式化为 B KB MB 为单位的字符串
+(NSString *)formatBookZipResSizeString:(NSString *)bookZipResSize {
  if ([NSString isEmpty:bookZipResSize]) {
    RNAssert(NO, @"入参异常 bookZipResSize 为空.");
    return nil;
  }
  
  long long longLongValue = [bookZipResSize longLongValue];
  if (longLongValue <= 0) {
    return @"0 B";
  }
  
  if (longLongValue >= 1024 * 1024) {
    return [NSString stringWithFormat:@"%.2f M", longLongValue / (float)(1024 * 1024)];
  } else if (longLongValue >= 1024) {
    return [NSString stringWithFormat:@"%.2f K", longLongValue / (float)(1024)];
  } else {
    return [NSString stringWithFormat:@"%.2f B", (float)longLongValue];
  }
  
}
@end
