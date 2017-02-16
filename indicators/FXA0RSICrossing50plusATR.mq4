//+------------------------------------------------------------------+
//|                                       FXA0 - RSI Crossing 50.mq4 |
//|                           Copyright © 2007, Adam J. Richter M.S. |
//|                                                                  |
//| debugged & enhanced efficiency by David J. Lin, April 5, 2008    |
//| dave.j.lin@sbcglobal.net                                         |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Adam J. Richter M.S."
//Version 1.2 fixed 8 digit double to 4 digits and set to remove all objects in deinitialize 
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Green

double dUpRsiBuffer[];
double dDownRsiBuffer[];
double dSellBuffer[];

extern double ATR_Percent = 0.15;  //This value sets the ATR Used, The ATR is 15%
extern int RSI_Period = 21;  //This value sets the RSI Period Used, The default is 21
extern int ATR_Period = 21;  //This value sets the ATR Period Used, The default is 21

bool lastRSI60arrow=false;
bool lastRSI40arrow=false;
bool lastCloseLong=false;
bool lastCloseShort=false;
datetime thistime; 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator buffers mapping  
    SetIndexBuffer(0,dUpRsiBuffer);
    SetIndexBuffer(1,dDownRsiBuffer);  
    SetIndexBuffer(2,dSellBuffer); 
//---- drawing settings
    SetIndexStyle(0,DRAW_ARROW);
    SetIndexArrow(0,233); //241 option for different arrow head
    SetIndexStyle(1,DRAW_ARROW);
    SetIndexArrow(1,234); //242 option for different arrow head
    SetIndexStyle(2,DRAW_ARROW);
    SetIndexArrow(2,252);  //251 x sign or 252 green check
    
//----
    SetIndexEmptyValue(0,0.0);
    SetIndexEmptyValue(1,0.0);
    SetIndexEmptyValue(2,0.0);
//---- name for DataWindow
    SetIndexLabel(0,"Rsi Buy");
    SetIndexLabel(1,"Rsi Sell");
    SetIndexLabel(2,"Exit");
//----


   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
      ObjectsDeleteAll();
//----
   return(0);
  }
  
  
void printmyline(double vala, int topbottom) //print target line
{
   vala = NormalizeDouble(vala,4);
   if(topbottom==1)//target
   {
      ObjectCreate("theentry " + vala,OBJ_HLINE,0,0,vala);
      ObjectSet("theentry " + vala,OBJPROP_COLOR, Blue);
      ObjectSetText("theentry " + vala,"Long Entry",13,"Arial",Black);
   }
   if(topbottom==2)//stop
   {
      ObjectCreate("thestop " + vala,OBJ_HLINE,0,0,vala);
      ObjectSet("thestop " + vala,OBJPROP_COLOR, Blue);
      ObjectSetText("thestop " + vala,"Long Stop",13,"Arial",Black);
   }
}


void printmylinedown(double vala, int topbottom) //print target line
{
   vala = NormalizeDouble(vala,4);
   if(topbottom==1)//target
   {
      ObjectCreate("theentry " + vala,OBJ_HLINE,0,0,vala);
      ObjectSet("theentry " + vala,OBJPROP_COLOR, Red);
      ObjectSetText("theentry " + vala,"Short Entry",13,"Arial",Black);
   }
   if(topbottom==2)//stop
   {
      ObjectCreate("thestop " + vala,OBJ_HLINE,0,0,vala);
      ObjectSet("thestop " + vala,OBJPROP_COLOR, Red);
      ObjectSetText("thestop " + vala,"Short Stop",13,"Arial",Black);
   }
}
   
void deletealllines()
{
   ObjectsDeleteAll();
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   if(thistime==iTime(NULL,0,0)) return;
   thistime=iTime(NULL,0,0);
   
   int nBars;

   int nCountedBars=IndicatorCounted(); //ncountedbars 655

   if(nCountedBars>0)
   {
    nCountedBars++;
    nBars=Bars-nCountedBars;
   }
   else if(nCountedBars==0) nBars=Bars-nCountedBars-3;
   else return(-1);


   for (int ii=nBars; ii>0; ii--)
   {

      dUpRsiBuffer[ii]=0;
      dDownRsiBuffer[ii]=0;

      double myRSInow = iRSI(NULL,0,RSI_Period,PRICE_CLOSE,ii);
      double myRSI2 = iRSI(NULL,0,RSI_Period,PRICE_CLOSE,ii+1); //RSI One bar ago
      
      int shift=iBarShift(NULL,PERIOD_D1,iTime(NULL,0,ii),false);
      double myATR1 = iATR(NULL,PERIOD_D1,ATR_Period,shift);

      if (myRSInow>=50) //is going long
      {
         if(myRSInow>50 && myRSI2<50) //did it cross from below 50
         {
            deletealllines();
            dUpRsiBuffer[ii] = iLow(NULL,0,ii) - 2 * Point;
            printmyline((iHigh(NULL,0,ii+1)+(myATR1*ATR_Percent)),1);
            printmyline((iHigh(NULL,0,ii+1)+(myATR1*ATR_Percent))-(0.30*myATR1),2);
            lastCloseLong=false;
            lastRSI60arrow=false;                   
         }
         else if(myRSInow>=60 && myRSI2<60 && !lastRSI60arrow) //add to position at cross of 60, sometimes this can occur twice
         {
            dUpRsiBuffer[ii] = iLow(NULL,0,ii) - 2 * Point;
            lastRSI60arrow=true;
         }
         
         else if(myRSInow<70 && myRSI2>=70 && !lastCloseLong) //sell first lot
         {
            dSellBuffer[ii] = iHigh(NULL,0,ii) + 4 * Point;
            lastCloseLong=true;
         }
      }
      else //is going short 
      {
         if(myRSInow<50 && myRSI2>50) //did it cross from above 50
         {
            deletealllines();
            dDownRsiBuffer[ii] = iHigh(NULL,0,ii) + 2 * Point;
            printmylinedown((iLow(NULL,0,ii+1)-(myATR1*ATR_Percent)),1);
            printmylinedown((iLow(NULL,0,ii+1)-(myATR1*ATR_Percent))+(0.30*myATR1),2);
            lastCloseShort=false;
            lastRSI40arrow=false;
         }
         else if(myRSInow<=40 && myRSI2>40 && !lastRSI40arrow)
         {
            dDownRsiBuffer[ii] = iHigh(NULL,0,ii) + 2 * Point;
            lastRSI40arrow=true;      
         }
         else if(myRSInow>30 && myRSI2<=30 && !lastCloseShort)
         {
            dSellBuffer[ii] = iLow(NULL,0,ii) - 4 * Point;
            lastCloseShort=true;
         }
      } 
         
 
 
   }
}

