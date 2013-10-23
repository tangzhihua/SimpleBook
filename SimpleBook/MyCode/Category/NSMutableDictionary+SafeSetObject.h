//
//  NSMutableDictionary+SafeSetObject.h
//  今日书院
//
//  Created by 唐志华 on 13-10-23.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (SafeSetObject)
// 如果 anObject 或者 aKey 为 nil 的话, 就不进行存储
- (void)safeSetObject:(id)anObject forKey:(id <NSCopying>)aKey;
@end
