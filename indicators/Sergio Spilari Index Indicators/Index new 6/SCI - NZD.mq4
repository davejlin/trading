//+----------------------------------------------------------------------+
//|                                         Stochastic Channel Index.mq4 |
//|                                                         David J. Lin |
//| Stochastic Channel Index                                             |
//|                                                                      |
//| Coded for Sérgio Spilari Filho <sergio@ssfconsultoriafinanceira.com> |
//| Coded by David J. Lin (dave.j.lin@gmail.com)                         |
//| Evanston, IL, May 26, 2013                                           |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2013,  Sérgio Spilari Filho and David J. Lin"

#include "Utilities SCI/SCI Main Header.mqh"

#property indicator_color1 DarkGreen          // Stoch 80
#property indicator_color2 DarkGreen          // Stoch L_50
#property indicator_color3 DarkGreen          // Stoch 20
#property indicator_color4 Gold               // Stoch Main
#property indicator_color5 DeepSkyBlue        // Index MA1
#property indicator_color6 PaleVioletRed      // Index MA2

#property indicator_style1 STYLE_SOLID        // Stoch 80
#property indicator_style2 STYLE_DOT          // Stoch L_50
#property indicator_style3 STYLE_SOLID        // Stoch 20
#property indicator_style4 STYLE_SOLID        // Stoch Main
#property indicator_style5 STYLE_DASH         // Index MA1
#property indicator_style6 STYLE_DOT          // Index MA2

//---- parameters
extern string Identifier       = "NZD";
extern int    maxBars          = 1500;

extern int KPeriod    = 14;
extern int DPeriod    =  3;
extern int Slowing    =  3;
extern int maPeriod   = 14;
extern int maMethod   =  1;
extern int maPrice    =  0;
extern double L_overBought1 = 76.4;//80
extern double L_50          = 50.0;
extern double L_overSold1   = 23.6;//20
 
extern int    ShortTermMAperiod = 20;
extern int    ShortTermMAmethod = MODE_SMA;
extern int    LongTermMAperiod  = 40;
extern int    LongTermMAmethod  = MODE_SMA;

extern bool   ShowBars          = true;
extern bool   ShowStochAndBands = false;
extern color  colorBarDown      = Red;
extern color  colorBarUp        = Green;
extern color  colorBarNeutral   = DimGray;
extern color  colorWickUp       = Blue;
extern color  colorWickDown     = Red;
extern color  colorWickNeutral  = DimGray;
extern int    widthWick         = 1;
extern int    widthBody         = 3;

#include "Utilities SCI/SCI Main Body.mqh"