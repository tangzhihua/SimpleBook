//
//  TestBookShelfController_ipad.m
//  SimpleBook
//
//  Created by 唐志华 on 13-11-8.
//  Copyright (c) 2013年 唐志华. All rights reserved.
//

#import "TestBookShelfController_ipad.h"
#import "SkyduckFile.h"
#import "BookShelfDataSourceSingleton.h"
#import "BookInfo.h"
#import "LocalBook.h"
#import "LocalBookList.h"
#import "SkyduckGridView.h"
#import "SkyduckGridViewCell.h"
#import "FolderCell.h"
#import "FileCell.h"
#import "SkyduckGridViewCell.h"

@interface TestBookShelfController_ipad () <SkyduckGridViewDelegate, SkyduckGridViewDataSource>
@property (nonatomic, strong) SkyduckGridView *gridView;
//
@property (nonatomic, retain) UINib *fileCellUINib;
@property (nonatomic, retain) UINib *folderCellUINib;
@end

@implementation TestBookShelfController_ipad
- (UINib *)fileCellUINib {
  if (_fileCellUINib == nil) {
    self.fileCellUINib = [FileCell nib];
  }
  return _fileCellUINib;
}

- (UINib *)folderCellUINib {
  if (_folderCellUINib == nil) {
    self.folderCellUINib = [FolderCell nib];
  }
  return _folderCellUINib;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    
    SkyduckFile *rootDirectory = [BookShelfDataSourceSingleton sharedInstance].rootDirectory;
    SkyduckFile *file = nil;
    
    LocalBookList *localBookFromBookshelf = [GlobalDataCacheForMemorySingleton sharedInstance].localBookList;
    BookInfo *bookInfo = nil;
    LocalBook *localBook = nil;
    
    for (int i=0; i<20; i++) {
      //
      bookInfo = [[BookInfo alloc] init];
      bookInfo.content_id = [[NSNumber numberWithInt:i] stringValue];
      bookInfo.name = @"初中叽叽报告";
      //bookInfo.thumbnail = @"http://img.baidu.com/img/image/sy.jpg";
      localBook = [[LocalBook alloc] initWithBookInfo:bookInfo];
      [localBookFromBookshelf addBook:localBook];
      
      file = [SkyduckFile createFileWithValue:bookInfo.content_id];
      [rootDirectory addFile:file];
    }
    
    
    
    
    //
    NSMutableArray *files = [NSMutableArray array];
    bookInfo = [[BookInfo alloc] init];
    bookInfo.content_id = @"3";
    bookInfo.name = @"岸本齐史";
    bookInfo.thumbnail = @"https://dreambook.retechcorp.com/dreambook/thumbnail/show/4";
    localBook = [[LocalBook alloc] initWithBookInfo:bookInfo];
    [localBookFromBookshelf addBook:localBook];
    file = [SkyduckFile createFileWithValue:bookInfo.content_id];
    [files addObject:file];
    //
    bookInfo = [[BookInfo alloc] init];
    bookInfo.content_id = @"4";
    bookInfo.name = @"火影忍者";
    bookInfo.thumbnail = @"https://dreambook.retechcorp.com/dreambook/thumbnail/show/4";
    localBook = [[LocalBook alloc] initWithBookInfo:bookInfo];
    [localBookFromBookshelf addBook:localBook];
    file = [SkyduckFile createFileWithValue:bookInfo.content_id];
    [files addObject:file];
    
    SkyduckFile *directory = [SkyduckFile createDirectoryWithValue:@"文件夹" files:files];
    [rootDirectory addFile:directory];
    
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  _gridView = [[SkyduckGridView alloc] initWithFrame:self.view.frame];
  _gridView.delegate = self;
  _gridView.dataSource = self;
  [self.view addSubview:_gridView];
  
  [_gridView reloadData];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - 
#pragma mark - SkyduckGridViewDataSource
// 在网格控件中cell总数量
- (NSUInteger)numberOfCellsInGridView:(SkyduckGridView *)gridview {
  return [BookShelfDataSourceSingleton sharedInstance].rootDirectory.listFiles.count;
}
//
- (SkyduckGridViewCell *)gridView:(SkyduckGridView *)gridview cellAtIndex:(NSUInteger)index {
  SkyduckFile *file = [BookShelfDataSourceSingleton sharedInstance].rootDirectory.listFiles[index];
  if (file.isFile) {
    FileCell *cell = [FileCell cellFromNib:self.fileCellUINib];
    [cell bind:file];
    return cell;
  } else {
    FolderCell *cell = [FolderCell cellFromNib:self.folderCellUINib];
    [cell bind:file];
    return cell;
  }
}
// 一行显示最多多少个cell
- (NSUInteger)numberOfCellsInRowOfGridView:(SkyduckGridView *)gridview {
  if (UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
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
// 单击一个cell
- (void)gridView:(SkyduckGridView *)gridView didSelectCellAtIndex:(NSUInteger)index {
  NSLog(@"点击了一个cell : %d", index);
}
// 合并两个cell
- (void)gridView:(SkyduckGridView *)gridview targetIndexForMergeFromCellAtIndex:(NSUInteger)sourceIndex toProposedIndex:(NSUInteger)proposedDestinationIndex {
  NSLog(@"合并两个cell : sourceIndex=%d, proposedDestinationIndex=%d", sourceIndex, proposedDestinationIndex);
}
// 移动两个cell
- (void)gridView:(SkyduckGridView *)gridview targetIndexForMoveFromCellAtIndex:(NSUInteger)sourceIndex toProposedIndex:(NSUInteger)proposedDestinationIndex {
  NSLog(@"移动两个cell :  sourceIndex=%d, proposedDestinationIndex=%d", sourceIndex, proposedDestinationIndex);
  
  SkyduckFile *rootDirectory = [BookShelfDataSourceSingleton sharedInstance].rootDirectory;
  SkyduckFile *temp = [rootDirectory.listFiles objectAtIndex:sourceIndex];
  [rootDirectory.listFiles removeObjectAtIndex:sourceIndex];
  [rootDirectory.listFiles insertObject:temp atIndex:proposedDestinationIndex];
}
// 删除一个cell
- (void)gridView:(SkyduckGridView *)gridview deleteCellAtIndex:(NSUInteger)index {
  NSLog(@"删除一个cell : %d", index);
  
  SkyduckFile *rootDirectory = [BookShelfDataSourceSingleton sharedInstance].rootDirectory;
  [rootDirectory.listFiles removeObjectAtIndex:index];
}

@end
