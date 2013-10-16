//
//  DreamBook
//
//  Created by 唐志华 on 13-9-26.
//
//

#import "PRPNibBasedTableViewCell.h"
#import "MacroConstantForThisProject.h"

@class BookStoreTableCell_ipad;
// cell 中的功能按钮被按下时, 触发的处理块
typedef void (^BookStoreTableCellFunctionButtonClickHandleBlock)(BookStoreTableCell_ipad* tableCell, NSString *contentIDString);

@class LocalBook;
@interface BookStoreTableCell_ipad : PRPNibBasedTableViewCell

// 点击 "功能按钮" 后的处理块, 这个由 "控制层" 实现, 这里块中提供业务逻辑, View中不包含任何业务逻辑.
@property (nonatomic, copy) BookStoreTableCellFunctionButtonClickHandleBlock bookStoreTableCellFunctionButtonClickHandleBlock;
// 当前Cell 对应的书籍 contentID, Cell View中 不直接包含模型 LocalBook, 防止深层次的引用环, 只需要包含一个 contentID, 控制层就可以找到对应的 LocalBook 模型了.
@property (nonatomic, copy, readonly) NSString *contentID;

// "数据绑定 (data binding)"
// 数据绑定最好的办法是将你的数据模型对象传递到自定义的表视图单元并让其绑定数据.
-(void) bind:(LocalBook *)bookInfoToBeDisplayed;

@end
