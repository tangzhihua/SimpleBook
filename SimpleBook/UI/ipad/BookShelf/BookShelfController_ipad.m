//
//  TestBookShelfController_ipad.m
//  SimpleBook
//
//  Created by 唐志华 on 13-11-8.
//  Copyright (c) 2013年 唐志华. All rights reserved.
//

#import "BookShelfController_ipad.h"

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
#import "JWFolders.h"
#import "ExpandFolderContentView.h"

@interface BookShelfController_ipad () <SkyduckGridViewDelegate, SkyduckGridViewDataSource>
@property (nonatomic, strong) SkyduckGridView *gridView;
//
@property (nonatomic, strong) UINib *fileCellUINib;
@property (nonatomic, strong) UINib *folderCellUINib;


@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation BookShelfController_ipad
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

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    // Custom initialization
    
    SkyduckFile *rootDirectory = [BookShelfDataSourceSingleton sharedInstance].rootDirectory;
    SkyduckFile *file = nil;
    
    LocalBookList *localBookFromBookshelf = [GlobalDataCacheForMemorySingleton sharedInstance].localBookList;
    BookInfo *bookInfo = nil;
    LocalBook *localBook = nil;
    
    NSArray *imageUrlArray = @[@"http://d.hiphotos.baidu.com/pic/w%3D310/sign=474e7140faedab6474724bc1c737af81/e824b899a9014c088d47272e0b7b02087bf4f439.jpg",
                               @"http://b.hiphotos.baidu.com/pic/w%3D310/sign=54d8d4db50da81cb4ee685cc6267d0a4/cefc1e178a82b901b326ff1c728da9773912ef12.jpg",
                               @"http://b.hiphotos.baidu.com/pic/w%3D310/sign=694ce8049f3df8dca63d8990fd1072bf/d833c895d143ad4bc890a03382025aafa50f0682.jpg",
                               @"http://a.hiphotos.baidu.com/pic/w%3D310/sign=0320b1f2cb8065387beaa212a7dca115/fcfaaf51f3deb48f1c679562f11f3a292df5787b.jpg",
                               @"http://c.hiphotos.baidu.com/pic/w%3D310/sign=777cd344a686c91708035438f93c70c6/34fae6cd7b899e51ed050da843a7d933c9950d86.jpg",
                               @"http://c.hiphotos.baidu.com/pic/w%3D310/sign=d371aaef5366d0167e199829a72ad498/4b90f603738da977d3b8af09b151f8198618e379.jpg",
                               @"http://c.hiphotos.baidu.com/pic/w%3D310/sign=0805c87c6a63f6241c5d3f02b744eb32/5882b2b7d0a20cf4cbb7bd9a77094b36acaf9954.jpg",
                               @"http://h.hiphotos.baidu.com/pic/w%3D310/sign=070287618718367aad8979dc1e728b68/3c6d55fbb2fb4316da71303221a4462309f7d308.jpg",
                               @"http://h.hiphotos.baidu.com/pic/w%3D310/sign=96fd9e15314e251fe2f7e2f99787c9c2/0824ab18972bd407e233efd27a899e510fb3092c.jpg",
                               @"http://f.hiphotos.baidu.com/pic/w%3D310/sign=c7a46a3863d0f703e6b293dd38fb5148/359b033b5bb5c9ea58793fccd439b6003af3b312.jpg",
                               
                               @"http://g.hiphotos.baidu.com/pic/w%3D310/sign=85cd8f8da08b87d65042ad1e37092860/08f790529822720e3a22df467acb0a46f31fab99.jpg",
                               @"http://b.hiphotos.baidu.com/pic/w%3D310/sign=bb195e3310dfa9ecfd2e501652d1f754/6159252dd42a28347d510a245ab5c9ea15cebf2d.jpg",
                               @"http://a.hiphotos.baidu.com/pic/w%3D310/sign=65a25d77b3fb43161a1f7c7b10a54642/e850352ac65c10380b8cf37eb3119313b17e899f.jpg",
                               @"http://d.hiphotos.baidu.com/pic/w%3D310/sign=054a79c60e2442a7ae0efba4e143ad95/4bed2e738bd4b31c1c1ad7fe86d6277f9e2ff855.jpg",
                               @"http://g.hiphotos.baidu.com/pic/w%3D310/sign=54ae9a741f178a82ce3c79a1c602737f/a8ec8a13632762d0218bc407a1ec08fa503dc6d5.jpg",
                               @"http://a.hiphotos.baidu.com/pic/w%3D310/sign=58979f88bba1cd1105b674218913c8b0/ac4bd11373f08202fae4ea874afbfbedab641b17.jpg",
                               @"http://c.hiphotos.baidu.com/pic/w%3D310/sign=61573758f603918fd7d13bcb613c264b/023b5bb5c9ea15ce34a380b1b7003af33a87b23c.jpg",
                               @"http://h.hiphotos.baidu.com/pic/w%3D310/sign=ee55fc648b13632715edc432a18ea056/d52a2834349b033ba43f9c6214ce36d3d439bdd7.jpg",
                               @"http://f.hiphotos.baidu.com/pic/w%3D310/sign=2ecab4bcd462853592e0d420a0ee76f2/b03533fa828ba61e1d4906614034970a314e59dd.jpg",
                               @"http://a.hiphotos.baidu.com/pic/w%3D310/sign=6d959f4c50da81cb4ee685cc6267d0a4/cefc1e178a82b9018a6bb48b728da9773812ef40.jpg",
                               
                               @"http://c.hiphotos.baidu.com/pic/w%3D310/sign=edfca6dc78310a55c424d8f587444387/0b7b02087bf40ad17813fbcc562c11dfa9ecce2d.jpg",
                               @"http://a.hiphotos.baidu.com/pic/w%3D310/sign=5f0d752c472309f7e76fab13420f0c39/faf2b2119313b07edac730b00dd7912397dd8c0b.jpg",
                               @"http://b.hiphotos.baidu.com/pic/w%3D310/sign=643384b9e4dde711e7d245f797eecef4/838ba61ea8d3fd1ff0659686314e251f95ca5f19.jpg",
                               @"http://h.hiphotos.baidu.com/pic/w%3D310/sign=d7820ba8aa18972ba33a06cbd6cc7b9d/a8773912b31bb051ff8d8494377adab44bede0e4.jpg",
                               @"http://d.hiphotos.baidu.com/pic/w%3D310/sign=186b97ec024f78f0800b9cf249300a83/a8014c086e061d95e9fd3e807af40ad163d9cacb.jpg",
                               @"http://h.hiphotos.baidu.com/pic/w%3D310/sign=c06fcc290b55b3199cf9847473a88286/03087bf40ad162d99d7fe23410dfa9ec8a13cd01.jpg",
                               @"http://d.hiphotos.baidu.com/pic/w%3D310/sign=b8dab9908601a18bf0eb144eae2e0761/472309f7905298224100067fd6ca7bcb0a46d45e.jpg",
                               @"http://e.hiphotos.baidu.com/pic/w%3D310/sign=55e5c070c2cec3fd8b3ea174e689d4b6/4afbfbedab64034f9407ffbaaec379310b551d47.jpg",
                               @"http://a.hiphotos.baidu.com/pic/w%3D310/sign=0eea101a0d3387449cc5297d610ed937/0df431adcbef7609b3f8d7d52fdda3cc7dd99e8d.jpg",
                               @"http://b.hiphotos.baidu.com/pic/w%3D310/sign=23ff9d96a9d3fd1f3609a43b004f25ce/38dbb6fd5266d016a8509090962bd40735fa3538.jpg"];
    
    //
    NSMutableArray *files = [NSMutableArray array];
    bookInfo = [[BookInfo alloc] init];
    bookInfo.content_id = [[NSNumber numberWithInt:imageUrlArray.count] stringValue];
    bookInfo.name = @"蓝胖子";
    bookInfo.thumbnail = @"http://f.hiphotos.baidu.com/pic/w%3D310/sign=db18c99ed0160924dc25a41ae405359b/f703738da9773912defe2ba9f8198618377ae21a.jpg";
    localBook = [[LocalBook alloc] initWithBookInfo:bookInfo];
    [localBookFromBookshelf addBook:localBook];
    file = [SkyduckFile createFileWithValue:bookInfo.content_id];
    [files addObject:file];
    //
    bookInfo = [[BookInfo alloc] init];
    bookInfo.content_id = [[NSNumber numberWithInt:imageUrlArray.count + 1] stringValue];
    bookInfo.name = @"风萧萧兮易水寒, 壮士一去兮不复还.";
    bookInfo.thumbnail = @"http://b.hiphotos.baidu.com/pic/w%3D310/sign=5a255dac9313b07ebdbd56093cd59113/cf1b9d16fdfaaf5152095b328c5494eef11f7a51.jpg";
    localBook = [[LocalBook alloc] initWithBookInfo:bookInfo];
    [localBookFromBookshelf addBook:localBook];
    file = [SkyduckFile createFileWithValue:bookInfo.content_id];
    [files addObject:file];
    
    SkyduckFile *directory = [SkyduckFile createDirectoryWithValue:@"文件夹" files:files];
    [rootDirectory addFile:directory];
    
    for (int i=0; i<imageUrlArray.count; i++) {
      //
      bookInfo = [[BookInfo alloc] init];
      bookInfo.content_id = [[NSNumber numberWithInt:i] stringValue];
      bookInfo.name = [NSString stringWithFormat:@"书籍 %d", i];
      bookInfo.thumbnail = imageUrlArray[i];
      localBook = [[LocalBook alloc] initWithBookInfo:bookInfo];
      [localBookFromBookshelf addBook:localBook];
      
      file = [SkyduckFile createFileWithValue:bookInfo.content_id];
      [rootDirectory addFile:file];
    }
    
    
    
    
    
    
  }
  return self;
}


- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  _gridView = [[SkyduckGridView alloc] initWithFrame:CGRectMake(0, 20 + 44, self.view.bounds.size.width, self.view.bounds.size.height - (20 + 44 + 44))];
  _gridView.delegate = self;
  _gridView.dataSource = self;
  _gridView.mergeEnabled = YES;
  UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
  searchButton.frame = CGRectMake(0, 0, _gridView.bounds.size.width, 44);
  //设置button填充图片
  //[searchButton setBackgroundImage:[UIImage imageNamed:@"search_bar_background"] forState:UIControlStateNormal];
  [searchButton setImage:[UIImage imageNamed:@"ss"] forState:UIControlStateNormal];
  [searchButton setImage:[UIImage imageNamed:@"ss_dj"] forState:UIControlStateHighlighted];
  _gridView.headerView = searchButton;
  
  //
  _gridView.topPadding = 20;
  _gridView.leftPadding = 40;
  _gridView.rightPadding = 40;
  _gridView.bottomPadding = 20;
  //
  [_gridView reloadData];
  [self.view addSubview:_gridView];
  
  
  [self.view bringSubviewToFront:_toolbar];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)logoutButtonOnClickListener:(id)sender {
  
  [self.navigationController setNavigationBarHidden:YES animated:TRUE];
}


#pragma mark -
#pragma mark - SkyduckGridViewDataSource
// 在网格控件中cell总数量
- (NSInteger)numberOfCellsInGridView:(SkyduckGridView *)gridview {
  return [BookShelfDataSourceSingleton sharedInstance].rootDirectory.listFiles.count;
}
//
- (SkyduckGridViewCell *)gridView:(SkyduckGridView *)gridview cellAtIndex:(NSInteger)index {
  SkyduckFile *rootDirectory = [BookShelfDataSourceSingleton sharedInstance].rootDirectory;
  SkyduckFile *file = rootDirectory.listFiles[index];
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
  return CGSizeMake(142, 190);
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

// 单击一个 directory cell
- (void)gridView:(SkyduckGridView *)gridView didSelectDirectoryCellAtIndex:(NSInteger)index {
  SkyduckFile *rootDirectory = [BookShelfDataSourceSingleton sharedInstance].rootDirectory;
  SkyduckFile *directory = [rootDirectory.listFiles objectAtIndex:index];
  ExpandFolderContentView *contentView = [[ExpandFolderContentView alloc] initWithFrame:self.view.frame];
  [contentView bind:directory];
  CGPoint openPoint = CGPointMake(200, 200); //arbitrary point
  
  
  
  // you can also open the folder this way
  // it could be potentially easier if you don't need the blocks
  JWFolders *folder = [JWFolders folder];
  folder.contentView = contentView;
  folder.containerView = self.view;
  folder.position = openPoint;
  folder.direction = JWFoldersOpenDirectionDown;
  folder.contentBackgroundColor = [UIColor colorWithWhite:0.90 alpha:1.0];
  folder.shadowsEnabled = YES;
  folder.shadowColor = [UIColor redColor];
  folder.darkensBackground = NO;
  //folder.showsNotch = YES;
  [folder open];
  
}

// 合并两个cell
- (void)gridView:(SkyduckGridView *)gridview targetIndexForMergeFromCellAtIndex:(NSInteger)sourceIndex toProposedIndex:(NSInteger)proposedDestinationIndex {
  
  SkyduckFile *rootDirectory = [BookShelfDataSourceSingleton sharedInstance].rootDirectory;
  SkyduckFile *sourceFile = rootDirectory.listFiles[sourceIndex];
  SkyduckFile *destinationFile = rootDirectory.listFiles[proposedDestinationIndex];
  
  //
  if (destinationFile.isDirectory) {
    [rootDirectory removeFile:sourceFile];
    [destinationFile addFile:sourceFile];
  } else if (destinationFile.isFile) {
    [rootDirectory removeFile:sourceFile];
    [rootDirectory removeFile:destinationFile];
    NSArray *files = [NSArray arrayWithObjects:sourceFile, destinationFile, nil];
    SkyduckFile *newDirectory = [SkyduckFile createDirectoryWithValue:@"新建文件夹" files:files];
    if (sourceIndex > proposedDestinationIndex) {
      [rootDirectory insertFile:newDirectory atIndex:proposedDestinationIndex];
    } else {
      [rootDirectory insertFile:newDirectory atIndex:proposedDestinationIndex - 1];
    }
    
  }
  
}
// 移动两个cell
- (void)gridView:(SkyduckGridView *)gridview targetIndexForMoveFromCellAtIndex:(NSInteger)sourceIndex toProposedIndex:(NSInteger)proposedDestinationIndex {
  
  SkyduckFile *rootDirectory = [BookShelfDataSourceSingleton sharedInstance].rootDirectory;
  SkyduckFile *temp = rootDirectory.listFiles[sourceIndex];
  [rootDirectory removeFileAtIndex:sourceIndex];
  [rootDirectory insertFile:temp atIndex:proposedDestinationIndex];
}

// 删除一个cell
- (void)gridView:(SkyduckGridView *)gridview deleteCellAtIndex:(NSInteger)index {
  
  SkyduckFile *rootDirectory = [BookShelfDataSourceSingleton sharedInstance].rootDirectory;
  SkyduckFile *fileForDelete = rootDirectory.listFiles[index];
  if (fileForDelete.isDirectory) {
    
    [UIAlertView showAlertViewWithTitle:@"删除分组"
                                message:@"是否也同时删除分组内的图书?"
                      cancelButtonTitle:@"取消"
                      otherButtonTitles:[NSArray arrayWithObjects:@"删除图书", @"不删除图书", nil]
                         alertViewStyle:UIAlertViewStyleDefault
                              onDismiss:^(UIAlertView *alertView, int buttonIndex) {
                                switch (buttonIndex) {
                                    case 0:{// 删除图书
                                      
                                      LocalBookList *localBookFromBookshelf = [GlobalDataCacheForMemorySingleton sharedInstance].localBookList;
                                      for (SkyduckFile *file in fileForDelete.listFiles) {
                                        NSString *contentID = file.value;
                                        [localBookFromBookshelf removeBookByContentID:contentID];
                                      }
                                      
                                      [rootDirectory removeFileAtIndex:index];
                                      [_gridView reloadData];
                                    }break;
                                    
                                    case 1:{// 不删除图书
                                      for (SkyduckFile *file in fileForDelete.listFiles) {
                                        [rootDirectory insertFile:file atIndex:index];
                                      }
                                      
                                      [rootDirectory removeFile:fileForDelete];
                                      [_gridView reloadData];
                                    }break;
                                  default:
                                    break;
                                }
                              } onCancel:^{
                                [_gridView resetDragingCellPosition];
                              }];
    
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
                                [rootDirectory removeFileAtIndex:index];
                                [_gridView reloadData];
                              } onCancel:^{
                                [_gridView resetDragingCellPosition];
                              }];
  }
  
  
  
  
  
  
}

@end
