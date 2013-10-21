//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "NetEntityDataToolsFactoryMethodSingleton.h"
 

// DreamBook项目
#import "NetRequestEntityDataPackageForDreamBook.h"
#import "NetRespondEntityDataUnpackForDreamBook.h"
#import "ServerRespondDataTestForDreamBook.h"
#import "NetRespondDataToNSDictionaryForDreamBook.h"

@interface NetEntityDataToolsFactoryMethodSingleton()

@end

@implementation NetEntityDataToolsFactoryMethodSingleton

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
    
  }
  
  return self;
}

+ (id<INetEntityDataTools>) sharedInstance {
  static NetEntityDataToolsFactoryMethodSingleton *singletonInstance = nil;
  static dispatch_once_t pred;
  dispatch_once(&pred, ^{singletonInstance = [[self alloc] initSingleton];});
  return singletonInstance;
}

#pragma mark
#pragma mark 实现 INetEntityDataTools 接口的方法
- (id<INetRequestEntityDataPackage>) getNetRequestEntityDataPackageStrategyAlgorithm {
  return [[NetRequestEntityDataPackageForDreamBook alloc] init];
}
- (id<INetRespondRawEntityDataUnpack>) getNetRespondEntityDataUnpackStrategyAlgorithm {
  return [[NetRespondEntityDataUnpackForDreamBook alloc] init];
}
- (id<IServerRespondDataTest>) getServerRespondDataTestStrategyAlgorithm {
  return [[ServerRespondDataTestForDreamBook alloc] init];
}
- (id<INetRespondDataToNSDictionary>) getNetRespondDataToNSDictionaryStrategyAlgorithm {
  return [[NetRespondDataToNSDictionaryForDreamBook alloc] init];
}
@end
