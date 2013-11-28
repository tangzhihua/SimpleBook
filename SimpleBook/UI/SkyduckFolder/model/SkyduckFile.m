//
//  SkyduckFile.m
//  SimpleBook
//
//  Created by 唐志华 on 13-11-11.
//  Copyright (c) 2013年 唐志华. All rights reserved.
//

#import "SkyduckFile.h"

@interface SkyduckFile ()
@property (nonatomic, assign) BOOL isFile;
@property (nonatomic, strong, readwrite) NSArray *listFiles;
@end

@implementation SkyduckFile

- (NSString *)description {
	return descriptionForDebug(self);
}

-(BOOL)isFile {
  return _isFile;
}
-(BOOL)isDirectory {
  return !_isFile;
}

-(void)addFile:(SkyduckFile *)file {
  if (_isFile) {
    // 文件不能包含文件
    return;
  }
  
  [(NSMutableArray *)_listFiles addObject:file];
}

-(void)insertFile:(SkyduckFile *)anFile atIndex:(NSUInteger)index {
  if (_isFile) {
    // 文件不能包含文件
    return;
  }
  
  [(NSMutableArray *)_listFiles insertObject:anFile atIndex:index];
}

-(void)removeFile:(SkyduckFile *)file {
  if (_isFile) {
    // 文件不能包含文件
    return;
  }
  
  [(NSMutableArray *)_listFiles removeObject:file];
}

-(void)removeFileAtIndex:(NSUInteger)index {
  if (_isFile) {
    // 文件不能包含文件
    return;
  }
  
  [(NSMutableArray *)_listFiles removeObjectAtIndex:index];
}

- (BOOL)isEqual:(id)object {
  SkyduckFile *destFile = (SkyduckFile *)object;
  if (_isFile) {
    // 是文件时, 比较 value
    return [_value isEqualToString:destFile.value];
  } else {
    // 是文件夹时, 只需要比较是否是同一个对象即可
    return self == object;
  }
}

+(SkyduckFile *)createFile {
  return [self createFileWithValue:nil];
}

+(SkyduckFile *)createDirectory {
  return [self createDirectoryWithValue:nil files:nil];
}

+(SkyduckFile *)createFileWithValue:(NSString *)value {
  SkyduckFile *file = [[SkyduckFile alloc] init];
  file.isFile = YES;
  file.value = value;
  file.listFiles = nil;
  return file;
}

+(SkyduckFile *)createDirectoryWithValue:(NSString *)value files:(NSArray *)files {
  SkyduckFile *directory = [[SkyduckFile alloc] init];
  directory.isFile = NO;
  directory.value = value;
  directory.listFiles = [NSMutableArray array];
  [(NSMutableArray *)directory.listFiles addObjectsFromArray:files];
  return directory;
}

@end
