//
//  StoreManager.h
//  MBEnterprise
//
//  Created by Yingjie Huo on 13-7-26.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>


extern NSString *const kInAppPurchaseManagerTransactionSucceededNotification;
extern NSString *const kInAppPurchaseManagerTransactionFailedNotification;
extern NSString *const kInAppPurchaseManagerTransactionCanceledNotification;

// 交易处理状态
typedef NS_ENUM(NSInteger, SMPaymentTransactionStatus) {
  SMPaymentTransactionStatusCancel,
  SMPaymentTransactionStatusSucceeded,
  SMPaymentTransactionStatusFailed
};

@interface StoreManager : NSObject<SKPaymentTransactionObserver, SKProductsRequestDelegate>

+ (StoreManager *)sharedInstance;
- (BOOL)canMakePayments;
// 购买产品
- (void)purchaseProductWithIdentifier:(NSString *)identifier;

@end
