//
//  DreamBook
//
//  Created by 唐志华 on 13-9-26.
//
//

#import "PRPNibBasedTableViewCell.h"
#import "MacroConstantForThisProject.h"

// Action Enum
typedef NS_ENUM(NSInteger, BookShelfTableCellActionEnum) {
  
  // 阅读
  kBookShelfTableCellActionEnum_Read = 0,
  // 删除
  kBookShelfTableCellActionEnum_Delete
};

@class BookShelfTableCell_ipad;
// cell 中的功能按钮被按下时, 触发的处理块
typedef void (^BookShelfTableCellFunctionButtonClickHandleBlock)(BookShelfTableCell_ipad* tableCell, BookShelfTableCellActionEnum actionEnum, NSString *contentIDString);

@class LocalBook;
@interface BookShelfTableCell_ipad : PRPNibBasedTableViewCell


// 点击 "功能按钮" 后的处理块, 这个由 "控制层" 实现, 这里块中提供业务逻辑, View中不包含任何业务逻辑.
@property (nonatomic, copy) BookShelfTableCellFunctionButtonClickHandleBlock bookShelfTableCellFunctionButtonClickHandleBlock;


// "数据绑定 (data binding)"
// 数据绑定最好的办法是将你的数据模型对象传递到自定义的表视图单元并让其绑定数据.
-(void) bindWithFirstDataBean:(LocalBook *)firstDataBean secondDataBean:(LocalBook *)secondDataBean;

// 隐藏/显示 "删除按钮"
-(void) hideDeleteButton:(BOOL)hidden;
@end
