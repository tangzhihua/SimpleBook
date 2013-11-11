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
@property (nonatomic, strong, readwrite) NSMutableArray *listFiles;
@end

@implementation SkyduckFile {
  
}

-(NSMutableArray *)listFiles{
  if (_listFiles == nil && self.isDirectory) {
    _listFiles = [[NSMutableArray alloc] init];
  }
  
  return _listFiles;
}

-(BOOL)isFile {
  return _isFile;
}
-(BOOL)isDirectory {
  return !_isFile;
}

-(void)addFile:(SkyduckFile *)file {
  do {
    if (self.isFile) {
      // 文件不能包含文件
      break;
    }
    
    if ([self containsSkyduckFile:file]) {
      // 文件已经存在
      break;
    }
    
    [self.listFiles addObject:file];
  } while (NO);
}

-(void)removeFile:(SkyduckFile *)file {
  do {
    if (self.isFile) {
      // 文件不能包含文件
      break;
    }
    
    for (SkyduckFile *tempFile in self.listFiles) {
      if (tempFile.isFile && file.isFile && [tempFile.value isEqualToString:file.value]) {
        [self.listFiles removeObject:tempFile];
      } else if (tempFile.isDirectory && file.isDirectory && [tempFile.value isEqualToString:file.value]) {
        [self.listFiles removeObject:tempFile];
      }
    }
  } while (NO);
}

- (BOOL)containsSkyduckFile:(SkyduckFile *)file {
  for (SkyduckFile *tempFile in self.listFiles) {
    if (tempFile.isFile && file.isFile && [tempFile.value isEqualToString:file.value]) {
      return YES;
    } else if (tempFile.isDirectory && file.isDirectory && [tempFile.value isEqualToString:file.value]) {
      return YES;
    }
  }
  
  return NO;
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
  return file;
}
+(SkyduckFile *)createDirectoryWithValue:(NSString *)value files:(NSArray *)files {
  SkyduckFile *directory = [[SkyduckFile alloc] init];
  directory.isFile = NO;
  directory.value = value;
  for (SkyduckFile *file in files) {
    [directory addFile:file];
  }
  return directory;
}

@end
