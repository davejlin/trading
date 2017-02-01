//+------------------------------------------------------------------+
//|                                              SCI Data Header.mq4 |
//|                                   Copyright © 2013, David J. Lin |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, David J. Lin"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 7

extern int    ShortTermMAperiod = 20;
extern int    ShortTermMAmethod = MODE_SMA;
extern int    LongTermMAperiod  = 40;
extern int    LongTermMAmethod  = MODE_SMA;

double IndexClose[];
double IndexHigh[];
double IndexLow[];
double IndexOpen[];
double IndexVolume[];
double IndexMa1[];
double IndexMa2[];

