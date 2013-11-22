//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import <Foundation/Foundation.h>

@interface BookListInBookstoresNetRequestBean : NSObject
// 书籍分类ID, 如果不设置此ID, 就是一次性获取全部的书籍
@property (nonatomic, copy) NSString *category_id;
@end
