//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "UrlConstantForThisProject.h"

@implementation UrlConstantForThisProject

@end

// https://61.177.139.215:8443
/// 主URL
NSString *const kUrlConstant_MainUrl = @"https://dreambook.retechcorp.com";// 外网地址
//NSString *const kUrlConstant_MainUrl = @"https://61.177.139.215:8443";// 外网地址
//NSString *const kUrlConstant_MainUrl = @"http://192.168.11.105:3000";// 内网地址
//NSString *const kUrlConstant_MainUrl = @"https://192.168.11.50";// 内网地址
// https://dreambook.retechcorp.com/dreambook/testcon.txt


/// 主Path
NSString *const kUrlConstant_MainPtah = @"dreambook";


// 1	获取本地书架书籍分类
NSString *const kUrlConstant_SpecialPath_local_bookshelf_categories = @"categories";
// 2	用户登录
NSString *const kUrlConstant_SpecialPath_account_login = @"account/login";
// 3	获取要下载的书籍的URL
NSString *const kUrlConstant_SpecialPath_content_download = @"content/download/";
// 4	企业书库的书籍列表
NSString *const kUrlConstant_SpecialPath_content_list = @"content/list";
// 5	主题
NSString *const kUrlConstant_SpecialPath_theme = @"theme";

 