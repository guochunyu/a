#ifndef __ZMF_VIDEO_H__
#define __ZMF_VIDEO_H__

/**
 * @file zmf_video.h
 * @brief ZMF video interfaces
 */

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Initialize Video module of ZMF(Zero Media Framework).
 * @param  applicationContext For Windows, it must be the handle of the window,
 *                            The notification event will be sent to that window.
 *                            For Android, it must be the Context.
 * @return                    0 on succeed, otherwise failed.
 */
int Zmf_VideoInitialize(void *applicationContext);

/**
 * @brief Destroy Video module of ZMF module. All resources will be released.
 * @return  0 on succeed, otherwise failed.
 */
int Zmf_VideoTerminate (void);

#ifdef __cplusplus
}
#endif /* __cplusplus */

/**
 * @brief Face direction of capture device.
 */
typedef enum {
    ZmfVideoFaceFront               = 1, /**< @brief Facing front. */
    ZmfVideoFaceBack                = 2, /**< @brief Facing back. */
} ZmfVideoFaceType;

/**
 * @brief Coordinate rotation angle.
 */
typedef enum {
    ZmfRotationAngle0               = 0, /**< @brief 0 degree. */
    ZmfRotationAngle90              = 90, /**< @brief 90 degrees CCW. */
    ZmfRotationAngle180             = 180, /**< @brief 180 degrees CCW. */
    ZmfRotationAngle270             = 270, /**< @brief 270 degrees CCW. */
} ZmfRotationAngle;

/**
 * @brief Mirror type.
 */
typedef enum {
    ZmfMirrorAuto                   = 0, /**< @brief Auto selection. */
    ZmfMirrorHorizontal             = 1, /**< @brief Horizontal mirror. */ 
    ZmfMirrorVertical               = 2, /**< @brief Vertical mirror. */
} ZmfMirrorType;

/**
 * @brief Built-in Effect type.
 */
typedef enum {
    ZmfRenderEffectNone             = 0, /**< @brief none effect. */
    /** Blur effect,
     *  JSON params:
     *   "hoffset": number of width pixel offset, default is 2
     *   "voffset": number of height pixel offset, defualt is 2
     *   "iterate": number of repetitions, default is 3
     *    "pixels": number of the blur radius 
    *      "sigma":
     */
    ZmfRenderEffectBlur             = 1,
    ZmfRenderEffectGrey             = 2, /**< @brief grey. */
    ZmfRenderEffectMask             = 3, /**< @brief mask. */
    /** Magnifier effect,
     *  JSON params:
     *    "dx":
     *    "dy":
     *     "x": number of center
     *     "y": number of center
     *  "zoom": number of zoom times, default is 2
     *"radius": number of radius, ratio of min(w,h), default is 0.2
     */
    ZmfRenderEffectMagnifier        = 4,
    ZmfRenderEffectOldTime          = 5,
    ZmfRenderEffectPhotoVerse       = 6,
    ZmfRenderEffectLomo             = 7,
    /** Blur effect,
     *  JSON params:
     *   "hoffset": number of width pixel offset, default is 2
     *   "voffset": number of height pixel offset, defualt is 2
     *   "iterate": number of repetitions, default is 3
     *    "pixels": number of the blur radius 
    *      "sigma":
     *         "x": number of center
     *         "y": number of center
     *    "radius": number of radius, ratio of min(w,h), default is 0.2
     *       "exp": number of alpha exp, default is 1.0
     */
    ZmfRenderEffectDepthOfField     = 8,
} ZmfRenderEffectType;

typedef enum {
    ZmfRenderMatchNone              = 0,
    /** 
     * JSON param:
     *  "epsilon":
     * "duration":
     * "position":
     *     "fovy":
     * "attitude":
     */
    ZmfRenderMatchAttitude          = 1,
    ZmfRenderMatchLight             = 2,
    /** 
     * JSON param:
     *  "timestamp":
     *     "action":"ResetEffect"
     */
    ZmfRenderMatchTimeStamp         = 3,
} ZmfRenderMatchType;

typedef enum {
    ZmfRenderView,
    ZmfRenderViewFx,
    ZmfRenderImmersive,
    ZmfRenderImmersiveFx
} ZmfRenderType;

/**
 * @brief Built-in Capture Effect.
 */
typedef int ZmfCaptureEffectType;
enum {
    ZmfCaptureEffectNone             = 0, /**< @brief none effect. */
    ZmfCaptureSmartExposure          = 1,
    ZmfCaptureGammaCorrection        = 2,
    ZmfCaptureContrastEnhance        = 4,
};

/**
 * @brief Video source type.
 */
typedef enum {
    ZmfVideoSourcePeer              = 0, /**< @brief Image is from peer. */
    ZmfVideoSourceCapture           = 1, /**< @brief Image is from capture device. */
    ZmfVideoSourceFile              = 2, /**< @brief Image is from file. */
} ZmfVideoSourceType;

/**
 * @brief Video render mode.
 */
typedef enum {
    /**
     * @brief Auto selection mode.
     *
     * When the aspect of image and render area is matched, it act as 
     * @ref ZmfRenderFullScreen. Otherwise, it act as @ref ZmfRenderFullContent.
     *
     * When matched, it means both aspect ratio of image and render area is 
     * larger than 1.0 or smaller than 1.0.
     */
    ZmfRenderAuto                   = 0,

    /**
     * @brief Scale image to fill the entire render area, and remain the aspect
     * ratio unchanged.
     */
    ZmfRenderFullScreen             = 1,

    /**
     * @brief Scale image to display all content in render area, and remain the
     * aspect ratio unchanged.
     */
    ZmfRenderFullContent            = 2,
} ZmfRenderMode;

#ifdef __OBJC__

#import <UIKit/UIKit.h>
@interface ZmfView : UIView
@end

/**
 * @defgroup ZmfVideoDeviceId Video Device ID
 * @{
 */

/** @brief Capture device ID string for rear camera. */
extern const char * ZmfVideoCaptureBack;

/** @brief Capture device ID string for front camera. */
extern const char * ZmfVideoCaptureFront;

/**
 * @}
 */

/**
 * @defgroup ZmfVideoNotificationParameters Video Notification Parameters.
 * @{
 */

/**
 * @brief An NSString object containing a string that identifies
 * ID of video capture device.
 */
extern NSString * const ZmfCapture;

/**
 * @brief An NSNumber object containing an integer that identifies
 * the facing type of capture device.
 * For a list of possible values, @ref ZmfVideoFaceType.
 */
extern NSString * const ZmfFace;

/**
 * @brief An NSNumber object containing an integer that identifies
 * the width in pixel.
 */
extern NSString * const ZmfWidth;

/**
 * @brief An NSNumber object containing an integer that indentifies
 * the height in pixel.
 */
extern NSString * const ZmfHeight;

/**
 * @brief An NSString object containing an integer that indentifies
 * the render source.
 */
extern NSString * const ZmfRender;

/**
 * @brief An NSNumber object containing an integer that identifies
 * the render source type.
 * For a list of possible values, @ref ZmfVideoSourceType.
 */
extern NSString * const ZmfSourceType;

/**
 * @brief An NSNumber object containing an integer that indentifies
 * the handle of render window.
 */
extern NSString * const ZmfWindow;

/**
 * @brief An NSNumber object containing an integer that indentifies
 * the frame rate in fps.
 */
extern NSString * const ZmfFrameRate;

/**
 * @brief A NSString object containing a string that error description.
 * the format match 'camera <id>|render <id>|video: <reason>'.
 */
extern NSString * const ZmfVideoError;

/**
 * @brief An NSNumber object containing an integer that indentifies
 * the matching.
 */
extern NSString * const ZmfMatching;

/**
 * @}
 */

/**
 * @defgroup ZmfVideoNotifications Video Notifications.
 * @{
 */

/**
 * @brief Post when the ZMF module request to start capture video data.
 *
 * The userInfo dictionary of this notification contains @ref ZmfCapture,
 * @ref ZmfWidth, @ref ZmfHeight and @ref ZmfFrameRate, which provide detail 
 * information for the request.
 */
extern NSString * const ZmfVideoCaptureRequestStart;

/**
 * @brief Post when the ZMF module request to change capture video data.
 *
 * The userInfo dictionary of this notification contains @ref ZmfCapture,
 * @ref ZmfWidth, @ref ZmfHeight and @ref ZmfFrameRate, which provide detail 
 * information for the request.
 */
extern NSString * const ZmfVideoCaptureRequestChange;

/**
 * @brief Post when the ZMF module request to stop capture.
 *
 * The userInfo dictionary of this notification contains @ref ZmfCapture,
 * which provide detail information for the request.
 */
extern NSString * const ZmfVideoCaptureRequestStop;

/**
 * @brief Post when the ZMF module has received first video data after
 * @ref Zmf_VideoCaptureStart invoked.
 *
 * The userInfo dictionary of this notification contains @ref ZmfCapture,
 * @ref ZmfFace, @ref ZmfWidth, and @ref ZmfHeight, 
 * which indicate the actual parameters of the video data captured.
 */
extern NSString * const ZmfVideoCaptureDidStart;

/**
 * @brief Post when the ZMF module request to start rendering video data.
 *
 * The userInfo dictionary of this notification contains @ref ZmfRender.
 */
extern NSString * const ZmfVideoRenderRequestAdd;

/**
 * @brief Post when the ZMF module has received the first image after
 * @ref Zmf_VideoRenderAdd invoked.
 */
extern NSString * const ZmfVideoRenderDidReceive;

/**
 * @brief Post when the ZMF module has delivery the first image to render after
 * @ref Zmf_VideoRenderStart and  @ref Zmf_VideoRenderAdd invoked.
 */
extern NSString * const ZmfVideoRenderDidStart;

/**
 * @brief Post when the rendering image size has changed.
 *
 * The userInfo dictionary of this notification contains @ref ZmfRender,
 * @ref ZmfWindow, @ref ZmfWidth and @ref ZmfHeight.
 */
extern NSString * const ZmfVideoRenderDidResize;

/**
 * @brief Post when the ZMF module has stop rendering video data.
 *
 * The userInfo dictionary of this notification contains @ref ZmfRender,
 * @ref ZmfWindow.
 */
extern NSString * const ZmfVideoRenderRequestRemove;

/**
 * @brief Post when the ZMF module has matched rendering video data.
 *
 * The userInfo dictionary of this notification contains @ref ZmfRender,
 * @ref ZmfWindow, and @ref ZmfMatching
 */
extern NSString * const ZmfVideoRenderDidMatch;

/**
 * @}
 */

#endif /* __OBJC__ */

#ifdef _WIN32

/**
 * @brief Event number for video notifications.
 *
 * The wParam of the event is the type of notification.
 * For a list of possible values, @ref ZmfVideoEventType.
 *
 * The lParam of the event may contains the JSON object depend on the
 * type of notification.
 */
#define ZmfVideoEvent                   ZmfAudioEvent + 10

/**
 * @defgroup ZmfVideoNotificationParameters Video Notification Parameters.
 * @{
 */

/**
 * @brief A String object containing an string that identifies
 * ID of video capture device.
 */
#define ZmfCapture "Capture"

/**
 * @brief An Number object containing an integer that identifies
 * the facing type of capture device.
 * For a list of possible values, @ref ZmfVideoFaceType.
 */
#define ZmfFace "Face"

/**
 * @brief An Number object containing an integer that identifies
 * the width in pixel.
 */
#define ZmfWidth "Width"

/**
 * @brief An Number object containing an integer that identifies
 * the height in pixel.
 */
#define ZmfHeight "Height"

/**
 * @brief An String object containing a string that identifies
 * the unique render name.
 * 
 */
#define ZmfRender "Render"

/**
 * @brief An Number object containing an integer that identifies
 * the render source type.
 *
 * @ref ZmfVideoSourceType.
 */
#define ZmfSourceType "SourceType"

/**
 * @brief An Number object containing an integer that identifies
 * the handle of render window.
 */
#define ZmfWindow "Window"

/**
 * @brief An Number object containing an integer that identifies
 * the frame rate in fps.
 */
#define ZmfFrameRate "FrameRate"

/**
 * @brief A NSString object containing a string that error description.
 * the format match 'camera <id>|render <id>|video: <reason>'.
 */
#define ZmfVideoError "VideoError"

/**
 * @brief An NSNumber object containing an integer that indentifies
 * the matching.
 */
#define ZmfMatching "Matching"

/**
 * @}
 */

/**
 * @brief Type of video notifications.
 */
typedef enum  {
    /**
     * @brief Post when the ZMF module request to start capture video data.
     *
     * The lParam of this event is a JSON object contains @ref ZmfCapture,
     * @ref ZmfWidth, @ref ZmfHeight and @ref ZmfFrameRate, which provide detail 
     * information for the request.
     */
    ZmfVideoCaptureRequestStart         = 20,

    /**
     * @brief Post when the ZMF module request to change capture video data.
     *
     * The lParam of this event is a JSON object contains @ref ZmfCapture,
     * @ref ZmfWidth, @ref ZmfHeight and @ref ZmfFrameRate, which provide detail 
     * information for the request.
     */
    ZmfVideoCaptureRequestChange        = 30,

    /**
     * @brief Post when the ZMF module request to stop capture.
     *
     * The lParam of this event is a JSON object contains @ref ZmfCapture,
     * which provide detail information for the request.
     */
    ZmfVideoCaptureRequestStop          = 21,

    /**
     * @brief Post when the ZMF module has received first video data after
     * @ref Zmf_VideoCaptureStart invoked.
     *
     * The lParam of this event is a JSON object contains @ref ZmfCapture,
     * @ref ZmfFace, @ref ZmfWidth, and @ref ZmfHeight,
     * which indicate the actual parameters of the video data captured.
     */
    ZmfVideoCaptureDidStart            = 22,

    /**
     * @brief Post when the ZMF module request to start rendering video data.
     *
     * The lParam of this event is a JSON object contains @ref ZmfRender.
     */
    ZmfVideoRenderRequestAdd            = 25,

    /**
     * @brief Post when the ZMF module has received the first image after
     * @ref Zmf_VideoRenderAdd invoked.
     */
    ZmfVideoRenderDidReceive            = 26,

    /**
     * @brief Post when the first image has delivery to render after
     * @ref Zmf_VideoRenderStart and @ref Zmf_VideoRenderAdd invoked.
     */
    ZmfVideoRenderDidStart              = 27,

    /**
     * @brief Post when the rendering image size has changed.
     *
     * The lParam of this event is a JSON object contains @ref ZmfRender,
     * @ref ZmfWindow, @ref ZmfWidth and @ref ZmfHeight.
     */
    ZmfVideoRenderDidResize             = 28,

    /**
     * @brief Post when the ZMF module request to stop rendering video data.
     *
     * The lParam of this event is a JSON object contains @ref ZmfRender,
     * @ref ZmfWindow
     */
    ZmfVideoRenderRequestRemove         = 29,

    /** @brief Post when the ZMF Video module has an error occurred.
     *
     * The userInfo dictionary of this notification contains @ref ZmfVideoError
     */
    ZmfVideoErrorOccurred               = 31,


    /** @brief Post when the ZMF module render matching.
     *
     * The userInfo dictionary of this notification contains @ref ZmfRender,
     * @ref ZmfWindow, and @ref ZmfMatching
     */
    ZmfVideoRenderDidMatch              = 32,

} ZmfVideoEventType;

#endif /* _WIN32 */

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Get count of video capture device.
 * @return  The total count of video capture device.
 */
int Zmf_VideoCaptureGetCount (void);

/**
 * @brief Get the name of specific capture device.
 * @param  iIndex    The index of capture device, from 0 to count - 1.
 * @param  acId      Pointer the buffer contains unique name utf8 string.
 * @param  acName    Pointer the buffer contains friendly name utf8 string.
 * @return        0  on succeed, otherwise failed.
 */
int Zmf_VideoCaptureGetName (int iIndex, char acId[512], char acName[512]);

/**
 * @brief Get the face and angle of specific capture device.
 * @param  pcId      The ID of capture device.
 * @param  piFace    Capture device face @ref ZmfVideoFaceType
 * @param  piAngle   Capture device angle @ref ZmfRotationAngle
 * @return  orient angle >0 on succeed, otherwise failed.
 */
int Zmf_VideoCaptureGetOrient (const char *pcId, int *piFace, int *piAngle);

/**
 * @brief Start running video capture device.
 * @param  pcId       The ID of capture device.
 * @param  iWidth     The captured image width in pixel, 0 for auto selection.
 * @param  iHeight    The captured image height in pixel, 0 for auto selection.
 * @param  iFrameRate The captured frame rate in fps, 0 for auto selection.
 * @return          0 on succeed, otherwise failed.
 */
int Zmf_VideoCaptureStart (const char *pcId, int iWidth, int iHeight, int iFrameRate);

/**
 * @brief rotate the image from the capture device
 * @param  pcId       The ID of capture device.
 * @param  enAngle    The rotation angle, @ref ZmfRotationAngle.
 * @return       0 on succeed, otherwise failed.
 */
int Zmf_VideoCaptureRotate (const char *pcId, ZmfRotationAngle enAngle);


/**
 * @brief Set the effect type of specific capture.
 * @param  pcId       The ID of capture device.
 * @param  enEffectType  Effect type, @ref ZmfCaptureEffectType
 * @param  strJson  Effect param, json string
 * @return 0 on succeed, otherwise failed.
 */
int Zmf_VideoCaptureEffect (const char *pcId, ZmfCaptureEffectType enEffectType, const char* strJson);

/**
 * @brief Stop running video capture device.
 * @param  pcId      The ID of capture device.
 * @return  0        on succeed, otherwise failed.
 */
int Zmf_VideoCaptureStop (const char *pcId);

/**
 * @brief Stop all running video capture device.
 * @return  0 on succeed, otherwise failed.
 */
int Zmf_VideoCaptureStopAll (void);

/**
 * @brief Initialize resource and start render on specific window.
 * @param  pWnd   The handle of window to render on.
 * @return      0 on succeed, otherwise failed.
 */
int Zmf_VideoRenderStart (void *pWnd, ZmfRenderType enRenderType);

/**
 * @brief Stop render and destroy resource.
 * @param  pWnd The handle of window to render on.
 * @return    0 on succeed, otherwise failed.
 */
int Zmf_VideoRenderStop (void *pWnd);

/**
 * @brief Attach render source to specific window.
 * @param  pWnd    The handle of window to render on.
 * @param  renderId The render source notified by @ref ZmfVideoRenderRequestAdd.
 * @param  iOrder  The Z-Order value render source. It must assign different
 *                 value for each render source. Render with larger value
 *                 overlapped on render with smaller value.
 * @param  enMode  Render mode, @ref ZmfRenderMode.
 * @return       0 on succeed, otherwise failed.
 */
int Zmf_VideoRenderAdd (void *pWnd, const char* renderId, int iOrder, ZmfRenderMode enMode);

/**
 * @brief replace render oldRenderId with newRenderId
 * @param  pWnd    The handle of window to render on.
 * @param  oldRenderId The render id
 * @param  newRenderId
 */
int Zmf_VideoRenderReplace(void *pWnd, const char* oldRenderId, const char *newRenderId);

/**
 * @brief Detach render source from specific window.
 * @param  pWnd    The handle of window.
 * @param  renderId The render source.
 * @return       0 on succeed, otherwise failed.
 */
int Zmf_VideoRenderRemove (void *pWnd, const char* renderId);

/**
 * @brief Detach all render source from specific window.
 * @param  pWnd    The handle of window.
 * @return       0 on succeed, otherwise failed.
 */
int Zmf_VideoRenderRemoveAll(void *pWnd);

/**
 * @brief Move render area of specific render source.
 * 
 * The origin of coordination is the top left point of window.
 * X-axis positive direction is from left to right.
 * Y-axis positive direction is from top to bottom.
 * The valid range is from 0.0 to 1.0.
 * 
 * @param  pWnd    The handle of window.
 * @param  renderId The render source.
 * @param  fLeft   The X position of top left point of render area.
 *                 Default is 0.0.
 * @param  fTop    The Y position of top left point of render area.
 *                 Default is 0.0.
 * @param  fRight  The X position of right bottom point of render area.
 *                 Default is 1.0.
 * @param  fBottom The Y position of right bottom point of render area.
 *                 Default is 1.0.
 * @return       0 on succeed, otherwise failed.
 */
int Zmf_VideoRenderMove (void *pWnd, const char* renderId, float fLeft, float fTop,
                         float fRight, float fBottom);

/**
 * @brief Set the mirror type of specific render source.
 * @param  pWnd    The handle of window.
 * @param  renderId The render source.
 * @param  enType  Mirror type, @ref ZmfMirrorType
 * @return       0 on succeed, otherwise failed.
 */
int Zmf_VideoRenderMirror (void *pWnd, const char* renderId, ZmfMirrorType enType);


/**
 * @brief  Set whether continuously update or freeze of specific render source.
 * @param  pWnd     The handle of window.
 * @param  renderId The render source.
 * @param  bEnable  boolean value
 * @return        0 on succeed, otherwise failed.
 */
int Zmf_VideoRenderFreeze (void *pWnd, const char* renderId, int bEnable);

/**
 * @brief Set coordination rotation angle according to the coordination
 * of the window.
 * @param  pWnd    The handle of window.
 * @param  enAngle The rotation angle, @ref ZmfRotationAngle.
 * @return       0 on succeed, otherwise failed.
 */
int Zmf_VideoRenderRotate (void *pWnd, ZmfRotationAngle enAngle);

/**
 * @brief Set the effect type of specific render.
 * @param  pWnd    The handle of window.
 * @param  renderId The render source.
 * @param  enEffectType  Effect type, @ref ZmfRenderEffectType
 * @param  strJson  Effect param, json string
 * @return 0 on succeed, otherwise failed.
 */
int Zmf_VideoRenderEffect(void *pWnd, const char* renderId, ZmfRenderEffectType enEffectType, const char* strJson);

/**
 * @brief Set the match type of specific render.
 * @param  pWnd    The handle of window.
 * @param  renderId The render source.
 * @param  enMatchType  Effect type, @ref ZmfRenderEffectType
 * @param  strJson  Effect param, json string
 * @return 0 on succeed, otherwise failed.
 */
int Zmf_VideoRenderMatch(void *pWnd, const char* renderId, ZmfRenderMatchType enMatchType, const char* strJson);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __ZMF_VIDEO_H__ */

