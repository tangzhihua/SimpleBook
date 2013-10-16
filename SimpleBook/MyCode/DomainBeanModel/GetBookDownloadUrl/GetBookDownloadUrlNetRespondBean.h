//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"


@interface GetBookDownloadUrlNetRespondBean : BaseModel
 
// 要下载的书籍的URL
@property (nonatomic, readonly, copy) NSString *bookDownloadUrl;

#pragma mark -
#pragma mark 构造方法
- (id) initWithBookDownloadUrl:(NSString *)bookDownloadUrl;
@end
