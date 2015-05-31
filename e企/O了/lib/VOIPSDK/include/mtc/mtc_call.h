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
  File name     : mtc_call.h
  Module        : multimedia talk client
  Author        : leo.lv
  Created on    : 2011-01-03
  Description   :
      Data structure and function declare required by MTC call

  Modify History:
  1. Date:        Author:         Modification:
*************************************************/
#ifndef _MTC_CALL_H__
#define _MTC_CALL_H__

/**
 * @file mtc_call.h
 * @brief MTC Call Interface Functions
 *
 * This file includes call interface function. Those function is used to manage calls.
 */
#ifdef __cplusplus
extern "C" {
#endif

/** @brief MTC call dtmf type */
typedef enum EN_MTC_CALL_DTMF_TYPE
{
    EN_MTC_CALL_DTMF_0,              /**< @brief DTMF signal 0. */
    EN_MTC_CALL_DTMF_1,              /**< @brief DTMF signal 1. */
    EN_MTC_CALL_DTMF_2,              /**< @brief DTMF signal 2. */
    EN_MTC_CALL_DTMF_3,              /**< @brief DTMF signal 3. */
    EN_MTC_CALL_DTMF_4,              /**< @brief DTMF signal 4. */
    EN_MTC_CALL_DTMF_5,              /**< @brief DTMF signal 5. */
    EN_MTC_CALL_DTMF_6,              /**< @brief DTMF signal 6. */
    EN_MTC_CALL_DTMF_7,              /**< @brief DTMF signal 7. */
    EN_MTC_CALL_DTMF_8,              /**< @brief DTMF signal 8. */
    EN_MTC_CALL_DTMF_9,              /**< @brief DTMF signal 9. */
    EN_MTC_CALL_DTMF_STAR,           /**< @brief DTMF signal *. */
    EN_MTC_CALL_DTMF_POUND,          /**< @brief DTMF signal #. */
    EN_MTC_CALL_DTMF_A,              /**< @brief DTMF signal A. */
    EN_MTC_CALL_DTMF_B,              /**< @brief DTMF signal B. */
    EN_MTC_CALL_DTMF_C,              /**< @brief DTMF signal C. */
    EN_MTC_CALL_DTMF_D,              /**< @brief DTMF signal D. */
} EN_MTC_CALL_DTMF_TYPE;

/** @brief MTC call record mode type */
typedef enum EN_MTC_CALL_REC_MODE_TYPE
{
    EN_MTC_CALL_REC_MODE_ALL,        /**< @brief Record all data. */
    EN_MTC_CALL_REC_MODE_PLAY,       /**< @brief Record palying data. */
    EN_MTC_CALL_REC_MODE_MIC         /**< @brief Record microphone data. */
} EN_MTC_CALL_REC_MODE_TYPE;

/** @brief MTC call terminate reason type */
typedef enum EN_MTC_CALL_TERM_STATUS_CODE
{
    EN_MTC_CALL_TERM_STATUS_NORMAL = 1000,  /**< @brief Normal session term, bye or cancel. */
    EN_MTC_CALL_TERM_STATUS_BUSY,    /**< @brief The session is rejected. */
    EN_MTC_CALL_TERM_STATUS_DECLINE, /**< @brief Decline the session. */

    EN_MTC_CALL_TERM_STATUS_TIMEOUT = 1100, /**< @brief Terminated by timeout. */
    EN_MTC_CALL_TERM_STATUS_USER_OFFLINE, /**< @brief Call participant is offline. */
    EN_MTC_CALL_TERM_STATUS_NOT_FOUND, /**< @brief Call participant not found. */
    EN_MTC_CALL_TERM_STATUS_NOT_FRIEND, /**< @brief Call participant is not friend. */
    EN_MTC_CALL_TERM_STATUS_IN_BLACK_LST, /**< @brief Call participant is in black list. */
    EN_MTC_CALL_TERM_STATUS_TRANSFERED,  /**< @brief Terminated by transfered. */
    EN_MTC_CALL_TERM_STATUS_REDIRECTED,/**< @brief Terminated by redirect. */
    EN_MTC_CALL_TERM_STATUS_REPLACED, /**< @brief Terminated by replace. */

    EN_MTC_CALL_TERM_STATUS_ERROR_OTHER = 1200, /**< @brief Other error. */
    EN_MTC_CALL_TERM_STATUS_ERROR_AUTH_FAILED, /**< @brief Authentication failed, invalid user or password. */
    EN_MTC_CALL_TERM_STATUS_ERROR_SESSION_TIMER, /**< @brief Call refresh error. */
    EN_MTC_CALL_TERM_STATUS_ERROR_FORBIDDEN, /**< @brief Call forbidden. */
    EN_MTC_CALL_TERM_STATUS_ERROR_NOT_ACCEPTED, /**< @brief Call not accepted. */
    EN_MTC_CALL_TERM_STATUS_ERROR_TEMP_UNAVAIL, /**< @brief Call participant temp unavailable. */
    EN_MTC_CALL_TERM_STATUS_ERROR_REQUEST_TERMED, /**< @brief Call request terminated. */
    EN_MTC_CALL_TERM_STATUS_ERROR_INTERNAL, /**< @brief Server internal error. */
    EN_MTC_CALL_TERM_STATUS_ERROR_SERVICE_UNAVAIL, /**< @brief Service unavailable. */
    EN_MTC_CALL_TERM_STATUS_ERROR_NOT_EXIST, /**< @brief Not exist. */
    EN_MTC_CALL_TERM_STATUS_ERROR_TRANSACTION_FAIL, /**< @brief Call transaction error. */
} EN_MTC_CALL_TERM_STATUS_CODE;

/** @brief MTC call alert type */
typedef enum EN_MTC_CALL_ALERT_TYPE
{
    EN_MTC_CALL_ALERT_UNDEFINED = 2000, /**< @brief Alerted by other type. */
    EN_MTC_CALL_ALERT_RING,          /**< @brief Alerted by 180. */
    EN_MTC_CALL_ALERT_QUEUED,        /**< @brief Alerted by 182. */
    EN_MTC_CALL_ALERT_IN_PROGRESS,   /**< @brief Alerted by 183. */
} EN_MTC_CALL_ALERT_TYPE;

/** @brief Type of MTC network status. */
typedef enum EN_MTC_NET_STATUS_TYPE
{
    EN_MTC_NET_STATUS_DISCONNECTED = -3, /**< @brief Disconnected from network. */
    EN_MTC_NET_STATUS_VERY_BAD  = -2, /**< @brief Network status is very bad. */
    EN_MTC_NET_STATUS_BAD       = -1, /**< @brief Network status is bad. */
    EN_MTC_NET_STATUS_NORMAL    = 0,  /**< @brief Network status is normal. */
    EN_MTC_NET_STATUS_GOOD      = 1,  /**< @brief Network status is good. */
    EN_MTC_NET_STATUS_VERY_GOOD = 2,  /**< @brief Network status is very good. */
} EN_MTC_NET_STATUS_TYPE;

/** @brief Type of MTC session state */
typedef enum EN_MTC_CALL_STATE_TYPE
{
    EN_MTC_CALL_STATE_IDLE,      /**<@brief Session state is idle. */
    EN_MTC_CALL_STATE_OUTGOING,  /**<@brief Session state is outgoing. */
    EN_MTC_CALL_STATE_INCOMING,  /**<@brief Session state is incoming. */
    EN_MTC_CALL_STATE_ALERTED,   /**<@brief Session state is alerted. */
    EN_MTC_CALL_STATE_CONNECTING,/**<@brief Session state is connecting. */ 
    EN_MTC_CALL_STATE_TALKING,   /**<@brief Session state is talking. */
    EN_MTC_CALL_STATE_TERMED,    /**<@brief Session state is terminated. */
    EN_MTC_CALL_STATE_DIDTERM,   /**<@brief Session state is did terminate. */
} EN_MTC_CALL_STATE_TYPE;

/**
 * @defgroup MtcCallKey MTC notification key of session event.
 * @{
 */

/**
 * @brief A key whose value is a number object reflecting the ID of voice/audio
 * call.
 */
#define MtcCallIdKey                "MtcCallIdKey"

/**
 * @brief A key whose value is a string object reflecting the SIP content.
 */
#define MtcCallBodyKey              "MtcCallBodyKey"

/**
 * @brief A key whose value is a number object reflecting the video image width
 * in pixels.
 */
#define MtcCallWidthKey             "MtcCallWidthKey"

/**
 * @brief A key whose value is a number object reflecting the video image 
 * height in pixels.
 */
#define MtcCallHeightKey            "MtcCallHeightKey"

/**
 * @brief A key whose value is a number object reflecting the video orientation.
 */
#define MtcCallOrentationKey        "MtcCallOrentationKey"

/**
 * @brief A key whose value is a number object reflecting the video frame rate
 * in fps.
 */
#define MtcCallFrameRateKey         "MtcCallFrameRateKey"

/**
 * @brief A key whose value is a number object reflecting the video bitrate in
 * bps.
 */
#define MtcCallBitRateKey           "MtcCallBitRateKey"

/**
 * @brief A key whose value is a number object reflecting the video bitrate 
 * of forward error correction.
 */
#define MtcCallBitRateFecKey        "MtcCallBitRateFecKey"

/**
 * @brief A key whose value is a number object reflecting the video bit rate 
 * of negative acknowledgement.
 */
#define MtcCallBitRateNackKey       "MtcCallBitRateNackKey"

/**
 * @brief A key whose value is a boolean object reflecting if the call is a video
 * call.
 */
#define MtcCallIsVideoKey           "MtcCallIsVideoKey"

/**
 * @brief A key whose value is a boolean object reflecting if the media data is 
 * being sent.
 */
#define MtcCallIsSendKey            "MtcCallIsSendKey"

/**
 * @brief A key whose value is a number object reflecting the network status
 * @ref EN_MTC_NET_STATUS_TYPE.
 */
#define MtcCallNetworkStatusKey     "MtcCallNetworkStatusKey"

/**
 * @brief A key whose value is a number object reflecting the status code
 * @ref EN_MTC_CALL_TERM_STATUS_CODE.
 */
#define MtcCallStatusCodeKey        "MtcCallStatusCodeKey"

/**
 * @brief A key whose value is a string object reflecting the description.
 */
#define MtcCallDescriptionKey       "MtcCallDescriptionKey"

/**
 * @brief A key whose value is a bool object reflecting if the network state is 
 * good enough to send data.
 */
#define MtcCallSendAdviceKey        "MtcCallSendAdviceKey"

/**
 * @brief A key whose value is a number object reflecting video status.
 */
#define MtcCallVideoStatusKey       "MtcCallVideoStatusKey"

/**
 * @brief A key whose value is a number object reflecting the alert type
 * @ref EN_MTC_CALL_ALERT_TYPE.
 */
#define MtcCallAlertTypeKey         "MtcCallAlertTypeKey"

/**
 * @brief A key whose value is a number object relfecting the image timestamp.
 */
#define MtcCallImageTimeStampKey    "MtcCallImageTimeStampKey"
/** @} */

/**
 * @defgroup MtcCallNotification MTC notification of session event.
 * @{
 */

/**
 * @brief Posted when the call goes out.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallOutgoingNotification           "MtcCallOutgoingNotification"

/**
 * @brief Posted when the call comes in.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallIncomingNotification           "MtcCallIncomingNotification"

/**
 * @brief Posted when the call is evoked by a refer.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallReferoutNotification           "MtcCallReferoutNotification"

/**
 * @brief Posted when the call rings.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey and
 * @ref MtcCallAlertTypeKey.
 */
#define MtcCallAlertedNotification            "MtcCallAlertedNotification"

/**
 * @brief Posted when the call is forwarded.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallForwardedNotification          "MtcCallForwardedNotification"

/**
 * @brief Posted when the call is pre-acknowledged.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallPrackNotification              "MtcCallPrackNotification"

/**
 * @brief Posted when the connection is being established.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallConnectingNotification         "MtcCallConnectingNotification"

/**
 * @brief Posted when the connection is established and the voice can be heard.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallTalkingNotification            "MtcCallTalkingNotification"

/**
 * @brief Posted when the call session is terminated by a user.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey and
 * @ref MtcCallStatusCodeKey.
 */
#define MtcCallDidTermNotification            "MtcCallDidTermNotification"

/**
 * @brief Posted when the call session is terminated but not by a user.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey, 
 * @ref MtcCallDescriptionKey and @ref MtcCallStatusCodeKey.
 */
#define MtcCallTermedNotification             "MtcCallTermedNotification"

/**
 * @brief Posted when you hold the call successfully.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallHoldOkNotification             "MtcCallHoldOkNotification"

/**
 * @brief Posted when you fail to hold the call.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallHoldFailedNotification         "MtcCallHoldFailedNotification"

/**
 * @brief Posted when you unhold the call successfully.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallUnholdOkNotification           "MtcCallUnholdOkNotification"

/**
 * @brief Posted when you fail to unhold the call.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallUnholdFailedNotification       "MtcCallUnholdFailedNotification"

/**
 * @brief Posted when you are held by the other peer.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallHeldNotification               "MtcCallHeldNotification"

/**
 * @brief Posted when you are unheld by the other peer.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallUnheldNotification             "MtcCallUnheldNotification"

/**
 * @brief Posted when the audio is added successfully.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallAddAudioOkNotification         "MtcCallAddAudioOkNotification"

/**
 * @brief Posted when the audo failed to be added.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallAddAudioFailedNotification     "MtcCallAddAudioFailedNotification"

/**
 * @brief Posted when the audio is removed successfully.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallRmvAudioOkNotification         "MtcCallRmvAudioOkNotification"

/**
 * @brief Posted when the audio failed to be removed.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallRmvAudioFailedNotification     "MtcCallRmvAudioFailedNotification"

/**
 * @brief Posted when receiving the request of adding audio to the call.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallAddAudioRequestNotification    "MtcCallAddAudioRequestNotification"

/**
 * @brief Posted when the video is added successfully.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallAddVideoOkNotification         "MtcCallAddVideoOkNotification"

/**
 * @brief Posted when the video failed to be added.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallAddVideoFaieldNotification     "MtcCallAddVideoFaieldNotification"

/**
 * @brief Posted when the video is added successfully.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallRmvVideoOkNotification         "MtcCallRmvVideoOkNotification"

/**
 * @brief Posted when the video faild to be added.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallRmvVideoFailedNotification     "MtcCallRmvVideoFailedNotification"

/**
 * @brief Posted when receiving the request of adding video to the call.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallAddVideoRequestNotification    "MtcCallAddVideoRequestNotification"

/**
 * @brief Posted when a request is received to refer the call.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallReferedNotification            "MtcCallReferedNotification"

/**
 * @brief Posted when the transfer is accepted.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallTransferAcceptedNotification   "MtcCallTransferAcceptedNotification"

/**
 * @brief Posted when the transfer process is finished.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallTransferEndedNotification      "MtcCallTransferEndedNotification"

/**
 * @brief Posted when the transfer is failed.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallTransferFailedNotification     "MtcCallTransferFailedNotification"

/**
 * @brief Posted when the call is redirected.
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallRedirectedNotification         "MtcCallRedirectedNotification"

/**
 * @brief Posted when your call is replaced.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallReplacedNotification           "MtcCallReplacedNotification"

/**
 * @brief Posted when you replace the call successfully.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallReplaceOkNotification          "MtcCallReplaceOkNotification"

/**
 * @brief Posted when you fail to replace the call.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallReplaceFailedNotification      "MtcCallReplaceFailedNotification"

/**
 * @brief Posted when an info message is received.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey and 
 * @ref MtcCallBodyKey.
 */
#define MtcCallInfoReceivedNotification       "MtcCallInfoReceivedNotification"

/**
 * @brief Posted when the camera is disconnected.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallCamDisconnedNotification       "MtcCallCamDisconnedNotification"

/**
 * @brief Posted when the video image size is changed.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey, 
 * @ref MtcCallWidthKey, @ref MtcCallHeightKey and @ref MtcCallOrentationKey.
 */
#define MtcCallVideoSizeChangedNotification   "MtcCallVideoSizeChangedNotification"

/**
 * @brief Posted when collecting the network statistics of the received video
 * stream including framerate and bitrate.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey, 
 * @ref MtcCallFrameRateKey and @ref MtcCallBitRateKey.
 */
#define MtcCallVideoIncomingStaNotification   "MtcCallVideoIncomingStaNotification"

/**
 * @brief Posted when collecting the network statistics of the sending video
 * stream including framerate and bitrate.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey, 
 * @ref MtcCallFrameRateKey and @ref MtcCallBitRateKey.
 */
#define MtcCallVideoOutgoingStaNotification   "MtcCallVideoOutgoingStaNotification"

/**
 * @brief Posted when collecting the status of FEC and NACK.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey, 
 * @ref MtcCallBitRateFecKey and @ref MtcCallBitRateNackKey.
 */
#define MtcCallVideoProtectStatusNotification "MtcCallVideoProtectStatusNotification"

/**
 * @brief Posted when capturing the video framerate.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey and
 * @ref MtcCallFrameRateKey.
 */
#define MtcCallCaptureFramerateNotification   "MtcCallCaptureFramerateNotification"

/**
 * @brief Posted when capturing the video size.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey,
 * @ref MtcCallWidthKey, and @ref MtcCallHeightKey.
 */
#define MtcCallCaptureSizeNotification        "MtcCallCaptureSizeNotification"

/**
 * @brief Posted when network status changes.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey,
 * @ref MtcCallIsVideoKey, @ref MtcCallIsSendKey and @ref MtcCallNetworkStatusKey.
 */
#define MtcCallNetworkStatusChangedNotification "MtcCallNetworkStatusChangedNotification"

/**
 * @brief Posted when render starts.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey.
 */
#define MtcCallRenderDidStartNotification     "MtcCallRenderDidStartNotification"

/**
 * @brief Posted when the send advice changes. The send advice decides whether 
 * or not to send the data depending on the network status.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey and
 * @ref MtcCallSendAdviceKey.
 */
#define MtcCallVideoSendAdviceChangedNotification    "MtcCallVideoSendAdviceChangedNotification"

/**
 * @brief Posted when the user stops receiving data or starts receiving data.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey and
 * @ref MtcCallVideoStatusKey.
 */
#define MtcCallVideoReceiveStatusChangedNotification "MtcCallVideoReceiveStatusChangedNotification"

/**
 * @brief Posted when received the mangified image.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey and
 * @ref MtcCallImageTimeStampKey.
 */
#define MtcCallReceivedMangifiedImageNotification "MtcCallReceivedMangifiedImageNotification"

/**
 * @brief Posted when error occurs.
 *
 * The pcInfo of this notification contains @ref MtcCallIdKey and
 * @ref MtcCallStatusCodeKey.
 */
#define MtcCallErrorNotification              "MtcCallErrorNotification"
/** @} */

/** 
 * @brief MTC Call, establishing session call with video or audio.
 *
 * If send a new call and the callee answered, GUI will be notified by
 * MtcCallAlertedNotification, MtcCallTalkingNotification
 *
 * If send a new call and the callee redirected, GUI will be notified by
 * MtcCallOutgoingNotification, MtcCallAlertedNotification, MtcCallTalkingNotification
 *
 * If send a new call and the callee do not answered(timeout, busy now, etc.), GUI will be 
 * notified by MtcCallAlertedNotification, MtcCallDidTermNotification
 *
 * While receiving call invitation, GUI will be notified by
 * MtcCallIncomingNotification.
 *
 * While receiving call invitation and session is exist, GUI will be notified by
 * MtcCallReplacedNotification.
 *
 * @param [in] pcUri The destination URI to which you want to make a session call.
 * @param [in] zCookie Used to correspond session with UI resource. The cookie
 *                      value could be get by @ref Mtc_CallGetCookie or reset by
 *                      @ref Mtc_CallSetCookie at any time of session's life.
 * @param [in] bAudio Indicate whether this call has a voice stream.
 * @param [in] bVideo Indicate whether this call has a video stream.
 *
 * @return The id of this new created session on succeed, otherwise return ZMAXULONG.
 *
 * @see @ref Mtc_CallAnswer, @ref Mtc_CallGetCookie, @ref Mtc_CallSetCookie
 */
MTCFUNC ZUINT Mtc_Call(ZCHAR *pcUri, ZCOOKIE zCookie, ZBOOL bAudio,
                ZBOOL bVideo);

/** 
 * @brief MTC session alert an incoming session.
 *
 * @param [in] iCallId The id of incoming session which you want answer.
 * @param [in] zCookie Used to correspond session with UI resource. The cookie
 *                      value could be get by Rse_SessGetCookie or reset by
 *                      Rse_SessSetCookie at any time of session's life.
 * @param [in] iType Alert type, @ref EN_MTC_CALL_ALERT_RING,
                      @ref EN_MTC_CALL_ALERT_QUEUED 
                      or @ref EN_MTC_CALL_ALERT_IN_PROGRESS.
 * @param [in] bReliable If ZTRUE, message will be sending as reliable
 *                      provisional response.
 *
 * @retval ZOK on succeed.
 * @retval ZFAILED on failure.
 *
 * @see Mtc_Call, Mtc_CallGetCookie, Mtc_CallSetCookie
 */
MTCFUNC ZINT Mtc_CallAlert(ZUINT iCallId, ZCOOKIE zCookie, ZUINT iType,
                ZBOOL bReliable);

/** 
 * @brief MTC session answer an incoming session call which is notified by
 *        callback function which MtcCallIncomingNotification.
 *
 * @param [in] iCallId The id of incoming session which you want to answer.
 * @param [in] zCookie Used to correspond session with UI resource. The cookie
 *                      value could be get by @ref Mtc_CallGetCookie or reset by
 *                      @ref Mtc_CallSetCookie at any time of session's life.
 * @param [in] bAudio Indicate whether this call has a voice stream.
 * @param [in] bVideo Indicate whether this call has a video stream.
 *
 * @retval ZOK on succeed.
 * @retval ZFAILED on failure.
 *
 * @see @ref Mtc_Call, MtcCallIncomingNotification, @ref Mtc_CallGetCookie, @ref Mtc_CallSetCookie
 */
MTCFUNC ZINT Mtc_CallAnswer(ZUINT iCallId, ZCOOKIE zCookie, ZBOOL bAudio,
                ZBOOL bVideo);

/** 
 * @brief MTC session terminate.
 *
 * @param [in] iCallId The ID of session which you want to terminate.
 * @param [in] iReason Indicate the terminate reason. Only
 *                      EN_MTC_CALL_TERM_STATUS_NORMAL,
 *                      EN_MTC_CALL_TERM_STATUS_BUSY,
 *                      EN_MTC_CALL_TERM_STATUS_DECLINE can be used.
 * @param [in] pcDesc Detail description string.
 *
 * @retval ZOK on succeed.
 * @retval ZFAILED on failure.
 *
 * Actually Mtc_CallTerm does not free all resource allocated for this
 * session. It only starts a terminating procedure. All resource will be
 * freed automatically when the procedure ends.
 *
 * @see @ref Mtc_Call, @ref Mtc_CallAnswer...
 */
MTCFUNC ZINT Mtc_CallTerm(ZUINT iCallId, ZUINT iReason, ZCONST ZCHAR *pcDesc);

/** 
 * @brief MTC session hold.
 *
 * If sending session hold successfully, GUI will be notified by
 * MtcCallHoldOkNotification
 *
 * If sending session hold failed, GUI will be notified by
 * MtcCallHoldFailedNotification
 *
 * While receiving session held, GUI will be notified by
 * MtcCallHeldNotification.
 *
 * @param [in] iCallId The ID of session which you want to hold.
 *
 * @retval ZOK on succeed.
 * @retval ZFAILED on failure.
 *
 * @see @ref Mtc_CallUnhold
 */
MTCFUNC ZINT Mtc_CallHold(ZUINT iCallId);

/** 
 * @brief MTC session unhold.
 *
 * If sending session unhold successfully, GUI will be notified by
 * MtcCallUnholdOkNotification
 *
 * If sending session hold failed, GUI will be notified by
 * MtcCallUnholdFailedNotification
 *
 * While receiving session unheld, GUI will be notified by
 * MtcCallUnheldNotification.
 *
 * @param [in] iCallId The ID of session which you want to unhold.
 *
 * @retval ZOK on succeed.
 * @retval ZFAILED on failure.
 *
 * @see @ref Mtc_CallUnhold
 */
MTCFUNC ZINT Mtc_CallUnhold(ZUINT iCallId);

/** 
 * @brief MTC session unattended transfer.
 *
 * If unattended transfer successfully, GUI will be notified by
 * MtcCallTransferAcceptedNotification
 *
 * If unattended transfer failed, GUI will be notified by
 * MtcCallTransferFailedNotification, MtcCallTransferEndedNotification
 *
 * while receiving unattended transfer, GUI will be notified by
 * MtcCallReferedNotification
 *
 * @param [in] iCallId The ID of session which you want to make unattended transfer.
 * @param [in] pcUri The destination URI to which you want to transfer this session.
 *
 * @retval ZOK on succeed.
 * @retval ZFAILED on failure.
 *
 * After this operation, the session will be terminated by server.
 *
 * @see @ref Mtc_CallATrsf
 */
MTCFUNC ZINT Mtc_CallUTrsf(ZUINT iCallId, ZCHAR *pcUri);

/** 
 * @brief MTC session attended transfer.
 *
 * If attended transfer successfully, GUI will be notified by
 * MtcCallTransferAcceptedNotification
 *
 * If attended transfer failed, GUI will be notified by
 * MtcCallTransferFailedNotification, MtcCallTransferEndedNotification
 *
 * while receiving attended transfer, GUI will be notified by
 * MtcCallReferedNotification
 *
 * @param [in] iCallId The ID of session which you want to make attended transfer.
 * @param [in] iTrsfCallId The destination session to which you want to transfer
 *                          this session.
 *
 * @retval ZOK on succeed.
 * @retval ZFAILED on failure.
 *
 * If you have a session with user A(indicated by dwCallId) and a session with
 * user B(indicated by dwTrsfSessId), the result of attended transfer is A will
 * have a session with B and all sessions you had with A and B will be terminated.
 *
 * @see @ref Mtc_CallUTrsf
 */
MTCFUNC ZINT Mtc_CallATrsf(ZUINT iCallId, ZUINT iTrsfCallId);

/** 
 * @brief MTC session diverse an incoming session call which is notified by
 *        callback function which MtcCallIncomingNotification.
 *
 * While receiving forwarded, GUI will be notified by
 * MtcCallRedirectedNotification.
 *
 * @param [in] iCallId The ID of session which you want to diverse.
 * @param [in] pcUri The URI of diverse destination.
 *
 * @retval ZOK on succeed.
 * @retval ZFAILED on failure.
 *
 * @see MtcCallIncomingNotification
 */
MTCFUNC ZINT Mtc_CallDiv(ZUINT iCallId, ZCHAR *pcUri);

/** 
 * @brief MTC session send a media update request to peer. The update in this
 *        function means open a new media stream or close an already exist
 *        media stream.
 *
 * If sending update successfully, GUI will be notified by 
 * MtcCallAddAudioOkNotification, MtcCallRmvAudioOkNotification, MtcCallAddVideoOkNotification,
 * MtcCallRmvVideoOkNotification
 *
 * If sending update failed, GUI will be notified by
 * MtcCallAddAudioFailedNotification, MtcCallRmvAudioFailedNotification, MtcCallAddVideoFaieldNotification,
 * MtcCallRmvVideoFailedNotification
 *
 * While receiving update, GUI will be notified by 
 * MtcCallAddAudioRequestNotification, MtcCallAddVideoRequestNotification.
 *
 * @param [in] iCallId The ID of session which you want to update its media.
 * @param [in] bAudio Indicate whether you want to have a audio stream after
 *                    update.
 * @param [in] bVideo Indicate whether you want to have a video stream after
 *                    update.
 *
 * @retval ZOK on succeed.
 * @retval ZFAILED on failure.
 *
 * @see @ref Mtc_CallUpdateRsp
 */
MTCFUNC ZINT Mtc_CallUpdate(ZUINT iCallId, ZBOOL bAudio, ZBOOL bVideo);

/** 
 * @brief MTC session response a media update request from peer. The update
 *        in this function means open a new media stream or close an already
 *        exist media stream.
 *
 * @param [in] iCallId The ID of session which you want to accept the update
 *                      of its media.
 * @param [in] bAudio Indicate whether you want to have a audio stream after
 *                    update.
 * @param [in] bVideo Indicate whether you want to have a video stream after
 *                    update.
 *
 * @retval ZOK on succeed.
 * @retval ZFAILED on failure.
 *
 * @see @ref Mtc_CallUpdate
 */
MTCFUNC ZINT Mtc_CallUpdateRsp(ZUINT iCallId, ZBOOL bAudio, ZBOOL bVideo);

/** 
 * @brief MTC PickUp, establishing session call with video or audio 
          by replacing specific call.
 *
 * If the new session call was accept by callee, GUI will be notified by 
  MtcCallTalkingNotification.
 *
 * If the new session call was reject by callee or no answer, GUI will be 
   notified by MtcCallDidTermNotification.
 *
 * @param [in] pcUri The destination URI to which you want to make a session call.
 * @param [in] pcReplaceInfo The replace information used to locate replaced call.
                     The format must comply with RFC3891, 
                     like '425928@phone.example.org;to-tag=7743;from-tag=6472'.
 * @param [in] zCookie Used to correspond session with UI resource. The cookie
 *                      value could be get by @ref Mtc_CallGetCookie or reset by
 *                      @ref Mtc_CallSetCookie at any time of session's life.
 * @param [in] bAudio Indicate whether this call has a voice stream.
 * @param [in] bVideo Indicate whether this call has a video stream.
 *
 * @return The id of this new created session on succeed, otherwise return ZMAXULONG.
 *
 * @see @ref Mtc_CallPickUpX
 */
MTCFUNC ZUINT Mtc_CallPickUp(ZCHAR *pcUri, ZCHAR *pcReplaceInfo,
                ZCOOKIE zCookie, ZBOOL bAudio, ZBOOL bVideo);

/** 
 * @brief MTC session PickUp, establishing session call with video or audio 
          by replacing specific call.
 *
 * @param [in] iCallId The session ID indication which session to be pick up.
 *
 * @retval ZOK on succeed.
 * @retval ZFAILED on failure.
 *
 * @see Mtc_CallPickUp
 */
MTCFUNC ZINT Mtc_CallPickUpX(ZUINT iCallId);

/** 
 * @brief MTC session send DTMF info.
 *
 * @param [in] iCallId The ID of session which you want to send DTMF info.
 * @param [in] iDtmfType DTMF type which will be sent, see @ref EN_MTC_CALL_DTMF_TYPE.
 *
 * @retval ZOK on succeed.
 * @retval ZFAILED on failure.
 */
MTCFUNC ZINT Mtc_CallDtmf(ZUINT iCallId, ZUINT iDtmfType);

/** 
 * @brief MTC session send INFO with text.
 *
 * @param [in] iCallId The ID of session which you want to send INFO.
 * @param [in] pcInfo Text string carried by INFO.
 *
 * @retval ZOK on succeed.
 * @retval ZFAILED on failure.
 */
MTCFUNC ZINT Mtc_CallInfo(ZUINT iCallId, ZCHAR *pcInfo);

/** 
 * @brief MTC session attach camera.
 *
 * @param [in] iCallId The ID of session.
 * @param [in] pcName The name string of camera.
 *
 * @retval ZOK on succeed.
 * @retval ZFAILED on failure.
 */
MTCFUNC ZINT Mtc_CallCameraAttach(ZUINT iCallId, ZCONST ZCHAR *pcName);

/** 
 * @brief MTC session detach camera.
 *
 * @param [in] iCallId The ID of session.
 *
 * @retval ZOK on succeed.
 * @retval ZFAILED on failure.
 */
MTCFUNC ZINT Mtc_CallCameraDetach(ZUINT iCallId);

/**
 * @brief MTC get session name.
 *
 * @param [in] iCallId The ID of session.
 *
 * @return The Render name string when found, otherwise "".
 */
MTCFUNC ZCONST ZCHAR * Mtc_CallGetName(ZUINT iCallId);

/**
 * @brief MTC get session from render name.
 *
 * @param pcName Render name string.
 *
 * @return The ID of session when found, otherwise ZMAXULONG.
 */
MTCFUNC ZVOID * Mtc_CallFromName(ZCONST ZCHAR *pcName);

/**
 * @brief MTC session get network status of video stream.
 *
 * @param [in] iCallId The ID of session.
 *
 * @return Network status @ref EN_MTC_NET_STATUS_TYPE.
 */
MTCFUNC ZINT Mtc_CallGetVideoNetSta(ZUINT iCallId);

/**
 * @brief MTC session get network status of audio stream.
 *
 * @param [in] iCallId The ID of session.
 *
 * @return Network status @ref EN_MTC_NET_STATUS_TYPE.
 */
MTCFUNC ZINT Mtc_CallGetAudioNetSta(ZUINT iCallId);

/**
 * @brief MTC session get session state.
 *
 * @param [in] iCallId The ID of session.
 *
 * @return Session state @ref EN_MTC_CALL_STATE_TYPE.
 */
MTCFUNC ZINT Mtc_CallGetState(ZUINT iCallId);

/** 
 * @brief MTC session check if has a active video stream.
 *
 * @param [in] iCallId The ID of session.
 *
 * @retval ZTRUE on yes.
 * @retval ZFALSE on no.
 *
 * @see @ref Mtc_CallVideoStart, @ref Mtc_CallVideoStop, @ref Mtc_CallHasAudio
 */
MTCFUNC ZBOOL Mtc_CallHasVideo(ZUINT iCallId);

/** 
 * @brief MTC session check if has a active audio stream.
 *
 * @param [in] iCallId The ID of session.
 *
 * @retval ZTRUE on yes.
 * @retval ZFALSE on no.
 *
 * @see @ref Mtc_CallHasVideo
 */
MTCFUNC ZBOOL Mtc_CallHasAudio(ZUINT iCallId);

/** 
 * @brief MTC check session has entered in talking state.
 *
 * @param [in] iCallId The ID of session.
 *
 * @retval ZTRUE on talking state.
 * @retval ZFALSE on talking state.
 *
 * @see @ref Mtc_Call, @ref Mtc_CallAnswer
 */
MTCFUNC ZBOOL Mtc_CallHasTalk(ZUINT iCallId);

/** 
 * @brief MTC check session has entered in hold state.
 *
 * @param [in] iCallId The ID of session.
 *
 * @retval ZTRUE on hold state.
 * @retval ZFALSE on hold state.
 *
 * @see @ref Mtc_CallHasHeld
 */
MTCFUNC ZBOOL Mtc_CallHasHold(ZUINT iCallId);

/** 
 * @brief MTC check session has entered in held state.
 *
 * @param [in] iCallId The ID of session.
 *
 * @retval ZTRUE on held state.
 * @retval ZFALSE on held  state.
 *
 * @see @ref Mtc_CallHasHold
 */
MTCFUNC ZBOOL Mtc_CallHasHeld(ZUINT iCallId);

/** 
 * @brief MTC session check if peer offer a video stream.
 *
 * @param [in] iCallId The ID of session.
 *
 * @retval ZTRUE on yes.
 * @retval ZFALSE on no.
 *
 * @see @ref Mtc_CallVideoStart, @ref Mtc_CallVideoStop, @ref Mtc_CallPeerOfferAudio
 */
MTCFUNC ZBOOL Mtc_CallPeerOfferVideo(ZUINT iCallId);

/** 
 * @brief MTC session check if peer offer a audio stream.
 *
 * @param [in] iCallId The ID of session.
 *
 * @retval ZTRUE on yes.
 * @retval ZFALSE on no.
 *
 * @see @ref Mtc_CallPeerOfferVideo
 */
MTCFUNC ZBOOL Mtc_CallPeerOfferAudio(ZUINT iCallId);

/** 
 * @brief MTC session get the mute status of microphone.
 *
 * @param [in] iCallId The ID of session which you want to get.
 *
 * @retval ZTRUE on muted.
 * @retval ZFALSE on not muted.
 *
 * @see @ref Mtc_CallSetMicMute
 */
MTCFUNC ZBOOL Mtc_CallGetMicMute(ZUINT iCallId);

/** 
 * @brief MTC session set the mute status of microphone.
 *
 * @param [in] iCallId The ID of session which you want to set.
 * @param [in] bMute Indicate whether to mute the microphone.
 *
 * @retval ZOK on succeed.
 * @retval ZFAILED on failure.
 *
 * @see @ref Mtc_CallGetMicMute
 */
MTCFUNC ZINT Mtc_CallSetMicMute(ZUINT iCallId, ZBOOL bMute);

/** 
 * @brief MTC session get scale of microphone.
 *
 * @param [in] iCallId The ID of session which you want get.
 *
 * @return Scale value, from 0.0 to 10.0, 1.0 for no scaling.
 *
 * @see Mtc_CallSetMicScale
 */
MTCFUNC ZFLOAT Mtc_CallGetMicScale(ZUINT iCallId);

/** 
 * @brief MTC session set scale of microphone.
 *
 * @param [in] iCallId The ID of session which you want set.
 * @param [in] fScale Scale value, from 0.0 to 10.0, 1.0 for no scaling.
 *
 * @retval ZOK on succeed.
 * @retval ZFAILED on failure.
 *
 * @see Mtc_CallGetMicScale
 */
MTCFUNC ZINT Mtc_CallSetMicScale(ZUINT iCallId, ZFLOAT fScale);

/** 
 * @brief MTC session get the mute status of speaker.
 *
 * @param [in] iCallId The ID of session which you want to get.
 *
 * @retval ZTRUE on muted.
 * @retval ZFALSE on not muted.
 *
 * @see @ref Mtc_CallSetSpkMute
 */
MTCFUNC ZBOOL Mtc_CallGetSpkMute(ZUINT iCallId);

/** 
 * @brief MTC session set the mute status of speaker.
 *
 * @param [in] iCallId The ID of session which you want to set.
 * @param [in] bMute Indicate whether to mute the speaker.
 *
 * @retval ZOK on succeed.
 * @retval ZFAILED on failure.
 *
 * @see @ref Mtc_CallGetSpkMute
 */
MTCFUNC ZINT Mtc_CallSetSpkMute(ZUINT iCallId, ZBOOL bMute);

/** 
 * @brief MTC session get scale of speaker.
 *
 * @param [in] iCallId The ID of session which you want get.
 *
 * @return Scale value, from 0.0 to 10.0, 1.0 for no scaling.
 *
 * @see Mtc_CallSetSpkScale
 */
MTCFUNC ZFLOAT Mtc_CallGetSpkScale(ZUINT iCallId);

/** 
 * @brief MTC session set scale of speaker.
 *
 * @param [in] iCallId The ID of session which you want set.
 * @param [in] fScale Scale value, from 0.0 to 10.0, 1.0 for no scaling.
 *
 * @retval ZOK on succeed.
 * @retval ZFAILED on failure.
 *
 * @see Mtc_CallGetSpkScale
 */
MTCFUNC ZINT Mtc_CallSetSpkScale(ZUINT iCallId, ZFLOAT fScale);

/** 
 * @brief MTC session get volume of speaker.
 *
 * @param [in] iCallId The ID of session which you want get.
 *
 * @return Volume value, from 0 to 20.
 *
 * @see Mtc_CallSetSpkVol
 */
MTCFUNC ZUINT Mtc_CallGetSpkVol(ZUINT iCallId);

/** 
 * @brief MTC session set volume of speaker.
 *
 * @param [in] iCallId The ID of session which you want set.
 * @param [in] iVol Volume value, from 0 to 20.
 *
 * @retval ZOK on succeed.
 * @retval ZFAILED on failure.
 *
 * @see Mtc_CallGetSpkVol
 */
MTCFUNC ZINT Mtc_CallSetSpkVol(ZUINT iCallId, ZUINT iVol);

/** 
 * @brief MTC session get mix voice status.
 *
 * @param [in] iCallId The ID of session which you want to set.
 *
 * @return mix voice status.
 */
MTCFUNC ZBOOL Mtc_CallGetMixVoice(ZUINT iCallId);

/** 
 * @brief MTC session set mix voice status.
 *
 * @param [in] iCallId The ID of session which you want to set.
 * @param [in] bEnable Indicate whether to mix voice. If ZTRUE, it will mix
 *                     corresponding session's voice.
 *
 * @retval ZOK on succeed.
 * @retval ZFAILED on failure.
 */
MTCFUNC ZINT Mtc_CallSetMixVoice(ZUINT iCallId, ZBOOL bEnable);

/** 
 * @brief MTC session get cookie value.
 *
 * @param [in] iCallId The ID of session which you want to get cookie of.
 *
 * @return The cookie of session.
 *
 * The cookie value could be set by @ref Mtc_Call, @ref Mtc_CallAnswer or
 * @ref Mtc_CallSetCookie previously.
 *
 * @see @ref Mtc_Call, @ref Mtc_CallAnswer, @ref Mtc_CallSetCookie
 */
MTCFUNC ZCOOKIE Mtc_CallGetCookie(ZUINT iCallId);

/** 
 * @brief MTC session set cookie value.
 *
 * @param [in] iCallId The ID of session which you want to set cookie.
 * @param [in] zCookie The cookie which you want to set.
 *
 * @retval ZOK on succeed.
 * @retval ZFAILED on failure.
 *
 * @see @ref Mtc_Call, @ref Mtc_CallAnswer, @ref Mtc_CallGetCookie
 */
MTCFUNC ZINT Mtc_CallSetCookie(ZUINT iCallId, ZCOOKIE zCookie);

/** 
 * @brief MTC session get name of peer id, based on polices.
 *
 * @param [in] iCallId The ID of session which you want to get.
 *
 * @retval The string of name.
 *
 * Note the result of this function may be different with Mtc_CallGetPeerUri
 * because the apply of polices. For example, OIP, OIR, TIP, TIR, and privacy.
 *
 * @see @ref Mtc_CallGetPeerId
 */
MTCFUNC ZCONST ZCHAR * Mtc_CallGetPeerName(ZUINT iCallId);

/** 
 * @brief MTC session get display name of peer id, based on polices.
 *
 * @param [in] iCallId The ID of session which you want to get.
 *
 * @retval The string of display name.
 *
 * Note the result of this function may be different with Mtc_CallGetPeerUri
 * because the apply of polices. For example, OIP, OIR, TIP, TIR, and privacy.
 *
 * @see @ref Mtc_CallGetPeerId
 */
MTCFUNC ZCONST ZCHAR * Mtc_CallGetPeerDisplayName(ZUINT iCallId);

/** 
 * @brief Mtc session get audio statistics.
 *
 * @param [in] iCallId The ID of session.
 *
 * @retval String of audio statistics.
 *
 * @see 
 */
MTCFUNC ZCONST ZCHAR * Mtc_CallGetAudioStat(ZUINT iCallId);

/** 
 * @brief Mtc session get video statistics.
 *
 * @param [in] iCallId The ID of session.
 *
 * @retval String of video statistics.
 *
 * @see 
 */
MTCFUNC ZCONST ZCHAR * Mtc_CallGetVideoStat(ZUINT iCallId);

/** 
 * @brief Mtc session get mpt statistics.
 *
 * @param [in] iCallId The ID of session.
 *
 * @retval String of mpt statistics.
 *
 * @see 
 */
MTCFUNC ZCONST ZCHAR * Mtc_CallGetMptStat(ZUINT iCallId);

/**
 * @brief MTC session get audio stream ID.
 * 
 * @param [in] iCallId The ID of session.
 *
 * @retval ID of audio stream.
 */
MTCFUNC ZUINT Mtc_CallGetAudioStreamId(ZUINT iCallId);

/**
 * @brief MTC session get video stream ID.
 * 
 * @param [in] iCallId The ID of session.
 *
 * @retval ID of video stream.
 */
MTCFUNC ZUINT Mtc_CallGetVideoStreamId(ZUINT iCallId);

/**
 * @brief MTC session mangify image of video.
 *
 * @param [in] iCallId The ID of session.
 * @param [in] dCenterX X position of original point of the movement, from 0.0 to 1.0.
 * @param [in] dCenterY Y position of original point of the movement, from 0.0 to 1.0.
 * @param [in] dZoom Mangification factor.
 * @param [in] dOffsetX The moving distance of the X-axis direction, from 0.0 to 1.0.
 * @param [in] dOffsetY The moving distance of the Y-axis direction, from 0.0 to 1.0.
 *
 * @retval ZOK on successfully.
 * @retval ZFAILED on failed.
 */
MTCFUNC ZINT Mtc_CallMangify(ZUINT iCallId, ZDOUBLE dCenterX, ZDOUBLE dCenterY,
                ZDOUBLE dZoom, ZDOUBLE dOffsetX, ZDOUBLE dOffsetY);

/**
 * @brief Reccord call start.
 *
 * It will reccord from call to file.
 *
 * @param [in] iCallId The ID of session.
 * @param [in] pcFileName The reccord file name.
 * @param [in] ucFileType The reccord file type, @ref EN_MTC_MFILE_TYPE
 *
 * @retval ZOK Audio Reccord  successfully.
 * @retval ZFAILED Audio Reccord failed.
 *
 * @see @ref Mtc_CallRecCallStop
 */
MTCFUNC ZINT Mtc_CallRecCallStart(ZUINT iCallId, ZCONST ZCHAR *pcFileName,
                ZUCHAR ucFileType);

/**
 * @brief Reccord Audio stop.
 *
 * @param [in] iCallId The ID of session.
 *
 * @see @ref Mtc_CallRecCallStart
 */
MTCFUNC ZINT Mtc_CallRecCallStop(ZUINT iCallId);

/**
 * @brief MTC session start recoding incoming video.
 *
 * @param [in] iCallId The ID of session.
 * @param [in] pcFileName Name of the file which to store the recording data.
 * @param [in] ucFileType File type, @ref EN_MTC_MFILE_TYPE.
 * @param [in] iWidth Video width in pixel of recoding data.
 * @param [in] iHeight Video height in pixel of recoding data.
 * @param [in] bWithAudio ZTRUE to recording audio data.
 *
 * @retval ZOK on successfully.
 * @retval ZFAILED on failed.
 *
 * @see Mtc_CallRecRecvVideoStop
 */
MTCFUNC ZINT Mtc_CallRecRecvVideoStart(ZUINT iCallId, 
                ZCONST ZCHAR *pcFileName, ZUCHAR ucFileType, ZUINT iWidth, 
                ZUINT iHeight, ZBOOL bWithAudio);

/**
 * @brief MTC session stop recoding incoming video.
 *
 * @param [in] iCallId The ID of session.
 *
 * @retval ZOK on successfully.
 * @retval ZFAILED on failed.
 *
 * @see Mtc_CallRecRecvVideoStart
 */
MTCFUNC ZINT Mtc_CallRecRecvVideoStop(ZUINT iCallId);

/**
 * @brief MTC session start recoding sending video.
 *
 * @param [in] iCallId The ID of session.
 * @param [in] pcFileName Name of the file which to store the recording data.
 * @param [in] ucFileType File type, @ref EN_MTC_MFILE_TYPE.
 * @param [in] iWidth Video width in pixel of recoding data.
 * @param [in] iHeight Video height in pixel of recoding data.
 * @param [in] bWithAudio ZTRUE to recording audio data.
 *
 * @retval ZOK on successfully.
 * @retval ZFAILED on failed.
 *
 * @see Mtc_CallRecSendVideoStop
 */
MTCFUNC ZINT Mtc_CallRecSendVideoStart(ZUINT iCallId, 
                ZCONST ZCHAR *pcFileName, ZUCHAR ucFileType, 
                ZUINT iWidth, ZUINT iHeight, ZBOOL bWithAudio);

/**
 * @brief MTC session stop recoding sending video.
 *
 * @param [in] iCallId The ID of session.
 *
 * @retval ZOK on successfully.
 * @retval ZFAILED on failed.
 *
 * @see Mtc_CallRecSendVideoStart
 */
MTCFUNC ZINT Mtc_CallRecSendVideoStop(ZUINT iCallId);

/**
 * @brief Take a snapshot of display render.
 *
 * @param [in] iCallId The ID of session.
 * @param [in] pcFileName Name of the file which to store the picture.
 *
 * @retval ZOK on successfully.
 * @retval ZFAILED on failed.
 *
 * @see Mtc_CallCaptureSnapshot
 */
MTCFUNC ZINT Mtc_CallRenderSnapshot(ZUINT iCallId, ZCONST ZCHAR *pcFileName);

/**
 * @brief Take a snapshot of capture.
 *
 * @param [in] iCallId The ID of session.
 * @param [in] pcFileName Name of the file which to store the picture.
 *
 * @retval ZOK on successfully.
 * @retval ZFAILED on failed.
 *
 * @see Mtc_CallRenderSnapshot
 */
MTCFUNC ZINT Mtc_CallCaptureSnapshot(ZUINT iCallId, ZCONST ZCHAR *pcFileName);

#ifdef __cplusplus
}
#endif

#endif /* _MTC_CALL_H__ */

