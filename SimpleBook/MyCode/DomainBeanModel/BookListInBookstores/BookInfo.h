//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"


@interface BookInfo : BaseModel
// 一本书籍的唯一性 标识ID
@property (nonatomic, readonly, copy) NSString *content_id;
// 书籍名称
@property (nonatomic, readonly, copy) NSString *name;
// 书籍发行日期
@property (nonatomic, readonly, copy) NSString *published;
// 书籍过期时间
@property (nonatomic, readonly, copy) NSString *expired;
// 作者
@property (nonatomic, readonly, copy) NSString *author;
// 价钱
@property (nonatomic, readonly, copy) NSString *price;
// 书籍对应的产品ID, 用于收费书籍的购买行为
@property (nonatomic, readonly, copy) NSString *productid;
// 书籍归属的类别ID
@property (nonatomic, readonly, copy) NSString *categoryid;
// 出版社/发行人
@property (nonatomic, readonly, copy) NSString *publisher;
// 书籍封面图片URL地址
@property (nonatomic, readonly, copy) NSString *thumbnail;

// 20130925 唐志华 : 千万注意, Bean 的字段不能声明成 description, 否则在打印这个Bean的时候会引起死循环调用.
// 书籍描述
@property (nonatomic, readonly, copy) NSString *bookDescription;
// 书籍zip资源包大小, 以byte为单位.
@property (nonatomic, readonly, copy) NSString *size;
@end
