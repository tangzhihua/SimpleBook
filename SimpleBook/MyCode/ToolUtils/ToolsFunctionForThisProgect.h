//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import <Foundation/Foundation.h>

@class VersionNetRespondBean;
@class LogonNetRespondBean;
@interface ToolsFunctionForThisProgect : NSObject {
  
}

+(void)noteLogonSuccessfulInfoWithLogonNetRespondBean:(LogonNetRespondBean *)LogonNetRespondBean
									usernameForLastSuccessfulLogon:(NSString *)usernameForLastSuccessfulLogon
									passwordForLastSuccessfulLogon:(NSString *)passwordForLastSuccessfulLogon;


// 同步网络请求App最新版本信息(一定要在子线程中调用此方法, 因为使用sendSynchronousRequest发起的网络请求), 并且返回 VersionNetRespondBean
+(VersionNetRespondBean *)synchronousRequestAppNewVersionAndReturnVersionBean;

// 使用 Info.plist 中的 "Bundle version" 来保存本地App Version
+(NSString *)localAppVersion;

// 加载内部错误时的UI(Activity之间传递的必须参数无效), 并且隐藏 bodyLayout, 这里的设计要统一划一, 如果想要使用这种设计, 就要按照要求设计bodyLayout
+(void)loadIncomingIntentValidUIWithSuperView:(UIView *)superView andHideBodyLayout:(UIView *)bodyLayout;

// 将 "秒" 格式化成 "天小时分钟秒", 例如 : 入参是 118269(秒), 返回 "1天8时51分9秒"
+(NSString *)formatSecondToDayHourMinuteSecond:(NSNumber *)secondSource;

// 获取当前设备的UA信息
+(NSString *)getUserAgent;

// 格式化 书籍zip资源包大小的字符串显示, 服务器传过来的是 byte 为单位的, 我们要进行格式化为 B KB MB 为单位的字符串
+(NSString *)formatBookZipResSizeString:(NSString *)bookZipResSize;
@end
