#ifndef __ZMF_EXT_H__
#define __ZMF_EXT_H__
#ifdef __cplusplus
extern "C" {
#endif

/**
 * The pixel format supported by ZMF
 */
typedef enum {
    ZmfPixelFormatI420              = 1,
    ZmfPixelFormatIYUV              = 2,
    ZmfPixelFormatRGB24             = 3,
    ZmfPixelFormatABGR              = 4,
    ZmfPixelFormatARGB              = 5,
    ZmfPixelFormatARGB4444          = 6,
    ZmfPixelFormatRGB565            = 7,
    ZmfPixelFormatARGB1555          = 8,
    ZmfPixelFormatYUY2              = 9,
    ZmfPixelFormatYV12              = 10,
    ZmfPixelFormatUYVY              = 11,
    ZmfPixelFormatMJPG              = 12,
    ZmfPixelFormatNV21              = 13,
    ZmfPixelFormatNV12              = 14,
    ZmfPixelFormatBGRA              = 15
} ZmfPixelFormatType;

/** the callback to receive captured image
 * @param[in] pUser   the user data registered by Zmf_VideoCaptureAddCallback
 * @param[in] iFace   the capture Face
 * @param[in] iImgAngle the image rotated angle (CW)
 * @param[in] iCamOrient the camera fixed orient
 * @param[in] iWidth  the image width
 * @param[in] iHeight the image height
 * @param[in] buf     the image data buffer
 * @param[in] len     the image data length
 */
typedef void (*ZmfVideoCaptureCallback)(void* pUser, const char* captureId, int iType, 
                                        int iImgAngle, int iCamOrient, int iWidth, int iHeight,
                                        const unsigned char *buf);

/**
 * The callback to receive video render data 
 *
 * @param[in] pUser         the user data registered by Zmf_AddVideoRenderCallback
 * @param[in] renderId      video render unique name
 * @param[in] sourceType    video render source type @see ZmfVideoSourceType
 * @param[in] iAngle        
 * @param[in] iMirror 
 * @param[in] iWidth
 * @param[in] iHeight
 * @param[in] buf           I420 render data
 *
 * @return                  if process render data should return > 0, other 0
 *
 * @remarks
 *  if buf == 0 or iWidth <=0 or iHeight <= 0, means the render will close,
 *  so should call Zmf_OnVideoRenderRequestRemove.
 */
typedef int  (*ZmfVideoRenderCallback)(void* pUser, const char* renderId, int sourceType, int iAngle,
                                       int iMirror, int iWidth, int iHeight, const unsigned char *buf,
                                       unsigned long timeStamp);

/**
 * The Event Callback
 *
 */
typedef void (*ZmfEventListenCallback) (int iEventType, const char *json);


/**
 * The sensor data input data entry to ZMF
 *
 */
void Zmf_OnSensorData       (const ZmfSensorData *sensor);

/**
 * The audio input data entry to ZMF
 *
 * @param[in] inputId       unique name of the audio input
 * @param[in] sampleRateHz  the sample rating of the pcm data
 * @param[in] iChannels     the channel number of the pcm data
 * @param[in] buf           the pcm data
 * @param[in] len           the pcm data length
 * @param[in,out] micLevel  
 * @param[in] playDelayMS
 * @param[in] recDelayMS
 * @param[in] clockDrift
 *
 */
void Zmf_OnAudioInput       (const char *inputId, int sampleRateHz, int iChannels,  const unsigned char *buf, int len,
                             int *micLevel, int playDelayMS, int recDelayMS, int clockDrift);

/**
 * The outlet which audio output can get data from.
 *
 * @param[in] outputId      unique name of the audio output
 * @param[in] sampleRateHz  the sample rating of the pcm data
 * @param[in] iChannels     the channel number of the pcm data
 * @param[in] buf           the pcm data to be filled
 * @param[in] len           the pcm data length
 */
void Zmf_OnAudioOutput      (const char *outputId, int sampleRateHz, int iChannels, unsigned char *buf, int len);

/**
 * The video capture data entry to ZMF
 *
 * @param[in] captureId     unique name of the video capture
 * @param[in] iFace         the capture face, @see ZmfVideoFaceType
 * @param[in] iImgAngle     the image rotated angle (CW)
 * @param[in] iCamOrient    the camera fixed orient
 * @param[in] iWidth        the image width
 * @param[in] iHeight       the image height
 * @param[in] buf           the image data I420 buffer
 */
void Zmf_OnVideoCapture     (const char *captureId, int iFace, int iImgAngle, int iCamAngle,
                             int iWidth, int iHeight, unsigned char *bufI420);

/**
 * The video render data entry to ZMF
 *
 * @param[in] renderId      unique name of the video render source
 * @param[in] sourceType    the render source type, @see ZmfVideoSourceType
 * @param[in] iAngle        the image rotated angle (CW)ZmfVideoCaptureCallback
 * @param[in] iWidth        the image width
 * @param[in] iHeight       the image height
 * @param[in] buf           the image data I420 buffer
 */
void Zmf_OnVideoRender      (const char *renderId, int sourceType, int iAngle, int iMirror,
                             int iWidth, int iHeight, unsigned char *bufI420, unsigned long timeStamp);

/**
 * add video capture data callback
 *
 * @param[in] pUser         the callback user data
 * @param[in] pfnCb         the callback
 *
 * @return                  0 on succeed, otherwise failed.
 */
int  Zmf_VideoCaptureAddCallback    (void *pUser, ZmfVideoCaptureCallback pfnCb);

/**
 * remove video capture data callback
 *
 * @param[in]  pUser        the callback user data
 *
 * @return                  0 on succeed, otherwise failed.
 */
int  Zmf_VideoCaptureRemoveCallback (void *pUser);

/**
 * add render data callback
 *
 * @param[in] pUser         the callback user data
 * @param[in] pfnCb         the callback
 *
 * @return                  0 on succeed, otherwise failed.
 */
int  Zmf_VideoRenderAddCallback     (void *pUser, ZmfVideoRenderCallback pfnCb);

/**
 * remove render data callback
 *
 * @param[in]  pUser        the callback user data
 *
 * @return                  0 on succeed, otherwise failed.
 */
int  Zmf_VideoRenderRemoveCallback  (void *pUser);

/**
 * utility for convert pixel from I420
 *
 * @param[in] dstFrame      the buffer to save the convert result
 * @param[in] dstFormat     the convert result pixel format
 * @param[in] srcFrame      the source I420 buffer
 * @param[in] srcWidth      the width of image
 * @param[in] srcHeight     the height of image
 *
 * @return                  0 on succeed, otherwise failed.
 */
int  Zmf_ConvertFromI420 (void* dstFrame, int dstFormat,
                          const void* srcFrame, int srcWidth, int srcHeight);

/**
 * utility for convert pixel to I420
 *
 * @param[in] dstFrame      the I420 buffer to save the convert result
 * @param[in] dstFormat     the convert result pixel format
 * @param[in] srcFrame      the source buffer
 * @param[in] srcWidth      the width of image
 * @param[in] srcHeight     the height of image
 * @param[in] rotateAngle   the clockwise rotation angle
 *
 * @return                  0 on succeed, otherwise failed.
 */
int  Zmf_ConvertToI420(void* dstframe,
                       int srcFormat, const void* srcFrame, unsigned srcBufLen,
		               int srcWidth, int srcHeight,int crop_x, int crop_y,
		               int dstWidth, int dstHeight, int rotateAngle);

int  Zmf_ScaleI420(void* srcframe, int srcWidth, int srcHeight,
		           void* dstframe, int dstWidth, int dstHeight);
/**
 * trigger ZmfVideoRenderDidReceive event
 *
 * @param[in] renderId      unique name of the render
 * @param[in] hWnd          the window which the render has been added
 * @param[in] iWidth        the width of image
 * @param[in] iHeight       the height of image
 */
void Zmf_OnVideoRenderDidReceived  (const char *renderId, void* hWnd, int iWidth, int iHeight);

/**
 * trigger ZmfVideoRenderDidResize event
 *
 * @param[in] renderId      unique name of the render
 * @param[in] hWnd          the window which the render has been added
 * @param[in] iWidth        the new width of image
 * @param[in] iHeight       the new height of image
 */
void Zmf_OnVideoRenderDidResized   (const char *renderId, void* hWnd, int iWidth, int iHeight);

/**
 * trigger ZmfVideoRenderDidStart event
 *
 * @param[in] renderId      unique name of the render
 * @param[in] hWnd          the window which the render has been added
 */
void Zmf_OnVideoRenderDidStarted   (const char *renderId, void* hWnd, int iWidth, int iHeight);

/**
 * trigger ZmfVideoRenderRequestRemove event
 *
 * @param[in] renderId      unique name of the render
 * @param[in] hWnd          the window which the render has been added
 */
void Zmf_OnVideoRenderRequestRemove(const char *renderId, void* hWnd);

/**
 * trigger ZmfVideoRenderDidMatch event
 *
 * @param[in] renderId      unique name of the render
 * @param[in] hWnd          the window which the render has been added
 * @param[in] matching      the percent of mathcing
 */
void Zmf_OnVideoRenderDidMatch (const char *provideId, void* hWnd, int matching);

/**
 * tell ZMF the video capture has stopped
 * 
 * @param[in] captureId     unique name of the device
 */
void Zmf_OnVideoCaptureDidStop     (const char *captureId);

/**
 * tell ZMF the audio output has stopped
 *
 * @param[in] outputId      unique name of the device
 */
void Zmf_OnAudioOutputDidStop      (const char *outputId);

/**
 * tell ZMF the audio input has stopped
 *
 * @param[in] inputId       unique name of the device
 */
void Zmf_OnAudioInputDidStop       (const char *inputId);


/**
 * The converter to transform the video render data at rendering
 *
 */
typedef void (*ZmfVideoRenderFilter)(const char* renderId, int sourceType, int iAngle,
                                     int iMirror, int *iWidth, int *iHeight, unsigned char *srcI420);

/**
 * The converter to transform the video capture data at capturing
 *
 */

typedef void (*ZmfVideoCaptureFilter)(const char* captureId, int iFace, int iImgAngle,
                                      int iCamAngle, int *iWidth, int *iHeight, unsigned char *bufI420);
/**
 * set ZMF the render filter
 *
 */
int Zmf_VideoRenderFilter (ZmfVideoRenderFilter filter);


/**
 * set ZMF the capture filter
 *
 */
int Zmf_VideoCaptureFilter (ZmfVideoCaptureFilter filter);


/**
 * Set Audio Event Callback
 */
int Zmf_AudioSetListener   (ZmfEventListenCallback pfnAudioListen);

/**
* Set Video Event Callback
*/
int Zmf_VideoSetListener   (ZmfEventListenCallback pfnVideoListen);

/** Font layout info */
typedef struct {
    unsigned        shadowRGBA;
    float           shadowBlurRadius;
    float           shadowOffsetX, shadowOffsetY;
    unsigned        outlineRGBA;
    float           outlineWidth;
    unsigned        fontRGBA;
    float           fontSize;
    unsigned        boundingWidth;
    float           scale;
    char            fontName[1024];
} ZmfFontLayout;

/** I420 Buffer */
typedef struct _ZmfI420Stencil {
    unsigned char   *bufI420;
    unsigned        width, height;
} ZmfI420Stencil;

/**
 * alloc I420 buffer
 *
 * @param[in] str   string
 * @param[in] info  layout info
 * @return I420 buffer
 */
ZmfI420Stencil* Zmf_I420StencilFromString(const char*str, ZmfFontLayout* info);

/**
 * delete I420 buffer
 */
void Zmf_I420StencilDelete(ZmfI420Stencil *stencil);

/**
 * blend I420
 *
 * @param[in] aligns Alignment @ref ZmfAlignmentType
 */
int Zmf_I420StencilBlend(const ZmfI420Stencil*stencil, unsigned dstX, unsigned dstY, unsigned char *dstI420, unsigned dstW, unsigned dstH);

typedef struct {
    int     tracePosition; 
    int     traceDirection;
    int     framePosition;
    int     frameDirection;
    int     progress;
    char    debugInfo[512];
    unsigned waiting;
} ZmfTraceVideoStatus;

typedef void (*ZmfTraceVideoCallback)(void* pUser, const ZmfTraceVideoStatus *status);

/**
 * record trace video
 *
 * @param[in] filePath
 * @param[in] json
 * @return the trace handle
 */
void* Zmf_TraceVideoRecord(const char* filePath, const char* json);

/* playback trace video
 *
 * @param[in] filePath
 * @param[in] json
 * @return the trace handle
 */
void* Zmf_TraceVideoPlayback(const char* filePath, ZmfTraceVideoCallback callback, void* user_data);

/**
 * delete trace video
 *
 * @param[in] handle The trace handle
 * @return 0 on succeed, otherwise failed.
 */
int Zmf_TraceVideoStop (void* handle);

/**
 * convert to mjpeg file
 *
 * @param[out] progress
 * @return 0 on succeed, otherwise failed.
 */
int  Zmf_TraceVideoConvert(const char* filePath, const char* mjpgPath, int *progress);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif
