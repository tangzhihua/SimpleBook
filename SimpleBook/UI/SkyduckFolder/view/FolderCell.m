//
//  FolderCell.m
//  SimpleBook
//
//  Created by 唐志华 on 13-11-8.
//  Copyright (c) 2013年 唐志华. All rights reserved.
//

#import "FolderCell.h"
#import "SkyduckFile.h"

@interface FolderCell ()


@property (weak, nonatomic) IBOutlet UIView *backgroundContainerView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileNumberLabel;

@property (weak, nonatomic) IBOutlet UIView *foregroundContainerView;
@end

@implementation FolderCell

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
  
  self.nameLabel.text = file.value;
  self.fileNumberLabel.text = [NSString stringWithFormat:@"%d", file.listFiles.count];
}

#pragma mark -
#pragma mark - SkyduckGridViewMargeCellAnimationDelegate
- (void)beginMargeCellAnimation {
  super.backgroundImageViewForMargeCell.hidden = NO;
  
  super.backgroundImageViewForMargeCell.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
  super.backgroundImageViewForMargeCell.transform = CGAffineTransformMakeScale(0.5, 0.5);
  [UIView animateWithDuration:0.3 animations:^{
    super.backgroundImageViewForMargeCell.transform = CGAffineTransformMakeScale(1.0, 1.0);
   // _bookCoverImageView.transform = CGAffineTransformMakeScale(0.9, 0.9);
  }];
}

- (void)endMargeCellAnimation {
  [UIView animateWithDuration:0.3 animations:^{
    super.backgroundImageViewForMargeCell.transform = CGAffineTransformMakeScale(0.5, 0.5);
    //_bookCoverImageView.transform = CGAffineTransformIdentity;
  } completion:^(BOOL finished) {
    super.backgroundImageViewForMargeCell.hidden = YES;
  }];
}
@end
