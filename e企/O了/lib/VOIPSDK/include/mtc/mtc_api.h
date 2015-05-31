/************************************************************************
 
        Copyright (c) 2005-2011 by Juphoon System Software, Inc.
                        All rights reserved.
 
     This software is confidential and proprietary to Juphoon System,
     Inc. No part of this software may be reproduced, stored, transmitted,
     disclosed or used in any form or by any means other than as expressly
     provided by the written license agreement between Juphoon and its
     licensee.
 
     THIS SOFTWARE IS PROVIDED BY JUPHOON "AS IS" AND ANY EXPRESS OR
     IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
     WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
     ARE DISCLAIMED. IN NO EVENT SHALL JUPHOON BE LIABLE FOR ANY DIRECT,
     INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
     (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
     OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
     HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
     STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
     IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
     POSSIBILITY OF SUCH DAMAGE.
 
                    Juphoon System Software, Inc.
                    Email: support@juphoon.com
                    Web: http://www.juphoon.com
 
************************************************************************/
/*************************************************
  File name     : mtc_api.h
  Module        : multimedia talk client
  Author        : Young
  Created on    : 2015-01-14
  Description   :
      Function and notification declare required by mtc api
 
  Modify History:
  1. Date:        Author:         Modification:
*************************************************/

#import <Foundation/Foundation.h>
#import "zos_type.h"

#define MTCFUNC
#import "mtc_cli.h"
#import "mtc_call.h"
#import "mtc_mdm.h"
#import "mtc_ring.h"
#import "mtc_media.h"

/**
 * @defgroup Notification of login and logout event.
 * @{
 */
#define MtcLoginOkNotification "MtcLoginOkNotification"
#define MtcLoginDidFailNotification "MtcLoginDidFailNotification"
#define MtcLoginPasswordNotification "MtcLoginPasswordNotification"
#define MtcDidLogoutNotification "MtcDidLogoutNotification"
#define MtcLogoutedNotification "MtcLogoutedNotification"
/** @} */

/** @brief The key use in the parameter info of function Mtc_Login.*/
#define MtcServerAddressKey "MtcServerAddressKey"

/**
 * @brief Initialize Resource.
 *
 * @param [in] pcAppKey the appKey what you apply for.
 *
 * @retval ZOK Initialize resource successfully.
 * @retval ZFAILED Initialize resource failed.
 *
 * @see @ref Mtc_Destroy
 */
ZINT Mtc_Init(ZCONST ZCHAR *pcAppKey);

/**
 * @brief Destroy Resource.
 *
 * @see @ref Mtc_Init
 */
ZVOID Mtc_Destroy(ZFUNC_VOID);

/**
 * @brief Start to Login.
 *
 * @param [in] pcAccount The account what you want to login.
 * @param [in] info The configration info such as server address, you can 
 * ceate a dictionary by use zhe MtcServerAddressKey.
 *
 * If login successfully, Login result is notified by the notification which
 * is MtcLoginOkNotification. Otherwise, login failed and login result is 
 * notified by the notification which is MtcLoginDidFailNotification.
 * You can register these notification and do something in the notification
 * callbacks, such as alert user the login result.
 *
 * @retval ZOK Login successfully.
 * @retval ZFAILED Login failed.
 *
 * @see @ref Mtc_Logout @ref Mtc_LoginPassword
 */
ZINT Mtc_Login(ZCONST ZCHAR *pcAccount, NSDictionary *info);

/**
 * @brief Start to Login by the password.
 *
 * @param [in] pcPassword The password what you will receive by the SMS.
 *
 * You should register the MtcLoginPasswordNotification and invoke the 
 * function in the notification callbacks.
 *
 * If login successfully, Login result is notified by the notification which
 * is MtcLoginOkNotification. Otherwise, login failed and login result is
 * notified by the notification which is MtcLoginDidFailNotification.
 * You can register these notification and do something in the notification
 * callbacks, such as alert user the login result.
 *
 * @retval ZOK Login successfully.
 * @retval ZFAILED Login failed.
 *
 * @see @ref Mtc_Login @ref Mtc_Logout 
 */
ZINT Mtc_LoginPassword(ZCONST ZCHAR *pcPassword);

/**
 * @brief Start to Logout.
 *
 * If the return value returns ZOK, Logout result is notified by the
 * notification which is MtcDidLogoutNotification. You can register the 
 * notification and do something in the notification callbacks,
 * such as alert user already logouted.
 *
 * And also you should register the MtcLogoutedNotification and do something 
 * in the notification callbacks. Such as when your account login another
 * device, the MtcLogoutedNotification will be notified.
 *
 * @retval ZOK Logout successfully.
 * @retval ZFAILED Logout failed.
 *
 * @see @ref Mtc_Login @ref Mtc_LoginPassword
 */
ZINT Mtc_Logout(ZFUNC_VOID);

