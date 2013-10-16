//
//  BookShelfTableCell_iPhone.m
//  MBEnterprise
//
//  Created by Yingjie Huo on 13-10-11.
//
//


#import "BookShelfTableCell_iPhone.h"
#import "LocalBook.h"
#import "BookInfo.h"
#import "UIImageView+MKNetworkKitAdditions.h"
#import "MKNetworkKit.h"
#import "UIColor+ColorSchemes.h"

@interface BookShelfTableCell_iPhone ()

// 书籍封面
@property (weak, nonatomic) IBOutlet UIImageView *bookCoverImageView;
// 书籍名称
@property (weak, nonatomic) IBOutlet UILabel *bookNameLabel;
// 发行日
@property (weak, nonatomic) IBOutlet UILabel *bookPublishedLabel;
// 作者
@property (weak, nonatomic) IBOutlet UILabel *bookAuthorLabel;
// 发行人/出版社
@property (weak, nonatomic) IBOutlet UILabel *bookPublisherLabel;

@property (nonatomic, weak) MKNetworkOperation *bookCoverImageOperation;

// 当前Cell 对应的书籍 contentID, Cell View中 不直接包含模型 LocalBook, 防止深层次的引用环, 只需要包含一个 contentID, 控制层就可以找到对应的 LocalBook 模型了.
@property (nonatomic, readwrite, copy) NSString *bookContentID;

@end

@implementation BookShelfTableCell_iPhone

+(void) initialize {
  // 这是为了子类化当前类后, 父类的initialize方法会被调用2次
  if (self == [BookShelfTableCell_iPhone class]) {
    
  }
}


#pragma mark -
#pragma mark 数据绑定
-(void) bindWithDataBean:(LocalBook *)dataBean{
  
  // 复位当前View的一些控件状态, 因为Cell View是会被重用的
  self.bookContentID = nil;
  [self.bookCoverImageOperation cancel];
  self.bookCoverImageOperation = nil;
  
  if ([dataBean isKindOfClass:[LocalBook class]] && dataBean.bookInfo != nil) {
    
    // 使用模型初始化Cell View
    BookInfo *bookInfo = dataBean.bookInfo;
    self.bookContentID = bookInfo.content_id;
    
    // 加载书籍 封面图片
    if (![NSString isEmpty:bookInfo.thumbnail]) {
      NSURL *urlOfBookCoverImage = [NSURL URLWithString:bookInfo.thumbnail];
      self.bookCoverImageOperation = [self.bookCoverImageView setImageFromURL:urlOfBookCoverImage];
    }
    
    self.bookNameLabel.text = bookInfo.name;
    self.bookPublishedLabel.text = bookInfo.published;
    self.bookAuthorLabel.text = bookInfo.author;
    self.bookPublisherLabel.text = bookInfo.publisher;
    
  }
}

#pragma mark -
#pragma mark Action
- (void)readButtonOnClickListener{
  if (self.bookShelfTableCellFunctionButtonClickHandleBlock != NULL) {
    NSString *contentID = nil;
    contentID = self.bookContentID;
    self.bookShelfTableCellFunctionButtonClickHandleBlock(self, kBookShelfTableCellActionEnum_Read, contentID);
  }
  
}

- (void)deleteButtonOnClickListener{
  if (self.bookShelfTableCellFunctionButtonClickHandleBlock != NULL) {
    NSString *contentID = nil;
    contentID = self.bookContentID;
    self.bookShelfTableCellFunctionButtonClickHandleBlock(self, kBookShelfTableCellActionEnum_Delete, contentID);
  }
}


@end
