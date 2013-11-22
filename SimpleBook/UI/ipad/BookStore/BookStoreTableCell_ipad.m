//
//  DreamBook
//
//  Created by 唐志华 on 13-9-26.
//
//

#import "BookStoreTableCell_ipad.h"
#import "LocalBook.h"
#import "BookInfo.h"
#import "UIImageView+MKNetworkKitAdditions.h"
#import "MKNetworkKit.h"
#import "UIColor+ColorSchemes.h"

@interface BookStoreTableCell_ipad ()

// 书籍封面
@property (weak, nonatomic) IBOutlet UIImageView *bookCoverImageView;
// 书籍名称
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
// 发行日
@property (weak, nonatomic) IBOutlet UILabel *publishedLabel;
// 有效期
@property (weak, nonatomic) IBOutlet UILabel *expiredLabel;
// 作者
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
// 发行人/出版社
@property (weak, nonatomic) IBOutlet UILabel *publisherLabel;
// 书籍zip资源包大小
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;

// 功能按钮(根据不同的状态, 来切换背景图片和title, 并且触发不同的功能)
@property (weak, nonatomic) IBOutlet UIButton *functionButton;

// 下载书籍封面图片时的 "活动指示器"
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bookCoverDownloadIndicator;

@property (nonatomic, weak) MKNetworkOperation *bookCoverImageOperation;
@property (nonatomic, copy, readwrite) NSString *contentID;
@end

@implementation BookStoreTableCell_ipad

static UIImage *kButtonDefaultBGImageOfBlank = nil;
static UIImage *kButtonHighlightedBGImageOfBlank = nil;
static UIImage *kButtonDefaultBGImageOfDownload = nil;
static UIImage *kButtonHighlightedBGImageOfDownload = nil;
static UIImage *kButtonDefaultBGImageOfPause = nil;
static UIImage *kButtonHighlightedBGImageOfPause = nil;
static UIImage *kButtonDefaultBGImageOfInstalled = nil;
static UIImage *kButtonHighlightedBGImageOfInstalled = nil;

+(void) initialize {
  // 这是为了子类化当前类后, 父类的initialize方法会被调用2次
  if (self == [BookStoreTableCell_ipad class]) {
    
    kButtonDefaultBGImageOfBlank = [UIImage imageNamed:@"k"];
    kButtonHighlightedBGImageOfBlank = [UIImage imageNamed:@"k_touch"];
    kButtonDefaultBGImageOfDownload = [UIImage imageNamed:@"xz"];
    kButtonHighlightedBGImageOfDownload = [UIImage imageNamed:@"xz_touch"];
    kButtonDefaultBGImageOfPause = [UIImage imageNamed:@"zt"];
    kButtonHighlightedBGImageOfPause = [UIImage imageNamed:@"zt_touch"];
    kButtonDefaultBGImageOfInstalled = [UIImage imageNamed:@"yd"];
    kButtonHighlightedBGImageOfInstalled = [UIImage imageNamed:@"yd_touch"];
  }
}

// 复写父类的 +(NSString *)nibName 方法, 是为了支持屏幕翻转时加载不同的 xib文件.
/*
+ (NSString *)nibName {
  UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
  NSString *nibNameString = [self cellIdentifier];
  if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
    // 竖屏
    nibNameString = [NSString stringWithFormat:@"%@_vertical", nibNameString];
  } else {
    // 横屏
    nibNameString = [NSString stringWithFormat:@"%@_horizontal", nibNameString];
  }
  
  return nibNameString;
}
 */

- (void)dealloc {
  
}

- (IBAction)functionButtonOnClickListener:(UIButton *)sender {
  
  if (self.bookStoreTableCellFunctionButtonClickHandleBlock != NULL) {
    self.bookStoreTableCellFunctionButtonClickHandleBlock(self, self.contentID);
  }
}

-(void)updateFunctionButtonUIWithBookObject:(LocalBook *)book{
  
  self.functionButton.enabled = YES;
  [self.functionButton setTitle:@"" forState:UIControlStateNormal];
  [self.functionButton setTitle:@"" forState:UIControlStateHighlighted];
  
  switch (book.bookStateEnum) {
    case kBookStateEnum_Unpaid:{
      self.functionButton.enabled = YES;
      [self.functionButton setTitleColor:[UIColor colorOfListCellPrice] forState:UIControlStateNormal];
      [self.functionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
      [self.functionButton setTitle:[NSString stringWithFormat:@"¥%@", book.bookInfo.price] forState:UIControlStateNormal];
      [self.functionButton setTitle:[NSString stringWithFormat:@"¥%@", book.bookInfo.price] forState:UIControlStateHighlighted];
      [self.functionButton setBackgroundImage:kButtonDefaultBGImageOfBlank forState:UIControlStateNormal];
      [self.functionButton setBackgroundImage:kButtonHighlightedBGImageOfBlank forState:UIControlStateHighlighted];
    }break;
    case kBookStateEnum_Paiding:{
      [self.functionButton setTitle:[NSString stringWithFormat:@"¥%@", book.bookInfo.price] forState:UIControlStateNormal];
      [self.functionButton setTitle:[NSString stringWithFormat:@"¥%@", book.bookInfo.price] forState:UIControlStateHighlighted];
      self.functionButton.enabled = NO;
    }break;
    case kBookStateEnum_Paid:{
      self.functionButton.enabled = YES;
      [self.functionButton setBackgroundImage:kButtonDefaultBGImageOfDownload forState:UIControlStateNormal];
      [self.functionButton setBackgroundImage:kButtonHighlightedBGImageOfDownload forState:UIControlStateHighlighted];
    }break;
    case kBookStateEnum_Downloading:{
      [self.functionButton setTitleColor:[UIColor colorOfListCellPrice] forState:UIControlStateNormal];
      [self.functionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
      NSString *downloadProgress = [NSString stringWithFormat:@"%.2f %%", book.downloadProgress * 100.0];
      [self.functionButton setTitle:downloadProgress forState:UIControlStateNormal];
      [self.functionButton setTitle:downloadProgress forState:UIControlStateHighlighted];
      [self.functionButton setBackgroundImage:kButtonDefaultBGImageOfBlank forState:UIControlStateNormal];
      [self.functionButton setBackgroundImage:kButtonHighlightedBGImageOfBlank forState:UIControlStateHighlighted];
    }break;
    case kBookStateEnum_Pause:{
      [self.functionButton setBackgroundImage:kButtonDefaultBGImageOfPause forState:UIControlStateNormal];
      [self.functionButton setBackgroundImage:kButtonHighlightedBGImageOfPause forState:UIControlStateHighlighted];
    }break;
    case kBookStateEnum_NotInstalled:{
      
    }break;
    case kBookStateEnum_Unziping:{
      self.functionButton.enabled = NO;
      [self.functionButton setTitleColor:[UIColor colorOfListCellPrice] forState:UIControlStateNormal];
      [self.functionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
      [self.functionButton setTitle:@"解压中" forState:UIControlStateNormal];
      [self.functionButton setTitle:@"解压中" forState:UIControlStateHighlighted];
      [self.functionButton setBackgroundImage:kButtonDefaultBGImageOfBlank forState:UIControlStateNormal];
      [self.functionButton setBackgroundImage:kButtonHighlightedBGImageOfBlank forState:UIControlStateHighlighted];
    }break;
    case kBookStateEnum_Installed:{
      self.functionButton.enabled = YES;
      [self.functionButton setBackgroundImage:kButtonDefaultBGImageOfInstalled forState:UIControlStateNormal];
      [self.functionButton setBackgroundImage:kButtonHighlightedBGImageOfInstalled forState:UIControlStateHighlighted];
    }break;
    case kBookStateEnum_Update:{
      
    }break;
    default:
      break;
  }
}

#pragma mark -
#pragma mark KVO 监听
-(void)observeValueForKeyPath:(NSString *)keyPath
										 ofObject:(id)object
											 change:(NSDictionary *)change
											context:(void *)context {
  
  if ((__bridge id)context == self) {// Our notification, not our superclass’s
  
    LocalBook *book = object;
    if([keyPath isEqualToString:kLocalBookProperty_bookStateEnum]) {
      // 监听 "书籍状态"
      [self updateFunctionButtonUIWithBookObject:book];
      
    } else if([keyPath isEqualToString:kLocalBookProperty_downloadProgress]) {
      
      // 监听 "下载进度"
      NSString *downloadProgress = [NSString stringWithFormat:@"%.2f %%", book.downloadProgress * 100.0];
      [self.functionButton setTitle:downloadProgress forState:UIControlStateNormal];
      [self.functionButton setTitle:downloadProgress forState:UIControlStateHighlighted];
    } else if ([keyPath isEqualToString:kIsContrllerDealloc]) {
      // 外部控制器, 已经被释放了, 在这里释放cell占用的资源
      [self.bookCoverImageOperation cancel];
      self.bookCoverImageOperation = nil;
    }
  } else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

#pragma mark -
#pragma mark 数据绑定
-(void) bind:(LocalBook *)bookInfoToBeDisplayed {
  if (![bookInfoToBeDisplayed isKindOfClass:[LocalBook class]] || bookInfoToBeDisplayed.bookInfo == nil) {
    RNAssert(NO, @"入参 bookInfoToBeDisplayed 无效.");
    return;
  }
  
  // 复位当前View的一些控件状态, 因为Cell View是会被重用的
  self.functionButton.enabled = YES;
  
  [self.bookCoverDownloadIndicator setHidden:NO];
  [self.bookCoverDownloadIndicator startAnimating];
  
  [self.bookCoverImageOperation cancel];
  self.bookCoverImageOperation = nil;
  
  // 使用模型初始化Cell View
  BookInfo *bookInfo = bookInfoToBeDisplayed.bookInfo;
  self.contentID = bookInfo.content_id;
  
  // 加载书籍 封面图片
  if (![NSString isEmpty:bookInfo.thumbnail]) {
    NSURL *urlOfBookCoverImage = [NSURL URLWithString:bookInfo.thumbnail];
    self.bookCoverImageOperation = [self.bookCoverImageView setImageFromURL:urlOfBookCoverImage];
    [self.bookCoverImageOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
      [self.bookCoverDownloadIndicator setHidden:YES];
      [self.bookCoverDownloadIndicator stopAnimating];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
      [self.bookCoverDownloadIndicator setHidden:YES];
      [self.bookCoverDownloadIndicator stopAnimating];
    }];
  }
  
  self.nameLabel.text = bookInfo.name;
  self.publishedLabel.text = bookInfo.published;
  self.expiredLabel.text = bookInfo.expired;
  self.authorLabel.text = bookInfo.author;
  self.publisherLabel.text = bookInfo.publisher;
  self.sizeLabel.text = [ToolsFunctionForThisProgect formatBookZipResSizeString:bookInfo.size];
  
  // 更新 功能按钮UI
  [self updateFunctionButtonUIWithBookObject:bookInfoToBeDisplayed];
}
@end
