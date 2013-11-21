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
- (NSUInteger)numberOfCellsInGridView:(SkyduckGridView *)gridview;
//
- (SkyduckGridViewCell *)gridView:(SkyduckGridView *)gridview cellAtIndex:(NSUInteger)index;
// 一行显示最多多少个cell
- (NSUInteger)numberOfCellsInRowOfGridView:(SkyduckGridView *)gridview;
// cell size
- (CGSize)sizeOfCellInGridView:(SkyduckGridView *)gridview;
// cell 之间上下空白处高度
- (CGFloat)marginOfVerticalCellInGridView:(SkyduckGridView *)gridview;
@end

#pragma mark -
#pragma mark - SkyduckGridViewDelegate
@protocol SkyduckGridViewDelegate <NSObject>

@optional
// 单击一个cell
- (void)gridView:(SkyduckGridView *)gridView didSelectCellAtIndex:(NSUInteger)index;
// 合并两个cell
- (void)gridView:(SkyduckGridView *)gridview targetIndexForMergeFromCellAtIndex:(NSUInteger)sourceIndex toProposedIndex:(NSUInteger)proposedDestinationIndex;
// 移动两个cell
- (void)gridView:(SkyduckGridView *)gridview targetIndexForMoveFromCellAtIndex:(NSUInteger)sourceIndex toProposedIndex:(NSUInteger)proposedDestinationIndex;
// 删除一个cell
- (void)gridView:(SkyduckGridView *)gridview deleteCellAtIndex:(NSUInteger)index;

@end



#pragma mark - SkyduckGridView
@interface SkyduckGridView : UIView 

//
@property (nonatomic, weak) IBOutlet id<SkyduckGridViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<SkyduckGridViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;
- (void)reloadData;

@end
