//
//  NSMutableDictionary+SafeSetObject.m
//  今日书院
//
//  Created by 唐志华 on 13-10-23.
//
//

#import "NSMutableDictionary+SafeSetObject.h"

@implementation NSMutableDictionary (SafeSetObject)
// 如果 anObject 或者 aKey 为 nil 的话, 就不进行存储
- (void)safeSetObject:(id)anObject forKey:(id <NSCopying>)aKey {
  if (anObject == nil || aKey == nil) {
    return;
  }
  
  [self setObject:anObject forKey:aKey];
}
@end
