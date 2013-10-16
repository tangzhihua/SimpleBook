//
//  CommandForNewAppVersionCheck.m
//  airizu
//
//  Created by 唐志华 on 13-3-22.
//
//

#import "CommandForNewAppVersionCheck.h"
#import "VersionNetRespondBean.h"
#import "UIAlertView+Blocks.h"
#import "AppDelegate.h"



@interface CommandForNewAppVersionCheck ()

// 这个命令只能执行一次
@property (nonatomic, assign) BOOL isExecuted;
@end

@implementation CommandForNewAppVersionCheck {
	
	
	// 检查当前App的版本信息
	VersionNetRespondBean *_versionBean;
}

/**
 
 * 执行命令对应的操作
 
 */
-(void)execute {
  if (!self.isExecuted) {
		self.isExecuted = YES;
    
    __weak id weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      do {
        _versionBean = [ToolsFunctionForThisProgect synchronousRequestAppNewVersionAndReturnVersionBean];
        
      } while (NO);
      
      dispatch_async(dispatch_get_main_queue(), ^{
        // 更新界面
        if (_versionBean != nil) {
          if (![_versionBean.latestVersion isEqualToString:[ToolsFunctionForThisProgect localAppVersion]]) {
            [weakSelf newAppUpdateHint];
          }
        }
        
        
      });
    });
 
  }
}

#pragma mark -
#pragma mark 单例方法群

// 使用 Grand Central Dispatch (GCD) 来实现单例, 这样编写方便, 速度快, 而且线程安全.
-(id)init {
  // 禁止调用 -init 或 +new
  RNAssert(NO, @"Cannot create instance of Singleton");
  
  // 在这里, 你可以返回nil 或 [self initSingleton], 由你来决定是返回 nil还是返回 [self initSingleton]
  return nil;
}

// 真正的(私有)init方法
-(id)initSingleton {
  self = [super init];
  if ((self = [super init])) {
    // 初始化代码
    _isExecuted = NO;
    
  }
  
  return self;
}

+(id)commandForNewAppVersionCheck {
	
  static CommandForNewAppVersionCheck *singletonInstance = nil;
  static dispatch_once_t pred;
  dispatch_once(&pred, ^{singletonInstance = [[self alloc] initSingleton];});
  return singletonInstance;
}

#pragma mark -
#pragma mark 子线程 ------> App新版本检查
-(void)newAppUpdateHint{
  
  if ([NSString isEmpty:_versionBean.downloadAddress]) {
    return;
  }
  [UIAlertView showAlertViewWithTitle:@"有新的版本更新，是否前往更新？"
                              message:_versionBean.updateContent
                    cancelButtonTitle:@"关闭"
                    otherButtonTitles:[NSArray arrayWithObject:@"升级"]
                       alertViewStyle:UIAlertViewStyleDefault
                            onDismiss:^(UIAlertView *alertView, int buttonIndex) {
                              UIApplication *application = [UIApplication sharedApplication];
                              [application openURL:[NSURL URLWithString:_versionBean.downloadAddress]];
                            } onCancel:^{
                              
                            }];
  
}

@end
