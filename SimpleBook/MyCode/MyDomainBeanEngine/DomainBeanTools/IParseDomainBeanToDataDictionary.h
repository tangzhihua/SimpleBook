//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import <Foundation/Foundation.h>

@protocol IParseDomainBeanToDataDictionary <NSObject>

- (NSDictionary *) parseDomainBeanToDataDictionary:(in id) netRequestDomainBean;
@end
