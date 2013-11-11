//
//  SkyduckFile.h
//  SimpleBook
//
//  Created by 唐志华 on 13-11-11.
//  Copyright (c) 2013年 唐志华. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SkyduckFile : NSObject

//
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
