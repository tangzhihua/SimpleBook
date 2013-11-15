//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "NSObject+DeepCopyingSupport.h"

@implementation NSObject (DeepCopyingSupport)

- (id) deepCopy {
  return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
}
@end
