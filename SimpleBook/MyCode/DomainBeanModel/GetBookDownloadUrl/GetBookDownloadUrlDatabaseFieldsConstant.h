//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#ifndef DreamBook_GetBookDownloadUrlDatabaseFieldsConstant_h
#define DreamBook_GetBookDownloadUrlDatabaseFieldsConstant_h

/************      RequestBean       *************/

// 要下载的书籍ID 必填
#define k_GetBookDownloadUrl_RequestKey_contentId        @"contentId"

 




/************      RespondBean       *************/

//
#define k_GetBookDownloadUrl_RespondKey_content         @"content"
// 校验
#define k_GetBookDownloadUrl_RespondKey_validate        @"validate"
//
#define k_GetBookDownloadUrl_RespondKey_url             @"url"


#endif
