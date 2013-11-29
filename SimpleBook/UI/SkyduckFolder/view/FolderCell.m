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
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileNumberLabel;

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

@end
