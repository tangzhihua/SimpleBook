//
//  GlobalDataCache.h
//  
//
//  Created by 唐志华 on 12-9-13.
//
//  内存级别缓存
//
//  这是是 "按需缓存" , 内部使用 "数据模型缓存" 实现.
//
//

#import <Foundation/Foundation.h>

// 用于外部 KVO 的, 属性名称(字符串格式).
#define kGlobalDataCacheForMemorySingletonProperty_logonNetRespondBean @"logonNetRespondBean"

@class LogonNetRespondBean;
@class LocalBookList;
@class LocalBookshelfCategoriesNetRespondBean;

@interface GlobalDataCacheForMemorySingleton : NSObject {
  
}

// 用户第一次启动App
@property (nonatomic, assign) BOOL isFirstStartApp;
// 是否需要在app启动时, 显示 "初学者指南界面"
@property (nonatomic, assign, setter=setNeedShowBeginnerGuide:) BOOL isNeedShowBeginnerGuide;
// 是否需要自动登录的标志
@property (nonatomic, assign, setter=setNeedAutologin:) BOOL isNeedAutologin;

 

 
// 用户登录成功后, 服务器返回的信息(判断有无此对象来判断当前用户是否已经登录)
@property (nonatomic, strong) LogonNetRespondBean *logonNetRespondBean;

 
// 用户最后一次登录成功时的用户名/密码(企业账户/公共账户 登录成功都会保存在这里)
@property (nonatomic, copy) NSString *usernameForLastSuccessfulLogon;
@property (nonatomic, copy) NSString *passwordForLastSuccessfulLogon;

// 本地缓存目录大小
@property (nonatomic, readonly) NSUInteger localCacheSize;


// 本地书籍列表
@property (nonatomic, strong) LocalBookList *localBookList;
// 本地书籍分类
@property (nonatomic, strong) LocalBookshelfCategoriesNetRespondBean *localBookshelfCategoriesNetRespondBean;

// TODO
// 当前可用的主机名(因为目前https网站还未配置完成, 所以临时还使用 https://61.177.139.215:8443 这个地址, 但是会判断https://dreambook.retechcorp.com 是否可用.
// 这里的设计是临时存在的, 将来还是要固定使用 https://dreambook.retechcorp.com
@property (nonatomic, copy) NSString *hostName;

#pragma mark -
#pragma mark 单例
+ (GlobalDataCacheForMemorySingleton *) sharedInstance;
@end
