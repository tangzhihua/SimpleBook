//
//  DreamBook
//
//  Created by 唐志华 on 13-11-08.
//
//

#import "SkyduckGridView.h"
#import "SkyduckFile.h"

#import "RNTimer.h"

@interface SkyduckGridView () <UIScrollViewDelegate, SkyduckGridViewCellDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;

// 单元格列表
@property (nonatomic, strong) NSMutableArray *cellList;
// 触点坐标
@property (nonatomic, assign) CGPoint beginTouchLocation;
@property (nonatomic, assign) CGPoint touchLocation;
// GridView Page move Timer
@property (nonatomic, strong) RNTimer *timerOfMovePage;
@property (nonatomic, strong) SkyduckGridViewCell *cellOfMoving;

// 长按 cell 会进入 编辑状态(处于编辑状态时, 可以吸附移动cell)
@property (nonatomic, assign) BOOL editable;
@end

@implementation SkyduckGridView

// 两个单元格碰撞时, 发生 Move 效果时的最小触发间距
#define kCellCollisionMoveMinDistance (80)
// 两个单元格碰撞时, 发生 Merge 效果时的最小触发间距
#define kCellCollisionMergeMinDistance (10)
// 拖动一个cell时, 当触碰到屏幕边缘时, 发生页面移动效果时的最小触发间距.
#define kPageMoveMargin (70)

// 移动方向
typedef NS_ENUM(NSInteger, MoveDirectionEnum) {
  // 上移
  kMoveDirectionEnum_Up = 0,
  // 下移
  kMoveDirectionEnum_Down,
  // 左移
  kMoveDirectionEnum_Left,
  // 右移
  kMoveDirectionEnum_Right
};


// ----------------------------------------------------------------------------------
#pragma mark -
#pragma - Property Override


#pragma mark -
#pragma mark

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    _editable = NO;
    _cellList = [[NSMutableArray alloc] init];
    
    [self createLayout];
    
    // 长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5;
    longPress.delegate = self;
    [self addGestureRecognizer:longPress];
  }
  
  return self;
}

- (void)dealloc {
  NSLog(@"dealloc uzysgridview");
}


// 将一个单元格移动到另一个单元格的位置(会重新排列网格)
// 将 sourceIndex 对应的单元格 移动到 proposedDestinationIndex 对应的位置, proposedDestinationIndex 之前的所有单元格 都向前推进, 填补 sourceIndex 空出的位置.
- (void)targetIndexForMoveFromPointAtIndex:(NSInteger)sourceIndex toProposedIndex:(NSInteger)proposedDestinationIndex {
  
  if(sourceIndex == proposedDestinationIndex || proposedDestinationIndex == -1) {
    return;
  }
  
  // 数据源索引重新排列(Data Position Rearrange)
  SkyduckGridViewCell *sourceCell = _cellList[sourceIndex];
  [_cellList removeObjectAtIndex:sourceIndex];
  [_cellList insertObject:sourceCell atIndex:proposedDestinationIndex];
  
  // 通知控制层 切换数据源中数据位置
  [_delegate gridView:self targetIndexForMoveFromCellAtIndex:sourceIndex toProposedIndex:proposedDestinationIndex];
  
  // cell 总数
  const NSUInteger numberOfCells = [_dataSource numberOfCellsInGridView:self];
  // 一行显示的cell的最大数量
  const NSUInteger numberOfCellsInRow = [_dataSource numberOfCellsInRowOfGridView:self];
  // 总行数
  const NSUInteger numberOfRows = ceilf((float)numberOfCells / (float)numberOfCellsInRow);// ceilf 向上取整
  // cell size
  const CGSize sizeOfCell = [_dataSource sizeOfCellInGridView:self];
  // cell 垂直方向的空白间距
  const CGFloat marginOfVerticalCell = [_dataSource marginOfVerticalCellInGridView:self];
  // 网格控件边界
  const CGRect gridBounds = _scrollView.bounds;
  // 单元格边界(这不是cell的真实边界, 而是用于计算每个cell 坐标)
  const CGRect cellBounds = CGRectMake(0, 0, gridBounds.size.width / (CGFloat) numberOfCellsInRow, sizeOfCell.height + marginOfVerticalCell);
  
  // 单元格重新排列(Cell Rearrange)
  // 定位所有的cell
  for(NSUInteger i=0; i<_cellList.count; i++) {
    
    SkyduckGridViewCell *cell = _cellList[i];
    //
    cell.index = i;
    
    if (sourceCell == cell) {
      // 在重新定位所有的cell时, 不要改变sourceCell, 否则会发生sourceCell脱离手指触点
      continue;
    }
    // 定位 cell
    const CGPoint origin = CGPointMake(((i % numberOfCellsInRow) * cellBounds.size.width), (i / numberOfCellsInRow * cellBounds.size.height));
    CGPoint center = CGPointMake((NSUInteger)(origin.x + cellBounds.size.width / 2), (NSUInteger)(origin.y + cellBounds.size.height/2));
    
    
    [UIView beginAnimations:@"Move" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    cell.frame = CGRectMake((NSUInteger)(center.x - cell.frame.size.width/2), (NSUInteger)(center.y - cell.frame.size.height/2), (NSUInteger)cell.frame.size.width, (NSUInteger)cell.frame.size.height);
    [UIView commitAnimations];
  }
 
  
  SkyduckGridViewCell *cellOfproposedDestinationIndex =  _cellList[proposedDestinationIndex];
  _beginTouchLocation = cellOfproposedDestinationIndex.center;
  
}

// 合并两个cell
- (void)targetIndexForMergeFromPointAtIndex:(NSInteger)sourceIndex toProposedIndex:(NSInteger)proposedDestinationIndex {
  if(sourceIndex == proposedDestinationIndex || proposedDestinationIndex == -1) {
    return;
  }
  
  SkyduckGridViewCell *sourceCell = _cellList[sourceIndex];
  [UIView animateWithDuration:0.1
                        delay:0
                      options:UIViewAnimationOptionCurveEaseIn
                   animations:^{
                     
                     sourceCell.transform = CGAffineTransformMakeScale(1, 1);
                     sourceCell.alpha = 0.8;
                     
                   }
                   completion:nil];
  
  SkyduckGridViewCell *proposedDestinationCell = _cellList[proposedDestinationIndex];
  [UIView animateWithDuration:0.1
                        delay:0
                      options:UIViewAnimationOptionCurveEaseIn
                   animations:^{
                     
                     proposedDestinationCell.transform = CGAffineTransformMakeScale(1.1, 1.1);
                     proposedDestinationCell.alpha = 0.8;
                     
                   }
                   completion:nil];
  
}

- (void)cellSetPosition:(SkyduckGridViewCell *)cell {
//  NSUInteger numCols = _numberOfColumns;
//  NSUInteger numRows = _numberOfRows;
//  NSUInteger cellsPerPage = numCols * numRows;
//  
//  if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
//    numCols = _numberOfRows;
//    numRows = _numberOfColumns;
//  }
//  
//  CGRect gridBounds = _scrollView.bounds;
//  CGRect cellBounds = CGRectMake(0, 0, gridBounds.size.width / (float) numCols, gridBounds.size.height / (float) numRows);
//  
//  NSUInteger setIndex = cell.index;
//  NSUInteger page = (NSUInteger)((float)(setIndex)/ cellsPerPage);
//  NSUInteger row = (NSUInteger)((float)(setIndex)/numCols) - (page * numRows);
//  
//  CGPoint origin = {0};
//  CGRect contractFrame = {0};
//  if([_colPosX count] == numCols && [_rowPosY count] == numRows) {
//    NSNumber *rowPos = [_rowPosY objectAtIndex:row];
//    NSNumber *col= [_colPosX objectAtIndex:(setIndex % numCols)];
//    origin = CGPointMake((page * gridBounds.size.width) + ( [col intValue]), [rowPos intValue]);
//    contractFrame = CGRectMake((NSUInteger)origin.x, (NSUInteger)origin.y, (NSUInteger)cell.cellInitFrame.size.width, (NSUInteger)cell.cellInitFrame.size.height);
//    [UIView beginAnimations:@"Move" context:nil];
//    [UIView setAnimationDuration:0.2];
//    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
//    cell.frame = contractFrame;
//    [UIView commitAnimations];
//  } else {
//    origin = CGPointMake((page * gridBounds.size.width) + (((setIndex) % numCols) * cellBounds.size.width), (row * cellBounds.size.height));
//    contractFrame = CGRectMake((NSUInteger)origin.x, (NSUInteger)origin.y, (NSUInteger)cellBounds.size.width, (NSUInteger)cellBounds.size.height);
//    [UIView beginAnimations:@"Move" context:nil];
//    [UIView setAnimationDuration:0.2];
//    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
//    cell.frame = CGRectInset(contractFrame, _cellMargin, _cellMargin);
//    [UIView commitAnimations];
//  }
}

// 源cell 和 所有其他的cell之间的碰撞检测处理
- (void)cellsCollisionDetectionHandleWithSourceCell:(SkyduckGridViewCell *)sourceCell moveDirection:(const MoveDirectionEnum)moveDirectionEnum {
  
  for(int i=0; i<_cellList.count; i++) {
    SkyduckGridViewCell *tempCell = _cellList[i];
    
    if(![sourceCell isEqual:tempCell]) {
      
      // 计算两个矩形的中心点距离(这是判断两个矩形是否相交的最简单方法)
      CGFloat xDist = (tempCell.center.x - sourceCell.center.x);
      CGFloat yDist = (tempCell.center.y - sourceCell.center.y);
      CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
      
      if (sourceCell.file.isDirectory) {
        
        if(distance < kCellCollisionMoveMinDistance) {
          // 要进行移动
          [self targetIndexForMoveFromPointAtIndex:sourceCell.index toProposedIndex:tempCell.index];
          break;
        }
        
      } else if (sourceCell.file.isFile) {
        
        if(distance < kCellCollisionMergeMinDistance) {
          // 要进行合并
          [self targetIndexForMergeFromPointAtIndex:sourceCell.index toProposedIndex:tempCell.index];
          break;
        } else if (distance < kCellCollisionMoveMinDistance) {
          
          if (kMoveDirectionEnum_Left == moveDirectionEnum) {
            // 向左移动
            if (sourceCell.center.x < tempCell.center.x) {
              // 要进行移动
              [self targetIndexForMoveFromPointAtIndex:sourceCell.index toProposedIndex:tempCell.index];
            }
          } else if (kMoveDirectionEnum_Right == moveDirectionEnum) {
            // 向右移动
            if (sourceCell.center.x > tempCell.center.x) {
              // 要进行移动
              [self targetIndexForMoveFromPointAtIndex:sourceCell.index toProposedIndex:tempCell.index];
            }
          }
        }
      }
    }
  }
}





// ----------------------------------------------------------------------------------
#pragma - Layout/Draw

- (void)createLayout {
  
  self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.contentMode = UIViewContentModeRedraw;
  self.backgroundColor = [UIColor clearColor];
  NSLog(@"SkyduckGridView bound:%@", NSStringFromCGRect(self.bounds));
  
  // 整个网格控件中, 填充着一个UIScrollView
  _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
  _scrollView.delegate = self;
  _scrollView.backgroundColor = [UIColor clearColor];
  _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  // 水平方向遇到边框是否反弹
  _scrollView.alwaysBounceHorizontal = NO;
  // 垂直方向遇到边框是否反弹
  _scrollView.alwaysBounceVertical = NO;
  // 是否显示垂直方向的滚动条
  _scrollView.showsVerticalScrollIndicator = YES;
  // 是否显示水平方向的滚动条
  _scrollView.showsHorizontalScrollIndicator = NO;
  // 控件是否整页翻动
  _scrollView.pagingEnabled = NO;
  // 视图是否延时调用开始滚动的方法
  _scrollView.delaysContentTouches = NO;
  // 控件滚动到顶部
  _scrollView.scrollsToTop = NO;
  //
  _scrollView.multipleTouchEnabled = NO;
  [self addSubview:_scrollView];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
// 只有覆盖此方法, 你才能执行自定义绘制.
- (void)drawRect:(CGRect)rect {
  // Drawing code
  [self reloadAllCells];
}

- (void)reloadData {
  [self setNeedsDisplay]; //called drawRect:(CGRect)rect
  [self setNeedsLayout];
}

// 加载全部的 cell
- (void)reloadAllCells {
  
  // 清理掉全部 cell view
  [_cellList removeAllObjects];
  // 清理掉 UIScrollView 中包含的 cell view
  for(UIView *v in _scrollView.subviews) {
    [v removeFromSuperview];
  }
  
  // cell 总数
  const NSUInteger numberOfCells = [_dataSource numberOfCellsInGridView:self];
  // 一行显示的cell的最大数量
  const NSUInteger numberOfCellsInRow = [_dataSource numberOfCellsInRowOfGridView:self];
  // 总行数
  const NSUInteger numberOfRows = ceilf((float)numberOfCells / (float)numberOfCellsInRow);// ceilf 向上取整
  // cell size
  const CGSize sizeOfCell = [_dataSource sizeOfCellInGridView:self];
  // cell 垂直方向的空白间距
  const CGFloat marginOfVerticalCell = [_dataSource marginOfVerticalCellInGridView:self];
  // 网格控件边界
  const CGRect gridBounds = _scrollView.bounds;
  // 单元格边界(这不是cell的真实边界, 而是用于计算每个cell 坐标)
  const CGRect cellBounds = CGRectMake(0, 0, gridBounds.size.width / (CGFloat) numberOfCellsInRow, sizeOfCell.height + marginOfVerticalCell);
  
  // UIScrollView 的 contentSize
  CGSize contentSizeOfScrollView = CGSizeMake(gridBounds.size.width, cellBounds.size.height * numberOfRows);
  [_scrollView setContentSize:contentSizeOfScrollView];
  
  // 定位所有的cell
  for(NSUInteger i=0; i<numberOfCells; i++) {
    
    SkyduckGridViewCell *cell = [_dataSource gridView:self cellAtIndex:i];
    cell.delegate = self;
    cell.index = i;
    
    // 定位 cell
    const CGPoint origin = CGPointMake(((i % numberOfCellsInRow) * cellBounds.size.width), (i / numberOfCellsInRow * cellBounds.size.height));
    CGPoint center = CGPointMake((NSUInteger)(origin.x + cellBounds.size.width / 2), (NSUInteger)(origin.y + cellBounds.size.height/2));
    cell.frame = CGRectMake((NSUInteger)(center.x - cell.frame.size.width/2), (NSUInteger)(center.y - cell.frame.size.height/2), (NSUInteger)cell.frame.size.width, (NSUInteger)cell.frame.size.height);
    //cell.center =
    CGRect cellFrame = cell.frame;
    
    //
    [_scrollView addSubview:cell];
    //
    [_cellList addObject:cell];
  }
}

// ----------------------------------------------------------------------------------
#pragma - Cell/Page Control

- (void)deleteCell:(NSInteger)index {
  
//  [_cellList[index] removeFromSuperview];
//  [_cellList removeObjectAtIndex:index];
//  
//  NSUInteger numCols = _numberOfColumns;
//  NSUInteger numRows = _numberOfRows;
//  NSUInteger cellsPerPage = numCols * numRows;
//  
//  if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
//    numCols = _numberOfRows;
//    numRows = _numberOfColumns;
//  }
//  
//  CGRect gridBounds = _scrollView.bounds;
//  CGRect cellBounds = CGRectMake(0, 0, gridBounds.size.width / (float) numCols, gridBounds.size.height / (float) numRows);
//  CGSize contentSizeOfScrollView = CGSizeMake(self.numberOfPages * gridBounds.size.width, gridBounds.size.height);
//  
//  [UIView animateWithDuration:0.4
//                   animations:^(void) {
//                     [_scrollView setContentSize:contentSizeOfScrollView];
//                   } ];
//  
//  for(NSUInteger i=index; i<_cellList.count; i++) {
//    SkyduckGridViewCell *cell = [_cellList objectAtIndex:i];
//    cell.index = i;
//    
//    NSUInteger page = (NSUInteger)((float)i / cellsPerPage);
//    NSUInteger row = (NSUInteger)((float)i / numCols) - (page * numRows);
//    
//    CGPoint origin = {0};
//    CGRect contractFrame = {0};
//    if(_colPosX.count == numCols && _rowPosY.count == numRows) {
//      NSNumber *rowPos = [_rowPosY objectAtIndex:row];
//      NSNumber *col= [_colPosX objectAtIndex:(i % numCols)];
//      origin = CGPointMake((page * gridBounds.size.width) + ( [col intValue]), [rowPos intValue]);
//      contractFrame = CGRectMake((NSUInteger)origin.x, (NSUInteger)origin.y, (NSUInteger)cell.cellInitFrame.size.width, (NSUInteger)cell.cellInitFrame.size.height);
//      [UIView beginAnimations:@"Move" context:nil];
//      [UIView setAnimationDuration:0.2];
//      [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
//      cell.frame = contractFrame;
//      [UIView commitAnimations];
//    } else {
//      origin = CGPointMake((page * gridBounds.size.width) + ((i % numCols) * cellBounds.size.width), (row * cellBounds.size.height));
//      contractFrame = CGRectMake((NSUInteger)origin.x, (NSUInteger)origin.y, (NSUInteger)cellBounds.size.width, (NSUInteger)cellBounds.size.height);
//      [UIView beginAnimations:@"Move" context:nil];
//      [UIView setAnimationDuration:0.2];
//      [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
//      cell.frame = CGRectInset(contractFrame, _cellMargin, _cellMargin);
//      [UIView commitAnimations];
//    }
//  }
}


// ----------------------------------------------------------------------------------
#pragma - SkyduckGridView callback


- (void)cellWasDelete:(SkyduckGridViewCell *)cell {
  [_delegate gridView:self deleteCellAtIndex:cell.index];
  //
  [self deleteCell:cell.index];
}

#pragma mark -
#pragma mark - UIScrollViewDelegate




#pragma mark -
#pragma mark - SkyduckGridViewCell Delegate
- (MoveDirectionEnum)moveDirectionFrom:(CGPoint)fromPoint to:(CGPoint)toPoint {
  if (fromPoint.x > toPoint.x) {
    return kMoveDirectionEnum_Left;
  } else if (fromPoint.x < toPoint.x) {
    return kMoveDirectionEnum_Right;
  } else if (fromPoint.y > toPoint.y) {
    return kMoveDirectionEnum_Up;
  } else {
    return kMoveDirectionEnum_Down;
  }
}

- (void)gridViewCell:(SkyduckGridViewCell *)cell touchesBegan:(UITouch *)touch {
  
  // 记录第一个 "触点" 点中的 cell 的中心点
  _beginTouchLocation = cell.center;
  _touchLocation = [touch locationInView:_scrollView];
  
  // 改变被点中的 cell 的UI效果, 好体现被点中的效果
  cell.alpha = 0.8;
  // 记录第一个 "触点" 点中的 cell 对象
  _cellOfMoving = cell;
}

- (void)gridViewCell:(SkyduckGridViewCell *)cell touchesMoved:(UITouch *)touch {
  // 一旦发生移动时, 就取消了点中cell时的效果
  cell.alpha = 1.0;
  _cellOfMoving = nil;
}

- (void)gridViewCell:(SkyduckGridViewCell *)cell touchesEnded:(UITouch *)touch {
  
  
}

- (void)gridViewCell:(SkyduckGridViewCell *)cell touchesCancelled:(UITouch *)touch {
  if (!_editable) {
    cell.alpha = 1.0;
  }
}

// cell 单击事件监听
- (void)gridViewCell:(SkyduckGridViewCell *)cell handleSingleTap:(NSUInteger)index {
  [_delegate gridView:self didSelectCellAtIndex:index];
}

// called when a gesture recognizer attempts to transition out of UIGestureRecognizerStatePossible.
// returning NO causes it to transition to UIGestureRecognizerStateFailed
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
  // 长按手势 代理 (如果没有点中一个有效的 cell 时, 是不需要检测 长按手势的)
  return _cellOfMoving != nil;
}

// 长按
- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
  
  NSLog(@"handleLongPress");
  
  switch (recognizer.state) {
    case UIGestureRecognizerStateBegan:{// 手势开始
      _editable = YES;
      
      _scrollView.scrollEnabled = NO;
      //Bring Subview to Front
      [_scrollView bringSubviewToFront:_cellOfMoving];
      
      [UIView animateWithDuration:0.1
                            delay:0
                          options:UIViewAnimationOptionCurveEaseIn
                       animations:^{
                         _cellOfMoving.transform = CGAffineTransformMakeScale(1.1, 1.1);
                         //_cellOfMoving.alpha = 1.0;
                       }
                       completion:nil];
    }break;
      
    case UIGestureRecognizerStateChanged:{// 手势变化
      // 发生了 touch move 事件, 获取一个最新的坐标点
      CGPoint newTouchLocation = [recognizer locationInView:_scrollView];
      
      // 选择 并且 移动 (Picking & Move) 一个 cell
      const float deltaX = newTouchLocation.x - _touchLocation.x;
      const float deltaY = newTouchLocation.y - _touchLocation.y;
      [_cellOfMoving moveByOffset:CGPointMake(deltaX, deltaY)];
      
      // 源cell 和 所有其他的cell之间的碰撞检测处理
      // cell 发生碰撞时, 会引起后续的处理逻辑, 如果源cell是 file类型, 就会和发生碰撞的cell发生cell合并事件, 如果是 folder 类型的, 就会发生cell移动事件.
      [self cellsCollisionDetectionHandleWithSourceCell:_cellOfMoving moveDirection:[self moveDirectionFrom:_beginTouchLocation to:newTouchLocation]];
      
//      // 页面移动(PageMove)
//      NSInteger maxScrollwidth = _scrollView.contentOffset.x + _scrollView.bounds.size.width;
//      NSInteger minScrollwidth = _scrollView.contentOffset.x;
//      
//      if (maxScrollwidth - _cellOfMoving.center.x < kPageMoveMargin) {
//        // 向右滑动
//        if(_timerOfMovePage == nil) {
//          _timerOfMovePage = [RNTimer repeatingTimerWithTimeInterval:0.7 block:^{
//            NSInteger maxScrollwidth = _scrollView.contentOffset.x + _scrollView.bounds.size.width;
//            
//            if(maxScrollwidth - _cellOfMoving.center.x < kPageMoveMargin) {
//              
//              if(self.numberOfPages - 1 > _currentPageIndex) {
//                //
//                //[self movePage:_currentPageIndex + 1 animated:YES];
//                //
//                [_cellOfMoving moveByOffset:CGPointMake(_scrollView.frame.size.width, 0)];
//                //
//                _touchLocation = CGPointMake(_touchLocation.x + _scrollView.frame.size.width, _touchLocation.y);
//                
//                if(self.numberOfPages - 1 == _currentPageIndex) {
//                  // 已经滑到了最后一页
//                  SkyduckGridViewCell *targetCell = [_cellList lastObject];
//                  [self targetIndexForMoveFromPointAtIndex:_cellOfMoving.index toProposedIndex:targetCell.index];
//                }
//              }
//            }
//            
//            _timerOfMovePage = nil;
//          }];
//        }
//        
//      } else if (_cellOfMoving.center.x - minScrollwidth < kPageMoveMargin) {
//        // 向左滑动
//        if(_timerOfMovePage == nil) {
//          
//          _timerOfMovePage = [RNTimer repeatingTimerWithTimeInterval:0.7 block:^{
//            NSInteger minScrollwidth = _scrollView.contentOffset.x;
//            if(_cellOfMoving.center.x - minScrollwidth < kPageMoveMargin) {
//              if(_currentPageIndex > 0) {
//                //
//                //[self movePage:_currentPageIndex - 1 animated:YES];
//                //
//                [_cellOfMoving moveByOffset:CGPointMake(_scrollView.frame.size.width * -1, 0)];
//                //
//                _touchLocation = CGPointMake(_touchLocation.x - _scrollView.frame.size.width, _touchLocation.y);
//              }
//            }
//            
//            _timerOfMovePage = nil;
//          }];
//        }
//        
//      } else {
//        [_timerOfMovePage invalidate], _timerOfMovePage = nil;
//      }
      
      // 更新
      _touchLocation = newTouchLocation;
    }break;
      
    case UIGestureRecognizerStateFailed:
      // do nothing
      break;
    case UIGestureRecognizerStatePossible:
      break;
    case UIGestureRecognizerStateCancelled:
      
    case UIGestureRecognizerStateEnded:{// 手势结束
      _editable = NO;
      
      _scrollView.scrollEnabled = YES;
      
      _cellOfMoving.alpha = 1.0;
      [_timerOfMovePage invalidate], _timerOfMovePage = nil;
      
      [UIView animateWithDuration:0.1
                            delay:0
                          options:UIViewAnimationOptionCurveEaseIn
                       animations:^{
                         _cellOfMoving.transform = CGAffineTransformIdentity;
                         _cellOfMoving.alpha = 1.0;
                       }
                       completion:nil];
      
      // 将移动的cell 复位
      [self cellSetPosition:_cellOfMoving];
    }break;
      
    default:
      break;
  }
  
}

// cell 长按事件监听
- (void)gridViewCell:(SkyduckGridViewCell *)cell handleLongPress:(NSUInteger)index {
  // 如果在 "编辑状态" 中, 点中一个 cell 时, 目的可能是移动这个cell, 那么必须先禁用 UIScrollView, 否则在拖动一个cell时, 后面的 UIScrollView也会一起运动.
  _scrollView.scrollEnabled = NO;
  // Bring Subview to Front
  [_scrollView bringSubviewToFront:cell];
  
  [UIView animateWithDuration:0.1
                        delay:0
                      options:UIViewAnimationOptionCurveEaseIn
                   animations:^{
                     
                     // 设置缩放，及改变a、d的值
                     cell.transform = CGAffineTransformMakeScale(1.1, 1.1);
                     //cell.alpha = 0.8;
                     
                   }
                   completion:nil];
  
}

@end
