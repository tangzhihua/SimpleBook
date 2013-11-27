//
//  ExpandFolderContentView.m
//  SimpleBook
//
//  Created by 唐志华 on 13-11-27.
//  Copyright (c) 2013年 唐志华. All rights reserved.
//

#import "ExpandFolderContentView.h"


#import "SkyduckFile.h"
#import "BookShelfDataSourceSingleton.h"
#import "BookInfo.h"
#import "LocalBook.h"
#import "LocalBookList.h"
#import "SkyduckGridView.h"
#import "SkyduckGridViewCell.h"

#import "FileCell.h"
#import "SkyduckGridViewCell.h"

@interface ExpandFolderContentView () <SkyduckGridViewDelegate, SkyduckGridViewDataSource>
@property (nonatomic, strong) SkyduckGridView *gridView;
//
@property (nonatomic, strong) UINib *fileCellUINib;
//
@property (nonatomic, strong) SkyduckFile *directory;
@end


@implementation ExpandFolderContentView

- (UINib *)fileCellUINib {
  if (_fileCellUINib == nil) {
    self.fileCellUINib = [FileCell nib];
  }
  return _fileCellUINib;
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    _gridView = [[SkyduckGridView alloc] initWithFrame:self.bounds];
    _gridView.delegate = self;
    _gridView.dataSource = self;
    [self addSubview:_gridView];

  }
  return self;
}

- (void)bind:(SkyduckFile *)directory {
  self.directory = directory;
  [_gridView reloadData];
}

#pragma mark -
#pragma mark - SkyduckGridViewDataSource
// 在网格控件中cell总数量
- (NSInteger)numberOfCellsInGridView:(SkyduckGridView *)gridview {
  return _directory.listFiles.count;
}
//
- (SkyduckGridViewCell *)gridView:(SkyduckGridView *)gridview cellAtIndex:(NSInteger)index {
  SkyduckFile *file = _directory.listFiles[index];
  FileCell *cell = [FileCell cellFromNib:self.fileCellUINib];
  [cell bind:file];
  return cell;
}
// 一行显示最多多少个cell
- (NSInteger)numberOfCellsInRowOfGridView:(SkyduckGridView *)gridview {
  if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
    // 竖屏
    return 4;
  } else {
    // 横屏
    return 5;
  }
}
// cell size
- (CGSize)sizeOfCellInGridView:(SkyduckGridView *)gridview {
  return CGSizeMake(170, 237);
}
// cell 之间上下空白处高度
- (CGFloat)marginOfVerticalCellInGridView:(SkyduckGridView *)gridview {
  return 20.0;
}

#pragma mark- SkyduckGridViewDelegate
// 单击一个 file cell
- (void)gridView:(SkyduckGridView *)gridView didSelectFileCellAtIndex:(NSInteger)index {
  [UIAlertView showAlertViewWithTitle:@"打开一本书"
                              message:nil
                    cancelButtonTitle:@"取消"
                    otherButtonTitles:nil
                       alertViewStyle:UIAlertViewStyleDefault
                            onDismiss:^(UIAlertView *alertView, int buttonIndex) {
                              
                            } onCancel:^{
                              
                            }];
}



// 移动两个cell
- (void)gridView:(SkyduckGridView *)gridview targetIndexForMoveFromCellAtIndex:(NSInteger)sourceIndex toProposedIndex:(NSInteger)proposedDestinationIndex {
  
  SkyduckFile *rootDirectory = [BookShelfDataSourceSingleton sharedInstance].rootDirectory;
  SkyduckFile *temp = [rootDirectory.listFiles objectAtIndex:sourceIndex];
  [rootDirectory.listFiles removeObjectAtIndex:sourceIndex];
  [rootDirectory.listFiles insertObject:temp atIndex:proposedDestinationIndex];
}

// 删除一个cell
- (void)gridView:(SkyduckGridView *)gridview deleteCellAtIndex:(NSInteger)index {
  
  SkyduckFile *rootDirectory = [BookShelfDataSourceSingleton sharedInstance].rootDirectory;
  SkyduckFile *fileForDelete = rootDirectory.listFiles[index];
  if (fileForDelete.isDirectory) {
    
  } else if (fileForDelete.isFile) {
    
    [UIAlertView showAlertViewWithTitle:@"删除书籍"
                                message:@"您确定删除这本书籍吗?"
                      cancelButtonTitle:@"取消"
                      otherButtonTitles:[NSArray arrayWithObjects:@"删除图书", nil]
                         alertViewStyle:UIAlertViewStyleDefault
                              onDismiss:^(UIAlertView *alertView, int buttonIndex) {
                                NSString *contentID = fileForDelete.value;
                                LocalBookList *localBookFromBookshelf = [GlobalDataCacheForMemorySingleton sharedInstance].localBookList;
                                [localBookFromBookshelf removeBookByContentID:contentID];
                                [rootDirectory.listFiles removeObjectAtIndex:index];
                                [_gridView reloadData];
                              } onCancel:^{
                                [_gridView resetDragingCellPosition];
                              }];
  }
  
  
}


@end
