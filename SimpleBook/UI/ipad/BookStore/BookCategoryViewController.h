//
//  BookCategoryViewController.h
//  SimpleBook
//
//  Created by 唐志华 on 13-10-23.
//  Copyright (c) 2013年 唐志华. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BookCategory;
@interface BookCategoryViewController : UIViewController

// 书籍分类
@property (nonatomic, strong) BookCategory *bookCategory;

//
@property (nonatomic, strong) NSArray *bookListes;
@end
