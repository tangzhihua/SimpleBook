//
//  DreamBook
//
//  Created by 唐志华 on 13-11-08.
//
//

#import <UIKit/UIKit.h>

@class SkyduckGridView;
@class SkyduckGridViewCell;

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

// 单元格类型
typedef NS_ENUM(NSUInteger, SkyduckFolderCellTypeEnum) {
  // 文件
  kSkyduckFolderCellTypeEnum_File = 0,
  // 文件夹
  kSkyduckFolderCellTypeEnum_Folder
};

@interface SkyduckGridViewCell : UIView

//
@property (nonatomic, weak) IBOutlet id<SkyduckGridViewCellDelegate> delegate;

//
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, assign) CGRect cellInitFrame;

// 单元格类型(分为 文件夹/文件 两种)
@property (nonatomic, assign) SkyduckFolderCellTypeEnum type;

// 将单元格移动到新的位置
- (void)moveByOffset:(CGPoint)offset;

@end
