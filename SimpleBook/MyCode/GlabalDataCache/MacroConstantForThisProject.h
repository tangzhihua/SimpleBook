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
  kUserNotificationEnum_OrderPayFailed
  
};


typedef NS_ENUM(NSInteger, NewVersionDetectStateEnum) {
  // 还未进行 新版本 检测
  kNewVersionDetectStateEnum_NotYetDetected = 0,
  // 服务器端有新版本存在
  kNewVersionDetectStateEnum_HasNewVersion,
  // 本地已经是最新版本
  kNewVersionDetectStateEnum_LocalAppIsTheLatest
};

 

#endif
