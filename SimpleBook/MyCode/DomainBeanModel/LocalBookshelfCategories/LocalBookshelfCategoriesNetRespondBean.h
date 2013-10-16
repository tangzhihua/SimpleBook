//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"


@interface LocalBookshelfCategoriesNetRespondBean : BaseModel
 
@property (nonatomic, readonly, strong) NSArray *categories;

// 根据 "分类ID" 获取该分类对应的 "分类name"
-(NSString *)categoryNameByCategoryID:(const NSInteger)categoryID;
@end
