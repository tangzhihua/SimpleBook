//
//  LocalBook.h
//  MBEnterprise
//
//  Created by 唐志华 on 13-9-22.
//
//

#import "BaseModel.h"


// 用于外部 KVO 的, 属性名称(字符串格式).
#define kLocalBookProperty_bookStateEnum    @"bookStateEnum"
#define kLocalBookProperty_downloadProgress @"downloadProgress"

// 书籍下载解压过程中, 如果发生错误时, 通知控制层的块
typedef void (^BookDownloadErrorBlock)(NSError* error);

// 书籍状态枚举
typedef NS_ENUM(NSInteger, BookStateEnum) {
  
  // 未付费(只针对收费的书籍, 如果是免费的书籍, 会直接到下一个状态.
  kBookStateEnum_Unpaid = 0,
  // 支付中....
  kBookStateEnum_Paiding,
  // 已付费(已付费的书籍可以直接下载了)
  kBookStateEnum_Paid,
  // 正在下载中...
  kBookStateEnum_Downloading,
  // 暂停(也就是未下载完成, 可以进行断电续传)
  kBookStateEnum_Pause,
  // 未安装(已经下载完成, 还未完成安装)
  kBookStateEnum_NotInstalled,
  // 解压书籍zip资源包中....
  kBookStateEnum_Unziping,
  // 已安装(已经解压开的书籍, 可以正常阅读了)
  kBookStateEnum_Installed,
  // 有可以更新的内容
  kBookStateEnum_Update
};

@class BookInfo;
@class LogonNetRespondBean;
@interface LocalBook : BaseModel

// 书籍信息(从服务器获取的, 这个属性在初始化 LocalBook 时被赋值, 之后就是只读数据了)
@property (nonatomic, strong) BookInfo *bookInfo;

// 下载进度, 100% 数值是 1, 外部可以这样计算完成百分比 downloadProgress * 100
@property (nonatomic, readonly) double downloadProgress;

// 书籍状态
@property (nonatomic, assign) BookStateEnum bookStateEnum;

// 书籍下载解压过程中, 如果发生错误时, 通知控制层的块
@property (nonatomic, copy) BookDownloadErrorBlock bookDownloadErrorBlock;

// 书籍保存文件夹路径
@property (nonatomic, readonly, copy) NSString *bookSaveDirPath;

// 从书城中, 点击一本还未下载的书籍时, 这本书籍会被加入 "本地书籍列表(在 GlobalDataCacheForMemorySingleton->localBookList 中保存)"
// 目前有两个需求:
// 1) 当A账户登录书城下载书籍时, 如果此时A账户退出了(或者被B账户替换了), 那么就要暂停正在进行下载的所有跟A账户绑定的书籍;
//    这里考虑的一点是, 如果A/B账户切换时, 当前账户是希望独享下载网速的.
//    但是, 对于跟 "公共账户" 绑定的书籍, 是不需要停止下载的.
// 2) 已经存在于 "本地书籍列表" 中的未下载完成的书籍, 再次进行断点续传时, 需要将跟这本书绑定的账号信息传递给服务器, 才能获取到最新的书籍下载地址.
//    因为服务器为了防止盗链, 所以每次断点续传时, 都需要重新获取目标书籍的最新下载地址.
@property (nonatomic, strong) LogonNetRespondBean *bindAccount;

// 当前书籍所归属的本地文件夹
@property (nonatomic, copy) NSString *folder;

#pragma mark -
#pragma mark 构造方法
- (id) initWithBookInfo:(BookInfo *)bookInfo;

#pragma mark -
#pragma mark 对外接口方法
// 设置当前书籍最新的版本(可以通过书籍的版本来确定服务器是否有可以下载的更新包)
- (void) setBookVersion:(NSString *)bookLatestVersion;
// 开始下载一本书籍(为了防止盗链, 所以每次下载书籍时的URL都是一次性的)
- (BOOL) startDownloadBookWithURLString:(NSString *)urlString;
// 停止下载一本书籍
- (void) stopDownloadBook;

@end
