//
//  LocalBookshelfCategory.h
//  MBEnterprise
//
//  Created by 唐志华 on 13-9-22.
//
//

#import "BaseModel.h"

@interface BookCategory : BaseModel
// 分类ID
@property (nonatomic, readonly, copy) NSString *identifier;
// 分类名称
@property (nonatomic, readonly, strong) NSString *name;
// 当前分类下面, 书籍总数(如果书籍总数为 0, 那么在书城界面, 就不要显示这个分类)
@property (nonatomic, readonly, assign) NSInteger bookcount;
@end
