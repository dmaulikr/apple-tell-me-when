#pragma once

#define TMWHasBigScreen             (MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) > 320)
#define TMWColorConverter(rgbValue)  {                  \
    ( (float)( (rgbValue & 0xFF0000) >> 16) ) / 255.0f, \
    ( (float)( (rgbValue & 0xFF00) >> 8) ) / 255.0f,    \
    ( (float)(rgbValue & 0xFF) ) / 255.0f,              \
    1.0f }

#define TMWFont_NewJuneBook             @"NewJuneBook"
#define TMWFont_NewJuneBold             @"NewJuneBold"

#define TMWCntrl_UpperLineColor        [UIColor colorWithWhite:0.65 alpha:0.15]
#define TMWCntrl_BottomLineColor       [UIColor colorWithWhite:0.2 alpha:0.65]
#define TMWCntrl_LineHeight            1
#define TMWCntrl_EndRefreshingDelay    0.36
#define TMWCntrl_RowAdditionAnimation  UITableViewRowAnimationLeft
#define TMWCntrl_RowDeletionAnimation  UITableViewRowAnimationLeft
