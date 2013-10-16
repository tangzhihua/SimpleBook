//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import <Foundation/Foundation.h>

@interface StrategyClassNameMappingBase : NSObject {
@protected
  NSMutableDictionary *strategyClassesNameMappingList;
}

//@property (nonatomic, readonly) NSMutableDictionary *strategyClassesNameMappingList;

- (NSString *) getTargetClassNameForKey:(id) key;
@end
