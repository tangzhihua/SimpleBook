//
//  DreamBook
//
//  Created by 唐志华 on 13-11-08.
//
//

#import <UIKit/UIKit.h>
#import "SkyduckGridViewCell.h"

@class SkyduckGridView;

#pragma mark - SkyduckGridViewDataSource
@protocol SkyduckGridViewDataSource <NSObject>
-(NSInteger) numberOfCellsInGridView:(SkyduckGridView *)gridview;
-(SkyduckGridViewCell *)gridView:(SkyduckGridView *)gridview cellAtIndex:(NSUInteger)index;

@optional                                                                                                   // edit mode
-(void) gridView:(SkyduckGridView *)gridview moveAtIndex:(NSUInteger)fromindex toIndex:(NSUInteger)toIndex;    // Cell Position Reorder
-(void) gridView:(SkyduckGridView *)gridview deleteAtIndex:(NSUInteger)index;
-(void) gridView:(SkyduckGridView *)gridview InsertAtIndex:(NSUInteger)index;
@end

#pragma mark - SkyduckGridViewDelegate
@protocol SkyduckGridViewDelegate <NSObject>
@optional
-(void) gridView:(SkyduckGridView *)gridView didSelectCell:(SkyduckGridViewCell *)cell atIndex:(NSUInteger)index;
//-(void) gridView:(SkyduckGridView *)gridView didDeselectCell:(SkyduckGridViewCell *)cell atIndex:(NSUInteger)index;
//-(void) gridView:(SkyduckGridView *)gridView didEndEditingCell:(SkyduckGridViewCell *)cell atIndex:(NSUInteger)index;
-(void) gridView:(SkyduckGridView *)gridView changedPageIndex:(NSUInteger)index;
-(void) gridView:(SkyduckGridView *)gridView endMovePage:(NSUInteger)index;

-(void) gridView:(SkyduckGridView *)gridView touchUpInside:(SkyduckGridViewCell *)cell;
-(void) gridView:(SkyduckGridView *)gridView touchUpOoutside:(SkyduckGridViewCell *)cell;
-(void) gridView:(SkyduckGridView *)gridView touchCanceled:(SkyduckGridViewCell *)cell;
@end

#pragma mark - SkyduckGridViewScrollViewDelegate
@protocol SkyduckGridViewScrollViewDelegate<NSObject>
@optional
-(void) gridView:(SkyduckGridView *)gridView scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
-(void) gridView:(SkyduckGridView *)gridView scrollViewWillBeginDragging:(UIScrollView *)scrollView;
-(void) gridView:(SkyduckGridView *)gridView scrollViewWillBeginDecelerating:(UIScrollView *)scrollView;
-(void) gridView:(SkyduckGridView *)gridView scrollViewDidScroll:(UIScrollView *)scrollView;
-(void) gridView:(SkyduckGridView *)gridView scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
@end

#pragma mark - SkyduckGridView
@interface SkyduckGridView : UIView 


@property (nonatomic, weak) IBOutlet id<SkyduckGridViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<SkyduckGridViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet id<SkyduckGridViewScrollViewDelegate> delegateScrollView;

// 总页数
@property (nonatomic, readonly) NSUInteger numberOfPages;
@property (nonatomic, assign) BOOL editable;

- (void) reloadData;
- (id) initWithFrame:(CGRect)frame numOfRow:(NSUInteger)rows numOfColumns:(NSUInteger)columns cellMargin:(NSUInteger)cellMargins;
@end
