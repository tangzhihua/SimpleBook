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
- (void)gridViewCell:(SkyduckGridViewCell *)cell touchesBegan:(UITouch *)touch;
- (void)gridViewCell:(SkyduckGridViewCell *)cell touchesMoved:(UITouch *)touch;
- (void)gridViewCell:(SkyduckGridViewCell *)cell touchesEnded:(UITouch *)touch;
- (void)gridViewCell:(SkyduckGridViewCell *)cell touchesCancelled:(UITouch *)touch;
// 单击
- (void)gridViewCell:(SkyduckGridViewCell *)cell handleSingleTap:(NSUInteger)index;

@end


#pragma mark -
#pragma mark - SkyduckGridViewCell
@interface SkyduckGridViewCell : UIView

//
@property (nonatomic, weak) IBOutlet id<SkyduckGridViewCellDelegate> delegate;

//
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) CGRect cellInitFrame;


// 将单元格移动到新的位置
- (void)moveByOffset:(CGPoint)offset;

// 只能使用 bind方法 更换 file 属性.
@property (nonatomic, strong, readonly) SkyduckFile *file;
// "数据绑定 (data binding)"
// 数据绑定最好的办法是将你的数据模型对象传递到自定义的表视图单元并让其绑定数据.
- (void)bind:(SkyduckFile *)file;

#pragma mark -
#pragma mark - 通过 xib 创建 cell view
+ (UINib *)nib;
+ (id)cellFromNib:(UINib *)nib;
+ (CGRect)viewFrameRectFromNib;
@end
