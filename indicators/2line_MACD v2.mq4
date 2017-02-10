//+------------------------------------------------------------------+
//|                                                         MACD.mq4 |
//|                                Copyright © 2005, David W. Thomas |
//|                                           mailto:davidwt@usa.net |
//| Modification: color backgrounds for Jesper Pederson              |
//| jesperdenmark@hotmail.com                                        |
//|                                                                  |
//| Modified by David J. Lin                                         |
//| dave.j.lin@gmail.com                                             |
//| Evanston, IL, November 9, 2010                                   |
//+------------------------------------------------------------------+
// This is the correct computation and display of MACD.
#property copyright "Copyright © 2005, David W. Thomas"
#property link      "mailto:davidwt@usa.net"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Green

//---- input parameters
extern int       FastMAPeriod=12;
extern int       SlowMAPeriod=26;
extern int       SignalMAPeriod=9;
extern color     Up_Color=PaleGoldenrod;
extern color     Dn_Color=DarkGray;

//---- buffers
double MACDLineBuffer[];
double SignalLineBuffer[];
double HistogramBuffer[];

//---- variables
double alpha = 0;
double alpha_1 = 0;

int winindex;
string mainwinname="MainWindow";
string macdwinname="MACDWindow";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
   //---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MACDLineBuffer);
   SetIndexDrawBegin(0,SlowMAPeriod);
   SetIndexStyle(1,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(1,SignalLineBuffer);
   SetIndexDrawBegin(1,SlowMAPeriod+SignalMAPeriod);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,HistogramBuffer);
   SetIndexDrawBegin(2,SlowMAPeriod+SignalMAPeriod);
   //---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD v2("+FastMAPeriod+","+SlowMAPeriod+","+SignalMAPeriod+")");
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"Signal");
   //----
	alpha = 2.0 / (SignalMAPeriod + 1.0);
	alpha_1 = 1.0 - alpha;
   //----

   return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   //---- 
  int i,obj_total=ObjectsTotal(OBJ_RECTANGLE);
  string name,err;
  bool del;
  for(i=obj_total;i>=0;i--)
  {
   name=ObjectName(i);
   if(StringFind(name,mainwinname)>=0) del=ObjectDelete(name);
   else if(StringFind(name,macdwinname)>=0) del=ObjectDelete(name);
  }
  winindex=WindowFind("MACD v2("+FastMAPeriod+","+SlowMAPeriod+","+SignalMAPeriod+")");  
  ObjectsDeleteAll(winindex);
   //----
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   winindex=WindowFind("MACD v2("+FastMAPeriod+","+SlowMAPeriod+","+SignalMAPeriod+")");
   string objname;
   int limit;
   color indcolor;

   int counted_bars = IndicatorCounted();
   //---- check for possible errors
   if (counted_bars<0) return(-1);
   //---- last counted bar will be recounted
   if (counted_bars>0) counted_bars--;
   limit = Bars - counted_bars;

   for(int i=limit; i>=0; i--)
   {
      MACDLineBuffer[i] = iMA(NULL,0,FastMAPeriod,0,MODE_EMA,PRICE_CLOSE,i) - iMA(NULL,0,SlowMAPeriod,0,MODE_EMA,PRICE_CLOSE,i);
      SignalLineBuffer[i] = alpha*MACDLineBuffer[i] + alpha_1*SignalLineBuffer[i+1];
      HistogramBuffer[i] = MACDLineBuffer[i] - SignalLineBuffer[i];
      
      if(i>=Bars-1||i==0) continue;
      
      if(MACDLineBuffer[i]>=SignalLineBuffer[i]) indcolor=Up_Color;
      else                                       indcolor=Dn_Color;
        
      objname=StringConcatenate(mainwinname," ",DoubleToStr(Period(),0)," ",DoubleToStr(iTime(NULL,0,i),0));
      ObjectDelete(objname);
      ObjectCreate(objname,OBJ_RECTANGLE,0,iTime(NULL,0,i),1000,iTime(NULL,0,i-1),0);
      ObjectSet(objname,OBJPROP_COLOR,indcolor);
      
      objname=StringConcatenate(macdwinname," ",DoubleToStr(Period(),0)," ",DoubleToStr(iTime(NULL,0,i),0));  
      ObjectDelete(objname);         
      ObjectCreate(objname,OBJ_RECTANGLE,winindex,iTime(NULL,0,i),1,iTime(NULL,0,i-1),-1);
      ObjectSet(objname,OBJPROP_COLOR,indcolor);   
   }

   //----
   return(0);
}
//+------------------------------------------------------------------+