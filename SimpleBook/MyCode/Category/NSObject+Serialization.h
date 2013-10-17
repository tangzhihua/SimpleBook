//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import <Foundation/Foundation.h>

// 序列化对象到文件
@interface NSObject (Serialization)


- (void)serializeObjectToFileSystemWithFileName:(NSString *)fileName directoryPath:(NSString *)directoryPath;
+ (id)deserializeObjectFromFileSystemWithFileName:(NSString *)fileName directoryPath:(NSString *)directoryPath;

- (void)serializeObjectToFileSystemWithPath:(NSString *)path;
+ (id)deserializeObjectFromFileSystemWithPath:(NSString *)path;
@end
