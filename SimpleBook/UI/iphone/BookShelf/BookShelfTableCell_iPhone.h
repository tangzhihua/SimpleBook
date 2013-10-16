//
//  BookShelfTableCell_iPhone.h
//  MBEnterprise
//
//  Created by Yingjie Huo on 13-10-11.
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

@class BookShelfTableCell_iPhone;
// cell 中的功能按钮被按下时, 触发的处理块
typedef void (^BookShelfTableCellFunctionButtonClickHandleBlock)(BookShelfTableCell_iPhone* tableCell, BookShelfTableCellActionEnum actionEnum, NSString *contentIDString);

@class LocalBook;

@interface BookShelfTableCell_iPhone : PRPNibBasedTableViewCell


// 点击 "功能按钮" 后的处理块, 这个由 "控制层" 实现, 这里块中提供业务逻辑, View中不包含任何业务逻辑.
@property (nonatomic, copy) BookShelfTableCellFunctionButtonClickHandleBlock bookShelfTableCellFunctionButtonClickHandleBlock;
@property (nonatomic, readonly, copy) NSString *bookContentID;

// "数据绑定 (data binding)"
// 数据绑定最好的办法是将你的数据模型对象传递到自定义的表视图单元并让其绑定数据.
-(void) bindWithDataBean:(LocalBook *)dataBean;
// 阅读
- (void)readButtonOnClickListener;
// 删除
- (void)deleteButtonOnClickListener;

@end
