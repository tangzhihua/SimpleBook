//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "LogonNetRespondBean.h"

#define kNSCodingField_username @"username"
#define kNSCodingField_password @"password"

@interface LogonNetRespondBean ()

@end

@implementation LogonNetRespondBean

- (NSString *)description {
	return descriptionForDebug(self);
}

#pragma mark -
#pragma mark 实现 NSCoding 接口
- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:_username forKey:kNSCodingField_username];
  [aCoder encodeObject:_password forKey:kNSCodingField_password];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super init])) {
    
    // 如果有不需要序列化的属性存在时, 可以在这里先进行初始化
    //
    if ([aDecoder containsValueForKey:kNSCodingField_username]) {
      _username = [aDecoder decodeObjectForKey:kNSCodingField_username];
    }
    //
    if ([aDecoder containsValueForKey:kNSCodingField_password]) {
      _password = [aDecoder decodeObjectForKey:kNSCodingField_password];
    }
    
  }
  
  return self;
}
@end
