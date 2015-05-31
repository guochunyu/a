#ifndef __ZMF_H__
#define __ZMF_H__

#define __ZMF_API__             1
#define __ZMF_VERSION__         "5ea9dbea"
#define __ZMF_LOCAL_MODIFIED__  0

#if __ZMF_LOCAL_MODIFIED__
#ifdef _WIN32
#pragma message ("Warning: Not all files has been commit to the repository.")
#else
#warning Not all files has been commit to the repository!
#endif
#endif

#include "zmf_audio.h"
#include "zmf_video.h"
#include "zmf_sensor.h"
#include "zmf_codec.h"
#include "zmf_ext.h"

#ifdef __cplusplus
extern "C" {
#endif
/** @brief Get ZMF version string. */
const char* Zmf_GetVersion();

/** @brief Get ZMF API Level */
int Zmf_GetApiLevel();

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __ZMF_H__ */
