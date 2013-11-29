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

//
@property (nonatomic, strong) UIScrollView *scrollView;
// 删除按钮
@property (nonatomic, strong) UIButton *deleteButton;

// 单元格列表
@property (nonatomic, strong) NSMutableArray *cellList;
// 触点坐标
@property (nonatomic, assign) CGPoint beginTouchLocation;// 本次触摸行为 源点
@property (nonatomic, assign) CGPoint currentlyTouchLocation;// 本次触摸行为 最新触点
//
@property (nonatomic, strong) SkyduckGridViewCell *dragCell;// 处于拖动状态的cell
@property (nonatomic, strong) SkyduckGridViewCell *mergeCell;// 处于合并状态的cell


// 长按 cell 会进入 编辑状态(处于编辑状态时, 可以吸附移动cell)
@property (nonatomic, assign) BOOL editable;

// 倒计时 Timer
@property (nonatomic, strong) RNTimer *timer;
@end

@implementation SkyduckGridView {
  // Scroll While Drag
  CADisplayLink *_displayLink;
  double _lastDragScrollTime;
}

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
  //const NSInteger numberOfCells = [_dataSource numberOfCellsInGridView:self];
  // 一行显示的cell的最大数量
  const NSInteger numberOfCellsInRow = [_dataSource numberOfCellsInRowOfGridView:self];
  // 总行数
  //const NSInteger numberOfRows = ceilf((float)numberOfCells / (float)numberOfCellsInRow);// ceilf 向上取整
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
    _dragCell.transform = CGAffineTransformMakeScale(1.2, 1.2);
  }];
  
  //
  [UIView animateWithDuration:0.1 animations:^{
    _mergeCell.transform = CGAffineTransformIdentity;
    _mergeCell = nil;
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
  if (_mergeCell == proposedDestinationCell) {
    return NO;
  }
  NSLog(@"合并两个cell :  sourceIndex=%d, proposedDestinationIndex=%d", sourceIndex, proposedDestinationIndex);
  
  _mergeCell.transform = CGAffineTransformIdentity;
  _mergeCell = proposedDestinationCell;
  //
  [UIView animateWithDuration:0.1 animations:^{
    sourceCell.transform = CGAffineTransformMakeScale(1.0, 1.0);
    sourceCell.alpha = 0.5;
  }];
  
  //
  [UIView animateWithDuration:0.1 animations:^{
    proposedDestinationCell.transform = CGAffineTransformMakeScale(1.2, 1.2);
  }];
  
  return YES;
}

- (void)resetDragingCellPosition {
  // cell 总数
  //const NSInteger numberOfCells = [_dataSource numberOfCellsInGridView:self];
  // 一行显示的cell的最大数量
  const NSInteger numberOfCellsInRow = [_dataSource numberOfCellsInRowOfGridView:self];
  // 总行数
  //const NSInteger numberOfRows = ceilf((float)numberOfCells / (float)numberOfCellsInRow);// ceilf 向上取整
  // cell size
  const CGSize sizeOfCell = [_dataSource sizeOfCellInGridView:self];
  // cell 垂直方向的空白间距
  const CGFloat marginOfVerticalCell = [_dataSource marginOfVerticalCellInGridView:self];
  // 网格控件边界
  const CGRect gridBounds = _scrollView.bounds;
  // 单元格边界(这不是cell的真实边界, 而是用于计算每个cell 坐标)
  const CGRect cellBounds = CGRectMake(0, 0, gridBounds.size.width / (CGFloat) numberOfCellsInRow, sizeOfCell.height + marginOfVerticalCell);
  
  // 定位 cell
  const CGPoint origin = CGPointMake(((_dragCell.index % numberOfCellsInRow) * cellBounds.size.width), (_dragCell.index / numberOfCellsInRow * cellBounds.size.height));
  CGPoint center = CGPointMake((NSInteger)(origin.x + cellBounds.size.width / 2), (NSInteger)(origin.y + cellBounds.size.height/2));
  
  [UIView animateWithDuration:0.1
                   animations:^{
                     
                     _dragCell.frame = CGRectMake((NSInteger)(center.x - _dragCell.frame.size.width/2), (NSInteger)(center.y - _dragCell.frame.size.height/2), (NSInteger)_dragCell.frame.size.width, (NSInteger)_dragCell.frame.size.height);
                     
                     //
                     _dragCell.transform = CGAffineTransformIdentity;
                     _dragCell.alpha = 1.0;
                     _dragCell = nil;
                     
                     //
                     _mergeCell.transform = CGAffineTransformIdentity;
                     _dragCell.alpha = 1.0;
                     _mergeCell = nil;
                   } completion:^(BOOL finished) {
                     
                   }];
  
}

- (void)moveCellsIfNecessary {
  
  // 移动方向, 是用来判断 cell 之间移动/合并 细节的
  MoveDirectionEnum moveDirectionEnum = [self moveDirectionFrom:_beginTouchLocation to:_currentlyTouchLocation];
  
  for(int i=0; i<_cellList.count; i++) {
    SkyduckGridViewCell *tempCell = _cellList[i];
    
    if(![_dragCell isEqual:tempCell]) {
      
      // 计算两个矩形的中心点距离(这是判断两个矩形是否相交的最简单方法)
      CGFloat xDist = (tempCell.center.x - _dragCell.center.x);
      CGFloat yDist = (tempCell.center.y - _dragCell.center.y);
      CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
      
      // 如果没有激活 合并功能, 就只做两个cell的碰撞移动操作.
      if (!_mergeEnabled || _dragCell.file.isDirectory) {
        
        if(distance < kCellCollisionMoveMinDistance) {
          // 要进行移动
          if ([self targetIndexForMoveFromPointAtIndex:_dragCell.index toProposedIndex:tempCell.index]) {
            break;
          }
        }
        
      } else if (_dragCell.file.isFile) {
        
        if(distance < kCellCollisionMergeMinDistance) {// 进入了可以合并的范围
          // 要进行合并
          if ([self targetIndexForMergeFromPointAtIndex:_dragCell.index toProposedIndex:tempCell.index]) {
            break;
          }
          
        } else if (distance < kCellCollisionMoveMinDistance && distance > kCellCollisionMergeMinDistance + 10) {// 进入了可以移动的范围
          
          if (kMoveDirectionEnum_Left == moveDirectionEnum) {
            // 向左移动
            if (_dragCell.center.x < tempCell.center.x) {
              // 要进行移动
              if ([self targetIndexForMoveFromPointAtIndex:_dragCell.index toProposedIndex:tempCell.index]) {
                break;
              }
            }
          } else if (kMoveDirectionEnum_Right == moveDirectionEnum) {
            // 向右移动
            if (_dragCell.center.x > tempCell.center.x) {
              // 要进行移动
              if ([self targetIndexForMoveFromPointAtIndex:_dragCell.index toProposedIndex:tempCell.index]) {
                break;
              }
            }
          }
        } else {// 此时都是可以取消, 合并状态的范围
          if (_mergeCell != nil) {
            if (distance > kCellCollisionMergeMinDistance && distance < kCellCollisionMoveMinDistance) {
              //
              [UIView animateWithDuration:0.1 animations:^{
                _dragCell.transform = CGAffineTransformMakeScale(1.2, 1.2);
                _dragCell.alpha = 1.0;
              }];
              
              //
              [UIView animateWithDuration:0.1 animations:^{
                _mergeCell.transform = CGAffineTransformIdentity;
                _mergeCell = nil;
              }];
              
              break;
            }
          }
        }
      }
    }
  }
}

- (void)deleteCellIfNecessary {
  // 计算两个矩形的中心点距离(这是判断两个矩形是否相交的最简单方法)
  CGFloat xDist = (_deleteButton.center.x - _dragCell.center.x);
  CGFloat yDist = (_deleteButton.center.y - _dragCell.center.y);
  CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
  
  if(distance < kCellCollisionMergeMinDistance) {
    // 引发删除状态
    if (!_deleteButton.isSelected) {
      [_deleteButton setSelected:YES];
      
      [UIView animateWithDuration:0.1 animations:^{
        _dragCell.alpha = 0.8;
        _dragCell.transform = CGAffineTransformIdentity;
      }];
    }
    
  } else {
    // 取消删除状态
    
    [_deleteButton setSelected:NO];
    //_dragCell.alpha = 1.0;
    //_dragCell.transform = CGAffineTransformMakeScale(1.2, 1.2);
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
  _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 30)];
  _scrollView.delegate = self;
  _scrollView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
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
  _dragCell = nil;
  _mergeCell = nil;
  _editable = NO;
  
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
  
  // 增加删除按钮
  self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
  _deleteButton.hidden = YES;
  [_deleteButton setFrame:CGRectMake(20, _scrollView.bounds.size.height + 91, 70, 91)];
  [_deleteButton setImage:[UIImage imageNamed:@"button_trashbox"] forState:UIControlStateNormal];
  [_deleteButton setImage:[UIImage imageNamed:@"button_trashbox_active"] forState:UIControlStateSelected];
  [_deleteButton setImage:[UIImage imageNamed:@"button_trashbox_active"] forState:UIControlStateHighlighted];
  [_scrollView addSubview:_deleteButton];
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

#pragma mark - Scroll While Draging

#define kScroll_trigger_dis 40.0f
#define kScroll_dis_scale 27
#define kScroll_max_speed 20

- (void)stopScrollTimer {
  [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
  [_displayLink invalidate];
  _displayLink = nil;
}

- (void)scrollIfNecessary {
  [self stopScrollTimer];
  
  CGFloat distanceFromTop = _dragCell.center.y - _scrollView.bounds.origin.y;
  if (distanceFromTop < kScroll_trigger_dis || distanceFromTop > _scrollView.bounds.size.height - kScroll_trigger_dis) {
    _lastDragScrollTime = CACurrentMediaTime(); // Note: See http://stackoverflow.com/questions/358207/iphone-how-to-get-current-milliseconds for speed comparation
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(dragScroll:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
  }
}

- (CGFloat)safeHorizontalScrollDistanceWithDistance:(CGFloat)distance isScrollUp:(BOOL)isScrollUp {
  if (isScrollUp) {
    CGFloat maxDis = _scrollView.contentOffset.y;
    return MIN(maxDis, distance);
  }
  else {
    CGFloat maxDis = _scrollView.contentSize.height - (_scrollView.contentOffset.y + _scrollView.bounds.size.height);
    return MIN(maxDis, distance);
  }
}

- (void)dragScroll:(NSTimer *)timer {
  BOOL isScrollUp;
  CGFloat distanceFromTop = _dragCell.center.y - _scrollView.bounds.origin.y;
  double timeSinceLastScroll = CACurrentMediaTime() - _lastDragScrollTime; // Around 0.015
  CGFloat scrollDistance = 0;
  double rate; // Between 0 to 40
  
  if (distanceFromTop < kScroll_trigger_dis) {
    isScrollUp = YES;
    rate = (kScroll_trigger_dis - distanceFromTop);
  }
  else {
    isScrollUp = NO;
    rate = (kScroll_trigger_dis - (_scrollView.bounds.size.height - distanceFromTop));
  }
  
  //
  scrollDistance = rate * timeSinceLastScroll * kScroll_dis_scale; // Between 0 to around 20
  scrollDistance = [self safeHorizontalScrollDistanceWithDistance:scrollDistance isScrollUp:isScrollUp];
  if (scrollDistance >= 1) {
    // Actually it won't scroll when the distance is below 1
    // Also the contentOffset is always interger
    // so there's no difference betteen scroll 1.0 and 1.4/1.9 ??
    // we round the float to integer to get the best fit value <<- is this necessary ?
    scrollDistance = roundf(scrollDistance);
    scrollDistance = MIN(scrollDistance, kScroll_max_speed);
    
    CGPoint newOffset = _scrollView.contentOffset;
    newOffset.y = newOffset.y + (isScrollUp ? -scrollDistance : scrollDistance);
    [_scrollView setContentOffset:newOffset];
    
    CGPoint newDragViewCenter = _dragCell.center;
    newDragViewCenter.y = newDragViewCenter.y + (isScrollUp ? -scrollDistance : scrollDistance);
    _dragCell.center = newDragViewCenter;
    
    // 在滚屏的过程中, 也要移动 cell
    [self moveCellsIfNecessary];
    
    // Refresh time only when it really scrolled
    _lastDragScrollTime = CACurrentMediaTime();
    
    // 更新 删除按钮的坐标
    _deleteButton.frame = CGRectMake(20, _scrollView.contentOffset.y + _scrollView.bounds.size.height - _deleteButton.bounds.size.height, _deleteButton.bounds.size.width, _deleteButton.bounds.size.height);
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
  
  NSLog(@"点中的cell frame = %@", NSStringFromCGRect(cell.frame));
  
  // 记录第一个 "触点" 点中的 cell 的中心点
  _beginTouchLocation = cell.center;
  _currentlyTouchLocation = [touch locationInView:_scrollView];
  
  // 记录新的选中cell, 这个cell就是要发生拖动效果的cell
  _dragCell = cell;
  
}

- (void)gridViewCell:(SkyduckGridViewCell *)cell touchesMoved:(UITouch *)touch {
  // 一旦发生移动时, 就取消了点中cell时的效果
  _dragCell = nil;
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
    
    [_timer invalidate], _timer = nil;
    _timer = [RNTimer repeatingTimerWithTimeInterval:0.5 block:^{
      _scrollView.scrollEnabled = YES;
      
      [_delegate gridView:self didSelectDirectoryCellAtIndex:index];
      
      _timer = nil;
    }];
  }
  
//  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
//  view.backgroundColor = [UIColor blackColor];
//  view.userInteractionEnabled = NO;
//  [UIView animateWithDuration:0.5 animations:^{
//    view.frame = self.bounds;
//    view.alpha = 0.8;
//  } completion:^(BOOL finished) {
//  
//  }];
//  [self addSubview:view];
}

// called when a gesture recognizer attempts to transition out of UIGestureRecognizerStatePossible.
// returning NO causes it to transition to UIGestureRecognizerStateFailed
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
  // 长按手势 代理 (如果没有点中一个有效的 cell 时, 是不需要检测 长按手势的)
  return _dragCell != nil;
}

// 长按
- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
  
  switch (recognizer.state) {
    case UIGestureRecognizerStateBegan:{// 手势开始
      _editable = YES;
      //
      _scrollView.scrollEnabled = NO;
      // Bring Subview to Front
      [_scrollView bringSubviewToFront:_dragCell];
      [_scrollView bringSubviewToFront:_deleteButton];
      //
      _deleteButton.hidden = NO;
      _deleteButton.frame = CGRectMake(20, _scrollView.contentOffset.y + _scrollView.bounds.size.height + _deleteButton.bounds.size.height, _deleteButton.bounds.size.width, _deleteButton.bounds.size.height);
      //
      CGPoint touchPoint = [recognizer locationInView:_scrollView];
      [UIView animateWithDuration:0.1 animations:^{
        _dragCell.center = touchPoint;
        _dragCell.transform = CGAffineTransformMakeScale(1.2, 1.2);
        _deleteButton.frame = CGRectMake(20, _scrollView.contentOffset.y + _scrollView.bounds.size.height - _deleteButton.bounds.size.height, _deleteButton.bounds.size.width, _deleteButton.bounds.size.height);
      }];
      
    }break;
      
    case UIGestureRecognizerStateChanged:{// 手势变化
      // 发生了 touch move 事件, 获取一个最新的坐标点
      CGPoint newTouchLocation = [recognizer locationInView:_scrollView];
      
      // 选择 并且 移动 (Picking & Move) 一个 cell
      _dragCell.center = newTouchLocation;
      
      // 更新最新的触点坐标
      _currentlyTouchLocation = newTouchLocation;
      
      [self moveCellsIfNecessary];
      
      [self scrollIfNecessary];
      
      [self deleteCellIfNecessary];
    }break;
      
    default:{// 手势结束
      [self stopScrollTimer];
      
      // 隐藏删除按钮
      [UIView animateWithDuration:0.1 animations:^{
        _deleteButton.frame = CGRectMake(20, _scrollView.contentOffset.y + _scrollView.bounds.size.height + _deleteButton.bounds.size.height, _deleteButton.bounds.size.width, _deleteButton.bounds.size.height);
      } completion:^(BOOL finished) {
        _deleteButton.hidden = YES;
      }];
      
      _editable = NO;
      
      _scrollView.scrollEnabled = YES;
      
      
      if (_deleteButton.isSelected) {// 优先处理 "删除"
        //
        [_delegate gridView:self deleteCellAtIndex:_dragCell.index];
        
        //
        [_deleteButton setSelected:NO];
      } else if (_mergeCell != nil) {// 其次处理 "合并"
        
        // 如果当前处于合并状态时, 就告知控制器合并目标cell, 并且重新加载数据
        [_delegate gridView:self targetIndexForMergeFromCellAtIndex:_dragCell.index toProposedIndex:_mergeCell.index];
        
        // 重新加载全部数据
        [self reloadData];
        
        //[UIView an
        
      } else {// 没有任何事件发生, 就复位处于拖动中的 cell
        // 复位拖动中的cell的位置坐标
        [self resetDragingCellPosition];
      }
      
    }break;
      
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
