//+----------------------------------------------------------------------+
//|                                                       MFriel Fix.mq4 |
//|                                                         David J. Lin |
//| Fix an EA for Mike Friel to work at Alpari                           |
//| written for Mike Friel (mfriel@hotmail.com)                          |
//|                                                                      |
//| Lines containing David's fixes are commented by // dl+               |
//|                                                                      |
//| Coded by David J. Lin (dave.j.lin@gmail.com)                         |
//| Evanston, IL, April 22, 2012                                         |
//+----------------------------------------------------------------------+
#property copyright "Copyright ForexFreedom 2012, mpfriel@gmail.com"
#property link      "http://www.drfrielgood.co.uk"

extern int TradePeriod = 0;
extern int RSIPeriod = 13;
extern double rsihighcut = 69.0;
extern double rsilowcut = 31.0;
extern double Lots = 0.05;
extern bool UseMM = TRUE;
extern double LotMultiplier = 15.0;
extern double SLMultiplier = 0.0;
extern double TakeMultiplier = 0.382;
extern double TrailMultiplier = 0.618;
extern double ATRmultiplier = 0.618;
extern int ATRTimePeriod = 10080;
extern int ATRperiod = 3;
extern int ATRshift = 1;
extern int MagicNumber = 10203;
double gd_168;
double gd_176;
double g_price_184;
double g_price_192;
double gd_200;
double gd_208;
double gd_216;
double gd_224;
double gd_unused_232;
double gd_240;
double gd_248;
double gd_256;
double gd_unused_264;
double gd_272;
int gi_280;
int gi_284;
int gi_unused_288;
int g_datetime_292;
int gi_296;
int gi_300;
int gi_unused_304;
int g_datetime_308;
double g_price_312;
double g_price_320;
double g_price_328;
double g_price_336;
int g_datetime_344;
int g_datetime_348;
int g_datetime_352;
int g_datetime_356;
double g_irsi_360;
double gd_368;
double g_irsi_376;
double gd_384;
double g_irsi_392;
double g_irsi_400;
double gd_408;
double g_irsi_416;
double g_irsi_424;
int g_datetime_432;
int g_datetime_436;
int g_datetime_440;
int g_datetime_444;
double gd_464;
double gd_472;
int g_datetime_480;
int gi_484;
int g_datetime_488;
int gi_492;
int g_datetime_496;
int g_datetime_500;
int g_datetime_504;
int g_datetime_508;
int g_datetime_512;
double g_price_516;
double g_price_524;
double g_price_532;
double g_price_540;
double g_price_548;
double g_price_556;
string g_comment_564;
string gs_dummy_572;
color g_color_580;
int g_ticket_584;
int g_ticket_588;
bool gi_592;
double g_tickvalue_596;
double gd_604;
double gd_612;
double gd_620;
double gd_628;
double gd_636;
double gd_644;
double gd_652;
double gd_660;
double gd_668;
double g_lots_676;

int init() {
   gi_592 = FALSE;
   return (0);
}

int deinit() {
   if (!IsTesting()) ObjectsDeleteAll();
   gi_592 = FALSE;
   return (0);
}

int start() {
   if (gi_592 == FALSE && (!IsTesting())) {
      Back.Plot();
      gi_592 = TRUE;
   }
   GetATR(); // dl+
   OneHighLow();
   Avg.Price();
   comments();
   g_irsi_360 = iRSI(Symbol(), TradePeriod, RSIPeriod, PRICE_CLOSE, 1);
   gd_368 = iRSI(Symbol(), TradePeriod, RSIPeriod, PRICE_CLOSE, 2);
   g_irsi_376 = iRSI(Symbol(), TradePeriod, RSIPeriod, PRICE_CLOSE, 3);
   if (g_irsi_360 < rsilowcut || (gd_368 > 0.0 && gd_384 > 0.0 && gd_368 > gd_384)) {
      g_price_312 = 0;
      g_datetime_344 = 0;
      g_price_320 = 0;
      g_datetime_348 = 0;
      gd_384 = 0;
      g_datetime_488 = 0;
      gd_472 = 0;
      gi_492 = 0;
      g_irsi_392 = 0;
      g_datetime_432 = 0;
      g_irsi_400 = 0;
      g_datetime_436 = 0;
   }
   if (g_irsi_360 > rsihighcut || (gd_368 > 0.0 && gd_408 > 0.0 && gd_368 < gd_408)) {
      g_price_328 = 0;
      g_datetime_352 = 0;
      g_price_336 = 0;
      g_datetime_356 = 0;
      gd_408 = 0;
      g_datetime_480 = 0;
      gd_464 = 0;
      gi_484 = 0;
      g_irsi_416 = 0;
      g_datetime_440 = 0;
      g_irsi_424 = 0;
      g_datetime_444 = 0;
   }
   if (g_price_312 == 0.0 && iRSI(Symbol(), TradePeriod, RSIPeriod, PRICE_CLOSE, iBarShift(Symbol(), TradePeriod, gi_280)) > rsihighcut) {
      g_price_312 = gd_216;
      g_datetime_344 = gi_280;
   }
   if (g_price_328 == 0.0 && iRSI(Symbol(), TradePeriod, RSIPeriod, PRICE_CLOSE, iBarShift(Symbol(), TradePeriod, gi_296)) < rsilowcut) {
      g_price_328 = gd_248;
      g_datetime_352 = gi_296;
   }
   if (g_irsi_376 <= gd_368 && g_irsi_360 <= gd_368 && gd_368 >= rsihighcut) {
      if (gd_384 == 0.0 || gd_368 >= gd_384) {
         gd_384 = gd_368;
         g_datetime_488 = iTime(Symbol(), TradePeriod, 2);
      }
   }
   if (g_irsi_376 >= gd_368 && g_irsi_360 >= gd_368 && gd_368 <= rsilowcut) {
      if (gd_408 == 0.0 || gd_368 <= gd_408) {
         gd_408 = gd_368;
         g_datetime_480 = iTime(Symbol(), TradePeriod, 2);
      }
   }
   if (g_price_312 > 0.0 && gd_216 > g_price_312 && gd_216 > g_price_320 || g_price_320 == 0.0 && gd_384 > 0.0) {
      g_price_320 = gd_216;
      g_datetime_348 = gi_280;
      gd_472 = 0;
      for (int count_0 = 0; count_0 <= iBarShift(Symbol(), TradePeriod, MathMax(g_datetime_488, gi_492)); count_0++) {
         g_irsi_360 = iRSI(Symbol(), TradePeriod, RSIPeriod, PRICE_CLOSE, count_0 + 1);
         gd_368 = iRSI(Symbol(), TradePeriod, RSIPeriod, PRICE_CLOSE, count_0 + 2);
         g_irsi_376 = iRSI(Symbol(), TradePeriod, RSIPeriod, PRICE_CLOSE, count_0 + 3);
         if (g_irsi_376 <= gd_368 && g_irsi_360 <= gd_368 && gd_368 < gd_384 && gd_368 >= gd_472 || gd_472 == 0.0) {
            gd_472 = gd_368;
            gi_492 = Time[count_0 + 2];
         }
      }
      g_irsi_392 = gd_384;
      g_datetime_432 = g_datetime_488;
      g_irsi_400 = gd_472;
      g_datetime_436 = gi_492;
   }
   if (g_price_328 > 0.0 && gd_248 < g_price_328 && gd_248 < g_price_336 || g_price_336 == 0.0 && gd_408 > 0.0) {
      g_price_336 = gd_248;
      g_datetime_356 = gi_296;
      gd_464 = 0;
      for (int count_4 = 0; count_4 <= iBarShift(Symbol(), TradePeriod, MathMax(g_datetime_480, gi_484)); count_4++) {
         g_irsi_360 = iRSI(Symbol(), TradePeriod, RSIPeriod, PRICE_CLOSE, count_4 + 1);
         gd_368 = iRSI(Symbol(), TradePeriod, RSIPeriod, PRICE_CLOSE, count_4 + 2);
         g_irsi_376 = iRSI(Symbol(), TradePeriod, RSIPeriod, PRICE_CLOSE, count_4 + 3);
         if (g_irsi_376 >= gd_368 && g_irsi_360 >= gd_368 && gd_368 > gd_408 && gd_368 <= gd_464 || gd_464 == 0.0) {
            gd_464 = gd_368;
            gi_484 = Time[count_4 + 2];
         }
      }
      g_irsi_416 = gd_408;
      g_datetime_440 = g_datetime_480;
      g_irsi_424 = gd_464;
      g_datetime_444 = gi_484;
   }
   Plot();
   if (OrdersTotal() > 0) Modify();
   if (TimeCurrent() > StrToTime("2015.12.31 00:00:00")) {
      Alert("Expert Expired, No New Trades!");
      return (0);
   }
   if (UseMM) {
      gd_660 = MathMin(MathMin(AccountBalance(), AccountEquity()), AccountFreeMargin());
      if (gd_660 > gd_668) gd_668 = gd_660;
      g_lots_676 = NormalizeDouble(gd_668 / 100000.0 * LotMultiplier, 2);
      if (g_lots_676 < Lots) g_lots_676 = Lots;
      if (g_lots_676 < MarketInfo(Symbol(), MODE_MINLOT)) g_lots_676 = MarketInfo(Symbol(), MODE_MINLOT);
      if (g_lots_676 > MarketInfo(Symbol(), MODE_MAXLOT)) g_lots_676 = MarketInfo(Symbol(), MODE_MAXLOT);
   }
   if (UseMM == FALSE) g_lots_676 = Lots;
   if (g_irsi_424 > 0.0 && g_price_336 > 0.0 && g_datetime_496 < g_datetime_504 && TimeCurrent() < g_datetime_504 + 10800 * Period()) {
      g_price_516 = g_price_336 + (Ask - Bid);
      g_price_548 = g_price_516 - SLMultiplier * gd_636;
      g_price_532 = g_price_516 + gd_636;
      g_comment_564 = "convergence";
      g_datetime_512 = g_datetime_504 + 10800 * Period();
      Buy();
      return (0);
   }
   if (g_irsi_400 > 0.0 && g_price_320 > 0.0 && g_datetime_500 < g_datetime_508 && TimeCurrent() < g_datetime_508 + 10800 * Period()) {
      g_price_524 = g_price_320;
      g_price_556 = g_price_524 + SLMultiplier * gd_636;
      g_price_540 = g_price_524 - gd_636;
      g_comment_564 = "divergence";
      g_datetime_512 = g_datetime_508 + 10800 * Period();
      Sell();
      return (0);
   }
   return (0);
}

void Modify() {
   gd_636 = NormalizeDouble(ATRmultiplier * iATR(Symbol(), ATRTimePeriod, ATRperiod, ATRshift), Digits);
   if (gd_636 < MarketInfo(Symbol(), MODE_STOPLEVEL) * Point) gd_636 = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
   for (int pos_0 = 0; pos_0 < OrdersTotal(); pos_0++) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderType() == OP_SELLLIMIT && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         if (OrderOpenTime() > g_datetime_500) g_datetime_500 = OrderOpenTime();
      if (OrderType() == OP_BUYLIMIT && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         if (OrderOpenTime() > g_datetime_496) g_datetime_496 = OrderOpenTime();
   }
   if (g_price_192 > 0.0 && Ask + gd_636 * TrailMultiplier < g_price_192) {
      for (int pos_4 = 0; pos_4 < OrdersTotal(); pos_4++) {
         OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            g_price_556 = Ask + gd_636 * TrailMultiplier;
            g_price_556=CheckPrice(false,Ask,g_price_556); // dl+          
            if (NormDigits(OrderStopLoss()) > g_price_556 || (NormDigits(OrderStopLoss()) == NormDigits(0.0) && g_price_556 != NormDigits(0.0))) OrderModify(OrderTicket(), OrderOpenPrice(), NormDigits(g_price_556), OrderTakeProfit(), 0, g_color_580); //dl+
         }
      }
   }
   if (g_price_184 > 0.0 && Bid - gd_636 * TrailMultiplier > g_price_184) {
      for (int pos_8 = 0; pos_8 < OrdersTotal(); pos_8++) {
         OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            g_price_548 = Bid - gd_636 * TrailMultiplier;
            g_price_548=CheckPrice(true,Bid,g_price_548); // dl+           
            if (NormDigits(OrderStopLoss()) < g_price_548 || (NormDigits(OrderStopLoss()) == NormDigits(0.0) && g_price_548 != NormDigits(0.0))) OrderModify(OrderTicket(), OrderOpenPrice(), NormDigits(g_price_548), OrderTakeProfit(), 0, g_color_580); //dl+
         }
      }
   }
   Pips2Cover();
   if (g_price_192 > 0.0) {
      for (int pos_12 = 0; pos_12 < OrdersTotal(); pos_12++) {
         OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (gd_620 == 0.0) break;
            if (gd_620 < 0.0 && TakeMultiplier * gd_636 < gd_628) g_price_540 = g_price_192 - gd_628;
            if (gd_620 < 0.0 && TakeMultiplier * gd_636 > gd_628) g_price_540 = g_price_192 - TakeMultiplier * gd_636;
            if (gd_620 > 0.0) g_price_540 = g_price_192 - TakeMultiplier * gd_636 - gd_628;
            g_price_540=CheckPrice(true,Ask,g_price_540); // dl+
            if (NormDigits(OrderTakeProfit()) != g_price_540 || (NormDigits(OrderTakeProfit()) == NormDigits(0.0) && g_price_540 != NormDigits(0.0))) OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormDigits(g_price_540), 0, g_color_580); // dl+
         }
      }
   }
   if (g_price_184 > 0.0) {
      for (int pos_16 = 0; pos_16 < OrdersTotal(); pos_16++) {
         OrderSelect(pos_16, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (gd_604 == 0.0) break;
            if (gd_604 < 0.0 && TakeMultiplier * gd_636 < gd_612) g_price_532 = g_price_184 + gd_612;
            if (gd_604 < 0.0 && TakeMultiplier * gd_636 > gd_612) g_price_532 = g_price_184 + TakeMultiplier * gd_636;
            if (gd_604 > 0.0) g_price_532 = g_price_184 + TakeMultiplier * gd_636 + gd_612;
            g_price_532=CheckPrice(false,Bid,g_price_532); // dl+
            if (NormDigits(OrderTakeProfit()) != g_price_532 || (NormDigits(OrderTakeProfit()) == NormDigits(0.0) && g_price_532 != NormDigits(0.0))) OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormDigits(g_price_532), 0, g_color_580); // dl+
         }
      }
   }
}

void Buy() {
   if (SLMultiplier == 0.0) g_price_548 = 0;
   g_price_548=CheckPrice(true,g_price_516,g_price_548); // dl+
   g_price_532=CheckPrice(false,g_price_516,g_price_532); // dl+
   g_ticket_584 = OrderSend(Symbol(), OP_BUYLIMIT, g_lots_676, NormDigits(g_price_516), 0, NormDigits(g_price_548), NormDigits(g_price_532), g_comment_564, MagicNumber, g_datetime_512, Black); // dl+
   Print(g_price_516," ",g_price_548," ",g_price_532);
   if (g_ticket_584 > 0) {
      if (OrderSelect(g_ticket_584, SELECT_BY_TICKET, MODE_TRADES)) {
         g_datetime_496 = g_datetime_504;
         Print(g_ticket_584);
      } else Print("Error Opening BuyStop Order: ", GetLastError());
   }
}

void Sell() {
   if (SLMultiplier == 0.0) g_price_556 = 0;
   g_price_556=CheckPrice(false,g_price_524,g_price_556); // dl+
   g_price_540=CheckPrice(true,g_price_524,g_price_540); // dl+
   g_ticket_588 = OrderSend(Symbol(), OP_SELLLIMIT, g_lots_676, NormDigits(g_price_524), 0, NormDigits(g_price_556), NormDigits(g_price_540), g_comment_564, MagicNumber, g_datetime_512, Black); // dl+
   Print(g_price_524," ",g_price_556," ",g_price_540);
   if (g_ticket_588 > 0) {
      if (OrderSelect(g_ticket_588, SELECT_BY_TICKET, MODE_TRADES)) {
         g_datetime_500 = g_datetime_508;
         Print(g_ticket_588);
         return;
      }
      Print("Error Opening SellStop Order: ", GetLastError());
   }
}

double Pips2Cover() {
   g_tickvalue_596 = MarketInfo(Symbol(), MODE_TICKVALUE);
   if (gd_604 < 0.0) {
      gd_612 = (-MathFloor(gd_604 / (g_tickvalue_596 * gd_200))) * Point;
      return (gd_612);
   }
   if (gd_604 > 0.0) {
      gd_612 = MathFloor(gd_604 / (g_tickvalue_596 * gd_200)) * Point;
      return (gd_612);
   }
   if (gd_620 < 0.0) {
      gd_628 = (-MathFloor(gd_620 / (g_tickvalue_596 * gd_208))) * Point;
      return (gd_628);
   }
   if (gd_620 > 0.0) {
      gd_628 = MathFloor(gd_620 / (g_tickvalue_596 * gd_208)) * Point;
      return (gd_628);
   }
   return (0.0);
}

void Avg.Price() {
   gd_168 = 0;
   gd_200 = 0;
   gd_176 = 0;
   gd_208 = 0;
   gd_604 = 0;
   gd_620 = 0;
   for (int pos_0 = 0; pos_0 < OrdersTotal(); pos_0++) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) {
         if (OrderType() == OP_BUY) {
            gd_168 += OrderOpenPrice() * OrderLots();
            gd_200 += OrderLots();
            gd_604 += OrderSwap();
         }
         if (OrderType() == OP_SELL) {
            gd_176 += OrderOpenPrice() * OrderLots();
            gd_208 += OrderLots();
            gd_620 += OrderSwap();
         }
      }
   }
   if (gd_168 > 0.0) {
      g_price_184 = gd_168 / gd_200;
      g_price_184 = NormalizeDouble(g_price_184, Digits);
   }
   if (gd_168 <= 0.0) g_price_184 = 0;
   if (gd_176 > 0.0) {
      g_price_192 = gd_176 / gd_208;
      g_price_192 = NormalizeDouble(g_price_192, Digits);
   }
   if (gd_176 <= 0.0) g_price_192 = 0;
   ObjectDelete("Average Buys");
   ObjectDelete("Average Sells");
   if (g_price_184 > 0.0) {
      ObjectCreate("Average Buys", OBJ_HLINE, 0, Time[10], g_price_184);
      ObjectSetText("Average Buys", "Average Buys");
      ObjectSet("Average Buys", OBJPROP_COLOR, LimeGreen);
      ObjectSet("Average Buys", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("Average Buys", OBJPROP_WIDTH, 3);
      ObjectSet("Average Buys", OBJPROP_BACK, TRUE);
   }
   if (g_price_192 > 0.0) {
      ObjectCreate("Average Sells", OBJ_HLINE, 0, Time[10], g_price_192);
      ObjectSetText("Average Sells", "Average Sells");
      ObjectSet("Average Sells", OBJPROP_COLOR, LightSalmon);
      ObjectSet("Average Sells", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("Average Sells", OBJPROP_WIDTH, 3);
      ObjectSet("Average Sells", OBJPROP_BACK, TRUE);
   }
}

void Plot() {
   if (WindowFind(StringConcatenate("RSI(", RSIPeriod, ")")) > -1 && g_irsi_392 > 0.0 && g_irsi_400 > 0.0) {
      ObjectCreate(StringConcatenate("RSI divergence ", g_datetime_436), OBJ_TREND, WindowFind(StringConcatenate("RSI(", RSIPeriod, ")")), g_datetime_432, g_irsi_392, g_datetime_436,
         g_irsi_400);
      ObjectSet(StringConcatenate("RSI divergence ", g_datetime_436), OBJPROP_RAY, FALSE);
   }
   if (WindowFind(StringConcatenate("RSI(", RSIPeriod, ")")) > -1 && g_irsi_416 > 0.0 && g_irsi_424 > 0.0) {
      ObjectCreate(StringConcatenate("RSI convergence ", g_datetime_444), OBJ_TREND, WindowFind(StringConcatenate("RSI(", RSIPeriod, ")")), g_datetime_440, g_irsi_416,
         g_datetime_444, g_irsi_424);
      ObjectSet(StringConcatenate("RSI convergence ", g_datetime_444), OBJPROP_RAY, FALSE);
   }
   ObjectCreate(StringConcatenate("Price divergence ", g_datetime_348), OBJ_TREND, 0, g_datetime_344, g_price_312, g_datetime_348, g_price_320);
   ObjectSet(StringConcatenate("Price divergence ", g_datetime_348), OBJPROP_RAY, FALSE);
   g_datetime_508 = ObjectGet(StringConcatenate("Price divergence ", g_datetime_348), OBJPROP_TIME2);
   ObjectCreate(StringConcatenate("Price convergence ", g_datetime_356), OBJ_TREND, 0, g_datetime_352, g_price_328, g_datetime_356, g_price_336);
   ObjectSet(StringConcatenate("Price convergence ", g_datetime_356), OBJPROP_RAY, FALSE);
   g_datetime_504 = ObjectGet(StringConcatenate("Price convergence ", g_datetime_356), OBJPROP_TIME2);
}

double OneHighLow() {
   if (iHigh(Symbol(), TradePeriod, 3) <= iHigh(Symbol(), TradePeriod, 2) && iHigh(Symbol(), TradePeriod, 1) <= iHigh(Symbol(), TradePeriod, 2)) {
      gd_240 = iHigh(Symbol(), TradePeriod, 2);
      if (gd_240 == iHigh(Symbol(), TradePeriod, 2)) g_datetime_292 = iTime(Symbol(), TradePeriod, 2);
   }
   if (g_datetime_292 > gi_280) {
      gi_unused_288 = gi_284;
      gi_284 = gi_280;
      gi_280 = g_datetime_292;
      gd_unused_232 = gd_224;
      gd_224 = gd_216;
      gd_216 = gd_240;
   }
   if (iLow(Symbol(), TradePeriod, 3) >= iLow(Symbol(), TradePeriod, 2) && iLow(Symbol(), TradePeriod, 1) >= iLow(Symbol(), TradePeriod, 2)) {
      gd_272 = iLow(Symbol(), TradePeriod, 2);
      if (gd_272 == iLow(Symbol(), TradePeriod, 2)) g_datetime_308 = iTime(Symbol(), TradePeriod, 2);
   }
   if (g_datetime_308 > gi_296) {
      gi_unused_304 = gi_300;
      gi_300 = gi_296;
      gi_296 = g_datetime_308;
      gd_unused_264 = gd_256;
      gd_256 = gd_248;
      gd_248 = gd_272;
   }
   return (0.0);
}

void comments() {
   AccountExtremes();
   string ls_0 = "                                                                                      " + "                                                                                      " +
      "                                                                                      ";
   Comment(ls_0, "Last Tick: ", TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS), 
      "\n", ls_0, "Swap Long ", MarketInfo(Symbol(), MODE_SWAPLONG), 
      "\n", ls_0, "Swap Short ", MarketInfo(Symbol(), MODE_SWAPSHORT), "             atr: ", gd_636, 
      "\n", ls_0, "Average Longs:    ", g_price_184, " B.Lots: ", gd_200, 
      "\n", ls_0, "Average Shorts:   ", g_price_192, " S.Lots: ", gd_208, 
      "\n", ls_0, "Current Spread:   ", Ask - Bid, 
      "\n", ls_0, "AccountProfit()   ", AccountProfit(), 
      "\n", ls_0, "MaxDrawDown       ", gd_644, 
      "\n", ls_0, "AccountBalance()  ", AccountBalance(), 
      "\n", ls_0, "AccountEquity()   ", AccountEquity(), 
      "\n", ls_0, "AccountMargin()   ", AccountMargin(), 
      "\n", ls_0, "MaxMargin         ", gd_652, 
      "\n", ls_0, "Tick Value $", MarketInfo(Symbol(), MODE_TICKVALUE), 
   "\n", ls_0, "Swap Longs $", gd_604, " Swap Shorts $", gd_620);
}

void AccountExtremes() {
   if (AccountMargin() > gd_652) gd_652 = AccountMargin();
   if (AccountProfit() < gd_644) gd_644 = AccountProfit();
}

void Back.Plot() {
   for (int li_0 = iBars(Symbol(), TradePeriod); li_0 > 0; li_0--) {
      if (iHigh(Symbol(), TradePeriod, li_0 - 3) <= iHigh(Symbol(), TradePeriod, li_0 - 2) && iHigh(Symbol(), TradePeriod, li_0 - 1) <= iHigh(Symbol(), TradePeriod, li_0 - 2)) {
         gd_240 = iHigh(Symbol(), TradePeriod, li_0 - 2);
         if (gd_240 == iHigh(Symbol(), TradePeriod, li_0 - 2)) g_datetime_292 = iTime(Symbol(), TradePeriod, li_0 - 2);
      }
      if (g_datetime_292 > gi_280) {
         gi_unused_288 = gi_284;
         gi_284 = gi_280;
         gi_280 = g_datetime_292;
         gd_unused_232 = gd_224;
         gd_224 = gd_216;
         gd_216 = gd_240;
      }
      if (iLow(Symbol(), TradePeriod, li_0 - 3) >= iLow(Symbol(), TradePeriod, li_0 - 2) && iLow(Symbol(), TradePeriod, li_0 - 1) >= iLow(Symbol(), TradePeriod, li_0 - 2)) {
         gd_272 = iLow(Symbol(), TradePeriod, li_0 - 2);
         if (gd_272 == iLow(Symbol(), TradePeriod, li_0 - 2)) g_datetime_308 = iTime(Symbol(), TradePeriod, li_0 - 2);
      }
      if (g_datetime_308 > gi_296) {
         gi_unused_304 = gi_300;
         gi_300 = gi_296;
         gi_296 = g_datetime_308;
         gd_unused_264 = gd_256;
         gd_256 = gd_248;
         gd_248 = gd_272;
      }
      g_irsi_360 = iRSI(Symbol(), TradePeriod, RSIPeriod, PRICE_CLOSE, li_0 - 1);
      gd_368 = iRSI(Symbol(), TradePeriod, RSIPeriod, PRICE_CLOSE, li_0 - 2);
      g_irsi_376 = iRSI(Symbol(), TradePeriod, RSIPeriod, PRICE_CLOSE, li_0 - 3);
      if (g_irsi_360 < 30.0 || (gd_368 > 0.0 && gd_384 > 0.0 && gd_368 > gd_384)) {
         g_price_312 = 0;
         g_datetime_344 = 0;
         g_price_320 = 0;
         g_datetime_348 = 0;
         gd_384 = 0;
         g_datetime_488 = 0;
         gd_472 = 0;
         gi_492 = 0;
         g_irsi_392 = 0;
         g_datetime_432 = 0;
         g_irsi_400 = 0;
         g_datetime_436 = 0;
      }
      if (g_irsi_360 > 70.0 || (gd_368 > 0.0 && gd_408 > 0.0 && gd_368 < gd_408)) {
         g_price_328 = 0;
         g_datetime_352 = 0;
         g_price_336 = 0;
         g_datetime_356 = 0;
         gd_408 = 0;
         g_datetime_480 = 0;
         gd_464 = 0;
         gi_484 = 0;
         g_irsi_416 = 0;
         g_datetime_440 = 0;
         g_irsi_424 = 0;
         g_datetime_444 = 0;
      }
      if (g_price_312 == 0.0 && iRSI(Symbol(), TradePeriod, RSIPeriod, PRICE_CLOSE, iBarShift(Symbol(), TradePeriod, gi_280)) > 70.0) {
         g_price_312 = gd_216;
         g_datetime_344 = gi_280;
      }
      if (g_price_328 == 0.0 && iRSI(Symbol(), TradePeriod, RSIPeriod, PRICE_CLOSE, iBarShift(Symbol(), TradePeriod, gi_296)) < 30.0) {
         g_price_328 = gd_248;
         g_datetime_352 = gi_296;
      }
      if (g_irsi_376 <= gd_368 && g_irsi_360 <= gd_368 && gd_368 >= 70.0) {
         if (gd_384 == 0.0 || gd_368 >= gd_384) {
            gd_384 = gd_368;
            g_datetime_488 = iTime(Symbol(), TradePeriod, li_0 - 2);
         }
      }
      if (g_irsi_376 >= gd_368 && g_irsi_360 >= gd_368 && gd_368 <= 30.0) {
         if (gd_408 == 0.0 || gd_368 <= gd_408) {
            gd_408 = gd_368;
            g_datetime_480 = iTime(Symbol(), TradePeriod, li_0 - 2);
         }
      }
      if (g_price_312 > 0.0 && gd_216 > g_price_312 && gd_216 > g_price_320 || g_price_320 == 0.0 && gd_384 > 0.0) {
         g_price_320 = gd_216;
         g_datetime_348 = gi_280;
         gd_472 = 0;
         for (int li_4 = li_0; li_4 <= iBarShift(Symbol(), TradePeriod, MathMax(g_datetime_488, gi_492)); li_4++) {
            g_irsi_360 = iRSI(Symbol(), TradePeriod, RSIPeriod, PRICE_CLOSE, li_4 + 1);
            gd_368 = iRSI(Symbol(), TradePeriod, RSIPeriod, PRICE_CLOSE, li_4 + 2);
            g_irsi_376 = iRSI(Symbol(), TradePeriod, RSIPeriod, PRICE_CLOSE, li_4 + 3);
            if (g_irsi_376 <= gd_368 && g_irsi_360 <= gd_368 && gd_368 < gd_384 && gd_368 >= gd_472 || gd_472 == 0.0) {
               gd_472 = gd_368;
               gi_492 = Time[li_4 + 2];
            }
         }
         g_irsi_392 = gd_384;
         g_datetime_432 = g_datetime_488;
         g_irsi_400 = gd_472;
         g_datetime_436 = gi_492;
      }
      if (g_price_328 > 0.0 && gd_248 < g_price_328 && gd_248 < g_price_336 || g_price_336 == 0.0 && gd_408 > 0.0) {
         g_price_336 = gd_248;
         g_datetime_356 = gi_296;
         gd_464 = 0;
         for (int li_8 = li_0; li_8 <= iBarShift(Symbol(), TradePeriod, MathMax(g_datetime_480, gi_484)); li_8++) {
            g_irsi_360 = iRSI(Symbol(), TradePeriod, RSIPeriod, PRICE_CLOSE, li_8 + 1);
            gd_368 = iRSI(Symbol(), TradePeriod, RSIPeriod, PRICE_CLOSE, li_8 + 2);
            g_irsi_376 = iRSI(Symbol(), TradePeriod, RSIPeriod, PRICE_CLOSE, li_8 + 3);
            if (g_irsi_376 >= gd_368 && g_irsi_360 >= gd_368 && gd_368 > gd_408 && gd_368 <= gd_464 || gd_464 == 0.0) {
               gd_464 = gd_368;
               gi_484 = Time[li_8 + 2];
            }
         }
         g_irsi_416 = gd_408;
         g_datetime_440 = g_datetime_480;
         g_irsi_424 = gd_464;
         g_datetime_444 = gi_484;
      }
      Plot();
   }
}
Print(MarketInfo(Symbol(), MODE_STOPLEVEL));

//+------------------------------------------------------------------+
double NormDigits(double price) // dl+
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+
void GetATR() // dl+
{
 gd_636 = NormalizeDouble(ATRmultiplier * iATR(Symbol(), ATRTimePeriod, ATRperiod, ATRshift), Digits);
 if (gd_636 < MarketInfo(Symbol(), MODE_STOPLEVEL) * Point) gd_636 = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
 return;
}
//+------------------------------------------------------------------+
double CheckPrice(bool flag, double p1, double p2) //dl+
{
 if(p2==0.0) return(NormDigits(p2));

 double diff;
 if(flag)
 {
  diff=NormDigits(p1-p2);
  if(diff<MarketInfo(Symbol(), MODE_STOPLEVEL) * Point) 
   return(NormDigits(p1-MarketInfo(Symbol(), MODE_STOPLEVEL) * Point));
 }
 else
 {
  diff=NormDigits(p2-p1);
  if(diff<MarketInfo(Symbol(), MODE_STOPLEVEL) * Point) 
   return(NormDigits(p1+MarketInfo(Symbol(), MODE_STOPLEVEL) * Point));
 }

 return(NormDigits(p2));
}