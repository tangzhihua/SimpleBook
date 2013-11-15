//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#ifndef airizu_MacroConstantForThisProject_h
#define airizu_MacroConstantForThisProject_h


/******************         服务器返回的错误枚举      *********************/
typedef NS_ENUM(NSInteger, NetErrorCodeWithServerEnum) {
  kNetErrorCodeWithServerEnum_Failed    = 1000, // "操作失败"
  kNetErrorCodeWithServerEnum_Exception = 2000, // "处理异常"
  kNetErrorCodeWithServerEnum_Noresult  = 3000, // "无结果返回"
  kNetErrorCodeWithServerEnum_Needlogin = 4000  // "需要登录"
};

typedef NS_ENUM(NSInteger, UserNotificationEnum) {
	
	// 从服务器获取重要信息成功
	kUserNotificationEnum_GetImportantInfoFromServerSuccess = 2013,
  // 用户登录 "成功"
  kUserNotificationEnum_UserLogonSuccess,
  // 用户已经退出登录
  kUserNotificationEnum_UserLoged,
  
  // 获取软件新版本信息 "成功"
  kUserNotificationEnum_GetNewAppVersionSuccess,
  
  // 订单支付成功
  kUserNotificationEnum_OrderPaySucceed,
  // 订单支付失败
  kUserNotificationEnum_OrderPayFailed,
  
  
  // 下载完成并且安装成功一本书籍
  kUserNotificationEnum_DownloadAndInstallSucceed
};


typedef NS_ENUM(NSInteger, NewVersionDetectStateEnum) {
  // 还未进行 新版本 检测
  kNewVersionDetectStateEnum_NotYetDetected = 0,
  // 服务器端有新版本存在
  kNewVersionDetectStateEnum_HasNewVersion,
  // 本地已经是最新版本
  kNewVersionDetectStateEnum_LocalAppIsTheLatest
};

#define IS_IOS7             ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
#define CURRENT_IOS_VERSION [[UIDevice currentDevice].systemVersion floatValue]

// message title
//#define MSG_I_DEF              @"情報"
//#define MSG_W_DEF              @"警告"
//#define MSG_E_DEF              @"エラー"
//#define MSG_Q_DEF              @"確認"

// message title
//#define MSG_E_TITLE_LOGIN      @"認証エラー"
//#define MSG_E_LOGIN            @"ログインに失敗しました。IDとパスワードをご確認ください。"


//#define MSG_Q_LOGOUT           @"ログアウトしますよろしいですか？"
//#define MSG_E_NETWORK_OFFLINE  @"ネットワークの接続を確認してください。"
//#define MSG_E_AUTH             @"ログインに失敗しました。再度認証を行ってください。"
//#define MSG_E_AUTHFAILE        @"認証情報が無効です。再度認証を行ってください。"


//#define MSG_E_TITLE_NETWORK    @"ネットワーク無効"
//#define MSG_E_NETWORK          @"Wi-Fiネットワークかモバイルデータ通信を利用する必要があります。"

//#define MSG_I_DOWNLOADED       @"ダウンロード中..." // @"Please wait...\n\n\n"
//#define MSG_I_UNZIP            @"解凍中ですお待ちください。" // @"Please wait...\n\n\n"
//#define MSG_E_UNZIP            @"解凍に失敗しましたコンテンツの管理者に問い合わせてください。"

//#define MSG_I_OVER_EXPIRED     @"有効期限を過ぎているため、\n閲覧できません。"

// login view
//#define DEF_DESC_DIALOG_AUTH   @"アカウント認証"
//#define DEF_DESC_SWITCH_IDSAVE @"認証情報の保存"
//#define DEF_DESC_ID            @"ID"
//#define DEF_DESC_PASSWORD      @"PASSWORD"


// 7777 search
// 8888 ID
// 9999 PASSWORD

#define DEF_HTTP_POST           @"POST"
#define DEF_HTTP_GET            @"GET"
#define DEF_HTTP_USERAGENT      @"User-Agent"
#define DEF_HTTP_USERID         @"user_id="
#define DEF_HTTP_USERPASSWORD   @"&user_password="
#define DEF_HTTP_USERAGENT_FMT  @"%@_%@_%@%@_iOS%d.%d" // MbEnterprise_1.0_[Hardware]_[OS version] >> Ikemen_1.0_iPhone Simulator5.0_iOS5.0


// userdefault
//#define DEF_UD_ISSAVECOOKIE     @"SaveAccount"
//#define DEF_UD_USERID           @"UserID"   // _kawa 20120615  logout message + user_id
#define UD_USERNAME             @"username"
#define UD_USERPASSWORD         @"userpassword"
// public account
#define PUBLIC_USERNAME         @"public"
#define PUBLIC_PASSWORD         @"pwpublic"

#endif
