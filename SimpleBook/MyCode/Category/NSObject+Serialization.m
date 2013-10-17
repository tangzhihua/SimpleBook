//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "NSObject+Serialization.h"

@implementation NSObject (Serialization)

- (void)serializeObjectToFileSystemWithPath:(NSString *)path {
  @synchronized(self) {
    do {
      if (![self conformsToProtocol:@protocol(NSCoding)]) {
        RNAssert(NO, @"-->必须实现 NSCoding 协议");
        break;
      }
      
      if ([NSString isEmpty:path]) {
        RNAssert(NO, @"-->入参异常 fileName 或者 directoryPath 为空.");
        break;
      }
      
      // 先删除旧的序列化文件.
      NSFileManager *fileManager = [NSFileManager defaultManager];
      if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        [fileManager removeItemAtPath:path error:&error];
        if (error != nil) {
          NSLog(@"删除序列化到本地的对象文件失败! 错误描述:%@", error.localizedDescription);
          break;
        }
      }
      
      BOOL isSaveSuccessful = [NSKeyedArchiver archiveRootObject:self toFile:path];
      NSLog(@"序列化保存对象 %@ 结果 = %@", path, [[NSNumber numberWithBool:isSaveSuccessful] description]);
    } while (NO);
    
  }
  
}

-(void)serializeObjectToFileSystemWithFileName:(NSString *)fileName directoryPath:(NSString *)directoryPath {
  if ([NSString isEmpty:fileName] || [NSString isEmpty:directoryPath]) {
    RNAssert(NO, @"-->入参异常 fileName 或者 directoryPath 为空.");
    return;
  }
  
  // 先删除旧的序列化文件.
  NSString *serializeObjectPath = [directoryPath stringByAppendingPathComponent:fileName];
  [self serializeObjectToFileSystemWithPath:serializeObjectPath];
}

+ (id)deserializeObjectFromFileSystemWithPath:(NSString *)path {
  @synchronized(self) {
    
    if (![self conformsToProtocol:@protocol(NSCoding)]) {
      RNAssert(NO, @"-->必须实现 NSCoding 协议");
      return nil;
    }
    
    if ([NSString isEmpty:path]) {
      RNAssert(NO, @"-->入参异常 path 为空.");
      return nil;
    }
    
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
  }
}

+(id)deserializeObjectFromFileSystemWithFileName:(NSString *)fileName directoryPath:(NSString *)directoryPath {
  if ([NSString isEmpty:fileName] || [NSString isEmpty:directoryPath]) {
    RNAssert(NO, @"-->入参异常 fileName 或者 directoryPath 为空.");
    return nil;
  }
  
  NSString *serializeObjectPath = [directoryPath stringByAppendingPathComponent:fileName];
  return [self deserializeObjectFromFileSystemWithPath:serializeObjectPath];
}
@end
