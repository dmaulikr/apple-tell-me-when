#pragma once

#define TMWColorConverter(rgbValue)  {                  \
    ( (float)( (rgbValue & 0xFF0000) >> 16) ) / 255.0f, \
    ( (float)( (rgbValue & 0xFF00) >> 8) ) / 255.0f,    \
    ( (float)(rgbValue & 0xFF) ) / 255.0f,              \
    1.0f }

#define TMWFont_NewJuneBook             @"NewJuneBook"
#define TMWFont_NewJuneBold             @"NewJuneBold"
