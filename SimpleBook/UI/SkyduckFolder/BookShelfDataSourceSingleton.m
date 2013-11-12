//
//  BookFolderDataSourceSingleton.m
//  SimpleBook
//
//  Created by 唐志华 on 13-11-11.
//  Copyright (c) 2013年 唐志华. All rights reserved.
//

#import "BookShelfDataSourceSingleton.h"
#import "SkyduckFile.h"

@interface BookShelfDataSourceSingleton ()

@end
@implementation BookShelfDataSourceSingleton
#pragma mark -
#pragma mark Singleton Implementation

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
		_rootDirectory = [SkyduckFile createDirectory];
  }
  
  return self;
}

+ (BookShelfDataSourceSingleton *) sharedInstance {
  static BookShelfDataSourceSingleton *singletonInstance = nil;
  static dispatch_once_t pred;
  dispatch_once(&pred, ^{singletonInstance = [[self alloc] initSingleton];});
  return singletonInstance;
}
@end
