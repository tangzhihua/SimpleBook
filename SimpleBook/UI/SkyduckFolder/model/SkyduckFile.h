//
//  SkyduckFile.h
//  SimpleBook
//
//  Created by 唐志华 on 13-11-11.
//  Copyright (c) 2013年 唐志华. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SkyduckFile : NSObject

// 如果是文件 value 可以保存 书籍的contentID, 如果是文件夹, 可以保存文件夹的名称
@property (nonatomic, copy) NSString *value;
//
@property (nonatomic, strong, readonly) NSMutableArray *listFiles;

-(BOOL)isFile;
-(BOOL)isDirectory;

-(void)addFile:(SkyduckFile *)file;
-(void)removeFile:(SkyduckFile *)file;


+(SkyduckFile *)createFile;
+(SkyduckFile *)createDirectory;
+(SkyduckFile *)createFileWithValue:(NSString *)value;
+(SkyduckFile *)createDirectoryWithValue:(NSString *)value files:(NSArray *)files;
@end
