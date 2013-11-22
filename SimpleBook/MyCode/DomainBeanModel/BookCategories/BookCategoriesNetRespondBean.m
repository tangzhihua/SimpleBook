//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "BookCategoriesNetRespondBean.h"

#import "BookCategoriesDatabaseFieldsConstant.h"
#import "BookCategory.h"

#define kNSCodingField_categories @"categories"

@interface BookCategoriesNetRespondBean ()
@property (nonatomic, readwrite, strong) NSArray *categories;
@end

@implementation BookCategoriesNetRespondBean

#pragma mark
#pragma mark 不能使用默认的init方法初始化对象, 而必须使用当前类特定的 "初始化方法" 初始化所有参数
- (id) init {
  RNAssert(NO, @"Can not use the default init method!");
  
  return nil;
}

-(NSArray *)categories{
  if (_categories == nil) {
    _categories = [[NSMutableArray alloc] init];
  }
  return _categories;
}

- (NSString *)description {
	return descriptionForDebug(self);
}

-(void) setValue:(id)value forKey:(NSString *)key{
	if ([key isEqualToString:k_BookCategories_RespondKey_categories]) {
    id categories = [value objectForKey:k_BookCategories_RespondKey_category];
    if ([categories isKindOfClass:[NSArray class]]) {
      // 有多个数据
      for (NSDictionary *categoryDictionary in categories) {
        BookCategory *category = [[BookCategory alloc] initWithDictionary:categoryDictionary];
        [(NSMutableArray *)self.categories addObject:category];
      }
    } else if ([categories isKindOfClass:[NSDictionary class]]) {
      // 只有1个数据
      BookCategory *category = [[BookCategory alloc] initWithDictionary:categories];
      [(NSMutableArray *)self.categories addObject:category];
    } else {
      RNAssert(NO, @"服务器修改了数据格式!");
    }
    
	} else {
		[super setValue:value forKey:key];
	}
}

-(NSString *)categoryNameByCategoryID:(NSString *)categoryID {
  for (BookCategory *category in self.categories) {
    if ([category.identifier isEqualToString:categoryID]) {
      return category.name;
    }
  }
  
  return nil;
}

#pragma mark -
#pragma mark 实现 NSCoding 接口
- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:self.categories forKey:kNSCodingField_categories];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super init])) {
    
    // 如果有不需要序列化的属性存在时, 可以在这里先进行初始化
    
    //
    if ([aDecoder containsValueForKey:kNSCodingField_categories]) {
      _categories = [[aDecoder decodeObjectForKey:kNSCodingField_categories] copy];
    }
    
  }
  
  return self;
}
@end
