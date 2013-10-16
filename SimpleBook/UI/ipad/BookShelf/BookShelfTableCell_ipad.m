//
//  DreamBook
//
//  Created by 唐志华 on 13-9-26.
//
//

#import "BookShelfTableCell_ipad.h"
#import "LocalBook.h"
#import "BookInfo.h"
#import "UIImageView+MKNetworkKitAdditions.h"
#import "MKNetworkKit.h"
#import "UIColor+ColorSchemes.h"

@interface BookShelfTableCell_ipad ()

/// first book
@property (weak, nonatomic) IBOutlet UIView *firstBookPlaceholder;
//
@property (weak, nonatomic) IBOutlet UIButton *firstBookDeleteButton;
// 阅读按钮
@property (weak, nonatomic) IBOutlet UIButton *firstBookReadButton;

// 书籍封面
@property (weak, nonatomic) IBOutlet UIImageView *firstBookBookCoverImageView;
// 书籍名称
@property (weak, nonatomic) IBOutlet UILabel *firstBookNameLabel;
// 发行日
@property (weak, nonatomic) IBOutlet UILabel *firstBookPublishedLabel;
// 作者
@property (weak, nonatomic) IBOutlet UILabel *firstBookAuthorLabel;
// 发行人/出版社
@property (weak, nonatomic) IBOutlet UILabel *firstBookPublisherLabel;


/// second book
@property (weak, nonatomic) IBOutlet UIView *secondBookPlaceholder;
//
@property (weak, nonatomic) IBOutlet UIButton *secondBookDeleteButton;
// 阅读按钮
@property (weak, nonatomic) IBOutlet UIButton *secondBookReadButton;

// 书籍封面
@property (weak, nonatomic) IBOutlet UIImageView *secondBookBookCoverImageView;
// 书籍名称
@property (weak, nonatomic) IBOutlet UILabel *secondBookNameLabel;
// 发行日
@property (weak, nonatomic) IBOutlet UILabel *secondBookPublishedLabel;
// 作者
@property (weak, nonatomic) IBOutlet UILabel *secondBookAuthorLabel;
// 发行人/出版社
@property (weak, nonatomic) IBOutlet UILabel *secondBookPublisherLabel;


@property (nonatomic, weak) MKNetworkOperation *firstBookBookCoverImageOperation;
@property (nonatomic, weak) MKNetworkOperation *secondBookBookCoverImageOperation;

// 当前Cell 对应的书籍 contentID, Cell View中 不直接包含模型 LocalBook, 防止深层次的引用环, 只需要包含一个 contentID, 控制层就可以找到对应的 LocalBook 模型了.
@property (nonatomic, copy) NSString *firstBookContentID;
@property (nonatomic, copy) NSString *secondBookContentID;



@end

@implementation BookShelfTableCell_ipad

+(void) initialize {
  // 这是为了子类化当前类后, 父类的initialize方法会被调用2次
  if (self == [BookShelfTableCell_ipad class]) {
    
  }
}

// 复写父类的 +(NSString *)nibName 方法, 是为了支持屏幕翻转时加载不同的 xib文件.
+ (NSString *)cellIdentifier {
  UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
  NSString *cellIdentifier = [super cellIdentifier];
  if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
    // 竖屏
    cellIdentifier = [NSString stringWithFormat:@"%@_vertical", cellIdentifier];
  } else {
    // 横屏
    cellIdentifier = [NSString stringWithFormat:@"%@_horizontal", cellIdentifier];
  }
  
  return cellIdentifier;
}


#pragma mark -
#pragma mark 数据绑定
-(void) bindWithFirstDataBean:(LocalBook *)firstDataBean secondDataBean:(LocalBook *)secondDataBean {
  
  // 复位当前View的一些控件状态, 因为Cell View是会被重用的
  self.firstBookContentID = nil;
  self.secondBookContentID = nil;
  
  //
  [self.firstBookBookCoverImageOperation cancel];
  self.firstBookBookCoverImageOperation = nil;
  [self.secondBookBookCoverImageOperation cancel];
  self.secondBookBookCoverImageOperation = nil;
  
  //
  self.firstBookPlaceholder.hidden = YES;
  self.secondBookPlaceholder.hidden = YES;
  
  ///
  if ([firstDataBean isKindOfClass:[LocalBook class]] && firstDataBean.bookInfo != nil) {
    self.firstBookPlaceholder.hidden = NO;
    
    // 使用模型初始化Cell View
    BookInfo *bookInfo = firstDataBean.bookInfo;
    self.firstBookContentID = bookInfo.content_id;
    
    // 加载书籍 封面图片
    if (![NSString isEmpty:bookInfo.thumbnail]) {
      NSURL *urlOfBookCoverImage = [NSURL URLWithString:bookInfo.thumbnail];
      self.firstBookBookCoverImageOperation = [self.firstBookBookCoverImageView setImageFromURL:urlOfBookCoverImage];
    }
    
    self.firstBookNameLabel.text = bookInfo.name;
    self.firstBookPublishedLabel.text = bookInfo.published;
    self.firstBookAuthorLabel.text = bookInfo.author;
    self.firstBookPublisherLabel.text = bookInfo.publisher;
    
  }
  
  if ([secondDataBean isKindOfClass:[LocalBook class]] && secondDataBean.bookInfo != nil) {
    self.secondBookPlaceholder.hidden = NO;
    
    // 使用模型初始化Cell View
    BookInfo *bookInfo = secondDataBean.bookInfo;
    self.secondBookContentID = bookInfo.content_id;
    
    // 加载书籍 封面图片
    if (![NSString isEmpty:bookInfo.thumbnail]) {
      NSURL *urlOfBookCoverImage = [NSURL URLWithString:bookInfo.thumbnail];
      self.secondBookBookCoverImageOperation = [self.secondBookBookCoverImageView setImageFromURL:urlOfBookCoverImage];
    }
    
    self.secondBookNameLabel.text = bookInfo.name;
    self.secondBookPublishedLabel.text = bookInfo.published;
    self.secondBookAuthorLabel.text = bookInfo.author;
    self.secondBookPublisherLabel.text = bookInfo.publisher;
  }
  
  
}

#pragma mark -
#pragma mark Action
- (IBAction)readButtonOnClickListener:(UIButton *)sender {
  if (self.bookShelfTableCellFunctionButtonClickHandleBlock != NULL) {
    NSString *contentID = nil;
    if (sender == self.firstBookReadButton) {
      contentID = self.firstBookContentID;
    } else {
      contentID = self.secondBookContentID;
    }
    self.bookShelfTableCellFunctionButtonClickHandleBlock(self, kBookShelfTableCellActionEnum_Read, contentID);
  }
  
}

- (IBAction)deleteButtonOnClickListener:(UIButton *)sender {
  if (self.bookShelfTableCellFunctionButtonClickHandleBlock != NULL) {
    NSString *contentID = nil;
    if (sender == self.firstBookDeleteButton) {
      contentID = self.firstBookContentID;
    } else {
      contentID = self.secondBookContentID;
    }
    self.bookShelfTableCellFunctionButtonClickHandleBlock(self, kBookShelfTableCellActionEnum_Delete, contentID);
  }
}

#pragma mark -
#pragma mark KVO 监听
-(void)observeValueForKeyPath:(NSString *)keyPath
										 ofObject:(id)object
											 change:(NSDictionary *)change
											context:(void *)context {
  
  if ((__bridge id)context == self) {// Our notification, not our superclass’s
    
    BOOL isDeleteMode = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
    [self hideDeleteButton:!isDeleteMode];
  } else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

#pragma mark -
#pragma mark 对外的接口方法
// 隐藏/显示 "删除按钮"
-(void) hideDeleteButton:(BOOL)hidden {
  if (!self.firstBookPlaceholder.hidden) {
    self.firstBookDeleteButton.hidden = hidden;
  }
  
  if (!self.secondBookPlaceholder.hidden) {
    self.secondBookDeleteButton.hidden = hidden;
  }
}
@end
