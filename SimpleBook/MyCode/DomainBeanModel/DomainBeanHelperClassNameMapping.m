//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "DomainBeanHelperClassNameMapping.h"



// 1. 登录
#import "LogonNetRequestBean.h"
#import "LogonDomainBeanToolsFactory.h"

// 2. 本地书籍分类
#import "BookCategoriesNetRequestBean.h"
#import "BookCategoriesDomainBeanToolsFactory.h"

// 3. 获取要下载的书籍URL
#import "GetBookDownloadUrlNetRequestBean.h"
#import "GetBookDownloadUrlDomainBeanToolsFactory.h"

// 4. 获取书城图书列表
#import "BookListInBookstoresNetRequestBean.h"
#import "BookListInBookstoresDomainBeanToolsFactory.h"

static const NSString *const TAG = @"<DomainBeanHelperClassNameMapping>";

@implementation DomainBeanHelperClassNameMapping

- (id) init {
	
	if ((self = [super init])) {
		NSLog(@"init %@ [0x%x]", TAG, [self hash]);
    
    
		
		/**
		 * 1. 登录
		 */
    [strategyClassesNameMappingList setObject:NSStringFromClass([LogonDomainBeanToolsFactory class])
                                       forKey:NSStringFromClass([LogonNetRequestBean class])];
    
    /**
		 * 2. 本地书籍分类
		 */
    [strategyClassesNameMappingList setObject:NSStringFromClass([BookCategoriesDomainBeanToolsFactory class])
                                       forKey:NSStringFromClass([BookCategoriesNetRequestBean class])];
    
    /**
		 * 3. 获取要下载的书籍URL
		 */
    [strategyClassesNameMappingList setObject:NSStringFromClass([GetBookDownloadUrlDomainBeanToolsFactory class])
                                       forKey:NSStringFromClass([GetBookDownloadUrlNetRequestBean class])];
    
    /**
		 * 4. 获取书城图书列表
		 */
    [strategyClassesNameMappingList setObject:NSStringFromClass([BookListInBookstoresDomainBeanToolsFactory class])
                                       forKey:NSStringFromClass([BookListInBookstoresNetRequestBean class])];
	}
  
  
	
	return self;
}

@end
