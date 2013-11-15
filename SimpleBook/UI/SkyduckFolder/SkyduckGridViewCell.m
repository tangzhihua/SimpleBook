//
//  DreamBook
//
//  Created by 唐志华 on 13-11-08.
//
//

#import "SkyduckGridViewCell.h"
#import "SkyduckGridView.h"

@interface SkyduckGridViewCell ()
@property (nonatomic, strong, readwrite) SkyduckFile *file;
@end

@implementation SkyduckGridViewCell

- (void)initCell {
  _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [_deleteButton addTarget:self action:@selector(deleteButtonOnClickListener:) forControlEvents:UIControlEventTouchUpInside];
  [_deleteButton setImage:[UIImage imageNamed:@"icon_del.png"] forState:UIControlStateNormal];
  [_deleteButton setImage:[UIImage imageNamed:@"icon_del_h.png"] forState:UIControlStateHighlighted];
  [_deleteButton setHidden:YES];
  [self addSubview:_deleteButton];
  
  /* ------------>   UIView 的exclusiveTouch属性
   exclusiveTouch的意思是UIView会独占整个Touch事件，
   具体的来说，就是当设置了exclusiveTouch的 UIView是事件的第一响应者，
   那么到你的所有手指离开前，其他的视图UIview是不会响应任何触摸事件的，
   对于多点触摸事件，这个属性就非常重要，值得注意的是：手势识别（GestureRecognizers）会忽略此属性。
   列举用途：我们知道ios是没有GridView视图的，通常做法是在UITableView的cell上加载几个子视图，
   来模拟实现 GridView视图，但对于每一个子视图来说，就需要使用exclusiveTouch，
   否则当同时点击多个子视图，那么会触发每个子视图的事件。当然 还有我们常说的模态对话框。*/
  self.exclusiveTouch = YES;
  
  // 长按事件
  UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
  longPressGestureRecognizer.minimumPressDuration = 1.0;
  [self addGestureRecognizer:longPressGestureRecognizer];
  
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    
    [self initCell];
  }
  
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  //
  CGSize imgsize = [UIImage imageNamed:@"icon_del.png"].size;
  CGRect cellBound = self.bounds;
  [_deleteButton setFrame:CGRectMake(cellBound.size.width - imgsize.width * 2, 20, imgsize.width, imgsize.height)];
}



#pragma mark -
#pragma mark - Touch Event Handling
/*
 // Generally, all responders which do custom touch handling should override all four of these methods.
 // 通常情况, 所有的 响应者 应该覆写这里全部的4个方法.
 // Your responder will receive either touchesEnded:withEvent: or touchesCancelled:withEvent: for each touch it is handling (those touches it received in touchesBegan:withEvent:).
 // 你的 响应者 会接收到在touchesBegan:withEvent:中 接收到事件的 touchesEnded:withEvent: 或者 touchesCancelled:withEvent:
 //
 // *** You must handle cancelled touches to ensure correct behavior in your application.  Failure to do so is very likely to lead to incorrect behavior or crashes.
 // 你必须在你的app中处理已经取消的 触摸事件, 好确保正确的行为. 如果不这么做的话, 和可能导致不正确的行为或崩溃.
 //
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  
  if(self.delegate != nil && [self.delegate respondsToSelector:@selector(gridViewCell:touchesMoved:withEvent:)]) {
    [self.delegate gridViewCell:self touchesBegan:touches withEvent:event];
  }
  
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  
  if(self.delegate != nil && [self.delegate respondsToSelector:@selector(gridViewCell:touchesMoved:withEvent:)]) {
    [self.delegate gridViewCell:self touchesMoved:touches withEvent:event];
  }
  
  [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  
  if(self.delegate != nil && [self.delegate respondsToSelector:@selector(gridViewCell:touchesEnded:withEvent:)]) {
    [self.delegate gridViewCell:self touchesEnded:touches withEvent:event];
  }
  
  [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesCancelled:touches withEvent:event];
  
  if(self.delegate != nil && [self.delegate respondsToSelector:@selector(gridViewCell:touchesCancelled:withEvent:)]) {
    [self.delegate gridViewCell:self touchesCancelled:touches withEvent:event];
  }
}

//
- (IBAction)deleteButtonOnClickListener:(UIButton *)sender {
  NSLog(@"Delete Button %d",self.index);
  
  if(self.delegate != nil && [self.delegate respondsToSelector:@selector(gridViewCell:didDelete:)]) {
    [self.delegate gridViewCell:self didDelete:self.index];
  }
}

// 长按事件处理方法
- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer  {
  
  if(self.delegate != nil && [self.delegate respondsToSelector:@selector(gridViewCell:handleLongPress:)]) {
    [self.delegate gridViewCell:self handleLongPress:self.index];
  }
}

// 将单元格移动到新的位置
- (void)moveByOffset:(CGPoint)offset {
	CGRect frame = [self frame];
	frame.origin.x += offset.x;
	frame.origin.y += offset.y;
	[self setFrame:frame];
}

- (void)setEditable:(BOOL)editable {
  _editable = editable;
  [self.deleteButton setHidden:!editable];
}

- (void)bind:(SkyduckFile *)file {
  self.file = file;
}

#pragma mark -
#pragma mark Cell generation

+ (NSString *)cellIdentifier {
  return NSStringFromClass([self class]);
}

+ (id)cellFromNib:(UINib *)nib {
	RNAssert([nib isKindOfClass:[UINib class]], @"入参 nib 类型不为 UINib");
	
	NSArray *nibObjects = [nib instantiateWithOwner:nil options:nil];
	
	NSAssert2(([nibObjects count] > 0) &&
						[[nibObjects objectAtIndex:0] isKindOfClass:[self class]],
						@"Nib '%@' does not appear to contain a valid %@",
						[self nibName], NSStringFromClass([self class]));
	
	id cell = [nibObjects objectAtIndex:0];
  [cell initCell];
  return cell;
}

#pragma mark -
#pragma mark Nib support

+ (UINib *)nib {
  NSBundle *classBundle = [NSBundle bundleForClass:[self class]];
  UINib *nibObject =  [UINib nibWithNibName:[self nibName] bundle:classBundle];
  RNAssert(nibObject != nil, @"创建 nibObject 失败! 错误的nibName=%@", [self nibName]);
  return nibObject;
}

+ (NSString *)nibName {
  return [self cellIdentifier];
}

+(CGRect)viewFrameRectFromNib {
  NSArray *nibObjects = [[self nib] instantiateWithOwner:nil options:nil];
  UIView *view = [nibObjects objectAtIndex:0];
  return [view frame];
}
@end
