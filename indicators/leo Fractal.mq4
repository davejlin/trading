//+----------------------------------------------------------------------+
//|                                                      leo Fractal.mq4 |
//|                                                         David J. Lin |
//| added custom filters by Leo Lepore                                   |
//| (forexleo@yahoo.com)                                                 |
//|                                                                      |
//| Coded by David J. Lin (dave.j.lin@sbcglobal.net)                     |
//| Evanston, IL, January 28, 2010                                       |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2009, Leo Lepore & David J. Lin"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 LawnGreen
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Blue
#property indicator_color5 Orange
#property indicator_color6 Red
#property indicator_color7 LawnGreen

extern bool LongAlert=true;
extern bool ShortAlert=true;
extern bool GreenRedFilter=true;   // true = use MA angle indicator (green/red signals)
extern bool MAOrderFilter=true;    // true = use MA order filter (10, 21, 50 MA must be in correct order) 
extern bool PipCrossFilter=true;   // true = use entry filter to limit pips from last fast/medium MA cross, false = don't use this entry filter
extern int PipCrossPips=50;         // pips from last fast/medium MA cross to filter entries (applies if PipCrossFilter=true)

int gi_76 = 67890;
extern int YourAccountNumber = 12345;
bool gi_84 = FALSE;
int gi_88 = 12;
int gi_92 = 31;
int gi_96 = 2008;
extern bool Alert_SoundON = TRUE;
extern bool EmailON = FALSE;
extern bool ShowTradeArrowsOnly = TRUE;
extern bool ShowBuySellLines = TRUE;
extern bool ShowBadTradeExits = TRUE;
extern bool ShowFibProfitTargets = TRUE;
extern int MA_Period = 50;
extern string m = "--Moving Average Types--";
extern string m0 = " 0 = SMA";
extern string m1 = " 1 = EMA";
extern string m2 = " 2 = SMMA";
extern string m3 = " 3 = LWMA";
extern int MA_Type = 0;
extern string p = "--Applied Price Types--";
extern string p0 = " 0 = close";
extern string p1 = " 1 = open";
extern string p2 = " 2 = high";
extern string p3 = " 3 = low";
extern string p4 = " 4 = median(high+low)/2";
extern string p5 = " 5 = typical(high+low+close)/3";
extern string p6 = " 6 = weighted(high+low+close+close)/4";
extern int MA_AppliedPrice = 4;
extern double AngleTreshold = 0.25;
extern int PrevMAShift = 2;
extern int CurMAShift = 0;
int g_ma_method_256 = MODE_SMA;
bool gi_260 = TRUE;
bool gi_264 = TRUE;
extern string pg0 = "Bad Trade Exits";
extern string pg = "Price Gap inputs";
extern int PriceGapMN = 100;
extern int PriceGapW1 = 60;
extern int PriceGapD1 = 40;
extern int PriceGapH4 = 25;
extern int PriceGapH1 = 20;
extern int PriceGapM30 = 15;
extern int PriceGapM15 = 10;
extern int PriceGapM5 = 5;
extern int PriceGapM1 = 3;
extern string fp = "Face Position";
extern int FacePosMN = 80;
extern int FacePosW1 = 60;
extern int FacePosD1 = 48;
extern int FacePosH4 = 24;
extern int FacePosH1 = 16;
extern int FacePosM30 = 10;
extern int FacePosM15 = 8;
extern int FacePosM5 = 4;
extern int FacePosM1 = 4;
extern string tp12 = "Fib Retrace Inputs";
extern int BarsBack = 10;
extern double FibRetraceTrade1 = 100.0;
extern double FibRetraceTrade2 = 161.8;
extern double FibRetraceTrade3 = 261.8;
extern bool AddSpreadToTargets = TRUE;
extern string ap = "Arrow Position";
extern int Arrow_Position = 5;
extern string to = "---Text Object Settings---";
extern int Text_X_Offset = 20;
extern int StatusTxtSize = 10;
extern color StatusColor = White;
extern int CommentTxtSize = 10;
extern color CommentColor = White;
extern color BuyLineColor = Aqua;
extern color SellLineColor = Yellow;
extern color Fib1Color = Pink;
extern color Fib2Color = Orange;
extern color Fib3Color = Red;
int g_datetime_464;
double g_ibuf_468[];
double g_ibuf_472[];
double g_ibuf_476[];
double g_ibuf_480[];
double g_ibuf_484[];
double g_ibuf_488[];
double g_ibuf_492[];
double gd_496;
double gd_504;
string gs_512 = "";
string gs_520;
string gs_528;
int g_datetime_536;
bool g_global_var_540;
bool g_global_var_544;
int gi_548;
int gi_552;
int gi_556;
string gs_560;
string gs_568;
string gs_576;
string gs_584 = "Steinitz Fractal Breakout Status";
int gi_592;
bool gi_596 = FALSE;
string gs_600 = "_SFBInd15_";
bool gi_608;
bool gi_612;
double gd_616;
double gd_624;
double g_ima_632;
double g_ima_640;
double gd_648;
double gd_656;
double gd_664;
double gd_672;
double g_ilow_680;
double g_ihigh_688;
double gd_696;
double gd_704;
double gd_712;
int g_time_720 = 0;
int g_time_724 = 0;
int g_time_728 = 0;
int gi_732 = 0;
int gi_736;
string g_var_name_740;
string g_var_name_748;
string g_var_name_756;
string g_var_name_764;
string g_var_name_772;
string g_var_name_780;
string g_var_name_788;
string g_var_name_796;
string g_var_name_804;
string g_var_name_812;
string g_var_name_820;
string g_var_name_828;
string g_var_name_836;
string g_var_name_844;
string g_var_name_852;
bool gi_860 = TRUE;

double PipCrossPoints;

int init() {

 if(StringFind(Symbol(),"JPY")>0) 
 {
  if(Digits==3)
  {
   PipCrossPoints=NormPoints(PipCrossPips*10);   
  }
  else
  {
   PipCrossPoints=NormPoints(PipCrossPips);           
  }  
 }
 else
 {
  if(Digits==5)
  { 
   PipCrossPoints=NormPoints(PipCrossPips*10);                 
  }
  else
  {
   PipCrossPoints=NormPoints(PipCrossPips);                  
  }  
 } 

   string ls_0;
   string ls_8;
   string ls_16;
   bool li_24;
   string l_name_36;
   SetIndexStyle(0, DRAW_ARROW, EMPTY);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, g_ibuf_468);
   SetIndexStyle(1, DRAW_ARROW, EMPTY);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, g_ibuf_472);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(2, g_ibuf_476);
   SetIndexStyle(3, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(3, g_ibuf_480);
   SetIndexStyle(4, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(4, g_ibuf_484);
   SetIndexStyle(5, DRAW_ARROW, EMPTY);
   SetIndexArrow(5, 76);
   SetIndexBuffer(5, g_ibuf_492);
   SetIndexStyle(6, DRAW_ARROW, EMPTY);
   SetIndexArrow(6, 76);
   SetIndexBuffer(6, g_ibuf_488);
   if (MA_Type >= 4) li_24 = FALSE;
   else li_24 = MA_Type;
   switch (li_24) {
   case 0:
      g_ma_method_256 = 0;
      ls_0 = "sma10";
      ls_8 = "sma21";
      ls_16 = "sma50";
      break;
   case 1:
      g_ma_method_256 = 1;
      ls_0 = "ema10";
      ls_8 = "ema21";
      ls_16 = "ema50";
      break;
   case 2:
      g_ma_method_256 = 2;
      ls_0 = "smma10";
      ls_8 = "smma21";
      ls_16 = "smma50";
      break;
   case 3:
      g_ma_method_256 = 3;
      ls_0 = "lwma10";
      ls_8 = "lwma21";
      ls_16 = "lwma50";
      break;
   default:
      g_ma_method_256 = 0;
      ls_0 = "sma10";
      ls_8 = "sma21";
      ls_16 = "sma50";
   }
   SetIndexLabel(2, ls_0);
   SetIndexLabel(3, ls_8);
   SetIndexLabel(4, ls_16);
   gd_496 = Get_mFactor();
   gi_596 = FALSE;
   ClearArrows();
   DeleteBadLabels();
   if (IsDemo() == TRUE) gi_596 = TRUE;
   if (gi_596 == FALSE) gi_596 = CheckAccountNumber();
   if (gi_596 == TRUE) {
      DeleteExistingLabels();
      SetupLabels();
      ClearLabels();
      gd_504 = SetPoint();
      g_global_var_540 = FALSE;
      g_global_var_544 = FALSE;
      OutputStatusToChart(gs_584 + " INITIALIZED SUCCESSFULLY");
      if (gi_84 == TRUE) OutputComment1ToChart("Expires on " + gi_88 + "/" + gi_92 + "/" + gi_96);
      else OutputComment1ToChart("No expiration");
   }
   if (CurMAShift >= PrevMAShift) {
      Print("Error: CurMAShift >= PrevMAShift");
      PrevMAShift = 6;
      CurMAShift = 0;
   }
   GetGlobalVars();
   DeleteFractObjects();
   DeleteBadLabels();
   int l_objs_total_32 = ObjectsTotal();
   for (int li_44 = 0; li_44 < l_objs_total_32; li_44++) {
      l_name_36 = ObjectName(li_44);
      Print(li_44, "Object name for object #", li_44, " is " + l_name_36);
   }
   return (0);
}

int deinit() {
   ClearLabels();
   DeleteExistingLabels();
   ClearArrows();
   DeleteFractObjects();
   return (0);
}

int FibRetracement(int ai_0, int ai_4) {
   int li_ret_16;
   int l_highest_8 = iHighest(NULL, 0, MODE_HIGH, BarsBack, ai_4);
   int l_lowest_12 = iLowest(NULL, 0, MODE_LOW, BarsBack, ai_4);
   g_ihigh_688 = iHigh(NULL, 0, l_highest_8);
   g_ilow_680 = iLow(NULL, 0, l_lowest_12);
   if (ai_0 == 0)
      if (g_ihigh_688 > g_ilow_680) li_ret_16 = MathFloor((g_ihigh_688 - g_ilow_680) / gd_504);
   if (ai_0 == 1)
      if (g_ilow_680 < g_ihigh_688) li_ret_16 = MathFloor((g_ihigh_688 - g_ilow_680) / gd_504);
   return (li_ret_16);
}

void FibLines(int ai_0, int ai_4) {
   int li_8 = MarketInfo(Symbol(), MODE_SPREAD);
   if (Digits == 3 || Digits == 5) li_8 /= 10;
   int li_12 = FibRetracement(ai_0, ai_4);
   if (ai_0 == 0) {
      gd_696 = g_ilow_680 + li_12 * FibRetraceTrade1 / 100.0 * gd_504;
      if (AddSpreadToTargets) gd_696 += li_8 * gd_504;
      SaveFib1(gd_696);
      gd_704 = g_ilow_680 + li_12 * FibRetraceTrade2 / 100.0 * gd_504;
      if (AddSpreadToTargets) gd_704 += li_8 * gd_504;
      SaveFib2(gd_704);
      gd_712 = g_ilow_680 + li_12 * FibRetraceTrade3 / 100.0 * gd_504;
      if (AddSpreadToTargets) gd_712 += li_8 * gd_504;
      SaveFib3(gd_712);
   }
   if (ai_0 == 1) {
      gd_696 = g_ihigh_688 - li_12 * FibRetraceTrade1 / 100.0 * gd_504;
      if (AddSpreadToTargets) gd_696 -= li_8 * gd_504;
      SaveFib1(gd_696);
      gd_704 = g_ihigh_688 - li_12 * FibRetraceTrade2 / 100.0 * gd_504;
      if (AddSpreadToTargets) gd_704 -= li_8 * gd_504;
      SaveFib2(gd_704);
      gd_712 = g_ihigh_688 - li_12 * FibRetraceTrade3 / 100.0 * gd_504;
      if (AddSpreadToTargets) gd_712 -= li_8 * gd_504;
      SaveFib3(gd_712);
   }
   RemoveLine("Fib1");
   RemoveLine("Fib2");
   RemoveLine("Fib3");
   DisplayLine("Fib1", gd_696, Fib1Color);
   DisplayLine("Fib2", gd_704, Fib2Color);
   DisplayLine("Fib3", gd_712, Fib3Color);
}

int start() {
   int li_8;
   int li_12;
   int li_16 = IndicatorCounted();
   DeleteBadLabels();
   if (gi_552 < 10) {
      SetupLabels();
      ClearLabels();
      DeleteExistingLabels();
      SetupLabels();
   }
   if (gi_596 == FALSE) return (0);
   gi_592 = CheckTradeFilters();
   if (gi_592 == 1) return (0);
   if (li_16 < 0) return (-1);
   if (li_16 > 0) li_16--;
   int li_0 = Bars - li_16;
   if (gi_860) {
      ClearArrows();
      gi_860 = FALSE;
   }
   for (int li_4 = li_0 - 1; li_4 >= 0; li_4--) {
      GetMAs(li_4 + 1);
      gi_608 = FALSE;
      SaveBuy(gi_608);
      gi_612 = FALSE;
      SaveSell(gi_612);
      CheckMA_Angle(li_4 + 1);
      CheckHighLowRules(li_4 + 1);
      CheckMAs();
      if (gi_608) {
         gd_616 = iHigh(NULL, 0, li_4 + 1);
         SaveBuy1(gd_616);
      }
      if (gi_612) {
         gd_624 = iLow(NULL, 0, li_4 + 1);
         SaveSell1(gd_624);
      }
      if (ShowTradeArrowsOnly) {
         if (gi_608) {
            if (iHigh(NULL, 0, li_4) <= gd_616) {
               gi_608 = FALSE;
               SaveBuy(gi_608);
            }
         }
         if (gi_612) {
            if (iLow(NULL, 0, li_4) >= gd_624) {
               gi_612 = FALSE;
               SaveSell(gi_612);
            }
         }
      }
      if (gi_608) {
         if (li_4 == 0) {
            if (ShowTradeArrowsOnly) {
               if (NewTradeBar()) 
               {  
                if(filter(true)) ShowAlert("Buy Trade ");
               }
            } else
               if (NewSignalBar()) 
               {
                if(filter(true)) ShowAlert("Buy Alert ");
               }
         }
         li_8 = MathRound((High[li_4 + 1] - gd_672) / gd_504);
         if (ShowTradeArrowsOnly) gs_528 = GetSignalTime(li_4, 1);
         else gs_528 = GetSignalTime(li_4 + 1, 0);
         gs_512 = gs_520 + " - D:" + li_8 + " A:" + DoubleToStr(gd_648, 2) + " at " + gs_528;
         OutputComment2ToChart(gs_512);
         if (ShowTradeArrowsOnly) {
            g_ibuf_468[li_4] = iLow(NULL, 0, li_4) - Arrow_Position * gd_504;
            if (ShowFibProfitTargets) FibLines(0, li_4 + 1);
         } else g_ibuf_468[li_4 + 1] = iLow(NULL, 0, li_4 + 1) - Arrow_Position * gd_504;
         g_global_var_540 = FALSE;
         SaveLastArrow(0);
         g_global_var_544 = TRUE;
         SaveLastSmile(1);
         g_datetime_464 = Time[0];
         if (ShowBuySellLines) {
            DisplayLine("FractBuy", gd_616, BuyLineColor);
            RemoveLine("FractSell");
         }
      } else {
         if (gi_612) {
            if (li_4 == 0) {
               if (ShowTradeArrowsOnly) {
                  if (NewTradeBar()) 
                  {
                   if(filter(false)) ShowAlert("Sell Trade ");
                  }
               } else
                  if (NewSignalBar()) 
                  {
                   if(filter(false)) ShowAlert("Sell Alert ");
                  }
            }
            li_8 = MathRound((gd_672 - (Low[li_4 + 1])) / gd_504);
            if (ShowTradeArrowsOnly) gs_528 = GetSignalTime(li_4, 1);
            else gs_528 = GetSignalTime(li_4 + 1, 0);
            gs_512 = gs_520 + " - D:" + li_8 + " A:" + DoubleToStr(gd_648, 2) + " at " + gs_528;
            OutputComment2ToChart(gs_512);
            if (ShowTradeArrowsOnly) {
               g_ibuf_472[li_4] = iHigh(NULL, 0, li_4) + Arrow_Position * gd_504;
               if (ShowFibProfitTargets) FibLines(1, li_4 + 1);
            } else g_ibuf_472[li_4 + 1] = iHigh(NULL, 0, li_4 + 1) + Arrow_Position * gd_504;
            g_global_var_540 = TRUE;
            SaveLastArrow(1);
            g_global_var_544 = FALSE;
            SaveLastSmile(0);
            g_datetime_464 = Time[0];
            if (ShowBuySellLines) {
               DisplayLine("FractSell", gd_624, SellLineColor);
               RemoveLine("FractBuy");
            }
         }
      }
      if (ShowBadTradeExits) {
         if (g_global_var_540 == 0) {
            if (g_global_var_544 != 0) {
               if (CheckBadExit(0, li_4 + 1)) {
                  li_12 = GetFacePos(Period());
                  g_ibuf_488[li_4 + 1] = iLow(NULL, 0, li_4 + 1) - li_12 * gd_504;
                  g_global_var_544 = FALSE;
                  SaveLastSmile(0);
                  if (li_4 == 0)
                     if (NewBadTradeBar()) 
                     {
                      if(LongAlert) ShowAlert("BUY Trade Exit");
                     }
               }     
            }
         }
         if (g_global_var_540 == 1) {
            if (g_global_var_544 != 1) {
               if (CheckBadExit(1, li_4 + 1)) {
                  li_12 = GetFacePos(Period());
                  g_ibuf_492[li_4 + 1] = iHigh(NULL, 0, li_4 + 1) + li_12 * gd_504;
                  g_global_var_544 = TRUE;
                  SaveLastSmile(1);
                  if (li_4 == 0)
                     if (NewBadTradeBar()) 
                     {
                      if(ShortAlert) ShowAlert("SELL Trade Exit");
                     } 
               }
            }
         }
      }
   }
   return (0);
}

double Get_mFactor() {
   double ld_ret_8 = 10000.0;
   string ls_0 = StringSubstr(Symbol(), 3, 3);
   if (ls_0 == "JPY") ld_ret_8 = 100.0;
   int li_16 = PrevMAShift - CurMAShift;
   ld_ret_8 /= li_16;
   return (ld_ret_8);
}

bool NewSignalBar() {
   if (g_time_720 == Time[0]) return (FALSE);
   g_time_720 = Time[0];
   return (TRUE);
}

bool NewTradeBar() {
   if (g_time_724 == Time[0]) return (FALSE);
   g_time_724 = Time[0];
   return (TRUE);
}

bool NewBadTradeBar() {
   if (g_time_728 == Time[0]) return (FALSE);
   g_time_728 = Time[0];
   return (TRUE);
}

void GetMAs(int ai_0) {
   gd_656 = iMA(NULL, 0, 10, 0, g_ma_method_256, PRICE_CLOSE, ai_0);
   gd_664 = iMA(NULL, 0, 21, 0, g_ma_method_256, PRICE_CLOSE, ai_0);
   gd_672 = iMA(NULL, 0, 50, 0, g_ma_method_256, PRICE_CLOSE, ai_0);
   g_ibuf_476[ai_0] = gd_656;
   g_ibuf_480[ai_0] = gd_664;
   g_ibuf_484[ai_0] = gd_672;
   SaveMA10(gd_656);
   SaveMA21(gd_664);
   SaveMA50(gd_672);
}

void CheckMA_Angle(int ai_0) {
   g_ima_632 = iMA(NULL, 0, MA_Period, 0, g_ma_method_256, MA_AppliedPrice, ai_0 + CurMAShift);
   g_ima_640 = iMA(NULL, 0, MA_Period, 0, g_ma_method_256, MA_AppliedPrice, ai_0 + PrevMAShift);
   gd_648 = gd_496 * (g_ima_632 - g_ima_640) / 2.0;
   gd_648 = NormalizeDouble(gd_648, 2);
   SavefAngle(gd_648);
   if (gd_648 > AngleTreshold) {
      gi_608 = TRUE;
      SaveBuy(gi_608);
      gs_520 = "BUY";
      return;
   }
   if (gd_648 < -AngleTreshold) {
      gi_612 = TRUE;
      SaveSell(gi_612);
      gs_520 = "SELL";
   }
}

void CheckHighLowRules(int ai_0) {
   if (gi_260 == TRUE) {
      if (gi_608) {
         if (Low[ai_0] > gd_656) {
            gi_608 = FALSE;
            SaveBuy(gi_608);
         }
      }
      if (gi_612) {
         if (High[ai_0] < gd_656) {
            gi_612 = FALSE;
            SaveSell(gi_612);
         }
      }
   }
   if (gi_264 == TRUE) {
      if (gi_608) {
         if (High[ai_0] > High[ai_0 + 1]) {
            gi_608 = FALSE;
            SaveBuy(gi_608);
         }
      }
      if (gi_612) {
         if (Low[ai_0] < Low[ai_0 + 1]) {
            gi_612 = FALSE;
            SaveSell(gi_612);
         }
      }
   }
}

void CheckMAs() {
   if (gi_608) {
      if (gd_656 <= gd_672 || gd_664 <= gd_672) {
         gi_608 = FALSE;
         SaveBuy(gi_608);
      }
   }
   if (gi_612) {
      if (gd_656 >= gd_672 || gd_664 >= gd_672) {
         gi_612 = FALSE;
         SaveSell(gi_612);
      }
   }
}

string GetSignalTime(int ai_0, bool ai_4) {
   if (ai_4) {
      if (gi_732 != iTime(NULL, 0, ai_0)) {
         g_datetime_536 = TimeCurrent();
         gi_736 = g_datetime_536;
         SaveLastTradeSignalTime(g_datetime_536);
         gi_732 = iTime(NULL, 0, ai_0);
         SaveTradeCandleOpenTime(gi_732);
      } else g_datetime_536 = gi_736;
   } else g_datetime_536 = iTime(NULL, 0, ai_0);
   string ls_ret_8 = TimeToStr(g_datetime_536, TIME_DATE) + " " + TimeHour(g_datetime_536) + ":";
   if (TimeMinute(g_datetime_536) < 10) ls_ret_8 = ls_ret_8 + "0";
   ls_ret_8 = ls_ret_8 + TimeMinute(g_datetime_536);
   return (ls_ret_8);
}

int GetFacePos(int ai_0) {
   int li_ret_4 = 0;
   switch (ai_0) {
   case 43200:
      li_ret_4 = FacePosMN;
      break;
   case 10080:
      li_ret_4 = FacePosW1;
      break;
   case 1440:
      li_ret_4 = FacePosD1;
      break;
   case 240:
      li_ret_4 = FacePosH4;
      break;
   case 60:
      li_ret_4 = FacePosH1;
      break;
   case 30:
      li_ret_4 = FacePosM30;
      break;
   case 15:
      li_ret_4 = FacePosM15;
      break;
   case 5:
      li_ret_4 = FacePosM5;
      break;
   case 1:
      li_ret_4 = FacePosM1;
      break;
   default:
      li_ret_4 = 5;
   }
   return (li_ret_4);
}

void ShowAlert(string as_0) {
   string ls_8 = TimeToStr(TimeCurrent(), TIME_DATE) + " " + TimeHour(TimeCurrent()) + ":";
   if (TimeMinute(TimeCurrent()) < 10) ls_8 = ls_8 + "0";
   ls_8 = ls_8 + TimeMinute(TimeCurrent());
   if (Alert_SoundON) Alert(as_0, Symbol(), " on ", tf2txt(Period()), " ", ls_8, " Steinitz");
   if (EmailON) SendMail(as_0 + Symbol(), "Date=" + ls_8 + " on " + tf2txt(Period()));
}

void ClearArrows() {
   for (int li_0 = Bars; li_0 >= 0; li_0--) {
      g_ibuf_472[li_0] = 0;
      g_ibuf_468[li_0] = 0;
      g_ibuf_492[li_0] = 0;
      g_ibuf_488[li_0] = 0;
   }
}

int CheckTradeFilters() {
   bool li_4;
   bool li_ret_0 = FALSE;
   if (gi_84 == TRUE) {
      li_4 = FALSE;
      if (Year() > gi_96) li_4 = TRUE;
      if (li_4 == FALSE) {
         if (Year() == gi_96 && Month() > gi_88) li_4 = TRUE;
         if (li_4 == FALSE)
            if (Year() == gi_96 && Month() == gi_88 && Day() > gi_92) li_4 = TRUE;
      }
      if (li_4 == TRUE) OutputComment1ToChart("Indicator has expired - renew license");
      li_ret_0 = li_4;
   }
   return (li_ret_0);
}

double SetPoint() {
   double ld_ret_0;
   if (Digits < 4) ld_ret_0 = 0.01;
   else ld_ret_0 = 0.0001;
   return (ld_ret_0);
}

int CheckAccountNumber() {
   if (YourAccountNumber == AccountNumber() && YourAccountNumber == gi_76) return (1);
   Alert("AccountNumber entered is incorrect.\n You entered ", YourAccountNumber);
   return (0);
}

void ClearLabels() {
   string ls_0 = " ";
   OutputLabelToChart(gs_560, gi_548, StatusTxtSize, StatusColor, ls_0, " ");
   OutputLabelToChart(gs_568, gi_552, CommentTxtSize, CommentColor, ls_0, " ");
   OutputLabelToChart(gs_576, gi_556, CommentTxtSize, CommentColor, ls_0, " ");
}

void DeleteBadLabels() {
   string l_name_8;
   int l_objs_total_4 = ObjectsTotal();
   if (l_objs_total_4 > 0) {
      for (int li_0 = l_objs_total_4 - 1; li_0 >= 0; li_0--) {
         l_name_8 = ObjectName(li_0);
         if (StringFind(l_name_8, Symbol(), 0) < 0)
            if (StringFind(l_name_8, gs_600, 0) >= 0) ObjectDelete(l_name_8);
      }
   }
}

void DeleteExistingLabels() {
   string l_name_4;
   int l_objs_total_0 = ObjectsTotal(OBJ_LABEL);
   if (l_objs_total_0 > 0) {
      for (int l_objs_total_12 = l_objs_total_0; l_objs_total_12 >= 0; l_objs_total_12--) {
         l_name_4 = ObjectName(l_objs_total_12);
         if (StringFind(l_name_4, Symbol() + gs_600 + "FractalStatus", 0) >= 0) ObjectDelete(l_name_4);
         else
            if (StringFind(l_name_4, Symbol() + gs_600 + "FractalComment", 0) >= 0) ObjectDelete(l_name_4);
      }
   }
}

void SetupLabels() {
   gi_548 = 12;
   gi_552 = gi_548 + StatusTxtSize + 4;
   gi_556 = gi_552 + CommentTxtSize + 4;
   gs_560 = Symbol() + gs_600 + "FractalStatus";
   gs_568 = Symbol() + gs_600 + "FractalComment1";
   gs_576 = Symbol() + gs_600 + "FractalComment2";
}

void OutputLabelToChart(string a_name_0, int a_y_8, int a_fontsize_12, color a_color_16, string a_text_20, string as_unused_28) {
   if (ObjectFind(a_name_0) != 0) {
      ObjectCreate(a_name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(a_name_0, OBJPROP_CORNER, 0);
      ObjectSet(a_name_0, OBJPROP_XDISTANCE, Text_X_Offset);
      ObjectSet(a_name_0, OBJPROP_YDISTANCE, a_y_8);
   }
   ObjectSetText(a_name_0, a_text_20, a_fontsize_12, "Arial Bold", a_color_16);
}

void OutputStatusToChart(string as_0) {
   OutputLabelToChart(gs_560, gi_548, StatusTxtSize, StatusColor, as_0, "*");
}

void OutputComment1ToChart(string as_0) {
   OutputLabelToChart(gs_568, gi_552, CommentTxtSize, CommentColor, as_0, "*");
}

void OutputComment2ToChart(string as_0) {
   OutputLabelToChart(gs_576, gi_556, CommentTxtSize, CommentColor, as_0, "*");
}

string tf2txt(int ai_0) {
   switch (ai_0) {
   case 1:
      return ("M1");
   case 5:
      return ("M5");
   case 15:
      return ("M15");
   case 30:
      return ("M30");
   case 60:
      return ("H1");
   case 240:
      return ("H4");
   case 1440:
      return ("D1");
   case 10080:
      return ("W1");
   case 43200:
      return ("MN");
   }
   return ("??");
}

void DisplayLine(string as_0, double a_price_8, color a_color_16) {
   string l_name_20 = Symbol() + gs_600 + as_0;
   if (ObjectFind(l_name_20) != 0) {
      ObjectCreate(l_name_20, OBJ_HLINE, 0, g_datetime_464, a_price_8);
      ObjectSet(l_name_20, OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet(l_name_20, OBJPROP_COLOR, a_color_16);
      ObjectSet(l_name_20, OBJPROP_WIDTH, 1);
      return;
   }
   ObjectMove(l_name_20, 0, g_datetime_464, a_price_8);
}

void DeleteFractObjects() {
   ObjectDelete(Symbol() + gs_600 + "FractBuy");
   ObjectDelete(Symbol() + gs_600 + "FractSell");
   ObjectDelete(Symbol() + gs_600 + "Fib1");
   ObjectDelete(Symbol() + gs_600 + "Fib2");
   ObjectDelete(Symbol() + gs_600 + "Fib3");
}

void RemoveLine(string as_0) {
   ObjectDelete(Symbol() + gs_600 + as_0);
}

bool CheckBadExit(int ai_0, int ai_4) {
   double l_iopen_24 = iOpen(NULL, 0, ai_4);
   double l_iclose_40 = iClose(NULL, 0, ai_4);
   double l_iopen_32 = iOpen(NULL, 0, ai_4 + 1);
   double l_iclose_48 = iClose(NULL, 0, ai_4 + 1);
   double l_ima_8 = iMA(NULL, 0, 50, 0, g_ma_method_256, PRICE_CLOSE, ai_4);
   double l_ima_16 = iMA(NULL, 0, 50, 0, g_ma_method_256, PRICE_CLOSE, ai_4 + 1);
   int li_56 = GetPriceGap(Period());
   double ld_60 = li_56 * gd_504;
   if (Digits < 3) {
      ld_60 = NormalizeDouble(ld_60, 2);
      l_iopen_24 = NormalizeDouble(l_iopen_24, 2);
      l_iclose_40 = NormalizeDouble(l_iclose_40, 2);
      l_iopen_32 = NormalizeDouble(l_iopen_32, 2);
      l_iclose_48 = NormalizeDouble(l_iclose_48, 2);
      l_ima_8 = NormalizeDouble(l_ima_8, 2);
      l_ima_16 = NormalizeDouble(l_ima_16, 2);
   } else {
      ld_60 = NormalizeDouble(ld_60, 4);
      l_iopen_24 = NormalizeDouble(l_iopen_24, 4);
      l_iclose_40 = NormalizeDouble(l_iclose_40, 4);
      l_iopen_32 = NormalizeDouble(l_iopen_32, 4);
      l_iclose_48 = NormalizeDouble(l_iclose_48, 4);
      l_ima_8 = NormalizeDouble(l_ima_8, 4);
      l_ima_16 = NormalizeDouble(l_ima_16, 4);
   }
   switch (ai_0) {
   case 0:
      if (l_iopen_24 > l_iclose_40) {
         if (l_iopen_32 > l_iclose_48) {
            if (l_iclose_40 + ld_60 <= l_ima_8)
               if (l_iclose_48 + ld_60 <= l_ima_16) return (TRUE);
         }
      }
   case 1:
      if (l_iopen_24 < l_iclose_40) {
         if (l_iopen_32 < l_iclose_48) {
            if (l_iclose_40 - ld_60 >= l_ima_8)
               if (l_iclose_48 - ld_60 >= l_ima_16) return (TRUE);
         }
      }
   }
   return (FALSE);
}

int GetPriceGap(int ai_0) {
   int li_ret_4 = 0;
   switch (ai_0) {
   case 43200:
      li_ret_4 = PriceGapMN;
      break;
   case 10080:
      li_ret_4 = PriceGapW1;
      break;
   case 1440:
      li_ret_4 = PriceGapD1;
      break;
   case 240:
      li_ret_4 = PriceGapH4;
      break;
   case 60:
      li_ret_4 = PriceGapH1;
      break;
   case 30:
      li_ret_4 = PriceGapM30;
      break;
   case 15:
      li_ret_4 = PriceGapM15;
      break;
   case 5:
      li_ret_4 = PriceGapM5;
      break;
   case 1:
      li_ret_4 = PriceGapM1;
      break;
   default:
      li_ret_4 = 5;
   }
   return (li_ret_4);
}

void GetGlobalVars() {
   NameGlobalVars();
   InitGlobalVars();
   GetGlobalVarValues();
}

void GetGlobalVarValues() {
   double l_global_var_0 = GlobalVariableGet(g_var_name_740);
   if (l_global_var_0 > 0.0) gi_608 = TRUE;
   else gi_608 = FALSE;
   l_global_var_0 = GlobalVariableGet(g_var_name_748);
   if (l_global_var_0 > 0.0) gi_612 = TRUE;
   else gi_612 = FALSE;
   gd_616 = GlobalVariableGet(g_var_name_756);
   gd_624 = GlobalVariableGet(g_var_name_764);
   gd_656 = GlobalVariableGet(g_var_name_772);
   gd_664 = GlobalVariableGet(g_var_name_780);
   gd_672 = GlobalVariableGet(g_var_name_788);
   gd_648 = GlobalVariableGet(g_var_name_796);
   gi_732 = GlobalVariableGet(g_var_name_804);
   gi_736 = GlobalVariableGet(g_var_name_812);
   g_global_var_540 = GlobalVariableGet(g_var_name_820);
   g_global_var_544 = GlobalVariableGet(g_var_name_828);
   gd_696 = GlobalVariableGet(g_var_name_836);
   gd_704 = GlobalVariableGet(g_var_name_844);
   gd_712 = GlobalVariableGet(g_var_name_852);
}

void InitGlobalVars() {
   if (!GlobalVariableCheck(g_var_name_740)) GlobalVariableSet(g_var_name_740, -10);
   if (!GlobalVariableCheck(g_var_name_748)) GlobalVariableSet(g_var_name_748, -10);
   if (!GlobalVariableCheck(g_var_name_756)) GlobalVariableSet(g_var_name_756, 0);
   if (!GlobalVariableCheck(g_var_name_764)) GlobalVariableSet(g_var_name_764, 0);
   if (!GlobalVariableCheck(g_var_name_772)) GlobalVariableSet(g_var_name_772, 0);
   if (!GlobalVariableCheck(g_var_name_780)) GlobalVariableSet(g_var_name_780, 0);
   if (!GlobalVariableCheck(g_var_name_788)) GlobalVariableSet(g_var_name_788, 0);
   if (!GlobalVariableCheck(g_var_name_796)) GlobalVariableSet(g_var_name_796, 0);
   if (!GlobalVariableCheck(g_var_name_804)) GlobalVariableSet(g_var_name_804, 0);
   if (!GlobalVariableCheck(g_var_name_812)) GlobalVariableSet(g_var_name_812, 0);
   if (!GlobalVariableCheck(g_var_name_820)) GlobalVariableSet(g_var_name_820, 10);
   if (!GlobalVariableCheck(g_var_name_828)) GlobalVariableSet(g_var_name_828, 10);
   if (!GlobalVariableCheck(g_var_name_836)) GlobalVariableSet(g_var_name_836, 0);
   if (!GlobalVariableCheck(g_var_name_844)) GlobalVariableSet(g_var_name_844, 0);
   if (!GlobalVariableCheck(g_var_name_852)) GlobalVariableSet(g_var_name_852, 0);
}

void NameGlobalVars() {
   string ls_0 = "SFBI_15_" + Symbol() + tf2txt(Period());
   g_var_name_740 = ls_0 + "_Buy";
   g_var_name_748 = ls_0 + "_Sell";
   g_var_name_756 = ls_0 + "_BuyLine";
   g_var_name_764 = ls_0 + "_SellLine";
   g_var_name_772 = ls_0 + "_MA10";
   g_var_name_780 = ls_0 + "_MA21";
   g_var_name_788 = ls_0 + "_MA50";
   g_var_name_796 = ls_0 + "_fAngle";
   g_var_name_804 = ls_0 + "_TradeCandleOT";
   g_var_name_812 = ls_0 + "_LastTradeCandleST";
   g_var_name_820 = ls_0 + "_LastArrow";
   g_var_name_828 = ls_0 + "_LastSmile";
   g_var_name_836 = ls_0 + "_Fib1";
   g_var_name_844 = ls_0 + "_Fib2";
   g_var_name_852 = ls_0 + "_Fib3";
}

void SaveBuy(int ai_0) {
   if (ai_0 == 1) {
      GlobalVariableSet(g_var_name_740, 10.0);
      return;
   }
   GlobalVariableSet(g_var_name_740, -10.0);
}

void SaveSell(int ai_0) {
   if (ai_0 == 1) {
      GlobalVariableSet(g_var_name_748, 10.0);
      return;
   }
   GlobalVariableSet(g_var_name_748, -10.0);
}

void SaveBuy1(double ad_0) {
   GlobalVariableSet(g_var_name_756, ad_0);
}

void SaveSell1(double ad_0) {
   GlobalVariableSet(g_var_name_764, ad_0);
}

void SaveMA10(double ad_0) {
   GlobalVariableSet(g_var_name_772, ad_0);
}

void SaveMA21(double ad_0) {
   GlobalVariableSet(g_var_name_780, ad_0);
}

void SaveMA50(double ad_0) {
   GlobalVariableSet(g_var_name_788, ad_0);
}

void SavefAngle(double ad_0) {
   GlobalVariableSet(g_var_name_796, ad_0);
}

void SaveTradeCandleOpenTime(int ai_0) {
   GlobalVariableSet(g_var_name_804, ai_0);
}

void SaveLastTradeSignalTime(int ai_0) {
   GlobalVariableSet(g_var_name_812, ai_0);
}

void SaveLastArrow(int ai_0) {
   GlobalVariableSet(g_var_name_820, ai_0);
}

void SaveLastSmile(int ai_0) {
   GlobalVariableSet(g_var_name_828, ai_0);
}

void SaveFib1(int ai_0) {
   GlobalVariableSet(g_var_name_836, ai_0);
}

void SaveFib2(int ai_0) {
   GlobalVariableSet(g_var_name_844, ai_0);
}

void SaveFib3(int ai_0) {
   GlobalVariableSet(g_var_name_852, ai_0);
}

//+------------------------------------------------------------------+
bool filter(bool long)
{
 int Trigger[4], totN=4,i;
  
 for(i=0;i<totN;i++) Trigger[i]=-1;

 if(long) // long filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   {     
    case 0:
     if(LongAlert) Trigger[i]=1;
    break;
    case 1:
     if(MAFilter(true)) Trigger[i]=1;
    break;  
    case 2:
     if(PipXFilter(true)) Trigger[i]=1;
    break;    
    case 3:
     if(MALinesFilter(true)) Trigger[i]=1;
    break;
   }
   if(Trigger[i]<0) return(false);       
  } 
 }
 else // short filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   {         
    case 0:
     if(ShortAlert) Trigger[i]=1;
    break;    
    case 1:
     if(MAFilter(false)) Trigger[i]=1;
    break; 
    case 2:
     if(PipXFilter(false)) Trigger[i]=1;
    break;            
    case 3:
     if(MALinesFilter(false)) Trigger[i]=1;
    break;       
   }
   if(Trigger[i]<0) return(false);    
  }
 }

 return(true);  // no anti-trigger:  so, return true (to order)
}
//+------------------------------------------------------------------+
bool PipXFilter(bool long)
{
 if(!PipCrossFilter) return(true);
 int i; double f1,f2,m1,m2,x; 
 
 if(long)
 {
  for(i=0;i<=Bars-1;i++)
  {
   f1=g_ibuf_476[i];
   f2=g_ibuf_476[i+1];
   m1=g_ibuf_480[i];
   m2=g_ibuf_480[i+1];  
   
   if(f1>m1&&f2<m2)
   {
    x=NormDigits(0.5*(f1+f2));
    if(Bid<=NormDigits(x+PipCrossPoints)) return(true);
    else return(false);
    
    break;
   }
  }
 }
 else
 {
  for(i=0;i<=Bars-1;i++)
  {
   f1=g_ibuf_476[i];
   f2=g_ibuf_476[i+1];
   m1=g_ibuf_480[i];
   m2=g_ibuf_480[i+1];   
   
   if(f1<m1&&f2>m2)
   {
    x=NormDigits(0.5*(f1+f2));
    if(Bid>=NormDigits(x-PipCrossPoints)) return(true);
    else return(false);
    
    break;
   }
  } 
 }
 
 return(false);
}
//+------------------------------------------------------------------+
bool MAFilter(bool long)
{
 if(!GreenRedFilter) return(true);
 int period1,period2,period3;
 switch(Period())
 {
  case 1:
          period1=PERIOD_M1;
          period2=PERIOD_M5;
          period3=PERIOD_M15;
  break;
  case 5:
          period1=PERIOD_M5;
          period2=PERIOD_M15;
          period3=PERIOD_M30;
  break;
  case 15:
          period1=PERIOD_M15;
          period2=PERIOD_M30;
          period3=PERIOD_H1;
  break;  
  case 30:
          period1=PERIOD_M30;
          period2=PERIOD_H1;
          period3=PERIOD_H4;
  break;  
  case 60:
          period1=PERIOD_H1;
          period2=PERIOD_H4;
          period3=PERIOD_D1;
  break;
  case 240:
          period1=PERIOD_H4;
          period2=PERIOD_D1;
          period3=PERIOD_W1;
  break;  
  case 1440:
          period1=PERIOD_D1;
          period2=PERIOD_W1;
          period3=PERIOD_MN1;
  break;  
  case 10080:
          period1=PERIOD_W1;
          period2=PERIOD_MN1;
          period3=PERIOD_MN1;
  break;  
  default:
          period1=PERIOD_MN1;
          period2=PERIOD_MN1;
          period3=PERIOD_MN1;
  break;  
 }
 string ci2="Leo_MA";
 
 double MA10=iCustom(NULL,period1,ci2,0,0);
 double MA11=iCustom(NULL,period1,ci2,1,0); 
 double MA20=iCustom(NULL,period2,ci2,0,0);
 double MA21=iCustom(NULL,period2,ci2,1,0);  
 double MA30=iCustom(NULL,period3,ci2,0,0);
 double MA31=iCustom(NULL,period3,ci2,1,0); 
 
 if(long)
 {
  if(MA10!=EMPTY_VALUE&&MA10!=0)
  {
   if(MA20!=EMPTY_VALUE&&MA20!=0)      return(true);
   else if(MA21!=EMPTY_VALUE&&MA21!=0) return(false);
   else if(MA30!=EMPTY_VALUE&&MA30!=0) return(true);
   else            return(false);
  }
  else             return(false);
 }
 else
 {
  if(MA11!=EMPTY_VALUE&&MA11!=0)
  {
   if(MA21!=EMPTY_VALUE&&MA21!=0)      return(true);
   else if(MA20!=EMPTY_VALUE&&MA20!=0) return(false);
   else if(MA31!=EMPTY_VALUE&&MA31!=0) return(true);
   else            return(false);   
  }
  else             return(false);  
 }
 return(false);
}
//+------------------------------------------------------------------+
bool MALinesFilter(bool flag)
{
 if(!MAOrderFilter) return(true);
 if(flag)
 {
  if(g_ibuf_476[1]>g_ibuf_480[1]&&g_ibuf_480[1]>g_ibuf_484[1]) return(true);
  else return(false); 
 }
 else
 {
  if(g_ibuf_476[1]<g_ibuf_480[1]&&g_ibuf_480[1]<g_ibuf_484[1]) return(true);
  else return(false);
 }
 return(false);
} 
//+------------------------------------------------------------------+
double NormPoints(int pips)
{
 return(NormDigits(pips*Point));
}
//+------------------------------------------------------------------+
double NormDigits(double price)
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+