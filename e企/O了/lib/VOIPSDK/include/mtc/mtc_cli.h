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
  File name     : mtc_cli.h
  Module        : multimedia talk client
  Author        : leo.lv
  Created on    : 2011-01-03
  Description   :
    Marcos and structure definitions required by the mtc.

  Modify History:
  1. Date:        Author:         Modification:
*************************************************/
#ifndef _MTC_CLI_H__
#define _MTC_CLI_H__

/**
 * @file mtc_cli.h
 * @brief MTC Client Interface Functions
 *
    @code
    The MTC client startup procedure like below:
    Mtc_CliInit    ---   init system resource.
    Mtc_CliOpen    ---   open an user for config provision 
    *** Using Mtc_CliDbSetLocalIp etc db APIs for set provision
    Mtc_CliStart   ---   start client service

    The MTC client halt procedure like below:
    Mtc_CliStop    ---   stop client service
    Mtc_CliClose   ---   close client user 
    Mtc_CliDestroy ---   destroy system resource.

    The MTC client for support multi-user switch procedure like below:
    Mtc_CliStop    ---   stop client service
    Mtc_CliClose   ---   close current user provision 
    Mtc_CliOpen    ---   open another user config provision 
    *** Using Mtc_CliDbSetLocalIp etc db APIs for set provision
    Mtc_CliStart   ---   start client service
    @endcode

 *
 */
#ifdef __cplusplus
extern "C" {
#endif

/** @brief MTC state of REGISTER. */
#define MTC_REG_STATE_IDLE      0    /**< @brief Register idle state.*/
#define MTC_REG_STATE_REGING    1    /**< @brief Register registering state. */
#define MTC_REG_STATE_REGED     2    /**< @brief Register registered state. */
#define MTC_REG_STATE_REREGING  3    /**< @brief Register registered registering state. */
#define MTC_REG_STATE_UNREGING  4    /**< @brief Register unregistering state. */

/** @brief MTC error/status code base */
#define MTC_EBASE_CP      0xE000     /**< @brief CP error base. */
#define MTC_EBASE_REG     0xE100     /**< @brief REG error base. */
#define MTC_EBASE_CALL    0xE200     /**< @brief CALL error base. */
#define MTC_EBASE_VSHARE  0xE300     /**< @brief VSHARE error base. */
#define MTC_EBASE_CAP     0xE400     /**< @brief CAP error base. */
#define MTC_EBASE_BUDDY   0xE500     /**< @brief BUDDY error base. */
#define MTC_EBASE_GRP     0xE600     /**< @brief GRP error base. */
#define MTC_EBASE_CONF    0xE700     /**< @brief CONF error base. */
#define MTC_EBASE_GS      0xE800     /**< @brief GS error base. */
#define MTC_EBASE_PRES    0xE900     /**< @brief PRES error base. */
#define MTC_EBASE_IM      0xEA00     /**< @brief IM error base. */
#define MTC_EBASE_CONTACT 0xEB00     /**< @brief CONTACT error base. */
#define MTC_EBASE_LOG     0xEC00     /**< @brief LOG error base. */

/** @defgroup group_def_status_code Type define of status code. */
/** @{ */
#define MTC_CLI_ERR_NO                     (MTC_EBASE_REG + 0) /**< @brief No error. */
#define MTC_CLI_ERR_LCL_FAILED             (MTC_EBASE_REG + 1) /**< @brief Local request error. */
#define MTC_CLI_REG_ERR_SEND_MSG           (MTC_EBASE_REG + 2) /**< @brief Send message error. */
#define MTC_CLI_REG_ERR_AUTH_FAILED        (MTC_EBASE_REG + 3) /**< @brief Register authentication failed, invalid user or password. */
#define MTC_CLI_REG_ERR_INVALID_USER       (MTC_EBASE_REG + 4) /**< @brief Register using invalid user. */
#define MTC_CLI_REG_ERR_TIMEOUT            (MTC_EBASE_REG + 5) /**< @brief Register timeout. */
#define MTC_CLI_REG_ERR_SERV_BUSY          (MTC_EBASE_REG + 6) /**< @brief Register server busy. */
#define MTC_CLI_REG_ERR_SERV_NOT_REACH     (MTC_EBASE_REG + 7) /**< @brief Register server not reached. */
#define MTC_CLI_REG_ERR_SRV_FORBIDDEN      (MTC_EBASE_REG + 8) /**< @brief Register forbidden. */
#define MTC_CLI_REG_ERR_SRV_UNAVAIL        (MTC_EBASE_REG + 9) /**< @brief Register unavailable. */
#define MTC_CLI_REG_ERR_DNS_QRY            (MTC_EBASE_REG + 10) /**< @brief Register dns query error. */
#define MTC_CLI_REG_ERR_NETWORK            (MTC_EBASE_REG + 11) /**< @brief Register network error. */
#define MTC_CLI_REG_ERR_DEACTED            (MTC_EBASE_REG + 12) /**< @brief Register deactived. */
#define MTC_CLI_REG_ERR_PROBATION          (MTC_EBASE_REG + 13) /**< @brief Register probation. */
#define MTC_CLI_REG_ERR_INTERNAL           (MTC_EBASE_REG + 14) /**< @brief Register internal error. */
#define MTC_CLI_REG_ERR_NO_RESOURCE        (MTC_EBASE_REG + 15) /**< @brief Register no resource. */
#define MTC_CLI_REG_ERR_OTHER              (MTC_EBASE_REG + 16) /**< @brief Other register error. */
/** @} */

/** @brief MTC client open the last profile. */
#define MTC_CLI_OPEN_LAST(_ret) do { \
    /* get current profile user */ \
    ZCHAR *pcCurUser = Mtc_ProvDbGetCurProfUser(); \
    /* check the profile is exist, then open client if it is exist*/ \
    if (!ZOS_ISEMPTY_STR(pcCurUser) && Mtc_ProfExistUser(pcCurUser)) \
        _ret = Mtc_CliOpen(pcCurUser); \
    else \
        _ret = ZFAILED; \
} while (0)
    
/** @defgroup group_def_access_net_type Type define of access network type */
/** @{ */
#define MTC_ANET_UNAVAILABLE        -2
#define MTC_ANET_UNKNOWN            -1
#define MTC_ANET_MOBILE             0x0000
#define MTC_ANET_MOBILE_GPRS        0x0001
#define MTC_ANET_MOBILE_EDGE        0x0002
#define MTC_ANET_MOBILE_UMTS        0x0003
#define MTC_ANET_MOBILE_CDMA        0x0004
#define MTC_ANET_MOBILE_EVDO_0      0x0005
#define MTC_ANET_MOBILE_EVDO_A      0x0006
#define MTC_ANET_MOBILE_1XRTT       0x0007
#define MTC_ANET_MOBILE_HSDPA       0x0008
#define MTC_ANET_MOBILE_HSUPA       0x0009
#define MTC_ANET_MOBILE_HSPA        0x000A
#define MTC_ANET_MOBILE_IDEN        0x000B
#define MTC_ANET_MOBILE_EVDO_B      0x000C
#define MTC_ANET_MOBILE_LTE         0x000D
#define MTC_ANET_MOBILE_EHRPD       0x000E
#define MTC_ANET_MOBILE_HSPAP       0x000F
#define MTC_ANET_WIFI               0x0100
#define MTC_ANET_WIMAX              0x0600
#define MTC_ANET_BLUETOOTH          0x0700
#define MTC_ANET_ETHERNET           0x0900
#define MTC_ANET_MASK_CATEGORY      0xFF00
/** @} */

/** @defgroup group_def_account_status Type deifne of account status */
/** @{ */
#define MTC_ACCOUNT_STATUS_ERR      -1
#define MTC_ACCOUNT_STATUS_NOT_FOUND 0
#define MTC_ACCOUNT_STATUS_OFFLINE  1
#define MTC_ACCOUNT_STATUS_PUSH     2
#define MTC_ACCOUNT_STATUS_ONLINE   3
/** @} */

typedef ZCOOKIE ZMTCCLIINFOCOOKIE;

/**
 * @defgroup MtcCliKey MTC notification key of client event.
 * @{
 */
/**
 * @brief A key whose value is a number reflecting the response status code,
 * @ref group_def_status_code.
 */
#define MtcCliStatusCodeKey       "MtcCliStatusCodeKey"

/**
 * @brief A key whose value is a number reflecting the time left in seconds 
 * before registration expired.
 */
#define MtcCliExpiresKey          "MtcCliExpiresKey"

/**
 * @brief A key whose value is a boolean reflecting if the contact address
 * of registration has changed.
 */
#define MtcCliChangedKey          "MtcCliChangedKey"

/**
 * @brief A key whose value is a number reflecting the challenge.
 */
#define MtcCliCookieKey           "MtcCliCookieKey"

/**
 * @brief A key whose value is a string reflecting the random string of the challenge.
 */
#define MtcCliRandKey             "MtcCliRandKey"

/**
 * @brief A key whose value is a string reflecting the AUTN string of the challenge.
 */
#define MtcCliAutnKey             "MtcCliAutnKey"

/**
 * @brief A key whose value is a string reflecting the account's username.
 */
#define MtcCliUserNameKey         "MtcCliUserNameKey"

/**
 * @brief A key whose value is a number reflecting the account's status,
 * @ref group_def_account_status.
 */
#define MtcCliStatusKey           "MtcCliStatusKey"
/** @} */

/**
 * @defgroup MtcCliNotification MTC notification of client event.
 * @{
 */

/**
 * @brief Posted when the provision has been loaded and ready for perform service.
 *
 * The pcInfo of this notification is ZNULL.
 */
#define MtcCliLocalLoginOkNotification        "MtcCliLocalLoginOkNotification"

/**
 * @brief Posted when the service object has been destroied.
 *
 * The pcInfo of this notification is ZNULL.
 */
#define MtcCliLocalDidLogoutNotification      "MtcCliLocalDidLogoutNotification"

/**
 * @brief Posted when the provision has been loaded and client REGISTER on 
 *        server successfully.
 *
 * The pcInfo of this notification is ZNULL.
 */
#define MtcCliServerLoginOkNotification       "MtcCliServerLoginOkNotification"

/**
 * @brief Posted when the provision has loaded but failed to REGISTER on server.
 *
 * The pcInfo of this notification contains @ref MtcCliStatusCodeKey
 * reflecting failed reason.
 */
#define MtcCliServerLoginDidFailNotification  "MtcCliServerLoginDidFailNotification"

/**
 * @brief Posted when client un-REGISTER on sever successfully. The un-REGISTER
 * action was requested by user.
 *
 * The pcInfo of this notification contains @ref MtcCliStatusCodeKey
 * reflecting response code from server.
 */
#define MtcCliServerDidLogoutNotification     "MtcCliServerDidLogoutNotification"

/**
 * @brief Posted when client receives the message which indicates 
 * the registration was invalid.
 *
 * The pcInfo of this notification contains @ref MtcCliStatusCodeKey
 * reflecting detail information from server.
 */
#define MtcCliServerLogoutedNotification      "MtcCliServerLogoutedNotification"

/**
 * @brief Posted when the registration on server has been refreshed successfully.
 * The refresh action was requested by user.
 *
 * The pcInfo of this notification contains @ref MtcCliChangedKey
 * reflecting if the registration contact address has changed.
 */
#define MtcCliRefreshOkNotification           "MtcCliRefreshOkNotification"

/**
 * @brief Posted when the registration on server has been refreshed successfully.
 * The refresh action was requested by SDK.
 *
 * The pcInfo of this notification contains @ref MtcCliChangedKey
 * reflecting if the registration contact address has changed.
 */
#define MtcCliRefreshedNotification           "MtcCliRefreshedNotification"

/**
 * @brief Posted when failed to refresh the registration on server.
 * The refresh action was requested by user.
 *
 * The pcInfo of this notification contains @ref MtcCliStatusCodeKey
 * reflecting failed reason.
 */
#define MtcCliRefreshDidFailNotification      "MtcCliRefreshDidFailNotification"

/**
 * @brief Posted when failed to refresh the registration on server.
 * The refresh action was requested by SDK.
 *
 * The pcInfo of this notification contains @ref MtcCliStatusCodeKey
 * reflecting failed reason.
 */
#define MtcCliRefreshFailedNotification       "MtcCliRefreshFailedNotification"

/**
 * @brief Posted when the client REGISTER on server successfully.
 *
 * The pcInfo of this notification is ZNULL.
 */
#define MtcCliRegisterOkNotification          "MtcCliRegisterOkNotification"

/**
 * @brief Posted when the client REGISTER on server successfully.
 *
 * The pcInfo of this notification contains @ref MtcCliStatusCodeKey
 * reflecting failed reason.
 */
#define MtcCliRegisterDidFailNotification     "MtcCliRegisterDidFailNotification"

/**
 * @brief Posted when client un-REGISTER successfully.
 *
 * The pcInfo of this notification is ZNULL.
 */
#define MtcCliUnRegisterOkNotification        "MtcCliUnRegisterOkNotification"

/**
 * @brief Posted when client receives a challenge from server during REGISTER.
 * It requests password for digest authentication.
 *
 * The pcInfo of this notification contains @ref MtcCliCookieKey
 * reflecting the handle of this challenge.
 * User should provide this cookie and password while invoking
 * @ref Mtc_CliEnterDgstPwd
 */
#define MtcCliDigestChallengeNotification     "MtcCliDigestChallengeNotification"

/**
 * @brief Posted when client receives a challenge from server during REGISTER.
 * It requests response for AKA authentication.
 *
 * The pcInfo of this notification contains
 * @ref MtcCliCookieKey reflecting the handle of this challenge,
 * @ref MtcCliRandKey reflecting the random string of this challenge,
 * @ref MtcCliAutnKey reflecting the AUTN value of this challenge, 
 * User should provide cookie, response, CK, IK and AUTN while invoking
 * @ref Mtc_CliEnterAkaRsp.
 */
#define MtcCliAkaChallengeNotification        "MtcCliAkaChallengeNotification"

/**
 * @brief Posted when the INFO message sent successfully.
 *
 * The pcInfo of this notification is ZNULL.
 */
#define MtcCliInfoSendOkNotification          "MtcCliInfoSendOkNotification"

/**
 * @brief Posted when client failed to send INFO message.
 *
 * The pcInfo of this notification is ZNULL.
 */
#define MtcCliInfoSendDidFailNotification     "MtcCliInfoSendDidFailNotification"

/**
 * @brief Posted when client query status of the account successfully.
 *
 * The pcInfo of this notification contains
 * @ref MtcCliUserNameKey reflecting the username of the account,
 * @ref MtcCliStatusKey reflecting the status of the account.
 */
#define MtcCliAccountQueryOkNotificaiton      "MtcCliAccountQueryOkNotificaiton"

/**
 * @brief Posted when client failed to query status of the account.
 *
 * The pcInfo of this notification contains
 * @ref MtcCliUserNameKey reflecting the username of the account,
 * @ref MtcCliStatusKey reflecting the status of the account.
 */
#define MtcCliAccountQueryDidFailNotificaiton "MtcCliAccountQueryDidFailNotificaiton"
/** @} */

/**
 * @brief Initialize Client Resource.
 *
 * @param [in] pcProfDir Profile directory
 *
 * @retval ZOK Initialize client resource successfully.
 * @retval ZFAILED Initialize client resource failed.
 *
 * @see @ref Mtc_CliDestroy
 */
MTCFUNC ZINT Mtc_CliInit(ZCHAR *pcProfDir);

/**
 * @brief Destroy Client Resource.
 *
 * @see @ref Mtc_CliInit
 */
MTCFUNC ZVOID Mtc_CliDestroy(ZFUNC_VOID);

/**
 * @brief Open a account.
 *
 * @param [in] pcUserName The account name.
 * If account name is ZNULL, it will load default profile information.
 * For change parameter, call @ref Mtc_CliDbSetLocalIp etc functions.
 *
 * @retval ZOK Open a account successfully.
 * @retval ZFAILED Initialize a account failed.
 *
 * @see @ref Mtc_CliClose
 */
MTCFUNC ZINT Mtc_CliOpen(ZCHAR *pcUserName);

/**
 * @brief Close current account.
 *
 * @see @ref Mtc_CliOpen
 */
MTCFUNC ZVOID Mtc_CliClose(ZFUNC_VOID);

/**
 * @brief Start Client Service.
 *
 * @retval ZOK Start client service successfully.
 * @retval ZFAILED Start client service failed.
 *
 * @see @ref Mtc_CliStop
 */
MTCFUNC ZINT Mtc_CliStart(ZFUNC_VOID);

/**
 * @brief Stop Client Service.
 *
 * @see @ref Mtc_CliStart
 */
MTCFUNC ZVOID Mtc_CliStop(ZFUNC_VOID);

/**
 * @brief Start to Login Client.
 * 
 * @param [in] iAccNetType The access network type EN_MTC_ANET_TYPE.
 * @param [in] pcAccNetIp The access network IP string.
 * If @ref Mtc_CliDbGetUserReg returns ZTRUE, Login result notified by callbacks 
 * which were set by MtcCliRegisterOkNotification, MtcCliRegisterDidFailNotification, 
 * MtcCliServerLoginOkNotification or MtcCliLocalLoginOkNotification
 * or MtcCliServerLoginDidFailNotification or MtcCliDigestChallengeNotification. 
 * Otherwise, it means client needn't login to remote server,
 * and will return immediately without any GUI callback.
 *
 * @retval ZOK Client is logining.
 * @retval ZFAILED Client login failed.
 *
 * @see @ref Mtc_CliLogout
 */
MTCFUNC ZINT Mtc_CliLogin(ZUINT iAccNetType, ZCONST ZCHAR *pcAccNetIp);

/* mtc start */
ZFUNC ZINT Mtc_CliLoginX(ZFUNC_VOID);

/**
 * @brief Enter aka response to Login Client again.
 * 
 * If @ref Mtc_CliDbGetAuthType returns EN_MTC_IMS_AUTH_IMS_AKA, 
 * Login result will be notified by callback which was set by
 * MtcCliAkaChallengeNotification, then client must enter aka response to login again.
 *
 * @retval ZOK Client is logining.
 * @retval ZFAILED Client login failed.
 *
 * @see @ref Mtc_CliLogout
 */
MTCFUNC ZINT Mtc_CliEnterAkaRsp(ZUINT iCookie, ZCHAR *pcRsp, ZCHAR *pcCk,
                ZCHAR *pcIk, ZCHAR *pcAuts);

/**
 * @brief Enter digest password to Login Client again.
 * 
 * If @ref Mtc_CliDbGetAuthType returns EN_MTC_IMS_AUTH_SIP_DIGEST, 
 * Login result will be notified by 
 * MtcCliDigestChallengeNotification if no password was avaliable before, 
 * then client must enter digest password to login again.
 *
 * @retval ZOK Client is logining.
 * @retval ZFAILED Client login failed.
 *
 * @see @ref Mtc_CliLogout
 */
MTCFUNC ZINT Mtc_CliEnterDgstPwd(ZUINT iCookie, ZCHAR *pcPwd);

/**
 * @brief Refresh the registration.
 * 
 * This interface is try to send re-REGISTRE message to refresh the
 * registration information on the server. Although the SDK will send 
 * re-REGISTER automatically accroding to the expire time length, there still
 * be in some condition which the client wants to send re-REGISTER to keep
 * registration information valid. Like on mobile phone platfrom, the 
 * SDK may not be able to send re-REGISTER on time during background mode.
 * In these cases, the application should invoke this interface to send
 * re-REGISTER manually to discover errors maybe occured during background mode.
 *
 * @retval ZOK Client send re-REGISTER ok.
 * @retval ZFAILED Client send re-REGISTER failed.
 *
 * @see @ref Mtc_CliLogin @ref Mtc_CliLogout
 */
MTCFUNC ZINT Mtc_CliRefresh(ZFUNC_VOID);

/**
 * @brief Start to Logout Client.
 *
 * If Mtc_DbGetUserReg returns ZTRUE, Logout result will be notified by 
 * callbacks which were set by MtcCliLocalDidLogoutNotification and MtcCliServerLogoutedNotification. 
 *
 * @retval ZOK Client is logouting.
 * @retval ZFAILED Client logout failed.
 *
 * @see @ref Mtc_CliLogin
 */
MTCFUNC ZINT Mtc_CliLogout(ZFUNC_VOID);

/**
 * @brief Send INFO message.
 *
 * @param [in] zCookie User cookie value.
 * @param [in] pcType Body type string, ZNULL for "plain".
 * @param [in] pcInfo INFO message body string.
 *
 * @retval ZOK Send info ok.
 * @retval ZFAILED Send info failed.
 *
 * @see 
 */
MTCFUNC ZINT Mtc_CliInfo(ZMTCCLIINFOCOOKIE zCookie, ZCHAR *pcType, ZCHAR *pcInfo);

/**
 * @brief Get User Register State.
 *
 * @return Register State. State see @ref MTC_REG_STATE_IDLE...
 */
MTCFUNC ZUINT Mtc_CliGetRegState(ZFUNC_VOID);

/**
 * @brief Client Drive Service.
 *
 * MTC service was implemented by MSF, for multi-thread mode,
 * MSF is running in independent thread, GUI is another one generally.
 * MTC implmented service login in GUI, so it is running in GUI.
 * When MSF need notify status to GUI, the event should transfered in 
 * two threads. For thread safety, service event was posted by 
 *
 * @param [in] zEvntId Service Event from RSD.
 *
 * @retval ZOK Drive Service successfully.
 * @retval ZFAILED Drive Service failed.
 *
 */
MTCFUNC ZINT Mtc_CliDrive(ZEVNT zEvntId);

/**
 * @brief Detect available local IP address.
 *   It is available in register mode.
 *
 *   If user open it by @ref Mtc_CliCfgSetUseDetLclIp, Client will automatic
 *   call it before start services and login.
 * 
 * @return Available local IP detected.
 */
MTCFUNC ZUINT Mtc_CliDetLclIp(ZFUNC_VOID);

/**
 * @brief Get Device Id string.
 *
 * @return Device Id string.
 */
MTCFUNC ZCONST ZCHAR * Mtc_CliGetDevId(ZFUNC_VOID);

/**
 * @brief Apply application Id string.
 *
 * @param pcAppId Stirng of application Id.
 *
 * @retval ZOK Apply successfully.
 * @retval ZFAILED Apply failed.
 */
MTCFUNC ZINT Mtc_CliApplyAppId(ZCONST ZCHAR *pcAppId);

/**
 * @brief Apply application Key string.
 *
 * @param pcAppKey Stirng of application Key.
 *
 * @retval ZOK Apply successfully.
 * @retval ZFAILED Apply failed.
 */
MTCFUNC ZINT Mtc_CliApplyAppKey(ZCONST ZCHAR *pcAppKey);

/**
 * @brief Apply device Id string.
 *
 * @param pcDevId Stirng of device id.
 *
 * @retval ZOK Apply successfully.
 * @retval ZFAILED Apply failed.
 */
MTCFUNC ZINT Mtc_CliApplyDevId(ZCONST ZCHAR *pcDevId);

/**
 * @brief Set push parameter.
 *
 * example:
 * @code
 * {"Notify.APNS.AppId":"com.juphoon.justalk",
 *  "Notify.APNS.Token":"681C42B23EA88992B8856C"}
 * @endcode
 * or
 * @code
 * {"Notify.APNS.AppId":"com.juphoon.justalk.debug",
 *  "Notify.APNS.Token":"681C42B23EA88992B8856C"}
 * @endcode
 * or
 * @code
 * {"Notify.Baidu.AppId":"AECZXODEKCKDA",
 *  "Notify.Baidu.UserId":"ZZDEIEQRELASDIOUF",
 *  "Notify.Baidu.ChannelId":"123050392"}
 * @endcode
 * or
 * @code
 * {"Notify.Google.AppId":"QERIPUZXCVPDFA",
 *  "Notify.Google.RegistrationId":"AOIUERQEZV"}
 * @endcode
 *
 * @retval ZOK Set successfully.
 * @retval ZFAILED Set failed.
 */
MTCFUNC ZINT Mtc_CliSetPushParm(ZCONST ZCHAR *pcParm);

/**
 * @brief Clear push parameter.
 * @param  pcAppId The application ID string.
 * @retval ZOK Set successfully.
 * @retval ZFAILED Set failed.
 */
MTCFUNC ZINT Mtc_CliClrPushParm(ZCONST ZCHAR *pcAppId);

/**
 * @brief Network changed trigger.
 * @param iAccessNetworkType Access network type, @ref group_def_access_net_type.
 */
MTCFUNC ZVOID Mtc_CliNetworkChanged(ZINT iAccessNetworkType);

/**
 * @brief Awake client process.
 */
MTCFUNC ZVOID Mtc_CliWakeup(ZBOOL bAwake);

/* mtc query account status */
/**
 * @brief Query account status.
 *
 * @param pcUserName Account user name stirng.
 * @param zCookie Cookie value in notification.
 *
 * @retval ZOK Query performed, result will notify by
 * MtcCliAccountQueryOkNotificaiton or MtcCliAccountQueryDidFailNotificaiton
 * @retval ZFAILED Query perform failed.
 */
MTCFUNC ZINT Mtc_CliQueryStatus(ZCONST ZCHAR *pcUserName, ZCOOKIE zCookie);

#ifdef ZOS_SUPT_JAVA

/**
 * @brief Set Java notification process function name.
 *
 * @retval ZOK Set successfully.
 * @retval ZFAILED Set failed.
 */
MTCFUNC ZINT Mtc_CliSetJavaNotify(ZCONST ZCHAR *pcClassName,
                ZCONST ZCHAR *pcMethodName);

#endif

#ifdef __cplusplus
}
#endif

#endif /* _MTC_CLI_H__ */

