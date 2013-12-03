//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "BookInfo.h"
#import "BookListInBookstoresDatabaseFieldsConstant.h"

@interface BookInfo ()
////
//@property (nonatomic, readwrite, copy) NSString *content_id;
////
//@property (nonatomic, readwrite, copy) NSString *name;
////
//@property (nonatomic, readwrite, copy) NSString *published;
////
//@property (nonatomic, readwrite, copy) NSString *expired;
////
//@property (nonatomic, readwrite, copy) NSString *author;
////
//@property (nonatomic, readwrite, copy) NSString *price;
////
//@property (nonatomic, readwrite, copy) NSString *productid;
////
//@property (nonatomic, readwrite, copy) NSString *categoryid;
////
//@property (nonatomic, readwrite, copy) NSString *publisher;
////
//@property (nonatomic, readwrite, copy) NSString *thumbnail;
////
//@property (nonatomic, readwrite, copy) NSString *bookDescription;
//// 书籍zip资源包大小, 以byte为单位.
//@property (nonatomic, readwrite, copy) NSString *size;
//
@end

@implementation BookInfo

#pragma mark
#pragma mark 不能使用默认的init方法初始化对象, 而必须使用当前类特定的 "初始化方法" 初始化所有参数
- (id) init {
  RNAssert(NO, @"Can not use the default init method!");
  
  return nil;
}

- (NSString *)description {
	return descriptionForDebug(self);
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
  // 20130925 唐志华 : 千万注意, Bean 的字段不能声明成 description, 否则在打印这个Bean的时候会引起死循环调用.
  if ([key isEqualToString:k_BookListInBookstores_RespondKey_description]) {
    _bookDescription = [value copy];
  }
}
#pragma mark -
#pragma mark 实现 NSCoding 接口
- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:_content_id forKey:k_BookListInBookstores_RespondKey_content_id];
  [aCoder encodeObject:_name forKey:k_BookListInBookstores_RespondKey_name];
  [aCoder encodeObject:_published forKey:k_BookListInBookstores_RespondKey_published];
  [aCoder encodeObject:_expired forKey:k_BookListInBookstores_RespondKey_expired];
  [aCoder encodeObject:_author forKey:k_BookListInBookstores_RespondKey_author];
  [aCoder encodeObject:_price forKey:k_BookListInBookstores_RespondKey_price];
  [aCoder encodeObject:_productid forKey:k_BookListInBookstores_RespondKey_productid];
  [aCoder encodeObject:_categoryid forKey:k_BookListInBookstores_RespondKey_categoryid];
  [aCoder encodeObject:_publisher forKey:k_BookListInBookstores_RespondKey_publisher];
  [aCoder encodeObject:_thumbnail forKey:k_BookListInBookstores_RespondKey_thumbnail];
  [aCoder encodeObject:_bookDescription forKey:k_BookListInBookstores_RespondKey_description];
  [aCoder encodeObject:_size forKey:k_BookListInBookstores_RespondKey_size];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super init])) {
    
    // 如果有不需要序列化的属性存在时, 可以在这里先进行初始化
    
    //
    if ([aDecoder containsValueForKey:k_BookListInBookstores_RespondKey_content_id]) {
      _content_id = [aDecoder decodeObjectForKey:k_BookListInBookstores_RespondKey_content_id];
    }
    //
    if ([aDecoder containsValueForKey:k_BookListInBookstores_RespondKey_name]) {
      _name = [aDecoder decodeObjectForKey:k_BookListInBookstores_RespondKey_name];
    }
    //
    if ([aDecoder containsValueForKey:k_BookListInBookstores_RespondKey_published]) {
      _published = [aDecoder decodeObjectForKey:k_BookListInBookstores_RespondKey_published];
    }
    //
    if ([aDecoder containsValueForKey:k_BookListInBookstores_RespondKey_expired]) {
      _expired = [aDecoder decodeObjectForKey:k_BookListInBookstores_RespondKey_expired];
    }
    //
    if ([aDecoder containsValueForKey:k_BookListInBookstores_RespondKey_author]) {
      _author = [aDecoder decodeObjectForKey:k_BookListInBookstores_RespondKey_author];
    }
    //
    if ([aDecoder containsValueForKey:k_BookListInBookstores_RespondKey_price]) {
      _price = [aDecoder decodeObjectForKey:k_BookListInBookstores_RespondKey_price];
    }
    //
    if ([aDecoder containsValueForKey:k_BookListInBookstores_RespondKey_productid]) {
      _productid = [aDecoder decodeObjectForKey:k_BookListInBookstores_RespondKey_productid];
    }
    //
    if ([aDecoder containsValueForKey:k_BookListInBookstores_RespondKey_categoryid]) {
      _categoryid = [aDecoder decodeObjectForKey:k_BookListInBookstores_RespondKey_categoryid];
    }
    //
    if ([aDecoder containsValueForKey:k_BookListInBookstores_RespondKey_publisher]) {
      _publisher = [aDecoder decodeObjectForKey:k_BookListInBookstores_RespondKey_publisher];
    }
    //
    if ([aDecoder containsValueForKey:k_BookListInBookstores_RespondKey_thumbnail]) {
      _thumbnail = [aDecoder decodeObjectForKey:k_BookListInBookstores_RespondKey_thumbnail];
    }
    //
    if ([aDecoder containsValueForKey:k_BookListInBookstores_RespondKey_description]) {
      _bookDescription = [aDecoder decodeObjectForKey:k_BookListInBookstores_RespondKey_description];
    }
    //
    if ([aDecoder containsValueForKey:k_BookListInBookstores_RespondKey_size]) {
      _size = [aDecoder decodeObjectForKey:k_BookListInBookstores_RespondKey_size];
    }
  }
  
  return self;
}
@end
