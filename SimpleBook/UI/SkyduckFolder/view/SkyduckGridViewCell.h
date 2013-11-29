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
#pragma mark - SkyduckGridViewMargeCellAnimationDelegate
@protocol SkyduckGridViewMargeCellAnimationDelegate <NSObject>
@required
- (void)beginMargeCellAnimation;
- (void)endMargeCellAnimation;
@end

#pragma mark -
#pragma mark - SkyduckGridViewCellDelegate
@protocol SkyduckGridViewCellDelegate <NSObject>
//
- (void)gridViewCell:(SkyduckGridViewCell *)cell touchesBegan:(UITouch *)touch;
- (void)gridViewCell:(SkyduckGridViewCell *)cell touchesMoved:(UITouch *)touch;
- (void)gridViewCell:(SkyduckGridViewCell *)cell touchesEnded:(UITouch *)touch;
- (void)gridViewCell:(SkyduckGridViewCell *)cell touchesCancelled:(UITouch *)touch;

// 单击 "文件"
- (void)gridViewCell:(SkyduckGridViewCell *)cell handleSingleTapFile:(NSInteger)index;
// 单击 "文件夹"
- (void)gridViewCell:(SkyduckGridViewCell *)cell handleSingleTapDirectory:(NSInteger)index;
@end


#pragma mark -
#pragma mark - SkyduckGridViewCell
@interface SkyduckGridViewCell : UIView <SkyduckGridViewMargeCellAnimationDelegate>

//
@property (nonatomic, weak) IBOutlet id<SkyduckGridViewCellDelegate> delegate;

// 用于合并cell时使用的背景图片视图
@property (nonatomic, strong) UIImageView *backgroundImageViewForMargeCell;
//
@property (nonatomic, assign) NSInteger index;

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
