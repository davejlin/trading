//+----------------------------------------------------------------------+
//|                                                 Point and Figure.mq4 |
//|                                                         David J. Lin |
//| Point and Figure                                                     |
//| written for Melvin D'Souza (dmx_lab@yahoo.com)                       |
//|                                                                      |
//| Coded by David J. Lin (dave.j.lin@gmail.com)                         |
//| Evanston, IL, July 30, 2011                                          |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2011, Melvin D\'Souza and David J. Lin"
#property  indicator_separate_window
#property  indicator_buffers 3

extern   int      boxValue = 10;
extern   int      Multiply = 3;
extern   bool     ShowGrid = true;
extern   color    ColorUp = Green;
extern   color    ColorDown = Red;
extern   color    PriceLevel = Red;
extern   color    GridColor = Gray;

double   pointValue;
int      windowID = -1;
double   boxPoint;

bool     flag1 = true;
bool     flag2 = false;
bool     flag3 = false;
bool     flag4 = true;
bool     flag5 = false;

double   valueD1 = 0;
double   valueD2 = 0;
double   valueD3 = 0;
double   valueD4;
double   valueD5;

int      valueI1 = 0;
int      valueI2 = 0;
int      valueI3 = 0;
int      valueI4;
int      valueI5;

int      boxID = 0;
int      NBars;

double   chartBuffer[],chartLow[],chartHigh[];

//+------------------------------------------------------------------+

int init()
{
 double myDigits;
 myDigits = MarketInfo (Symbol(), MODE_DIGITS);
 if (myDigits < 4) pointValue = 0.01;
 else              pointValue = 0.0001;
   
 if(MarketInfo(Symbol(),MODE_PROFITCALCMODE)!=0) pointValue=Point;
        
 NBars = Bars;

 SetIndexStyle(0,DRAW_NONE);
 SetIndexDrawBegin(0,0);
 SetIndexBuffer(0,chartBuffer);

SetIndexStyle(1,DRAW_NONE);
SetIndexDrawBegin(1,0);
SetIndexBuffer(1,chartLow);
SetIndexLabel(1,"Low");

SetIndexStyle(2,DRAW_NONE);
SetIndexDrawBegin(2,0);
SetIndexBuffer(2,chartHigh);
SetIndexLabel(2,"High");

 IndicatorShortName("Point and Figure (" + boxValue + "," + Multiply + ")");

 boxPoint = NormalizeDouble(boxValue*pointValue,Digits);
  
 return(0);
}

//+------------------------------------------------------------------+

int deinit()
{
 ObjectsDeleteAll(windowID);
 return(0);
}
//+------------------------------------------------------------------+

void createHighLow(int code)
{
 if (code != 0)
 {
  for (int i = valueI5 - 5; i >= 0; i--)
  {
   if (chartBuffer[i + 1] < chartBuffer[i])
   {
    chartHigh[i] = chartBuffer[i];
    chartLow[i] = chartBuffer[i + 1];
   }
   else if (chartBuffer[i + 1] > chartBuffer[i])
   {
    chartHigh[i] = chartBuffer[i + 1] - boxPoint;
    chartLow[i] = chartBuffer[i] - boxPoint;
   }
  }
 }
 else
 {
  if (chartBuffer[code + 1] < chartBuffer[code])
  {
   chartHigh[code] = chartBuffer[code];
   chartLow[code] = chartBuffer[code + 1];
  }
  else if (chartBuffer[code + 1] > chartBuffer[code])
  {
   chartHigh[code] = chartBuffer[code + 1] - boxPoint;
   chartLow[code] = chartBuffer[code] - boxPoint;
  }
 }
 return;
}
//+------------------------------------------------------------------+

void moveToFront(int limit)
{
 int    moveToFront1,moveToFront2;
 int    time1,time2;
 int    shift1,shift2;
 int    i,j,k;

 moveToFront1 = valueI3;
 
 for (i = 0; i <= boxID; i++)
 {
  time1 = ObjectGet("BodyX" + windowID + "_" + i,OBJPROP_TIME1);
  time2 = ObjectGet("BodyX" + windowID + "_" + i,OBJPROP_TIME2);
  shift1 = iBarShift(NULL,0,time1);
  shift2 = iBarShift(NULL,0,time2);
  ObjectSet("BodyX" + windowID + "_" + i,OBJPROP_TIME1,iTime(NULL,0,shift1 - moveToFront1));
  ObjectSet("BodyX" + windowID + "_" + i,OBJPROP_TIME2,iTime(NULL,0,shift2 - moveToFront1));
  ObjectSet("BodyXO" + windowID + "_" + i,OBJPROP_TIME1,iTime(NULL,0,shift1 - moveToFront1));
  ObjectSet("BodyXO" + windowID + "_" + i,OBJPROP_TIME2,iTime(NULL,0,shift2 - moveToFront1));
  if ((iTime(NULL,0,shift1 - moveToFront1) == 0) || (iTime(NULL,0,shift2 - moveToFront1) == 0)) flag5 = true;
 }

 moveToFront2 = 0;

 if (flag4)
 {
  flag4 = false;
  valueI5 = limit - valueI2-10;
  for (k = valueI2; k <= limit; k++)
  {
   chartBuffer[moveToFront2] = chartBuffer[k];
   moveToFront2++;
  }
 }
}

//+------------------------------------------------------------------+

void moveAllBack()
{
 int moveAllBack1,moveAllBack2;
 int time1,time2;
 int shift1,shift2;
 int i,j;

 moveAllBack1 = valueI3;

 for (i = boxID; i >= 0; i--)
 {
  time1 = ObjectGet("BodyX" + windowID + "_" + i,OBJPROP_TIME1);
  time2 = ObjectGet("BodyX" + windowID + "_" + i,OBJPROP_TIME2);
  shift1 = iBarShift(NULL,0,time1);
  shift2 = iBarShift(NULL,0,time2);
  ObjectSet("BodyX" + windowID + "_" + i,OBJPROP_TIME1,iTime(NULL,0,shift1 + 1));
  ObjectSet("BodyX" + windowID + "_" + i,OBJPROP_TIME2,iTime(NULL,0,shift2 + 1));
  ObjectSet("BodyXO" + windowID + "_" + i,OBJPROP_TIME1,iTime(NULL,0,shift1 + 1));
  ObjectSet("BodyXO" + windowID + "_" + i,OBJPROP_TIME2,iTime(NULL,0,shift2 + 1));
  if ((iTime(NULL,0,shift1 + 1) == 0) || (iTime(NULL,0,shift2 + 1) == 0)) flag5 = true;
 }
 
 for (j = valueI5; j >= 0; j--)
 {
  chartBuffer[j + 1] = chartBuffer[j];
  chartHigh[j + 1] = chartHigh[j];
  chartLow[j + 1] = chartLow[j];
 } 
}

//+------------------------------------------------------------------+

int drawNewX(double price, int shift)
{
 if (valueI2 < 0) valueI2 = 0;

 ObjectCreate("BodyXO" + windowID + "_" + boxID,OBJ_RECTANGLE,windowID,Time[valueI2],price,Time[valueI2 + 1],price + boxPoint);
 ObjectSet("BodyXO" + windowID + "_" + boxID,OBJPROP_STYLE,STYLE_SOLID);
 ObjectSet("BodyXO" + windowID + "_" + boxID,OBJPROP_BACK,1);
 ObjectSet("BodyXO" + windowID + "_" + boxID,OBJPROP_COLOR,ColorUp);

 ObjectCreate("BodyX" + windowID + "_" + boxID,OBJ_RECTANGLE,windowID,Time[valueI2],price,Time[valueI2 + 1],price + boxPoint);
 ObjectSet("BodyX" + windowID + "_" + boxID,OBJPROP_STYLE,STYLE_SOLID);
 ObjectSet("BodyX" + windowID + "_" + boxID,OBJPROP_BACK,0);
 ObjectSet("BodyX" + windowID + "_" + boxID,OBJPROP_COLOR,Blue);

 boxID++;
}

//+------------------------------------------------------------------+

int drawNewO(double price, int shift)
{
 if (valueI2 < 0) valueI2 = 0;

 ObjectCreate("BodyXO" + windowID + "_" + boxID,OBJ_RECTANGLE,windowID,Time[valueI2],price,Time[valueI2 + 1],price - boxPoint);
 ObjectSet("BodyXO" + windowID + "_" + boxID,OBJPROP_STYLE,STYLE_SOLID);
 ObjectSet("BodyXO" + windowID + "_" + boxID,OBJPROP_BACK,1);
 ObjectSet("BodyXO" + windowID + "_" + boxID,OBJPROP_COLOR,ColorDown);

 ObjectCreate("BodyX" + windowID + "_" + boxID,OBJ_RECTANGLE,windowID,Time[valueI2],price,Time[valueI2 + 1],price - boxPoint);
 ObjectSet("BodyX" + windowID + "_" + boxID,OBJPROP_STYLE,STYLE_SOLID);
 ObjectSet("BodyX" + windowID + "_" + boxID,OBJPROP_BACK,0);
 ObjectSet("BodyX" + windowID + "_" + boxID,OBJPROP_COLOR,Blue);

 boxID++;
}

//+------------------------------------------------------------------+

int doReversal(int code, int shift)
{
 double price;

 if (valueI2 < 0) valueI2 = 0;

 if (code == 0)
 {
  if (shift == 0) price = iClose(NULL,0,0); else price = High[shift];
  while (price > valueD1 + boxPoint)
  {
   drawNewX(valueD1,shift);
   valueD1 = valueD1 + boxPoint;
   chartBuffer[valueI2] = valueD1;
  }
 }
 else if (code == 1)
 {
  if (shift == 0) price = iClose(NULL,0,0); else price = Low[shift];
  while (price < valueD1 - boxPoint)
  {
   valueD1 = valueD1 - boxPoint;
   drawNewO(valueD1,shift);
   chartBuffer[valueI2] = valueD1;
  }
 }
}

//+------------------------------------------------------------------+

int start()
{
 int    counted_bars,limit,i,j,k;

 counted_bars = IndicatorCounted();
 windowID = WindowOnDropped();
 
 limit = Bars - counted_bars;
 if (limit > 0) limit--;
 else if (limit < 0) limit = 0;

 if (flag4)
 {
  ObjectsDeleteAll(windowID);
  ObjectCreate("priceLine_" + windowID,OBJ_HLINE,windowID,0,Time[0],0,0);
  ObjectSet("priceLine_" + windowID,OBJPROP_PRICE1,iClose(NULL,0,0));
  ObjectSet("priceLine_" + windowID,OBJPROP_COLOR,PriceLevel);
 }
 else
 {
  valueI2 = 0;
  ObjectSet("priceLine_" + windowID,OBJPROP_PRICE1,iClose(NULL,0,0));

  if (flag5)
  {
   flag5 = false;
   NBars = Bars - 5;
  }

  if ((MathAbs(NBars - Bars) >= 2) && (valueI4 > 0))
  {
   NBars = Bars;
   //Print("More than one bar fed to indicator -- ",Symbol());
   //Print("Reloading indicator -- ",Symbol());
   ObjectsDeleteAll(windowID);

   limit = Bars - 1;
   ObjectCreate("priceLine_" + windowID,OBJ_HLINE,windowID,0,Time[0],0,0);
   ObjectSet("priceLine_" + windowID,OBJPROP_PRICE1,iClose(NULL,0,0));
   ObjectSet("priceLine_" + windowID,OBJPROP_COLOR,PriceLevel);
   valueI1 = 0;
   flag1 = true;
   valueD3 = 0;
   flag4 = true;
  }
  else
  {
   if (valueI4 != Bars)
   {
    for (i = 1; i <= valueI5; i++)
    {
     chartBuffer[i - 1] = chartBuffer[i];
     chartHigh[i - 1] = chartHigh[i];
     chartLow[i - 1] = chartLow[i];
    }   
    valueI4 = Bars;
    valueI3 = 1;
    moveToFront(limit);
   }
  }
 }

 NBars = Bars;

 for (j = limit; j >= 0; j--)
 {

  if (flag1)
  {
   if (Open[j] > Close[j])
   {
    valueD1 = High[j];
    flag2 = false;
    flag3 = true;
    valueI2 = iBarShift(Symbol(),0,Time[j]);
   }
   else if (Open[j] < Close[j])
   {
    valueD1 = Low[j];
    flag2 = true;
    flag3 = false;
    valueI2 = iBarShift(Symbol(),0,Time[j]);
   }
   else if (Open[j] == Close[j]) continue;

   flag1 = false;
  }

  if (Time[j] > valueI1)
  {
   valueD2 = valueD1;
   valueI1 = Time[j];
  }

  if (flag2)
  {
   if (j == 0) valueD4 = iClose(NULL,0,0); else valueD4 = High[j];
   while (valueD4 >= valueD1 + boxPoint)
   {
    drawNewX(valueD1,j);
    valueD1 = valueD1 + boxPoint;
    chartBuffer[valueI2] = valueD1;
   }

   if (j == 0)
   {
    valueD5 = valueD1;
    valueD4 = iClose(NULL,0,0);
   }
   else
   {
    valueD5 = valueD2;
    valueD4 = Low[j];
   }

   if (valueD5 - NormalizeDouble(boxPoint*Multiply,Digits) >= valueD4)
   {
    if (valueI2 != 0) valueI2--;
    if (!flag4)
    {
     valueI5++;
     moveAllBack();
    }

    doReversal(1,j);
    flag2 = false;
    flag3 = true;
    continue;
   }
  }

  if (flag3)
  {
   if (j == 0) valueD4 = iClose(NULL,0,0); else valueD4 = Low[j];
   while (valueD4 <= valueD1 - boxPoint)
   {
    valueD1 = valueD1 - boxPoint;
    drawNewO(valueD1,j);
    chartBuffer[valueI2] = valueD1;
   }
 
   if (j == 0)
   {
    valueD5 = valueD1;
    valueD4 = iClose(NULL,0,0);
   }
   else
   {
    valueD5 = valueD2;
    valueD4 = High[j];
   }
 
   if (valueD5 + NormalizeDouble(boxPoint*Multiply,Digits) <= valueD4)
   {
    if (valueI2 != 0) valueI2--;
    if (!flag4)
    {
     valueI5++;
     moveAllBack();
    }
 
    doReversal(0,j);
    flag2 = true;
    flag3 = false;
   }
  }
 }

 if (flag4)
 {
  valueI3 = valueI2;
  valueI4 = Bars;
  moveToFront(limit);
  if (ShowGrid)
  {
   double v44 = High[iHighest(NULL,0,MODE_HIGH,0,0)];
   double v52 = Low[iLowest(NULL,0,MODE_LOW,0,0)];
   double v60 = v52 - NormalizeDouble(boxPoint*12,Digits);
   for (k = (v44 - v52) / pointValue / (boxValue * 4) + 6.0; k >= 0; k--)
   {
    ObjectCreate("GridLine_" + k + "_" + windowID,OBJ_HLINE,windowID,0,0,0,0);
    ObjectSet("GridLine_" + k + "_" + windowID,OBJPROP_PRICE1,v60);
    ObjectSet("GridLine_" + k + "_" + windowID,OBJPROP_STYLE,STYLE_DOT);
    ObjectSet("GridLine_" + k + "_" + windowID,OBJPROP_COLOR,GridColor);
    v60 = v60 + NormalizeDouble(boxPoint*4,Digits);
   }
  }
  createHighLow(1);
 }
 else
 {
  createHighLow(0);  
 }
}

