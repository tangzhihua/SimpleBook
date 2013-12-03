//
//  StoreManager.m
//  MBEnterprise
//
//  Created by Yingjie Huo on 13-7-26.
//
//

#import "StoreManager.h"


NSString *const kInAppPurchaseManagerTransactionSucceededNotification   = @"kInAppPurchaseManagerTransactionSucceededNotification";
NSString *const kInAppPurchaseManagerTransactionFailedNotification      = @"kInAppPurchaseManagerTransactionFailedNotification";
NSString *const kInAppPurchaseManagerTransactionCanceledNotification    = @"kInAppPurchaseManagerTransactionCanceledNotification";

@implementation StoreManager

#pragma mark - Methods

- (BOOL)canMakePayments
{
  return [SKPaymentQueue canMakePayments];
}

- (void)purchaseProductWithIdentifier:(NSString *)identifier
{
  if([self canMakePayments])
  {
    // 请求产品
    [self productsRequestWithProductIdentifiers:[NSSet setWithObject:identifier]];
  }
}

- (void)productsRequestWithProductIdentifiers:(NSSet *)identifiers
{
  SKProductsRequest *proProductRequest = [[SKProductsRequest alloc]initWithProductIdentifiers:identifiers];
  proProductRequest.delegate = self;
  [proProductRequest start];
}


#pragma mark - SKProductsRequest Delegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
  NSLog(@"请求成功的产品的个数为：%d", response.products.count);
  for (SKProduct *product in response.products) {
    SKProduct *product = [response.products lastObject];
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
  }
  
  for (NSString *invalidProductId in response.invalidProductIdentifiers)
  {
    // 请求失败的产品标识
    NSLog(@"Invalid product id: %@" , invalidProductId);
  }
  
}

#pragma mark - SKPaymentTransactionObserver Delegate

// called when the transaction status is updated
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
  for (SKPaymentTransaction *transaction in transactions)
  {
    switch (transaction.transactionState)
    {
      case SKPaymentTransactionStatePurchased:
        [self completeTransaction:transaction];
        break;
        
      case SKPaymentTransactionStateFailed:
        [self failedTransaction:transaction];
        break;
        
      case SKPaymentTransactionStateRestored:
        [self restoreTransaction:transaction];
        break;
        
      case SKPaymentTransactionStatePurchasing:
        
        break;
        
      default:
        NSAssert(0, @"错误的处理状态");
        break;
    }
  }
}

// Sent when transactions are removed from the queue (via finishTransaction:).
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions {
  for (SKPaymentTransaction *transaction in transactions) {
    if (transaction.transactionState != SKPaymentTransactionStatePurchased) {
      [[NSNotificationCenter defaultCenter] postNotificationName:transaction.payment.productIdentifier object:self];
    }
  }
}


#pragma - Purchase helpers

// called when the transaction was successful
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
  [self recordTransaction:transaction];
  [self provideContent:transaction.payment.productIdentifier];
  [self finishTransaction:transaction paymentTransactionStatus:SMPaymentTransactionStatusSucceeded];
}

// called when a transaction has been restored and and successfully completed
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
  [self recordTransaction:transaction.originalTransaction];
  [self provideContent:transaction.originalTransaction.payment.productIdentifier];
  [self finishTransaction:transaction paymentTransactionStatus:SMPaymentTransactionStatusSucceeded];
}

// called when a transaction has failed
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
  if (transaction.error.code == SKErrorPaymentCancelled) {
    // this is fine, the user just cancelled.
    [self finishTransaction:transaction paymentTransactionStatus:SMPaymentTransactionStatusCancel];
  } else {
    // error!
    [self finishTransaction:transaction paymentTransactionStatus:SMPaymentTransactionStatusFailed];
  }
}

// saves a record of the transaction by storing the receipt to disk
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
  //    if ([transaction.payment.productIdentifier isEqualToString:@""])
  //    {
  //        // save the transaction receipt to disk
  //        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"proUpgradeTransactionReceipt" ];
  //        [[NSUserDefaults standardUserDefaults] synchronize];
  //    }
}

// enable pro features
- (void)provideContent:(NSString *)productId
{
  //    if ([productId isEqualToString:@""])
  //    {
  //        // enable the pro features
  //        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isProUpgradePurchased" ];
  //        [[NSUserDefaults standardUserDefaults] synchronize];
  //    }
}



// removes the transaction from the queue and posts a notification with the transaction result
- (void)finishTransaction:(SKPaymentTransaction *)transaction paymentTransactionStatus:(SMPaymentTransactionStatus)status
{
  // remove the transaction from the payment queue.
  [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
  NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
  switch (status) {
    case SMPaymentTransactionStatusSucceeded:
      // send out a notification that we’ve finished the transaction
      [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
      break;
    case SMPaymentTransactionStatusFailed:
      // send out a notification for the failed transaction
      [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
      break;
    case SMPaymentTransactionStatusCancel:
      [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionCanceledNotification object:self userInfo:userInfo];
      break;
    default:
      break;
  }
}



#pragma mark - Singleton Setting Method

static StoreManager *sharedInstance = nil;

+ (StoreManager *)sharedInstance
{
  static dispatch_once_t onceToken; // 锁
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

- (id)init
{
  self = [super init];
  if (self) {
    // 通常在这里做一些相关的初始化任务
  }
  return self;
}

// 通过返回当前的 sharedInstance 实例,就能防止实例化一个新的对象。
+ (id)allocWithZone:(NSZone*)zone
{
  @synchronized(self) {
		if (sharedInstance == nil) {
			sharedInstance = [super allocWithZone:zone];
		}
	}
	return sharedInstance;
}

// 同样,不希望生成单例的多个拷贝。
- (id)copyWithZone:(NSZone *)zone
{
  return self;
}

@end

