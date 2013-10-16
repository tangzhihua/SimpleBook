//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import <Foundation/Foundation.h>
@protocol IParseDomainBeanToDataDictionary;
@protocol IParseNetRespondDictionaryToDomainBean;

/**
 * 业务Bean相关的工具方法
 *
 * 这里罗列的接口是每个业务Bean都需要实现的.
 * @author zhihua.tang
 *
 */
@protocol IDomainBeanAbstractFactory <NSObject>
/**
 * 将当前业务Bean, 解析成跟后台数据接口对应的数据字典
 * @return
 */
- (id<IParseDomainBeanToDataDictionary>) getParseDomainBeanToDDStrategy;

/**
 * 将网络返回的数据字典, 解析成当前业务Bean
 * @return
 */
- (id<IParseNetRespondDictionaryToDomainBean>) getParseNetRespondDictionaryToDomainBeanStrategy;

/**
 * 当前业务Bean, 对应的path.
 * @return
 */
- (NSString *) getSpecialPath;

/**
 * 当前网络响应业务Bean的Class
 * @return
 */
- (Class) getClassOfNetRespondBean;
@end
