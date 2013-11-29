//
//  FileCell.m
//  SimpleBook
//
//  Created by 唐志华 on 13-11-8.
//  Copyright (c) 2013年 唐志华. All rights reserved.
//

#import "FileCell.h"
#import "UIImageView+MKNetworkKitAdditions.h"
#import "MKNetworkKit.h"
#import "LocalBookList.h"
#import "LocalBook.h"
#import "BookInfo.h"
#import "SkyduckFile.h"

@interface FileCell ()
@property (nonatomic, weak) MKNetworkOperation *bookCoverImageOperation;

@property (weak, nonatomic) IBOutlet UIImageView *bookCoverImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation FileCell

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
  }
  return self;
}

- (void)bind:(SkyduckFile *)file {
  [super bind:file];
  
  BookInfo *bookInfo = [[GlobalDataCacheForMemorySingleton sharedInstance].localBookList bookByContentID:file.value].bookInfo;
  
  
  
  // 加载书籍 封面图片
  if (![NSString isEmpty:bookInfo.thumbnail]) {
    NSURL *urlOfBookCoverImage = [NSURL URLWithString:bookInfo.thumbnail];
    self.bookCoverImageOperation = [self.bookCoverImageView setImageFromURL:urlOfBookCoverImage];
  }
  
  self.nameLabel.text = bookInfo.name;
}

#pragma mark -
#pragma mark - SkyduckGridViewMargeCellAnimationDelegate
- (void)beginMargeCellAnimation {
  super.backgroundImageViewForMargeCell.hidden = NO;
  
  super.backgroundImageViewForMargeCell.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
  super.backgroundImageViewForMargeCell.transform = CGAffineTransformMakeScale(0.5, 0.5);
  [UIView animateWithDuration:0.3 animations:^{
    super.backgroundImageViewForMargeCell.transform = CGAffineTransformMakeScale(1.0, 1.0);
    _bookCoverImageView.transform = CGAffineTransformMakeScale(0.9, 0.9);
  }];
}

- (void)endMargeCellAnimation {
  [UIView animateWithDuration:0.3 animations:^{
    super.backgroundImageViewForMargeCell.transform = CGAffineTransformMakeScale(0.5, 0.5);
    _bookCoverImageView.transform = CGAffineTransformIdentity;
  } completion:^(BOOL finished) {
    super.backgroundImageViewForMargeCell.hidden = YES;
  }];
}
@end
