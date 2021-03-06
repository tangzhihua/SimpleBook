//
//  LocalBookList.h
//  MBEnterprise
//
//  Created by 唐志华 on 13-9-22.
//
//

#import "BaseModel.h"

// 用于外部 KVO 的, 属性名称(字符串格式).
#define kLocalBookListProperty_localBookList @"localBookList"

@class LocalBook;
// 本地书籍列表(本地书籍包括, 已经下载完全, 并且已经解压开, 可以正常阅读的书籍; 也包括那些未下载完全的书籍(可以进行断电续传)).
@interface LocalBookList : BaseModel

// 外部可以使用KVO来监听localBookList, 当localBookList属性 增加/删除 一本书时, 都会触发KVO
@property (nonatomic, readonly, strong) NSArray *localBookList;

#pragma mark -
#pragma mark 对外的接口方法 (操作列表)
- (LocalBook *)bookByContentID:(NSString *)contentIDString;
- (BOOL)addBook:(LocalBook *const)newBook;
- (void)removeBook:(LocalBook *const)book;
- (BOOL)removeBookAtIndex:(const NSUInteger)index;
- (BOOL)removeBookByContentID:(NSString *)contentIDString;
- (NSUInteger)indexOfBookByContentID:(NSString *)contentIDString;

#pragma mark -
#pragma mark 对外的接口方法 (根据书籍所属 "分类" 进行格式化)

// 根据 "图书名称" 进行筛选后, 符合条件的书籍的分类总数
// 注意 : 如果传入 nil(或者 ""), 就认为要查询全部书籍的分类总数
-(NSUInteger)bookCategoryTotalByBookNameSearch:(NSString *)bookName;

// 根据 "图书名称" 进行筛选后, 符合条件的书籍的分类字典
// 字典结构是 key=categoryid , value=NSArray(属于该分类的BookInfo列表)
// 注意 : 如果传入 nil(或者 ""), 就认为要查询全部书籍的分类
-(NSDictionary *)bookCategoryDictionaryByBookNameSearch:(NSString *)bookName;

#pragma mark -
#pragma mark 对外的接口方法 (根据书籍所属 "本地文件夹" 进行格式化)

// 根据 "图书名称" 进行筛选后, 符合条件的书籍的文件夹总数
// 注意 : 如果传入 nil(或者 ""), 就认为要查询全部书籍的文件夹总数
-(NSUInteger)bookFolderTotalByBookNameSearch:(NSString *)bookName;

// 根据 "图书名称" 进行筛选后, 符合条件的书籍的文件夹字典
// 字典结构是 key=folder , value=NSArray(属于该文件夹的BookInfo列表)
// 注意 : 如果传入 nil(或者 ""), 就认为要查询全部书籍的文件夹
-(NSDictionary *)bookFolderDictionaryByBookNameSearch:(NSString *)bookName;

#pragma mark -
#pragma mark 对外的接口方法 (下面两个方法是临时存在的, 将来在书架要显示未下载完的书籍, 1.0版本 中临时处理)
// 下面两个获取的是 下载/安装 完成的书籍, 用于 书架界面
-(NSUInteger)bookCategoryTotalOfInstalledByBookNameSearch:(NSString *)bookName;
-(NSDictionary *)bookCategoryDictionaryOfInstalledByBookNameSearch:(NSString *)bookName;

#pragma mark -
#pragma mark 对外的接口方法 (下面两个方法是临时存在的, 因为目前没有后台人员, 所以不能提供根据书籍分类获取书籍列表的接口, 还是一次性取回全部书籍, 1.1版本 中临时处理)
-(NSArray *)bookListByCategoryID:(NSString *)categoryID;
@end
