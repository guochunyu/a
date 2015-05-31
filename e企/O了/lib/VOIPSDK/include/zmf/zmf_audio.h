#ifndef __ZMF_AUDIO_H__
#define __ZMF_AUDIO_H__

/**
 * @file zmf_audio.h
 * @brief ZMF audio interfaces
 */

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Initilize Audio module of ZMF(Zero Media Framework).
 * @param  applicationContext For Windows, it must be the handle of the window,
 *                            The notification event will be sent to that window.
 *                            For Android, it must be the Context.
 * @return                    0 on succeed, otherwise failed.
 */
int Zmf_AudioInitialize(void *applicationContext);

/**
 * @brief Destory Audio module of ZMF module. All resources will be released.
 * @return  0 on succeed, otherwise failed.
 */
int Zmf_AudioTerminate (void);

#ifdef __cplusplus
}
#endif /* __cplusplus */

/**
 * @brief AEC mode.
 */
typedef enum {
    ZmfAecAuto                          = -1, /**< @brief Auto select mode. */
    ZmfAecOff                           = 0, /**< @brief Disable AEC. */
    ZmfAecOn                            = 1, /**< @brief Enable AEC. */
} ZmfAecMode;

/**
 * @brief AGC mode.
 */
typedef enum {
    ZmfAgcAuto                          = -1, /**< @brief Auto select mode. */
    ZmfAgcOff                           = 0, /**< @brief Disable AGC. */
    ZmfAgcOn                            = 1, /**< @brief Enable AGC. */
} ZmfAgcMode;

/**
 * @brief Session Mode.
 */
typedef enum {
    ZmfSessionAutoMode                  = 0, /**< @brief Auto select mode, i.e. do nothing. */
    ZmfSessionDefault                   = 1, /**< @brief Default mode. if not support, do nothing */
    ZmfSessionVoiceChat                 = 2, /**< @brief Voice mode, if not support, set Default mode */
    ZmfSessionVideoChat                 = 3, /**< @brief Video mode, if not support, set Default mode */
} ZmfSessionMode;

#ifdef __OBJC__

#import <UIKit/UIKit.h>

/**
 * @defgroup ZmfAudioDeviceId Audio Device ID
 * @{
 */

/** @brief Device ID string of Remote IO. */
extern const char * const ZmfAudioDeviceRemote;

/** @brief Device ID string of Voice Processing IO. */
extern const char * const ZmfAudioDeviceVoice;

/**
 * @}
 */

/**
 * @defgroup ZmfAudioNotificationParameters Audio Notification Parameters.
 * @{
 */

/**
 * @brief A NSString object containing a string that indentifies
 * audio input device ID.
 */
extern NSString * const ZmfAudioInput;

/**
 * @brief A NSString object containing a string that indentifies
 * audio output device ID.
 */
extern NSString * const ZmfAudioOutput;

/**
 * @brief An NSNumber object containing an integer that indentifies
 * the samping rate in Hz.
 */
extern NSString * const ZmfSamplingRate;

/**
 * @brief A NSNumber object containing an integer that indentifies
 * the channel number.
 */
extern NSString * const ZmfChannelNumber;

/**
 * @brief A NSNumber object containing a boolean that indentifies
 * the request type for Automatic Gain Control(AGC).
 * For a list of possible values, @ref ZmfAgcMode.
 */
extern NSString * const ZmfAutoGainControl;

/**
 * @brief A NSNumber object containing a boolean that indentifies
 * the request type for Acoustic Echo Cancelling(AEC).
 * For a list of possible values, @ref ZmfAecMode.
 */
extern NSString * const ZmfAcousticEchoCancel;

/**
 * @brief A NSString object containing a stirng that indentifies
 * the reason.
 */
extern NSString * const ZmfAudioError;

/**
 * @}
 */

/**
 * @defgroup ZmfAudioNotifications Audio Notifications.
 * @{
 */

/**
 * @brief Post when the ZMF module request to start recording audio data.
 *
 * The userInfo dictionary of this notification contains @ref ZmfAudioInput,
 * @ref ZmfSamplingRate and @ref ZmfChannelNumber, which provide detail 
 * information for the request.
 */
extern NSString * const ZmfAudioInputRequestStart;

/**
 * @brief Post when the ZMF module request to stop recording audio data.
 *
 * The userInfo dictionary of this notification contains @ref ZmfAudioInput,
 * which provide detail information for the request.
 */
extern NSString * const ZmfAudioInputRequestStop;

/**
 * @brief Post when the ZMF module has recieved first audio data after
 * @ref Zmf_AudioInputStart invoked.
 *
 * The userInfo dictionary of this notification contains @ref ZmfAudioInput,
 * @ref ZmfSamplingRate and @ref ZmfChannelNumber, which indicate the actual
 * parameters of the audio data recorded.
 */
extern NSString * const ZmfAudioInputDidStart;

/**
 * @brief Post when the ZMF module request to start playing audio data.
 *
 * The userInfo dictionary of this notification contains @ref ZmfAudioOutput,
 * @ref ZmfSamplingRate and @ref ZmfChannelNumber, which provide detail 
 * information for the request.
 */
extern NSString * const ZmfAudioOutputRequestStart;

/**
 * @brief Post when the ZMF module request to stop playing audio data.
 *
 * The userInfo dictionary of this notification contains @ref ZmfAudioOutput,
 * which provide detail information for the request.
 */
extern NSString * const ZmfAudioOutputRequestStop;

/**
 * @brief Post when the ZMF module has delivered the first audio data after
 * @ref Zmf_AudioOutputStart invoked.
 *
 * The userInfo dictionary of this notification contains @ref ZmfAudioOutput,
 * @ref ZmfSamplingRate and @ref ZmfChannelNumber, which indicate the actual
 * parameters of the audio data.
 */
extern NSString * const ZmfAudioOutputDidStart;

/**
 * @brief Post when the ZMF Audio module has received interruption during working,
 * then entry an interruption status.
 *
 * The ZMF Audio module will stop working (input/output) automatically.
 */
extern NSString * const ZmfAudioInterrupted;

/** 
 * @brief Post when the ZMF Audio module has received a 'should resume' message,
 * at the interruption status.
 *
 * The ZMF Audio module will restore working (input/output) automatically.
 */
extern NSString * const ZmfAudioDidResume;

/** @brief Post when the ZMF Audio module has an error occurred.
 *
 * The userInfo dictionary of this notification contains @ref ZmfAudioError
 */
extern NSString * const ZmfAudioErrorOccurred;

/**
 * @}
 */

#endif /* __OBJC__ */

#ifdef _WIN32

/**
 * @brief Event number for audio notifications.
 *
 * The wParam of the event is the type of notification.
 * For a list of possible values, @ref ZmfAudioEventType.
 *
 * The lParam of the event may contains the JSON object depend on the
 * type of notification.
 */
#define ZmfAudioEvent           WM_APP + 130

/**
 * @defgroup ZmfNotificationParameters Audio Notification Parameters.
 * @{
 */

/**
 * @brief An String object containing a string that indentifies
 * ID of audio input device.
 */
#define ZmfAudioInput           "AudioInput"

/**
* @brief An String object containing a string that indentifies
* ID of audio output device.
*/
#define ZmfAudioOutput          "AudioOutput"

/**
 * @brief An Number object containing an integer that indentifies
 * the samping rate in Hz.
 */
#define ZmfSamplingRate         "SamplingRate"

/**
 * @brief An Number object containing an integer that indentifies
 * the channel number.
 */
#define ZmfChannelNumber        "ChannelNumber"

/**
 * @brief An Number object containing a boolean that indentifies
 * the request type for Automatic Gain Control(AGC).
 * For a list of possible values, @ref ZmfAgcMode.
 */
#define ZmfAutoGainControl      "AutoGainControl"

/**
 * @brief An Number object containing a boolean that indentifies
 * the request type for Acoustic Echo Cancelling(AEC).
 * For a list of possible values, @ref ZmfAecMode.
 */
#define ZmfAcousticEchoCancel   "AcousticEchoCancel"

/**
 * @brief A NSString object containing a string that error description.
 * the format match 'input <id>|output <id>|audio: <reason>'.
 */
#define ZmfAudioError           "AudioError"

/**
 * @}
 */

/**
 * @brief Type of audio notifications.
 */
typedef enum {
    /**
     * @brief Post when the ZMF module request to start recording audio data.
     *
     * The lParam of this event is a JSON object contains @ref ZmfAudioInput,
     * @ref ZmfSamplingRate and @ref ZmfChannelNumber, which provide detail 
     * information for the request.
     */
    ZmfAudioInputRequestStart           = 1,

    /**
     * @brief Post when the ZMF module request to stop recording audio data.
     *
     * The userInfo dictionary of this notification contains @ref ZmfAudioInput,
     * which provide detail information for the request.
     */
    ZmfAudioInputRequestStop            = 2,

    /**
     * @brief Post when the ZMF module has recieved first audio data after
     * @ref Zmf_AudioInputStart invoked.
     *
     * The lParam of this event is a JSON object contains @ref ZmfAudioInput,
     * @ref ZmfSamplingRate and @ref ZmfChannelNumber, which indicate the actual
     * parameters of the audio data recorded.
     */
    ZmfAudioInputDidStart               = 3,

    /**
     * @brief Post when the ZMF module request to start playing audio data.
     *
     * The lParam of this event is a JSON object contains @ref ZmfAudioOutput,
     * @ref ZmfSamplingRate and @ref ZmfChannelNumber, which provide detail 
     * information for the request.
     */
    ZmfAudioOutputRequestStart          = 4,

    /**
     * @brief Post when the ZMF module request to stop playing audio data.
     *
     * The userInfo dictionary of this notification contains @ref ZmfAudioOutput,
     * which provide detail information for the request.
     */
    ZmfAudioOutputRequestStop           = 5,

    /**
     * @brief Post when the ZMF module has delivered the first audio data after
     * @ref Zmf_AudioOutputStart invoked.
     *
     * The lParam of this event is a JSON object contains @ref ZmfAudioOutput,
     * @ref ZmfSamplingRate and @ref ZmfChannelNumber, which indicate the actual
     * parameters of the audio data.
     */
    ZmfAudioOutputDidStart              = 6,

    /** @brief Post when the ZMF Audio module has an error occurred.
     *
     * The userInfo dictionary of this notification contains @ref ZmfAudioError
     */
    ZmfAudioErrorOccurred               = 7,
} ZmfAudioEventType;

#endif /* _WIN32 */

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Set audio session mode
 * @return        0 on succeed, otherwise failed.
 */
int Zmf_AudioSessionSetMode (ZmfSessionMode enAudioMode);

/**
 * @brief Get count of audio input device.
 * @return  The total count of audio input device.
 */
int Zmf_AudioInputGetCount (void);

/**
 * @brief Set volume of audio input device, only for windows
 *
 * @return          0 on succeed, otherwise failed.
 */
int Zmf_AudioInputSetVolume(int percent);

/**
 * @brief Get the name of audio input device.
 * @param  iIndex   The index of audio input device, from 0 to count - 1.
 * @param  acId     Pointer the buffer contains ID string.
 * @param  acName   Pointer the buffer contains name utf8 string.
 * @return          0 on succeed, otherwise failed.
 */
int Zmf_AudioInputGetName (int iIndex, char acId[512], char acName[512]);

/**
 * @brief Start audio input device to record data.
 * @param  pcId           The ID of audio input device.
 * @param  iSamplingRate  Sampling rate in Hz, 0 for auto selection.
 * @param  iChannelNumber Channel number, 0 for auto selction.
 * @param  enAecMode      AEC mode @ref ZmfAecMode.
 * @param  enAgcMode      AGC mode @ref ZmfAgcMode.
 * @return                0 on succeed, otherwise failed.
 */
int Zmf_AudioInputStart (const char* pcId, int iSamplingRate, int iChannelNumber,
                         ZmfAecMode enAecMode, ZmfAgcMode enAgcMode);

/**
 * @brief Stop audio input device.
 * @param  pcId  The ID of audio input device.
 * @return       0 on succeed, otherwise failed.
 */
int Zmf_AudioInputStop (const char* pcId);

/**
 * @brief Stop all audio input device.
 * @return  0 on succeed, otherwise failed.
 */
int Zmf_AudioInputStopAll (void);

/**
 * @brief Get count of audio output device.
 * @return  The total count of audio output device.
 */
int Zmf_AudioOutputGetCount (void);

/**
 * @brief Set volume of audio output device, only for windows
 *
 * @return          0 on succeed, otherwise failed.
 */
int Zmf_AudioOutputSetVolume(int percent);
/**
 * @brief Get the name of audio output device.
 * @param  iIndex   The index of audio output device, from 0 to count - 1.
 * @param  acId     Pointer the buffer contains ID string.
 * @param  acName   Pointer the buffer contains name utf8 string.
 * @return          0 on succeed, otherwise failed.
 */
int Zmf_AudioOutputGetName (int iIndex, char acId[512], char acName[512]);

/**
 * @brief Start audio output device to play data.
 * @param  pcId           The ID of audio output device.
 * @param  iSamplingRate  Sampling rate in Hz, 0 for auto selection.
 * @param  iChannelNumber Channel number, 0 for auto selection.
 * @return                0 on succeed, otherwise failed.
 */
int Zmf_AudioOutputStart (const char* pcId, int iSamplingRate, int iChannelNumber);

/**
 * @brief Stop audio output device.
 * @param  pcId The ID of audio output device.
 * @return      0 on succeed, otherwise failed.
 */
int Zmf_AudioOutputStop (const char* pcId);

/**
 * @brief Stop all audio output device.
 * @return  0 on succeed, otherwise failed.
 */
int Zmf_AudioOutputStopAll (void);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __ZMF_AUDIO_H__ */
