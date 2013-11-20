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

// 行
@property (nonatomic, assign) NSUInteger numberOfRows;
// 列
@property (nonatomic, assign) NSUInteger numberOfColumns;
// 单元格间距
@property (nonatomic, assign) NSUInteger cellMargin;
@property (nonatomic, strong) NSArray *colPosX;
@property (nonatomic, strong) NSArray *rowPosY;
// 当前页索引(从 0 开始)
@property (nonatomic, assign) NSUInteger currentPageIndex;
// 长按 cell 会进入 编辑状态
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

- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex {
  if(currentPageIndex < self.numberOfPages) {
    _currentPageIndex = currentPageIndex;
  }else{
    _currentPageIndex = self.numberOfPages - 1;
  }
  if(self.numberOfPages == 0){
    _currentPageIndex = 0;
  }
}

// 总页数
- (NSUInteger)numberOfPages {
  // 数据源中 真实单元格总数
  NSUInteger numberOfCells = [_dataSource numberOfCellsInGridView:self];
  // 网格控件中一页中能够放置的单元格总数
  NSUInteger cellsPerPage = _numberOfColumns * _numberOfRows;
  // ceil : 返回大于或者等于指定表达式的最小整数
  return (NSUInteger)(ceil((float)numberOfCells / (float)cellsPerPage));
}

#pragma mark -
#pragma mark

- (id)initWithFrame:(CGRect)frame numOfRow:(NSUInteger)rows numOfColumns:(NSUInteger)columns cellMargin:(NSUInteger)cellMargins {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    _editable = NO;
    
    _numberOfRows = rows;
    _numberOfColumns = columns;
    _cellMargin = cellMargins;
    
    [self createLayout];
    [self initVariable];
    
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


- (void)initVariable {
  _cellList = [[NSMutableArray alloc] init];
}

// 将一个单元格移动到另一个单元格的位置(会重新排列网格)
// 将 sourceIndex 对应的单元格 移动到 proposedDestinationIndex 对应的位置, proposedDestinationIndex 之前的所有单元格 都向前推进, 填补 sourceIndex 空出的位置.
- (void)targetIndexForMoveFromPointAtIndex:(NSInteger)sourceIndex toProposedIndex:(NSInteger)proposedDestinationIndex {
  
  if(sourceIndex == proposedDestinationIndex || proposedDestinationIndex == -1) {
    return;
  }
  
  NSUInteger numCols = _numberOfColumns;
  NSUInteger numRows = _numberOfRows;
  NSUInteger cellsPerPage = numCols * numRows;
  
  if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
    numCols = _numberOfRows;
    numRows = _numberOfColumns;
  }
  
  CGRect gridBounds = _scrollView.bounds;
  CGRect cellBounds = CGRectMake(0, 0, gridBounds.size.width / (float) numCols, gridBounds.size.height / (float) numRows);
  CGSize contentSize = CGSizeMake(self.numberOfPages * gridBounds.size.width , gridBounds.size.height);
  
  [_scrollView setContentSize:contentSize];
  
  // 数据源索引重新排列(Data Position Rearrange)
  SkyduckGridViewCell *sourceCell = _cellList[sourceIndex];
  [_cellList removeObjectAtIndex:sourceIndex];
  [_cellList insertObject:sourceCell atIndex:proposedDestinationIndex];
  
  // 通知控制层 切换数据源中数据位置
  if(_dataSource != nil && [_dataSource respondsToSelector:@selector(gridView:moveAtIndex:toIndex:)]) {
    [_dataSource gridView:self moveAtIndex:sourceIndex toIndex:proposedDestinationIndex];
  }
  
  // 单元格重新排列(Cell Rearrange)
  for(NSUInteger i=0; i<_cellList.count; i++) {
    
    SkyduckGridViewCell *tempCell = _cellList[i];
    //
    tempCell.index = i;
    
    if(sourceCell != tempCell) {
      NSUInteger page = (NSUInteger)((float)(i) / cellsPerPage);
      NSUInteger row = (NSUInteger)((float)(i) / numCols) - (page * numRows);
      // 源点
      CGPoint origin = {0};
      CGRect contractFrame = {0};
      
      if([_colPosX count] == numCols && [_rowPosY count] == numRows) {
        NSNumber *rowPos = [_rowPosY objectAtIndex:row];
        NSNumber *col= [_colPosX objectAtIndex:(i % numCols)];
        origin = CGPointMake((page * gridBounds.size.width) + ( [col intValue]), [rowPos intValue]);
        contractFrame = CGRectMake((NSUInteger)origin.x, (NSUInteger)origin.y, (NSUInteger)tempCell.cellInitFrame.size.width, (NSUInteger)tempCell.cellInitFrame.size.height);
        
        [UIView beginAnimations:@"Move" context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
        tempCell.frame = contractFrame;
        [UIView commitAnimations];
        
      } else {
        
        origin = CGPointMake((page * gridBounds.size.width) + ((i % numCols) * cellBounds.size.width), (row * cellBounds.size.height));
        contractFrame = CGRectMake((NSUInteger)origin.x, (NSUInteger)origin.y, (NSUInteger)cellBounds.size.width, (NSUInteger)cellBounds.size.height);
        
        [UIView beginAnimations:@"Move" context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
        // CGRectInset : 该结构体的应用是以原rect为中心，再参考dx，dy，进行缩放或者放大(dx为正数就是缩小, 为负数就是放大)。
        tempCell.frame = CGRectInset(contractFrame, _cellMargin, _cellMargin);
        [UIView commitAnimations];
      }
    }
  }
  
  SkyduckGridViewCell *cellOfproposedDestinationIndex =  _cellList[proposedDestinationIndex];
  _beginTouchLocation =  cellOfproposedDestinationIndex.center;
  
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
  NSUInteger numCols = _numberOfColumns;
  NSUInteger numRows = _numberOfRows;
  NSUInteger cellsPerPage = numCols * numRows;
  
  if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
    numCols = _numberOfRows;
    numRows = _numberOfColumns;
  }
  
  CGRect gridBounds = _scrollView.bounds;
  CGRect cellBounds = CGRectMake(0, 0, gridBounds.size.width / (float) numCols, gridBounds.size.height / (float) numRows);
  
  NSUInteger setIndex = cell.index;
  NSUInteger page = (NSUInteger)((float)(setIndex)/ cellsPerPage);
  NSUInteger row = (NSUInteger)((float)(setIndex)/numCols) - (page * numRows);
  
  CGPoint origin = {0};
  CGRect contractFrame = {0};
  if([_colPosX count] == numCols && [_rowPosY count] == numRows) {
    NSNumber *rowPos = [_rowPosY objectAtIndex:row];
    NSNumber *col= [_colPosX objectAtIndex:(setIndex % numCols)];
    origin = CGPointMake((page * gridBounds.size.width) + ( [col intValue]), [rowPos intValue]);
    contractFrame = CGRectMake((NSUInteger)origin.x, (NSUInteger)origin.y, (NSUInteger)cell.cellInitFrame.size.width, (NSUInteger)cell.cellInitFrame.size.height);
    [UIView beginAnimations:@"Move" context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    cell.frame = contractFrame;
    [UIView commitAnimations];
  } else {
    origin = CGPointMake((page * gridBounds.size.width) + (((setIndex) % numCols) * cellBounds.size.width), (row * cellBounds.size.height));
    contractFrame = CGRectMake((NSUInteger)origin.x, (NSUInteger)origin.y, (NSUInteger)cellBounds.size.width, (NSUInteger)cellBounds.size.height);
    [UIView beginAnimations:@"Move" context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    cell.frame = CGRectInset(contractFrame, _cellMargin, _cellMargin);
    [UIView commitAnimations];
  }
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
  
  _currentPageIndex = 0;
  
  self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.contentMode = UIViewContentModeRedraw;
  self.backgroundColor = [UIColor clearColor];
  NSLog(@"uzysView bound:%@", NSStringFromCGRect(self.bounds));
  
  _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
  _scrollView.delegate = self;
  _scrollView.backgroundColor = [UIColor clearColor];
  _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  _scrollView.alwaysBounceHorizontal = YES;
  _scrollView.alwaysBounceVertical = NO;
  _scrollView.showsVerticalScrollIndicator = NO;
  _scrollView.showsHorizontalScrollIndicator = NO;
  _scrollView.pagingEnabled = YES;
  _scrollView.delaysContentTouches =YES;
  _scrollView.scrollsToTop = NO;
  _scrollView.multipleTouchEnabled = NO;
  [self addSubview:_scrollView];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
// 只有覆盖此方法, 你才能执行自定义绘制.
- (void)drawRect:(CGRect)rect {
  // Drawing code
  [self loadTotalView];
  
}

- (void)reloadData {
  [self setNeedsDisplay]; //called drawRect:(CGRect)rect
  [self setNeedsLayout];
}

// 加载全部的 cell
- (void)loadTotalView {
  
  if(_dataSource != nil && _numberOfRows > 0 && _numberOfColumns > 0) {
    // 列
    NSUInteger numCols = _numberOfColumns;
    // 行
    NSUInteger numRows = _numberOfRows;
    // 单元格总数
    NSUInteger cellsPerPage = numCols * numRows;
    //
    [_cellList removeAllObjects];
    
    //
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
      numCols = _numberOfRows;
      numRows = _numberOfColumns;
    }
    
    // 网格边界
    CGRect gridBounds = self.scrollView.bounds;
    
    // 单元格边界
    CGRect cellBounds = CGRectMake(0, 0, gridBounds.size.width / (float) numCols, gridBounds.size.height / (float) numRows);
    
    // UIScrollView 的 contentSize
    CGSize contentSizeOfScrollView = CGSizeMake(self.numberOfPages * gridBounds.size.width , gridBounds.size.height);
    [self.scrollView setContentSize:contentSizeOfScrollView];
    
    //
    for(UIView *v in self.scrollView.subviews) {
      [v removeFromSuperview];
    }
    
    for(NSUInteger i=0; i<[_dataSource numberOfCellsInGridView:self]; i++) {
      
      SkyduckGridViewCell *cell = [_dataSource gridView:self cellAtIndex:i];
      cell.delegate = self;
      cell.index = i;
      
      NSUInteger page = (NSUInteger)((float)i / cellsPerPage);
      NSUInteger row = (NSUInteger)((float)i / numCols) - (page * numRows);
      
      CGPoint origin = {0};
      CGRect contractFrame = {0};
      if(_colPosX.count == numCols && _rowPosY.count == numRows) {
        NSNumber *rowPos = [_rowPosY objectAtIndex:row];
        NSNumber *col= [_colPosX objectAtIndex:(i % numCols)];
        origin = CGPointMake((page * gridBounds.size.width) + ( [col intValue]), [rowPos intValue]);
        contractFrame = CGRectMake((NSUInteger)origin.x, (NSUInteger)origin.y, (NSUInteger)cell.cellInitFrame.size.width, (NSUInteger)cell.cellInitFrame.size.height);
        cell.frame = contractFrame;
      } else {
        origin = CGPointMake((page * gridBounds.size.width) + ((i % numCols) * cellBounds.size.width), (row * cellBounds.size.height));
        contractFrame = CGRectMake((NSUInteger)origin.x, (NSUInteger)origin.y, (NSUInteger)cellBounds.size.width, (NSUInteger)cellBounds.size.height);
        cell.frame = CGRectInset(contractFrame, _cellMargin, _cellMargin);
      }
      
      [self.scrollView addSubview:cell];
      
      [_cellList addObject:cell];
    }
    
    //
    [self movePage:_currentPageIndex animated:NO];
    
  }
  
}

// ----------------------------------------------------------------------------------
#pragma - Cell/Page Control

- (void)deleteCell:(NSInteger)index {
  
  [_cellList[index] removeFromSuperview];
  [_cellList removeObjectAtIndex:index];
  
  NSUInteger numCols = _numberOfColumns;
  NSUInteger numRows = _numberOfRows;
  NSUInteger cellsPerPage = numCols * numRows;
  
  if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
    numCols = _numberOfRows;
    numRows = _numberOfColumns;
  }
  
  CGRect gridBounds = self.scrollView.bounds;
  CGRect cellBounds = CGRectMake(0, 0, gridBounds.size.width / (float) numCols, gridBounds.size.height / (float) numRows);
  CGSize contentSizeOfScrollView = CGSizeMake(self.numberOfPages * gridBounds.size.width, gridBounds.size.height);
  
  [UIView animateWithDuration:0.4
                   animations:^(void) {
                     [_scrollView setContentSize:contentSizeOfScrollView];
                   } ];
  
  for(NSUInteger i=index; i<_cellList.count; i++) {
    SkyduckGridViewCell *cell = [_cellList objectAtIndex:i];
    cell.index = i;
    
    NSUInteger page = (NSUInteger)((float)i / cellsPerPage);
    NSUInteger row = (NSUInteger)((float)i / numCols) - (page * numRows);
    
    CGPoint origin = {0};
    CGRect contractFrame = {0};
    if(_colPosX.count == numCols && _rowPosY.count == numRows) {
      NSNumber *rowPos = [_rowPosY objectAtIndex:row];
      NSNumber *col= [_colPosX objectAtIndex:(i % numCols)];
      origin = CGPointMake((page * gridBounds.size.width) + ( [col intValue]), [rowPos intValue]);
      contractFrame = CGRectMake((NSUInteger)origin.x, (NSUInteger)origin.y, (NSUInteger)cell.cellInitFrame.size.width, (NSUInteger)cell.cellInitFrame.size.height);
      [UIView beginAnimations:@"Move" context:nil];
      [UIView setAnimationDuration:0.2];
      [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
      cell.frame = contractFrame;
      [UIView commitAnimations];
    } else {
      origin = CGPointMake((page * gridBounds.size.width) + ((i % numCols) * cellBounds.size.width), (row * cellBounds.size.height));
      contractFrame = CGRectMake((NSUInteger)origin.x, (NSUInteger)origin.y, (NSUInteger)cellBounds.size.width, (NSUInteger)cellBounds.size.height);
      [UIView beginAnimations:@"Move" context:nil];
      [UIView setAnimationDuration:0.2];
      [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
      cell.frame = CGRectInset(contractFrame, _cellMargin, _cellMargin);
      [UIView commitAnimations];
    }
  }
}


- (void)updateCurrentPageIndex {
  NSUInteger curPage = round(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
  static NSUInteger prevPage = 0;
  
  if(curPage != prevPage) {
    _currentPageIndex = curPage;
    if (_delegate != nil && [_delegate respondsToSelector:@selector(gridView:changedPageIndex:)]) {
      
      [_delegate gridView:self changedPageIndex:curPage];
    }
  }
  
  prevPage = curPage;
}

- (void)movePage:(NSInteger)newPageIndex animated:(BOOL)animate {
  if(newPageIndex < self.numberOfPages) {
    CGPoint move = CGPointMake(self.scrollView.frame.size.width * newPageIndex, 0);
    
    if(animate) {
      [UIView animateWithDuration:0.3
                            delay:0
                          options:UIViewAnimationOptionCurveEaseInOut
                       animations:^{
                         _scrollView.contentOffset = move;
                       }
                       completion:^(BOOL finished){
                         
                         if (_delegate != nil && [_delegate respondsToSelector:@selector(gridView:endMovePage:)]) {
                           [_delegate gridView:self endMovePage:newPageIndex];
                         }
                         
                       }];
    } else {
      _scrollView.contentOffset = move;
    }
    
    _currentPageIndex = newPageIndex;
  } else {
    NSLog(@"MovePage - OutOfRange !");
  }
  
}


// ----------------------------------------------------------------------------------
#pragma - SkyduckGridView callback


- (void)cellWasDelete:(SkyduckGridViewCell *)cell {
  if (_dataSource != nil && [_dataSource respondsToSelector:@selector(gridView:deleteAtIndex:)]) {
    // 通知 控制层 deleteAtIndex:
    [_dataSource gridView:self deleteAtIndex:cell.index];
    
    //
    [self deleteCell:cell.index];
  }
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  [self updateCurrentPageIndex];
  
  if(_delegateScrollView != nil && [_delegateScrollView respondsToSelector:@selector(gridView:scrollViewDidEndDecelerating:)]) {
    [_delegateScrollView gridView:self scrollViewDidEndDecelerating:scrollView];
  }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
  if(_delegateScrollView != nil && [_delegateScrollView respondsToSelector:@selector(gridView:scrollViewDidEndScrollingAnimation:)]) {
    [_delegateScrollView gridView:self scrollViewDidEndScrollingAnimation:scrollView];
  }
  
  [self updateCurrentPageIndex];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [self updateCurrentPageIndex];
  
  if(_delegateScrollView != nil && [_delegateScrollView respondsToSelector:@selector(gridView:scrollViewDidScroll:)]) {
    [_delegateScrollView gridView:self scrollViewDidScroll:scrollView];
  }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [self updateCurrentPageIndex];
  
  if(_delegateScrollView != nil && [_delegateScrollView respondsToSelector:@selector(gridView:scrollViewWillBeginDragging:)]) {
    [_delegateScrollView gridView:self scrollViewWillBeginDragging:scrollView];
  }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
  [self updateCurrentPageIndex];
  
  if(_delegateScrollView != nil && [_delegateScrollView respondsToSelector:@selector(gridView:scrollViewWillBeginDecelerating:)]) {
    [_delegateScrollView gridView:self scrollViewWillBeginDecelerating:scrollView];
  }
}



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
  if (_delegate != nil && [_delegate respondsToSelector:@selector(gridView:didSelectCell:atIndex:)]) {
    [_delegate gridView:self didSelectCell:cell atIndex:index];
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
      
      // 页面移动(PageMove)
      NSInteger maxScrollwidth = _scrollView.contentOffset.x + _scrollView.bounds.size.width;
      NSInteger minScrollwidth = _scrollView.contentOffset.x;
      
      if (maxScrollwidth - _cellOfMoving.center.x < kPageMoveMargin) {
        // 向右滑动
        if(_timerOfMovePage == nil) {
          _timerOfMovePage = [RNTimer repeatingTimerWithTimeInterval:0.7 block:^{
            NSInteger maxScrollwidth = _scrollView.contentOffset.x + _scrollView.bounds.size.width;
            
            if(maxScrollwidth - _cellOfMoving.center.x < kPageMoveMargin) {
              
              if(self.numberOfPages - 1 > _currentPageIndex) {
                //
                [self movePage:_currentPageIndex + 1 animated:YES];
                //
                [_cellOfMoving moveByOffset:CGPointMake(_scrollView.frame.size.width, 0)];
                //
                _touchLocation = CGPointMake(_touchLocation.x + _scrollView.frame.size.width, _touchLocation.y);
                
                if(self.numberOfPages - 1 == _currentPageIndex) {
                  // 已经滑到了最后一页
                  SkyduckGridViewCell *targetCell = [_cellList lastObject];
                  [self targetIndexForMoveFromPointAtIndex:_cellOfMoving.index toProposedIndex:targetCell.index];
                }
              }
            }
            
            _timerOfMovePage = nil;
          }];
        }
        
      } else if (_cellOfMoving.center.x - minScrollwidth < kPageMoveMargin) {
        // 向左滑动
        if(_timerOfMovePage == nil) {
          
          _timerOfMovePage = [RNTimer repeatingTimerWithTimeInterval:0.7 block:^{
            NSInteger minScrollwidth = _scrollView.contentOffset.x;
            if(_cellOfMoving.center.x - minScrollwidth < kPageMoveMargin) {
              if(_currentPageIndex > 0) {
                //
                [self movePage:_currentPageIndex - 1 animated:YES];
                //
                [_cellOfMoving moveByOffset:CGPointMake(_scrollView.frame.size.width * -1, 0)];
                //
                _touchLocation = CGPointMake(_touchLocation.x - _scrollView.frame.size.width, _touchLocation.y);
              }
            }
            
            _timerOfMovePage = nil;
          }];
        }
        
      } else {
        [_timerOfMovePage invalidate], _timerOfMovePage = nil;
      }
      
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
