//
//  LocalBookshelfCategory.m
//  MBEnterprise
//
//  Created by 唐志华 on 13-9-22.
//
//

#import "BookCategory.h"

#define kNSCodingField_id   @"id"
#define kNSCodingField_name @"name"

@interface BookCategory()
// 分类ID
@property (nonatomic, readwrite, assign) NSInteger identifier;
// 分类名称
@property (nonatomic, readwrite, strong) NSString *name;
@end

@implementation BookCategory
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
  if ([key isEqualToString:kNSCodingField_id]) {
    _identifier = [value integerValue];
  }
}

#pragma mark -
#pragma mark 实现 NSCoding 接口
- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeInteger:_identifier forKey:kNSCodingField_id];
  [aCoder encodeObject:_name forKey:kNSCodingField_name];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super init])) {
    
    // 如果有不需要序列化的属性存在时, 可以在这里先进行初始化
    
    //
    if ([aDecoder containsValueForKey:kNSCodingField_id]) {
      _identifier = [aDecoder decodeIntegerForKey:kNSCodingField_id];
    }
    //
    if ([aDecoder containsValueForKey:kNSCodingField_name]) {
      _name = [[aDecoder decodeObjectForKey:kNSCodingField_name] copy];
    }
  }
  
  return self;
}

- (NSString *)description {
	return descriptionForDebug(self);
}
@end
