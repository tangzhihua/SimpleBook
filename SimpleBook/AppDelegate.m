//
//  AppDelegate.m
//  SimpleBook
//
//  Created by 唐志华 on 13-10-16.
//  Copyright (c) 2013年 唐志华. All rights reserved.
//

#import "AppDelegate.h"

#import "BookShelfViewController_ipad.h"
#import "BookShelfViewController_iPhone.h"

#import "TestBookShelfController_ipad.h"

#import "MKStoreManager.h"
//
#import "GlobalDataCacheForNeedSaveToFileSystem.h"
#import "LocalCacheDataPathConstant.h"
#import "MKNetworkEngineSingletonForUpAndDownLoadFile.h"

///
#import "CommandInvokerSingleton.h"
//
#import "CommandForInitApp.h"
#import "CommandForPrintDeviceInfo.h"
#import "CommandForGetImportantInfoFromServer.h"
#import "CommandForInitMobClick.h"
#import "CommandForNewAppVersionCheck.h"
#import "CommandForLoadingLocalCacheData.h"

@implementation AppDelegate

+ (AppDelegate *) sharedAppDelegate {
	return (AppDelegate *) [UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  PRPLog(@">>>>>>>>>>>>>>     应用程序启动      <<<<<<<<<<<<<<<<<");
  PRPLog(@">>>>>>>>>>>>>>     application:didFinishLaunchingWithOptions:      <<<<<<<<<<<<<<<<<");
  PRPLog(@"launchOptions=%@", launchOptions);
	
  
  
  id command = nil;
	
  // 初始化App, 一定要保证首先调用
  command = [CommandForInitApp commandForCommandForInitApp];
  [[CommandInvokerSingleton sharedInstance] runCommandWithCommandObject:command];
  
  // 加载本地缓存的数据, 一定要保证其次调用 (有一部分本地缓存的数据, 是必须同步加载完才能进入App的.)
  command = [CommandForLoadingLocalCacheData commandForLoadingLocalCacheData];
  [[CommandInvokerSingleton sharedInstance] runCommandWithCommandObject:command];
  
  // 打印当前设备的信息
  command = [CommandForPrintDeviceInfo commandForPrintDeviceInfo];
  [[CommandInvokerSingleton sharedInstance] runCommandWithCommandObject:command];
  
	// 从服务器获取重要的信息
  command = [CommandForGetImportantInfoFromServer commandForGetImportantInfoFromServer];
  [[CommandInvokerSingleton sharedInstance] runCommandWithCommandObject:command];
  
  // 启动友盟SDK
  command = [CommandForInitMobClick commandForInitMobClick];
  [[CommandInvokerSingleton sharedInstance] runCommandWithCommandObject:command];
  
	// 启动 "新版本信息检测" 子线程
  command = [CommandForNewAppVersionCheck commandForNewAppVersionCheck];
  [[CommandInvokerSingleton sharedInstance] runCommandWithCommandObject:command];
  
  
  // 判断当前设备 iPhone or iPad 之后加载相对应的nib文件
  
  UIViewController *firstViewController = nil;
  
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    
    /// iphone
    self.navigation = [[UINavigationController alloc] initWithRootViewController:(UIViewController *)[[BookShelfViewController_iPhone alloc] initWithNibName:@"BookShelfViewController_iPhone" bundle:nil]];
    firstViewController = self.navigation;
    
  } else {
    /// ipad
    self.navigation = [[UINavigationController alloc] initWithRootViewController:(UIViewController *)[[BookShelfViewController_ipad alloc] initWithNibName:@"TestBookShelfController_ipad" bundle:nil]];
    
    if ([GlobalDataCacheForMemorySingleton sharedInstance].isFirstStartApp) {
     
      
      firstViewController = self.navigation;
    } else {
      
      //
      firstViewController = self.navigation;
    }
  }
  
  [self.navigation.navigationBar setHidden:YES];
  
  // window
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.rootViewController = firstViewController;
  [self.window makeKeyAndVisible];
  
  {
    
    NSMutableArray *test = [NSMutableArray array];
    [test addObject:@"a"];
    [test addObject:@"b"];
    [test addObject:@"a"];
    [test addObject:@"b"];
    
    [test removeObject:@"a"];
    [test description];
  }
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  
  // Make sure we save the model when the application is quitting
  CoreData *sharedModel = [CoreData sharedModel:nil];
  [sharedModel saveContext];
}

@end
