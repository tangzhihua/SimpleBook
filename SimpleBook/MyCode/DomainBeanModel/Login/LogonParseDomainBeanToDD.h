//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "IParseDomainBeanToDataDictionary.h"

@interface LogonParseDomainBeanToDD : NSObject <IParseDomainBeanToDataDictionary> {
  
}

- (NSDictionary *) parseDomainBeanToDataDictionary:(in id) netRequestDomainBean;
@end