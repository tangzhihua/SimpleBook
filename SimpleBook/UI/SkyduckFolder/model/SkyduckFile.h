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
@property (nonatomic, strong, readonly) NSArray *listFiles;

-(BOOL)isFile;
-(BOOL)isDirectory;


// 属于 "文件夹" 专有的方法
-(void)addFile:(SkyduckFile *)file;
-(void)insertFile:(SkyduckFile *)anFile atIndex:(NSUInteger)index;
-(void)removeFile:(SkyduckFile *)file;
-(void)removeFileAtIndex:(NSUInteger)index;

+(SkyduckFile *)createFile;
+(SkyduckFile *)createDirectory;
+(SkyduckFile *)createFileWithValue:(NSString *)value;
+(SkyduckFile *)createDirectoryWithValue:(NSString *)value files:(NSArray *)files;
@end
