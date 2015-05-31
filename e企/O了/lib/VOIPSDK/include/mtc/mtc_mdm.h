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
  File name     : mtc_mdm.h
  Module        : multimedia talk client interface that using mdm
  Author        : sdk team
  Created on    : 2015-01-21
  Description   :
    Function implement required by mtc.

  Modify History:
  1. Date:        Author:         Modification:
*************************************************/

#ifndef _MTC_MDM_H__
#define _MTC_MDM_H__

/**
 * @file mtc_mdm.h
 * @brief MTC Multiple Device Management Interface Functions
 *
 * This file includes MDM interface function.
 */

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Download mmp file.
 *
 * @retval ZOK Download mmp file successfully.
 * @retval ZFAILED Download mmp file failed.
 */
MTCFUNC ZINT Mtc_MdmDownloadMmp(ZFUNC_VOID);

/**
 * @brief MTC get mmp version.
 *
 * @return mmp version.
 */
MTCFUNC ZINT Mtc_MdmGetMmpVersion();

/**
 * @brief Set video Adaptive negotiation bitrate mode.
 *
 * @param [in] iMode Adaptive negotiation bitrate mode @ref EN_MTC_AN_MODE.
 *
 * @retval ZOK on successfully.
 * @retval ZFAILED on failed.
 *
 * @see Mtc_MdmAnGetBitrateMode
 */
MTCFUNC ZINT Mtc_MdmAnSetBitrateMode(ZUINT iMode);

/**
 * @brief Get adaptive negotiation bitrate mode.
 *
 * @retval return adaptive negotiation bitrate mode, see @ref EN_MTC_AN_MODE.
 *
 */
MTCFUNC ZUINT Mtc_MdmAnGetBitrateMode(ZFUNC_VOID);

/**
 * @brief Set adaptive negotiation resolution.
 * @param  iWidth  Width in pixel, 0 to disable.
 * @param  iHeight Height in pixel, 0 to disable.
 * @return         ZOK on sucessfully.
 */
MTCFUNC ZINT Mtc_MdmAnSetResolution(ZUINT iWidth, ZUINT iHeight);

/**
 * @brief Get recommand max volume in percentage.
 * @return Max volume in percentage.
 */
MTCFUNC ZUINT Mtc_MdmAnGetMaxVol(ZFUNC_VOID);

/**
 * @brief Get MDM score.
 * @return The MDM score value.
 */
MTCFUNC ZFLOAT Mtc_MdmGetScore(ZFUNC_VOID);

/**
 * @brief Get android audiomanager mode.
 */
MTCFUNC ZINT Mtc_MdmGetAndroidAudioMode(ZFUNC_VOID);

/**
 * @brief Get android input device name.
 *
 * @return String of input device name.
 */
MTCFUNC ZCONST ZCHAR * Mtc_MdmGetAndroidAudioInputDevice(ZFUNC_VOID);

/**
 * @brief Get android output device name.
 *
 * @return String of output device name.
 */
MTCFUNC ZCONST ZCHAR * Mtc_MdmGetAndroidAudioOutputDevice(ZFUNC_VOID);

/**
 * @brief Get capture parameters
 */
MTCFUNC ZINT Mtc_MdmGetCaptureParms(ZUINT *piWidth, ZUINT *piHeight,
                ZUINT *piFrameRate);

/**
 * @brief Get OS AEC config.
 */
MTCFUNC ZBOOL Mtc_MdmGetOsAec(ZFUNC_VOID);

/**
 * @brief Get OS AGC config.
 */
MTCFUNC ZBOOL Mtc_MdmGetOsAgc(ZFUNC_VOID);

#ifdef __cplusplus
}
#endif

#endif /* _MTC_MDM_H__ */

