//
//  LocalBookshelfCategory.m
//  MBEnterprise
//
//  Created by 唐志华 on 13-9-22.
//
//

#import "BookCategory.h"

#define kNSCodingField_id        @"id"
#define kNSCodingField_name      @"name"
#define kNSCodingField_bookcount @"bookcount"

@interface BookCategory()
// 分类ID
@property (nonatomic, readwrite, copy) NSString *identifier;
// 分类名称
@property (nonatomic, readwrite, strong) NSString *name;
// 当前分类下面, 书籍总数(如果书籍总数为 0, 那么在书城界面, 就不要显示这个分类)
@property (nonatomic, readwrite, assign) NSInteger bookcount;
@end

@implementation BookCategory
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
  if ([key isEqualToString:kNSCodingField_id]) {
    _identifier = value;
  }
}

#pragma mark -
#pragma mark 实现 NSCoding 接口
- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:_identifier forKey:kNSCodingField_id];
  [aCoder encodeObject:_name forKey:kNSCodingField_name];
  [aCoder encodeInteger:_bookcount forKey:kNSCodingField_bookcount];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super init])) {
    
    // 如果有不需要序列化的属性存在时, 可以在这里先进行初始化
    
    //
    if ([aDecoder containsValueForKey:kNSCodingField_id]) {
      _identifier = [aDecoder decodeObjectForKey:kNSCodingField_id];
    }
    //
    if ([aDecoder containsValueForKey:kNSCodingField_name]) {
      _name = [[aDecoder decodeObjectForKey:kNSCodingField_name] copy];
    }
    //
    if ([aDecoder containsValueForKey:kNSCodingField_bookcount]) {
      _bookcount = [aDecoder decodeIntegerForKey:kNSCodingField_bookcount];
    }
  }
  
  return self;
}

- (NSString *)description {
	return descriptionForDebug(self);
}
@end
