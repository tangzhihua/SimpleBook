//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import <Foundation/Foundation.h>

@interface GetBookDownloadUrlNetRequestBean : NSObject {
  
}

// 要下载的书籍ID 必填
@property (nonatomic, readonly, copy) NSString *contentId;
// 需要付费的书籍, 在付费后得到的收据
@property (nonatomic, copy) NSData *receipt;
#pragma mark -
#pragma mark 构造方法
- (id) initWithContentId:(NSString *)contentId;

@end
