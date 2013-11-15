//
//  LocalBookList.m
//  MBEnterprise
//
//  Created by 唐志华 on 13-9-22.
//
//

#import "LocalBookList.h"
#import "BookInfo.h"
#import "LocalBook.h"
#import "LocalCacheDataPathConstant.h"

#define kNSCodingField_localBookList @"localBookList"

@interface LocalBookList ()
@property (nonatomic, readwrite, strong) NSMutableArray *localBookList;

// 这里做了搜索效率优化

// 对所有书籍进行了归类处理(缓存).
@property (nonatomic, strong) NSMutableDictionary *bookCategoryDictionaryOfAllBooks;
// 对符合搜索条件的书籍进行了归类处理(缓存)
@property (nonatomic, strong) NSMutableDictionary *bookCategoryDictionaryOfBookNameSearch;
// 最后的搜索条件(缓存)
@property (nonatomic, copy) NSString *bookNameForCategoryDictionaryLatestSearch;
@end

@implementation LocalBookList
-(NSArray *)localBookList{
  if (_localBookList == nil) {
    _localBookList = [[NSMutableArray alloc] init];
  }
  return _localBookList;
}

- (NSString *)description {
	return descriptionForDebug(self);
}

#pragma mark -
#pragma mark 私有方法
-(void)deleteBookFromFileSystemWithContentID:(NSString *)contentIDString {
  NSString *bookSaveDirPath = [NSString stringWithFormat:@"%@/%@", [LocalCacheDataPathConstant localBookCachePath], contentIDString];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSError *error = nil;
  [fileManager removeItemAtPath:bookSaveDirPath error:&error];
  if (error != nil) {
    NSLog(@"删除缓存的未下载完成的书籍数据失败! 错误描述:%@", error.localizedDescription);
  }
}

-(void)clearSearchCache {
  self.bookCategoryDictionaryOfAllBooks = nil;
  self.bookCategoryDictionaryOfBookNameSearch = nil;
  self.bookNameForCategoryDictionaryLatestSearch = nil;
}

#pragma mark -
#pragma mark 下列方法, 用于提供外部KVO监听 self.localBookList 属性的变化(增加/删除)
- (NSUInteger)countOfLocalBookList {
  return [self.localBookList count];
}

- (id)objectInLocalBookListAtIndex:(NSUInteger)index {
  return self.localBookList[index];
}

- (void)insertObject:(id)object inLocalBookListAtIndex:(NSInteger)index {
  [(NSMutableArray *)self.localBookList insertObject:object atIndex:index];
}

- (void)removeObjectFromLocalBookListAtIndex:(NSUInteger)index {
  [(NSMutableArray *)self.localBookList removeObjectAtIndex:index];
}

- (void)replaceObjectInLocalBookListAtIndex:(NSInteger)index withObject:(id)object {
  [(NSMutableArray *)self.localBookList replaceObjectAtIndex:index withObject:object];
}

#pragma mark -
#pragma mark 对外的接口方法 (操作列表)
- (LocalBook *)bookByContentID:(NSString *)contentIDString {
  if ([NSString isEmpty:contentIDString]) {
    RNAssert(NO, @"入参错误 contentIDString !");
    return nil;
  }
  
  LocalBook *result = nil;
  for (LocalBook *localBook in self.localBookList) {
    if ([contentIDString isEqualToString:localBook.bookInfo.content_id]) {
      result = localBook;
      break;
    }
  }
  
  return result;
}

- (BOOL)addBook:(LocalBook *const)newBook {
  do {
    if (![newBook isKindOfClass:[LocalBook class]]) {
      RNAssert(NO, @"入参 newBook 非法.");
      break;
    }
    
    if ([self.localBookList containsObject:newBook]) {
      PRPLog(@"当前书籍已经存在本地了, bookname=%@", newBook.bookInfo.name);
      return NO;
    }
    
    [self insertObject:newBook inLocalBookListAtIndex:self.localBookList.count];
    //[(NSMutableArray *)self.localBookList addObject:newBook];
    
    // 增删数据时, 一定要及时清空 搜索缓存
    [self clearSearchCache];
    return YES;
  } while (NO);
  
  return NO;
}

- (void)removeBook:(LocalBook *const)book {
  if (![book isKindOfClass:[LocalBook class]]) {
    RNAssert(NO, @"入参 book 类型错误.");
    return;
  }
  
  // 删除文件系统中保存的书籍
  [self deleteBookFromFileSystemWithContentID:book.bookInfo.content_id];
  // 删除内存中保存的书籍
  NSInteger indexInArray = [self.localBookList indexOfObject:book];
  [self removeObjectFromLocalBookListAtIndex:indexInArray];
  //[(NSMutableArray *)self.localBookList removeObject:book];
  
  // 增删数据时, 一定要及时清空 搜索缓存
  [self clearSearchCache];
}

- (BOOL)removeBookAtIndex:(const NSUInteger)index {
  if (index >= self.localBookList.count) {
    RNAssert(NO, @"入参 index 越界.");
    return NO;
  }
  
  LocalBook *book = self.localBookList[index];
  [self removeBook:book];
  return YES;
}

- (BOOL)removeBookByContentID:(NSString *)contentIDString {
  
  if ([NSString isEmpty:contentIDString]) {
    RNAssert(NO, @"入参错误 contentIDString !");
    return NO;
  }
  
  for (LocalBook *book in self.localBookList) {
    if ([contentIDString isEqualToString:book.bookInfo.content_id]) {
      [self removeBook:book];
      return YES;
    }
  }
  
  return NO;
}

- (NSUInteger)indexOfBookByContentID:(NSString *)contentIDString{
  do {
    if ([NSString isEmpty:contentIDString]) {
      RNAssert(NO, @"入参错误 contentIDString !");
      break;
    }
    
    for (int i=0; i<self.localBookList.count; i++) {
      LocalBook *book = self.localBookList[i];
      if ([contentIDString isEqualToString:book.bookInfo.content_id]) {
        return i;
      }
    }
  } while (NO);
  
  return -1;
}
#pragma mark -
#pragma mark 实现 NSCoding 接口
- (void)encodeWithCoder:(NSCoder *)aCoder {
  // 20130929 唐志华 : 一定注意, 在encode时, 一定要encode真实的数据类型, 尤其是这种对外是NSArray 而其实是NSMutableArray的情况
  [aCoder encodeObject:self.localBookList forKey:kNSCodingField_localBookList];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super init])) {
    
    // 如果有不需要序列化的属性存在时, 可以在这里先进行初始化
    
    //
    if ([aDecoder containsValueForKey:kNSCodingField_localBookList]) {
      //
      _localBookList = [aDecoder decodeObjectForKey:kNSCodingField_localBookList];
    }
    
  }
  
  return self;
}

#pragma mark -
#pragma mark 对外的接口方法 (根据书籍所属 "分类" 进行格式化)

-(NSUInteger)bookCategoryTotalByBookNameSearch:(NSString *)bookName {
  NSDictionary *bookCategoryDictionaryByBookNameSearch = [self bookCategoryDictionaryByBookNameSearch:bookName];
  return bookCategoryDictionaryByBookNameSearch.count;
}

-(NSMutableDictionary *)bookCategoryDictionaryOfAllBooks{
  if (_bookCategoryDictionaryOfAllBooks == nil) {
    _bookCategoryDictionaryOfAllBooks = [NSMutableDictionary dictionary];
  }
  
  if (_bookCategoryDictionaryOfAllBooks.count <= 0 && self.localBookList.count > 0) {
    // 进行归类
    for (LocalBook *book in self.localBookList) {
      BookInfo *bookInfo = book.bookInfo;
      if ([_bookCategoryDictionaryOfAllBooks.allKeys containsObject:bookInfo.categoryid]) {
        NSMutableArray *bookList = [_bookCategoryDictionaryOfAllBooks objectForKey:bookInfo.categoryid];
        [bookList addObject:book];
      } else {
        [_bookCategoryDictionaryOfAllBooks setObject:[NSMutableArray arrayWithObject:book] forKey:bookInfo.categoryid];
      }
    }
  }
  
  return _bookCategoryDictionaryOfAllBooks;
}

-(NSDictionary *)bookCategoryDictionaryByBookNameSearch:(NSString *)bookName {
  // 性能优化
  if ([NSString isEmpty:bookName]) {
    return self.bookCategoryDictionaryOfAllBooks;
  }
  
  // 性能优化
  if ([self.bookNameForCategoryDictionaryLatestSearch isEqualToString:bookName]) {
    return self.bookCategoryDictionaryOfBookNameSearch;
  } else {
    // 记录最新的搜索条件
    self.bookNameForCategoryDictionaryLatestSearch = bookName;
  }
  
  NSMutableDictionary *bookCategoryDictionary = [NSMutableDictionary dictionary];
  for (LocalBook *book in self.localBookList) {
    BookInfo *bookInfo = book.bookInfo;
    NSRange range = [bookInfo.name rangeOfString:bookName options:NSCaseInsensitiveSearch];
    
    if(range.location != NSNotFound){
      if ([bookCategoryDictionary.allKeys containsObject:bookInfo.categoryid]) {
        NSMutableArray *bookList = [bookCategoryDictionary objectForKey:bookInfo.categoryid];
        [bookList addObject:book];
      } else {
        [bookCategoryDictionary setObject:[NSMutableArray arrayWithObject:book] forKey:bookInfo.categoryid];
      }
    }
  }
  
  // 性能优化(记录最新的分类字典)
  self.bookCategoryDictionaryOfBookNameSearch = bookCategoryDictionary;
  
  return self.bookCategoryDictionaryOfBookNameSearch;
}

#pragma mark -
#pragma mark 对外的接口方法 (根据书籍所属 "本地文件夹" 进行格式化)

// 根据 "图书名称" 进行筛选后, 符合条件的书籍的分类总数
// 注意 : 如果传入 nil(或者 ""), 就认为要查询全部书籍的分类总数
-(NSUInteger)bookFolderTotalByBookNameSearch:(NSString *)bookName {
  NSDictionary *bookFolderDictionaryByBookNameSearch = [self bookFolderDictionaryByBookNameSearch:bookName];
  return bookFolderDictionaryByBookNameSearch.count;
}

// 根据 "图书名称" 进行筛选后, 符合条件的书籍的分类字典
// 字典结构是 key=categoryid , value=NSArray(属于该分类的BookInfo列表)
// 注意 : 如果传入 nil(或者 ""), 就认为要查询全部书籍的分类
-(NSDictionary *)bookFolderDictionaryByBookNameSearch:(NSString *)bookName {
  NSMutableDictionary *bookFolderDictionary = [NSMutableDictionary dictionary];
  for (LocalBook *book in self.localBookList) {
    
    if ([NSString isEmpty:bookName]) {
      
      if ([bookFolderDictionary.allKeys containsObject:book.folder]) {
        NSMutableArray *bookList = [bookFolderDictionary objectForKey:book.folder];
        [bookList addObject:book];
      } else {
        [bookFolderDictionary setObject:[NSMutableArray arrayWithObject:book] forKey:book.folder];
      }
      
    } else {
      
      NSRange range = [book.bookInfo.name rangeOfString:bookName options:NSCaseInsensitiveSearch];
      
      if(range.location != NSNotFound){
        if ([bookFolderDictionary.allKeys containsObject:book.folder]) {
          NSMutableArray *bookList = [bookFolderDictionary objectForKey:book.folder];
          [bookList addObject:book];
        } else {
          [bookFolderDictionary setObject:[NSMutableArray arrayWithObject:book] forKey:book.folder];
        }
      }
    }
    
  }
  
  return bookFolderDictionary;
}

#pragma mark -
#pragma mark 对外的接口方法 (下面两个方法是临时存在的, 将来在书架要显示未下载完的书籍, 1.0版本 中临时处理)
// 下面两个获取的是 下载/安装 完成的书籍, 用于 书架界面
-(NSUInteger)bookCategoryTotalOfInstalledByBookNameSearch:(NSString *)bookName {
  NSDictionary *bookCategoryDictionaryByBookNameSearch = [self bookCategoryDictionaryOfInstalledByBookNameSearch:bookName];
  return bookCategoryDictionaryByBookNameSearch.count;
}
-(NSDictionary *)bookCategoryDictionaryOfInstalledByBookNameSearch:(NSString *)bookName {
  NSMutableDictionary *bookCategoryDictionary = [NSMutableDictionary dictionary];
  for (LocalBook *book in self.localBookList) {
    if (kBookStateEnum_Installed == book.bookStateEnum) {
      BookInfo *bookInfo = book.bookInfo;
      
      if ([NSString isEmpty:bookName]) {
        
        if ([bookCategoryDictionary.allKeys containsObject:bookInfo.categoryid]) {
          NSMutableArray *bookList = [bookCategoryDictionary objectForKey:bookInfo.categoryid];
          [bookList addObject:book];
        } else {
          [bookCategoryDictionary setObject:[NSMutableArray arrayWithObject:book] forKey:bookInfo.categoryid];
        }
        
      } else {
        
        NSRange range = [bookInfo.name rangeOfString:bookName options:NSCaseInsensitiveSearch];
        
        if(range.location != NSNotFound){
          if ([bookCategoryDictionary.allKeys containsObject:bookInfo.categoryid]) {
            NSMutableArray *bookList = [bookCategoryDictionary objectForKey:bookInfo.categoryid];
            [bookList addObject:book];
          } else {
            [bookCategoryDictionary setObject:[NSMutableArray arrayWithObject:book] forKey:bookInfo.categoryid];
          }
        }
      }
    }
  }
  
  return bookCategoryDictionary;
}

#pragma mark -
#pragma mark 对外的接口方法 (下面两个方法是临时存在的, 因为目前没有后台人员, 所以不能提供根据书籍分类获取书籍列表的接口, 还是一次性取回全部书籍, 1.1版本 中临时处理)
-(NSArray *)bookListByCategoryID:(NSString *)categoryID {
  NSMutableArray *bookList = [NSMutableArray array];
  for (LocalBook *book in self.localBookList) {
    if ([book.bookInfo.categoryid isEqualToString:categoryID]) {
      [bookList addObject:book];
    }
  }
  
  return bookList;
}
@end
