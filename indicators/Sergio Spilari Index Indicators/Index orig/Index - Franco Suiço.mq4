//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 DimGray
#property indicator_color2 DeepSkyBlue
#property indicator_style2 1
#property indicator_color3 PaleVioletRed
#property indicator_style3 2
#property indicator_color4 PaleVioletRed
#property indicator_color5 DeepSkyBlue
#property indicator_width4 2
#property indicator_width5 2

//
//
//
//
//

extern string SymbolsPrefix     = "";
extern string SymbolsSuffix     = "";
extern int    ShortTermMAperiod = 20;
extern int    ShortTermMAmethod = MODE_SMA;
extern int    LongTermMAperiod  = 40;
extern int    LongTermMAmethod  = MODE_SMA;

extern bool   ShowLineValue    = true;
extern bool   ShowBars         = true;
extern bool   ShowCrossingDots = false;
extern string Identifier       = "fxyBars";
extern color  colorBarDown     = Red;
extern color  colorBarUp       = Blue;
extern color  colorBarNeutral  = DimGray;
extern color  colorWickUp      = Blue;
extern color  colorWickDown    = Red;
extern color  colorWickNeutral = DimGray;
extern int    widthWick        = 1;
extern int    widthBody        = 3;

extern bool   alertsOn         = false;
extern bool   alertsOnCurrent  = false;
extern bool   alertsMessage    = false;
extern bool   alertsSound      = false;
extern bool   alertsEmail      = false;

//
//
//
//
//

double diClose[];
double diHigh[];
double diLow[];
double diOpen[];
double diMa1[];
double diMa2[];
double arrUp[];
double arrDn[];
double trend[];

//
//
//
//
//

int    window;
string name;
string indicatorFileName;
bool   returnBars;
string symbols[] = {"USDCHF","EURCHF","GBPCHF","CHFJPY","AUDCHF","CADCHF","NZDCHF"};
double pows[]    = {-0.100,-0.100,-0.100,0.100,-0.100,-0.100,-0.100};

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//

int init()
{
   IndicatorBuffers(8);
   SetIndexBuffer(0,diClose);  SetIndexLabel(0,"FXY");
   SetIndexBuffer(1,diMa1);    SetIndexLabel(1,ShortTermMAperiod+" average");
   SetIndexBuffer(2,diMa2);    SetIndexLabel(2,LongTermMAperiod+" average");   
   SetIndexBuffer(3,arrDn);    
   SetIndexBuffer(4,arrUp);    
   SetIndexBuffer(5,diHigh);   SetIndexLabel(5,""); SetIndexStyle(5,DRAW_NONE);
   SetIndexBuffer(6,diLow);    SetIndexLabel(6,""); SetIndexStyle(6,DRAW_NONE);
   SetIndexBuffer(7,diOpen);

      //
      //
      //
      //
      //
      
         if (ShowLineValue)
               SetIndexStyle(0,DRAW_LINE);
         else  SetIndexStyle(0,DRAW_NONE);
         if (ShowCrossingDots)
         {
               SetIndexStyle(3,DRAW_ARROW); SetIndexArrow(3,159);
               SetIndexStyle(4,DRAW_ARROW); SetIndexArrow(4,159);
         }
         else
         {
               SetIndexStyle(3,DRAW_NONE);
               SetIndexStyle(4,DRAW_NONE);
         
         }
         for (int i=0; i<6; i++) symbols[i] = SymbolsPrefix+symbols[i]+SymbolsSuffix;
      
      //
      //
      //
      //
      //
            
   name = "("+Identifier+") Franco Suiço Index: FXY / "+ShortTermMAperiod+","+LongTermMAperiod; IndicatorShortName(name);
   return(0);
}

//
//
//
//
//

int deinit()
{
   string oName;
   for (int i = ObjectsTotal() - 1; i >= 0; i--)
   {
      oName = ObjectName(i); if (StringFind(oName, name, 0) >= 0) ObjectDelete(oName);
   }
   return (0);
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

int start()
{
   int i,r,limit,counted_bars=IndicatorCounted();

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit  = MathMin(Bars-counted_bars,Bars-1);
         window = WindowFind(name);
         if (returnBars) { diClose[0] = limit+1; return(0); }
         if (ArraySize(trend)!=Bars) ArrayResize(trend,Bars);

   //
   //
   //
   //
   //

   for (i=0; i<6; i++) limit = MathMax(limit,MathMin(Bars-1,iCustom(symbols[i],0,indicatorFileName,"returnBars",0,0)));
   for (i=limit; i>=0; i--)
   {
      double dxyClose = 50.14348112;
      double dxyOpen  = 50.14348112;
      double dxyHigh  = 50.14348112;
      double dxyLow   = 50.14348112;
      for (int k=0; k<6; k++)
      {
         int y = iBarShift(symbols[k],0,Time[i]);
            dxyClose *= MathPow(iClose(symbols[k],0,y),pows[k]);
            dxyOpen  *= MathPow(iOpen (symbols[k],0,y),pows[k]);
            dxyHigh  *= MathPow(iHigh (symbols[k],0,y),pows[k]);
            dxyLow   *= MathPow(iLow  (symbols[k],0,y),pows[k]);
      }
      diOpen[i]  = dxyOpen;
      diHigh[i]  = dxyHigh;
      diLow[i]   = dxyLow;
      diClose[i] = dxyClose; if (!ShowBars) continue;

      //
      //
      //
      //
      //

      color  theBarColor  = colorBarNeutral;
      color  theWickColor = colorWickNeutral;
         if (diClose[i]<diOpen[i]) { theBarColor = colorBarDown; theWickColor = colorWickDown; }
         if (diClose[i]>diOpen[i]) { theBarColor = colorBarUp;   theWickColor = colorWickUp;   }
               
         drawBar(Time[i],diHigh[i],diLow[i],diOpen[i],diClose[i],theBarColor,theWickColor);
   }     
   
   //
   //
   //
   //
   //
   
   for(i=limit, r=Bars-i-1; i>=0; i--,r++)
   {
      diMa1[i] = iMAOnArray(diClose,0,ShortTermMAperiod,0,ShortTermMAmethod,i);
      diMa2[i] = iMAOnArray(diClose,0,LongTermMAperiod ,0,LongTermMAmethod ,i);
      arrUp[i] = EMPTY_VALUE;
      arrDn[i] = EMPTY_VALUE;
      trend[r] = trend[r-1];
         if (diMa1[i] > diMa2[i]) trend[r] =  1;
         if (diMa1[i] < diMa2[i]) trend[r] = -1;
         if (trend[r] != trend[r-1])
            {
               double range = 0;
               for (k=0; k<10; k++) range += MathAbs(diHigh[i+k]-diLow[i+k]); 
                                    range /= 10.0;
               if (trend[r]== 1) arrUp[i] = diMa2[i] - range;
               if (trend[r]==-1) arrDn[i] = diMa1[i] + range;
            }
   } 
   manageAlerts();
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void drawBar(int bTime, double prHigh, double prLow, double prOpen, double prClose, color barColor, color wickColor)
{
   string oName;
          oName = name+TimeToStr(bTime)+"w";
            if (ObjectFind(oName) < 0) ObjectCreate(oName,OBJ_TREND,window,bTime,0,bTime,0);
                 ObjectSet(oName, OBJPROP_PRICE1, prHigh);
                 ObjectSet(oName, OBJPROP_PRICE2, prLow);
                 ObjectSet(oName, OBJPROP_COLOR, wickColor);
                 ObjectSet(oName, OBJPROP_WIDTH, widthWick);
                 ObjectSet(oName, OBJPROP_RAY, false);
                 ObjectSet(oName, OBJPROP_BACK, true);
           
         oName = name+TimeToStr(bTime)+"b";
            if (ObjectFind(oName) < 0)ObjectCreate(oName,OBJ_TREND,window,bTime,0,bTime,0);
                 ObjectSet(oName, OBJPROP_PRICE1, prOpen);
                 ObjectSet(oName, OBJPROP_PRICE2, prClose);
                 ObjectSet(oName, OBJPROP_COLOR, barColor);
                 ObjectSet(oName, OBJPROP_WIDTH, widthBody);
                 ObjectSet(oName, OBJPROP_RAY, false);
                 ObjectSet(oName, OBJPROP_BACK, true);
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = Bars-whichBar-1;
      if (trend[whichBar] != trend[whichBar-1])
      {
            if (trend[whichBar] ==  1) doAlert(whichBar,"up");
            if (trend[whichBar] == -1) doAlert(whichBar,"down");
      }
   }
}

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

       message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," short term ma crossed long term ma ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"dolar index"),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}


