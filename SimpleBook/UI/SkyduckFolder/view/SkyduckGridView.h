//
//  DreamBook
//
//  Created by 唐志华 on 13-11-08.
//
//

#import <UIKit/UIKit.h>
#import "SkyduckGridViewCell.h"

@class SkyduckGridView;

#pragma mark -
#pragma mark - SkyduckGridViewDataSource
@protocol SkyduckGridViewDataSource <NSObject>
@required
// 在网格控件中cell总数量
- (NSInteger)numberOfCellsInGridView:(SkyduckGridView *)gridview;
//
- (SkyduckGridViewCell *)gridView:(SkyduckGridView *)gridview cellAtIndex:(NSInteger)index;
// 一行显示最多多少个cell
- (NSInteger)numberOfCellsInRowOfGridView:(SkyduckGridView *)gridview;
// cell size
- (CGSize)sizeOfCellInGridView:(SkyduckGridView *)gridview;
// cell 之间上下空白处高度
- (CGFloat)marginOfVerticalCellInGridView:(SkyduckGridView *)gridview;
@end

#pragma mark -
#pragma mark - SkyduckGridViewDelegate
@protocol SkyduckGridViewDelegate <NSObject>

@optional
// 单击一个 file cell
- (void)gridView:(SkyduckGridView *)gridView didSelectFileCellAtIndex:(NSInteger)index;
// 单击一个 directory cell
- (void)gridView:(SkyduckGridView *)gridView didSelectDirectoryCellAtIndex:(NSInteger)index;

// 合并两个cell
- (void)gridView:(SkyduckGridView *)gridview targetIndexForMergeFromCellAtIndex:(NSInteger)sourceIndex toProposedIndex:(NSInteger)proposedDestinationIndex;
// 移动两个cell
- (void)gridView:(SkyduckGridView *)gridview targetIndexForMoveFromCellAtIndex:(NSInteger)sourceIndex toProposedIndex:(NSInteger)proposedDestinationIndex;
// 删除一个cell
- (void)gridView:(SkyduckGridView *)gridview deleteCellAtIndex:(NSInteger)index;

@end



#pragma mark - SkyduckGridView
@interface SkyduckGridView : UIView 

//
@property (nonatomic, weak) IBOutlet id<SkyduckGridViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<SkyduckGridViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;
- (void)reloadData;

@end
