//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import <Foundation/Foundation.h>

@interface LocalCacheDataPathConstant : NSObject {
  
}


// 项目中 "缩略图" 缓存目录 (可以被清除)
+(NSString *)thumbnailCachePath;
// 那些需要始终被保存, 不能由用户进行清除的文件
+(NSString *)importantDataCachePath;
// 本地书籍保存目录
+(NSString *)localBookCachePath;






// 返回能被用户清空的文件目录数组(可以从这里获取用户可以直接清空的文件夹路径数组)
+(NSArray *)directoriesCanBeClearByTheUser;

// 创建本地数据缓存目录(一次性全部创建, 不会重复创建)
+(void)createLocalCacheDirectories;
@end
