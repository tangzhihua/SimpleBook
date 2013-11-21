//
//  BookFolderDataSourceSingleton.h
//  SimpleBook
//
//  Created by 唐志华 on 13-11-11.
//  Copyright (c) 2013年 唐志华. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SkyduckFile;
@interface BookShelfDataSourceSingleton : NSObject
@property (nonatomic, readonly, strong) SkyduckFile *rootDirectory;
+ (BookShelfDataSourceSingleton *) sharedInstance;
@end
