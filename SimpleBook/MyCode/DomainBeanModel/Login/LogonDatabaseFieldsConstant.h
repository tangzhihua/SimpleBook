//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#ifndef DreamBook_LogonDatabaseFieldsConstant_h
#define DreamBook_LogonDatabaseFieldsConstant_h

/************      RequestBean       *************/

// 用户名 必填
#define k_Login_RequestKey_username        @"user_id"
// 密码 必填
#define k_Login_RequestKey_password        @"user_password"
 




/************      RespondBean       *************/

//
#define k_Login_RespondKey_response        @"response"
// 校验
#define k_Login_RespondKey_validate        @"validate"
// 错误信息
#define k_Login_RespondKey_error           @"error"


#endif
