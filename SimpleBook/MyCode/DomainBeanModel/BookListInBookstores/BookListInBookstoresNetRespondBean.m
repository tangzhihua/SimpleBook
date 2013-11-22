//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "BookListInBookstoresNetRespondBean.h"
#import "BookListInBookstoresDatabaseFieldsConstant.h"
#import "BookInfo.h"

@interface BookListInBookstoresNetRespondBean ()
//
@property (nonatomic, readwrite, strong) NSMutableArray *bookInfoList;

@end

@implementation BookListInBookstoresNetRespondBean

#pragma mark -
#pragma mark 不能使用默认的init方法初始化对象, 而必须使用当前类特定的 "初始化方法" 初始化所有参数
- (id) init {
  RNAssert(NO, @"Can not use the default init method!");
  
  return nil;
}

-(NSArray *)bookInfoList{
  if (_bookInfoList == nil) {
    _bookInfoList = [[NSMutableArray alloc] init];
  }
  return _bookInfoList;
}

- (NSString *)description {
	return descriptionForDebug(self);
}

-(void) setValue:(id)value forKey:(NSString *)key{
	if ([key isEqualToString:k_BookListInBookstores_RespondKey_catalog]) {
    id books = [value objectForKey:k_BookListInBookstores_RespondKey_book];
    if ([books isKindOfClass:[NSArray class]]) {
      // 有多个数据
      for (NSDictionary *book in books) {
        BookInfo *bookInfo = [[BookInfo alloc] initWithDictionary:book];
        [(NSMutableArray *)self.bookInfoList addObject:bookInfo];
      }
    } else if ([books isKindOfClass:[NSDictionary class]]) {
      // 只有1个数据
      BookInfo *bookInfo = [[BookInfo alloc] initWithDictionary:books];
      [(NSMutableArray *)self.bookInfoList addObject:bookInfo];
    } else if ([books isEqualToString:@"nil"]) {
      // 没有有效数据
      PRPLog(@"服务器没有返回任何有效的书籍.");
    } else {
      RNAssert(NO, @"服务器修改了数据格式!");
    }
    
	} else {
		[super setValue:value forKey:key];
	}
}
@end
