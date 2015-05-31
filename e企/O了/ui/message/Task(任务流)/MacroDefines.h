//
//  MacroDefines.h
//  e企
//
//  Created by zw on 4/20/15.
//  Copyright (c) 2015 QYB. All rights reserved.
//

#ifndef e__MacroDefines_h
#define e__MacroDefines_h

#define ScreenWidth [UIScreen  mainScreen].bounds.size.width
#define ScreenHeight ([UIScreen mainScreen].bounds.size.height-64)

//RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//RGB color macro with alpha
#define UIColorFromRGBWithAlpha(rgbValue,a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#define RGB(r,g,b,a)  [UIColor colorWithRed:(double)r/255.0f green:(double)g/255.0f blue:(double)b/255.0f alpha:a]

#define LineBgColor RGB(219, 220, 221, 1)


#define USER_ID   [[NSUserDefaults standardUserDefaults] objectForKey:MOBILEPHONE]
#define ORG_ID    [[NSUserDefaults standardUserDefaults] objectForKey:myGID]
#endif
