//
//  ExpandFolderContentView.h
//  SimpleBook
//
//  Created by 唐志华 on 13-11-27.
//  Copyright (c) 2013年 唐志华. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SkyduckFile;
@interface ExpandFolderContentView : UIView

// "数据绑定 (data binding)"
// 数据绑定最好的办法是将你的数据模型对象传递到自定义的表视图单元并让其绑定数据.
- (void)bind:(SkyduckFile *)directory;
@end
