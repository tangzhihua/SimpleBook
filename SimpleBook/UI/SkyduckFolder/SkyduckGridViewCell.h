//
//  DreamBook
//
//  Created by 唐志华 on 13-11-08.
//
//

#import <UIKit/UIKit.h>

@class SkyduckGridView;
@class SkyduckGridViewCell;
@class SkyduckFile;

#pragma mark -
#pragma mark - SkyduckGridViewCellDelegate
@protocol SkyduckGridViewCellDelegate <NSObject>
//
- (void)gridViewCell:(SkyduckGridViewCell *)cell touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)gridViewCell:(SkyduckGridViewCell *)cell touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)gridViewCell:(SkyduckGridViewCell *)cell touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)gridViewCell:(SkyduckGridViewCell *)cell touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
//
- (void)gridViewCell:(SkyduckGridViewCell *)cell didDelete:(NSUInteger)index;
- (void)gridViewCell:(SkyduckGridViewCell *)cell handleLongPress:(NSUInteger)index;
@end

@interface SkyduckGridViewCell : UIView

//
@property (nonatomic, weak) IBOutlet id<SkyduckGridViewCellDelegate> delegate;

//
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, assign) CGRect cellInitFrame;


// 将单元格移动到新的位置
- (void)moveByOffset:(CGPoint)offset;

@property (nonatomic, strong, readonly) SkyduckFile *file;
// "数据绑定 (data binding)"
// 数据绑定最好的办法是将你的数据模型对象传递到自定义的表视图单元并让其绑定数据.
- (void)bind:(SkyduckFile *)file;

#pragma mark -
#pragma mark - 通过 xib 创建 cell view
+ (UINib *)nib;
+ (id)cellFromNib:(UINib *)nib;
@end
