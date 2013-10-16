//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import <Foundation/Foundation.h>
#import "IParseNetRespondDictionaryToDomainBean.h"

@interface BookListInBookstoresParseNetRespondDictionaryToDomainBean : NSObject <IParseNetRespondDictionaryToDomainBean> {
  
}

#pragma mark 实现 IParseNetRespondStringToDomainBean 接口
- (id) parseNetRespondDictionaryToDomainBean:(in NSDictionary *) netRespondDictionary;
@end