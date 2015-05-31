#ifndef __ZMF_CODEC_H__
#define __ZMF_CODEC_H__

/**
 * @file zmf_codec.h
 * @brief ZMF codec interfaces
 */

#ifdef __cplusplus
extern "C" {
#endif
/**
 * @brief Parameters of video codec.
 */

typedef struct {
    /* 'Base','Main', 'Extd', 'High' */
    char                    cProfile[4];
    /* '10','1b','11','12',...,'51' */
    char                    cLevel[2];
    char                    bErrorConcealOn;
    char                    bSmallNalu;
} ZmfVideoCodecH264;

typedef struct {
    char                    bPictureLossIndicationOn;
    char                    feedbackModeOn;
    char                    bErrorConcealOn;
} ZmfVideoCodecVP8;

typedef union {
    ZmfVideoCodecH264       H264;
    ZmfVideoCodecVP8        VP8;
} ZmfVideoCodecSpecific;

typedef struct {
    /* video settings */
    unsigned                width;
    unsigned                height;
    unsigned                startBitrate;
    unsigned                maxBitrate;
    unsigned                minBitrate;
    unsigned                maxFramerate;
    ZmfVideoCodecSpecific   codecSpecific;
} ZmfVideoCodec;
/**
 * @}
 */

/**
 * @brief Parameters of audio codec.
 */

typedef struct {
    unsigned                bandMode;
} ZmfAudioCodecAMR;

typedef union {
    ZmfAudioCodecAMR        AMR;
} ZmfAudioCodecSpecific;

typedef struct {
    unsigned                sampleRate;
    ZmfAudioCodecSpecific   codecSpecific;
} ZmfAudioCodec;
/**
 * @}
 */

typedef union {
    ZmfVideoCodec           video;
    ZmfAudioCodec           audio;
} ZmfCodec;

typedef enum {
    ZmfCodecNextKeyFrame,
    ZmfCodecBitrate,
    ZmfCodecFramerate,
    ZmfAmrBandMode,
    /* optional */
    ZmfCodecWidth,
    ZmfCodecHeight,
    ZmfCodecPacketLoss,
    ZmfCodecRtt,
} ZmfCodecKey;

typedef enum {
    ZmfEncoderH264,
    ZmfDecoderH264,
    ZmfEncoderAmrWb,
    ZmfDecoderAmrWb,
    ZmfEncoderAmr,
    ZmfDecoderAmr,
    ZmfEncoderVP8,
    ZmfDecoderVP8,
} ZmfCodecType;

typedef void (*ZmfCodecOut)(void* user_data, const char* buf, unsigned length, void* cookie);

/**
 * @brief Type of Codec class.
 */
typedef struct {
    /**
     * @brief Create new codec instance
     * @param callback The codec receive callback
     * @param user_data The callback user data
     * @return  0  on succeed, otherwise failed.
     */
    void* (*codecNew)(ZmfCodecType codecType, ZmfCodecOut callback, void* user_data);

    /**
     * @brief execute codec instance
     * @param handle  The codec instance pointer.
     * @param in      The source data pointer. 
     * @param in_len  The byte count of in
     * @return  0  on succeed, otherwise failed.
     */
    int (*codecDo)(void *handle, void* in, unsigned in_len, void* cookie);

    /**
     * @brief reset codec instance
     * @param handle  The codec instance pointer.
     * @param settings The codec settings parameters. 
     * @return  0  on succeed, otherwise failed.
     */
    int (*codecReset)(void *handle, ZmfCodec* settings);

    /**
     * @brief set codec dynamic parameters.
     * @param handle    The codec instance pointer.
     * @param key       The name of parameters @ref ZmfCodecKey
     * @param value     The value of parameters. 
     * @param value_size  The bytes of value 
     * @return  0  on succeed, otherwise failed.
     */
    int (*codecSet)(void *handle, ZmfCodecKey key, const void *value, int value_size);

    /**
     * @brief get codec dynamic parameters, is optional.
     * @param handle    The codec instance pointer.
     * @param key       The name of parameters @ref ZmfCodecKey
     * @param value     The value of parameters. 
     * @param value_size  The bytes of value 
     * @return  0  on succeed, otherwise failed.
     */
    int (*codecGet)(void *handle, ZmfCodecKey key, void *value, int value_size);

    /**
     * @brief delete codec instance.
     * @param handle    The codec instance pointer.
     * @return  0  on succeed, otherwise failed.
     */
    int (*codecDelete)(void *handle);
} ZmfCodecClass;
/**
 * @}
 */

/**
 * @brief register external Codec 
 * @param  codecType        The codec type, @ref ZmfCodecType.
 * @param  ZmfCodecClass    The codec class @ref ZmfCodecClass.
 * @return  0  on succeed, otherwise failed.
 */
int Zmf_CodecRegister(ZmfCodecType codecType, ZmfCodecClass klass);


/**
 * @brief get Codec 
 * @param  codecType        The codec type, @ref ZmfCodecType.
 * @param  ZmfCodecClass    The codec class @ref ZmfCodecClass.
 * @return  0  on succeed, otherwise failed.
 */
int Zmf_GetCodecClass(int codecType, ZmfCodecClass*klass);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif
