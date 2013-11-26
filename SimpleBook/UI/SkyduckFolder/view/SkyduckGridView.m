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
@property (nonatomic, strong) SkyduckGridViewCell *cellOfMerging;


// 长按 cell 会进入 编辑状态(处于编辑状态时, 可以吸附移动cell)
@property (nonatomic, assign) BOOL editable;
@end

@implementation SkyduckGridView

// 两个单元格碰撞时, 发生 Move 效果时的最小触发间距
#define kCellCollisionMoveMinDistance (80)
// 两个单元格碰撞时, 发生 Merge 效果时的最小触发间距
#define kCellCollisionMergeMinDistance (30)
// 拖动一个cell时, 当触碰到屏幕边缘时, 发生页面移动效果时的最小触发间距.
#define kPageMoveMargin (100)

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
- (BOOL)targetIndexForMoveFromPointAtIndex:(NSInteger)sourceIndex toProposedIndex:(NSInteger)proposedDestinationIndex {
  
  if(sourceIndex == proposedDestinationIndex || proposedDestinationIndex == -1) {
    return NO;
  }
  
  NSLog(@"移动两个cell :  sourceIndex=%d, proposedDestinationIndex=%d", sourceIndex, proposedDestinationIndex);
  
  // 数据源索引重新排列(Data Position Rearrange)
  SkyduckGridViewCell *sourceCell = _cellList[sourceIndex];
  [_cellList removeObjectAtIndex:sourceIndex];
  [_cellList insertObject:sourceCell atIndex:proposedDestinationIndex];
  
  // 通知控制层 切换数据源中数据位置
  [_delegate gridView:self targetIndexForMoveFromCellAtIndex:sourceIndex toProposedIndex:proposedDestinationIndex];
  
  // cell 总数
  const NSInteger numberOfCells = [_dataSource numberOfCellsInGridView:self];
  // 一行显示的cell的最大数量
  const NSInteger numberOfCellsInRow = [_dataSource numberOfCellsInRowOfGridView:self];
  // 总行数
  const NSInteger numberOfRows = ceilf((float)numberOfCells / (float)numberOfCellsInRow);// ceilf 向上取整
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
  for(NSInteger i=0; i<_cellList.count; i++) {
    
    SkyduckGridViewCell *cell = _cellList[i];
    //
    cell.index = i;
    
    if (sourceCell == cell) {
      // 在重新定位所有的cell时, 不要改变sourceCell, 否则会发生sourceCell脱离手指触点
      continue;
    }
    // 定位 cell
    const CGPoint origin = CGPointMake(((i % numberOfCellsInRow) * cellBounds.size.width), (i / numberOfCellsInRow * cellBounds.size.height));
    CGPoint center = CGPointMake((NSInteger)(origin.x + cellBounds.size.width / 2), (NSInteger)(origin.y + cellBounds.size.height/2));
    
    [UIView animateWithDuration:0.5 animations:^{
      cell.frame = CGRectMake((NSInteger)(center.x - cell.frame.size.width/2), (NSInteger)(center.y - cell.frame.size.height/2), (NSInteger)cell.frame.size.width, (NSInteger)cell.frame.size.height);
    }];
    
  }
  
  
  SkyduckGridViewCell *cellOfproposedDestinationIndex =  _cellList[proposedDestinationIndex];
  _beginTouchLocation = cellOfproposedDestinationIndex.center;
  
  
  //
  [UIView animateWithDuration:0.1 animations:^{
    _cellOfMoving.transform = CGAffineTransformMakeScale(1.2, 1.2);
    _cellOfMoving.alpha = 0.8;
  }];
  
  //
  [UIView animateWithDuration:0.1 animations:^{
    _cellOfMerging.transform = CGAffineTransformIdentity;
    _cellOfMerging.alpha = 1.0;
    _cellOfMerging = nil;
  }];
  
  return YES;
}

// 合并两个cell
- (BOOL)targetIndexForMergeFromPointAtIndex:(NSInteger)sourceIndex toProposedIndex:(NSInteger)proposedDestinationIndex {
  if(sourceIndex == proposedDestinationIndex || proposedDestinationIndex == -1) {
    return NO;
  }
  
  
  SkyduckGridViewCell *sourceCell = _cellList[sourceIndex];
  SkyduckGridViewCell *proposedDestinationCell = _cellList[proposedDestinationIndex];
  if (_cellOfMerging == proposedDestinationCell) {
    return NO;
  }
  NSLog(@"合并两个cell :  sourceIndex=%d, proposedDestinationIndex=%d", sourceIndex, proposedDestinationIndex);
  
  _cellOfMerging.transform = CGAffineTransformIdentity;
  _cellOfMerging.alpha = 1.0;
  _cellOfMerging = proposedDestinationCell;
  //
  [UIView animateWithDuration:0.1 animations:^{
    sourceCell.transform = CGAffineTransformMakeScale(1.0, 1.0);
    sourceCell.alpha = 0.8;
  }];
  
  //
  [UIView animateWithDuration:0.1 animations:^{
    proposedDestinationCell.transform = CGAffineTransformMakeScale(1.2, 1.2);
    proposedDestinationCell.alpha = 0.8;
  }];
  
  return YES;
}

- (void)resetMovingCellPosition {
  // cell 总数
  const NSInteger numberOfCells = [_dataSource numberOfCellsInGridView:self];
  // 一行显示的cell的最大数量
  const NSInteger numberOfCellsInRow = [_dataSource numberOfCellsInRowOfGridView:self];
  // 总行数
  const NSInteger numberOfRows = ceilf((float)numberOfCells / (float)numberOfCellsInRow);// ceilf 向上取整
  // cell size
  const CGSize sizeOfCell = [_dataSource sizeOfCellInGridView:self];
  // cell 垂直方向的空白间距
  const CGFloat marginOfVerticalCell = [_dataSource marginOfVerticalCellInGridView:self];
  // 网格控件边界
  const CGRect gridBounds = _scrollView.bounds;
  // 单元格边界(这不是cell的真实边界, 而是用于计算每个cell 坐标)
  const CGRect cellBounds = CGRectMake(0, 0, gridBounds.size.width / (CGFloat) numberOfCellsInRow, sizeOfCell.height + marginOfVerticalCell);
  
  // 定位 cell
  const CGPoint origin = CGPointMake(((_cellOfMoving.index % numberOfCellsInRow) * cellBounds.size.width), (_cellOfMoving.index / numberOfCellsInRow * cellBounds.size.height));
  CGPoint center = CGPointMake((NSInteger)(origin.x + cellBounds.size.width / 2), (NSInteger)(origin.y + cellBounds.size.height/2));
  
  [UIView animateWithDuration:0.1
                   animations:^{
                     
                     _cellOfMoving.frame = CGRectMake((NSInteger)(center.x - _cellOfMoving.frame.size.width/2), (NSInteger)(center.y - _cellOfMoving.frame.size.height/2), (NSInteger)_cellOfMoving.frame.size.width, (NSInteger)_cellOfMoving.frame.size.height);
                     
                     //
                     _cellOfMoving.transform = CGAffineTransformIdentity;
                     _cellOfMoving.alpha = 1.0;
                     _cellOfMoving = nil;
                     
                     //
                     _cellOfMerging.transform = CGAffineTransformIdentity;
                     _cellOfMerging.alpha = 1.0;
                     _cellOfMerging = nil;
                   } completion:^(BOOL finished) {
                     
                   }];
  
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
          if ([self targetIndexForMoveFromPointAtIndex:sourceCell.index toProposedIndex:tempCell.index]) {
            break;
          }
        }
        
      } else if (sourceCell.file.isFile) {
        
        if(distance < kCellCollisionMergeMinDistance) {// 进入了可以合并的范围
          // 要进行合并
          if ([self targetIndexForMergeFromPointAtIndex:sourceCell.index toProposedIndex:tempCell.index]) {
            break;
          }
          
        } else if (distance < kCellCollisionMoveMinDistance && distance > kCellCollisionMergeMinDistance + 10) {// 进入了可以移动的范围
          
          if (kMoveDirectionEnum_Left == moveDirectionEnum) {
            // 向左移动
            if (sourceCell.center.x < tempCell.center.x) {
              // 要进行移动
              if ([self targetIndexForMoveFromPointAtIndex:sourceCell.index toProposedIndex:tempCell.index]) {
                break;
              }
            }
          } else if (kMoveDirectionEnum_Right == moveDirectionEnum) {
            // 向右移动
            if (sourceCell.center.x > tempCell.center.x) {
              // 要进行移动
              if ([self targetIndexForMoveFromPointAtIndex:sourceCell.index toProposedIndex:tempCell.index]) {
                break;
              }
            }
          }
        } else {// 此时都是可以取消, 合并状态的范围
          if (_cellOfMerging != nil) {
            if (distance > kCellCollisionMergeMinDistance && distance < kCellCollisionMoveMinDistance) {
              //
              [UIView animateWithDuration:0.1 animations:^{
                _cellOfMoving.transform = CGAffineTransformMakeScale(1.2, 1.2);
                _cellOfMoving.alpha = 0.8;
              }];
              
              //
              [UIView animateWithDuration:0.1 animations:^{
                _cellOfMerging.transform = CGAffineTransformIdentity;
                _cellOfMerging.alpha = 1.0;
                _cellOfMerging = nil;
              }];
              
              break;
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
  //_scrollView.scrollsToTop = YES;
  //_scrollView.pagingEnabled = YES;
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
  
  // 复位所有的状态变量
  _cellOfMoving = nil;
  _cellOfMerging = nil;
  _editable = NO;
  [_timerOfMovePage invalidate], _timerOfMovePage = nil;
  
  // 清理掉全部 cell view
  [_cellList removeAllObjects];
  // 清理掉 UIScrollView 中包含的 cell view
  for(UIView *v in _scrollView.subviews) {
    [v removeFromSuperview];
  }
  
  // cell 总数
  const NSInteger numberOfCells = [_dataSource numberOfCellsInGridView:self];
  // 一行显示的cell的最大数量
  const NSInteger numberOfCellsInRow = [_dataSource numberOfCellsInRowOfGridView:self];
  // 总行数
  const NSInteger numberOfRows = ceilf((float)numberOfCells / (float)numberOfCellsInRow);// ceilf 向上取整
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
  for(NSInteger i=0; i<numberOfCells; i++) {
    
    SkyduckGridViewCell *cell = [_dataSource gridView:self cellAtIndex:i];
    cell.delegate = self;
    cell.index = i;
    
    // 定位 cell
    const CGPoint origin = CGPointMake(((i % numberOfCellsInRow) * cellBounds.size.width), (i / numberOfCellsInRow * cellBounds.size.height));
    CGPoint center = CGPointMake((NSInteger)(origin.x + cellBounds.size.width / 2), (NSInteger)(origin.y + cellBounds.size.height/2));
    cell.frame = CGRectMake((NSInteger)(center.x - cell.frame.size.width/2), (NSInteger)(center.y - cell.frame.size.height/2), (NSInteger)cell.frame.size.width, (NSInteger)cell.frame.size.height);
    
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
  //  NSInteger numCols = _numberOfColumns;
  //  NSInteger numRows = _numberOfRows;
  //  NSInteger cellsPerPage = numCols * numRows;
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
  //  for(NSInteger i=index; i<_cellList.count; i++) {
  //    SkyduckGridViewCell *cell = [_cellList objectAtIndex:i];
  //    cell.index = i;
  //
  //    NSInteger page = (NSInteger)((float)i / cellsPerPage);
  //    NSInteger row = (NSInteger)((float)i / numCols) - (page * numRows);
  //
  //    CGPoint origin = {0};
  //    CGRect contractFrame = {0};
  //    if(_colPosX.count == numCols && _rowPosY.count == numRows) {
  //      NSNumber *rowPos = [_rowPosY objectAtIndex:row];
  //      NSNumber *col= [_colPosX objectAtIndex:(i % numCols)];
  //      origin = CGPointMake((page * gridBounds.size.width) + ( [col intValue]), [rowPos intValue]);
  //      contractFrame = CGRectMake((NSInteger)origin.x, (NSInteger)origin.y, (NSInteger)cell.cellInitFrame.size.width, (NSInteger)cell.cellInitFrame.size.height);
  //      [UIView beginAnimations:@"Move" context:nil];
  //      [UIView setAnimationDuration:0.2];
  //      [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
  //      cell.frame = contractFrame;
  //      [UIView commitAnimations];
  //    } else {
  //      origin = CGPointMake((page * gridBounds.size.width) + ((i % numCols) * cellBounds.size.width), (row * cellBounds.size.height));
  //      contractFrame = CGRectMake((NSInteger)origin.x, (NSInteger)origin.y, (NSInteger)cellBounds.size.width, (NSInteger)cellBounds.size.height);
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
  
  NSLog(@"点中的cell frame = %@", NSStringFromCGRect(cell.frame));
  
  // 记录第一个 "触点" 点中的 cell 的中心点
  _beginTouchLocation = cell.center;
  _touchLocation = [touch locationInView:_scrollView];
  
  // 记录新的选中cell, 这个cell就是要发生拖动效果的cell
  _cellOfMoving = cell;
  // 改变被点中的 cell 的UI效果, 好体现被点中的效果
  _cellOfMoving.alpha = 0.8;
  
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

// 单击 "文件"
- (void)gridViewCell:(SkyduckGridViewCell *)cell handleSingleTapFile:(NSInteger)index {
  [_delegate gridView:self didSelectFileCellAtIndex:index];
}

// 单击 "文件夹"
- (void)gridViewCell:(SkyduckGridViewCell *)cell handleSingleTapDirectory:(NSInteger)index {
  // contentOffset:滑动视图里面的内容的相对位置
  CGPoint contentOffset = _scrollView.contentOffset;
  CGPoint newOffset = CGPointMake(contentOffset.x, cell.frame.origin.y);
  if (!CGPointEqualToPoint(contentOffset, newOffset)) {
    // 现在发现使用UIView的核心动画改变contentOffset属性时, 如果cell在屏幕下方只显示了一半的范围,
    // 那么点击cell 就不会跑到屏幕顶端, 而是正好进入屏幕, 且还在屏幕下方, 所以暂时使用
    // setContentOffset:animated: 方法并且结合 delegate 的 scrollViewDidEndScrollingAnimation: 方法进行处理
    // 在这里关闭 scrollEnabled 在 scrollViewDidEndScrollingAnimation: 打开 scrollEnabled
    _scrollView.scrollEnabled = NO;
    [_scrollView setContentOffset:newOffset animated:YES];
  }
}

// called when a gesture recognizer attempts to transition out of UIGestureRecognizerStatePossible.
// returning NO causes it to transition to UIGestureRecognizerStateFailed
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
  // 长按手势 代理 (如果没有点中一个有效的 cell 时, 是不需要检测 长按手势的)
  return _cellOfMoving != nil;
}

// 长按
- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
  
  switch (recognizer.state) {
    case UIGestureRecognizerStateBegan:{// 手势开始
      _editable = YES;
      //
      _scrollView.scrollEnabled = NO;
      //Bring Subview to Front
      [_scrollView bringSubviewToFront:_cellOfMoving];
      //
      [UIView animateWithDuration:0.1 animations:^{
        _cellOfMoving.transform = CGAffineTransformMakeScale(1.2, 1.2);
      }];
      
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
      
      [_timerOfMovePage invalidate], _timerOfMovePage = nil;
      
      if (_cellOfMerging != nil) {
        // 如果当前处于合并状态时, 就告知控制器合并目标cell, 并且重新加载数据
        [_delegate gridView:self targetIndexForMergeFromCellAtIndex:_cellOfMoving.index toProposedIndex:_cellOfMerging.index];
        // 重新加载全部数据
        [self reloadData];
        //[UIView an
      } else {
        // 将移动中的cell 复位
        [self resetMovingCellPosition];
      }
      
    }break;
      
    default:
      break;
  }
  
}

// cell 长按事件监听
- (void)gridViewCell:(SkyduckGridViewCell *)cell handleLongPress:(NSInteger)index {
  // 如果在 "编辑状态" 中, 点中一个 cell 时, 目的可能是移动这个cell, 那么必须先禁用 UIScrollView, 否则在拖动一个cell时, 后面的 UIScrollView也会一起运动.
  _scrollView.scrollEnabled = NO;
  // Bring Subview to Front
  [_scrollView bringSubviewToFront:cell];
  
  [UIView animateWithDuration:0.1
                   animations:^{
                     // 设置缩放，及改变a、d的值
                     cell.transform = CGAffineTransformMakeScale(1.2, 1.2);
                     //cell.alpha = 0.8;
                     
                   }];
}

#pragma mark -
#pragma mark - UIScrollView delegate
// 1、只要view有滚动（不管是拖、拉、放大、缩小等导致）都会执行此函数
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
  
}
// 2、将要开始拖拽，手指已经放在view上并准备拖动的那一刻
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}
// 3、将要结束拖拽，手指已拖动过view并准备离开手指的那一刻，注意：当属性pagingEnabled为YES时，此函数不被调用
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
  
}
// 4、已经结束拖拽，手指刚离开view的那一刻
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  
}
// 5、view将要开始减速，view滑动之后有惯性
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
  
}
// 6、view已经停止滚动
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  
}
// 7、view的缩放
-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
  
}
// 8、有动画时调用
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
  _scrollView.scrollEnabled = YES;
}

@end
