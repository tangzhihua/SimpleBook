//
//  LocalBookshelfCategory.h
//  MBEnterprise
//
//  Created by 唐志华 on 13-9-22.
//
//

#import "BaseModel.h"

@interface LocalBookshelfCategory : BaseModel
// 分类ID
@property (nonatomic, readonly, assign) NSInteger ID;
// 分类名称
@property (nonatomic, readonly, strong) NSString *name;
@end
