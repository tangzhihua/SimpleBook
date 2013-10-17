//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import <Foundation/Foundation.h>

@class VersionNetRespondBean;
@class LogonNetRespondBean;
@interface ToolsFunctionForThisProgect : NSObject

// 同步网络请求App最新版本信息(一定要在子线程中调用此方法, 因为使用sendSynchronousRequest发起的网络请求), 并且返回 VersionNetRespondBean
+(VersionNetRespondBean *)synchronousRequestAppNewVersionAndReturnVersionBean;

// 使用 Info.plist 中的 "Bundle version" 来保存本地App Version
+(NSString *)localAppVersion;

// 获取当前设备的UA信息
+(NSString *)getUserAgent;

// 格式化 书籍zip资源包大小的字符串显示, 服务器传过来的是 byte 为单位的, 我们要进行格式化为 B KB MB 为单位的字符串
+(NSString *)formatBookZipResSizeString:(NSString *)bookZipResSize;
@end
