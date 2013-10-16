//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "StrategyClassNameMappingBase.h"

@protocol IDomainBeanAbstractFactory;
@interface DomainBeanAbstractFactoryCacheSingleton : NSObject {
  
}

+ (DomainBeanAbstractFactoryCacheSingleton *) sharedInstance;

/**
 * 将目标网络请求业务Bean, 组成Map<String, String>格式的参数列表
 *
 * @param netRequestDomainBean
 *          网络请求业务Bean
 * @return
 */
- (id<IDomainBeanAbstractFactory>) getDomainBeanAbstractFactoryObjectByKey : (NSString *) key;
@end
