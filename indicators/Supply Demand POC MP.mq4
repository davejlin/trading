//+----------------------------------------------------------------------+
//|                                             Supply Demand POC MP.mq4 |
//|                                                         David J. Lin |
//|                                                                      |
//| Displays supply & demand POC (point-of-control) & cluster lines      |
//| as determined by the Market Profile M30 method                       | 
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, May 15, 2007                                            |
//+----------------------------------------------------------------------+
#property copyright "2007 David J. Lin"
#property link      ""

#property indicator_chart_window

//---- input parameters
extern int binperiod=PERIOD_M30;
extern bool volpercenttoggle=true;
//---- buffers
// Price & Volume arrays, possible price & volume points
double price[],volume[]; 
double binincrement;
datetime time1,time2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//----
 Comment("Supply Demand POC \nMarket Profile Bin Period: M"+binperiod);
 binincrement=NormDigits(Point);
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
//----
 ObjectsDeleteAll();
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
 int i,j,k,max,counted_bars,limit,rangePips,BarShiftStart,BarShiftEnd;
 double high,low,binhigh,binlow,lowprice,typprice,currentprice,maxprice,midprice,textprice,range,increment,volpercentage;
 string linename,textname,voltext;

 if (Period()<=1) return(0); // must be greater than M1 to function
 
 counted_bars = IndicatorCounted(); // IndicatorCounted() returns the count of unchanged bars minus one
 if(counted_bars>0) counted_bars++;
 else counted_bars=1;
 
 limit=Bars-counted_bars;

 for(i=limit;i>=0;i--) // don't mark the most recent, unformed bar
 {
  if(i==0)
  {
   BarShiftStart=iBarShift(NULL,binperiod,Time[i],  false);
   BarShiftEnd  =0;
  }
  else
  {
   BarShiftStart=iBarShift(NULL,binperiod,Time[i],  false);
   BarShiftEnd  =iBarShift(NULL,binperiod,Time[i-1],false);
  }
  
  if(BarShiftStart==BarShiftEnd) continue;
   
  high     =NormDigits(High[i]);
  low      =NormDigits(Low[i]);
  range    =NormDigits(high-low); 
  rangePips=range/Point;  
  rangePips+=1; // to avoid rangePips=0 situation

// resize, initialize, & load price & volume arrays

  ArrayResize(price,rangePips); 
  ArrayResize(volume,rangePips);
  ArrayInitialize(price,0);
  ArrayInitialize(volume,0);

  currentprice=low;

  for(j=0;j<rangePips;j++)
  {
   price[j]=currentprice;
   currentprice+=binincrement;
   currentprice=NormDigits(currentprice);
  }   

  for(k=BarShiftStart;k>BarShiftEnd;k--) // cycle through binperiod bars
  {
   binlow=iLow(NULL,binperiod,k);
   binhigh=iHigh(NULL,binperiod,k);

   for(j=0;j<rangePips;j++)
   {
    if(binlow<=price[j]&&binhigh>=price[j])
     volume[j]+=1;  // tally "volume" ... use as a placeholder to tally frequency
   }   
  }

//  if(TimeMonth(Time[i])==5&&TimeDay(Time[i])==10)
//  {
//   for(j=0;j<rangePips;j++)
//    Print(j," ",price[j]," ",volume[j]);
//  }  
  
// maximum price associated with maximum volume 

  max=ArrayMaximum(volume);
  maxprice=price[max];
  
  if(i==0)
  {
   time1=Time[1];
   time2=Time[0]+(Period()*60);
  }
  else
  {
   time1=Time[i+1];
   time2=Time[i-1];
  }
  
  linename=TimeToStr(Time[i],TIME_DATE|TIME_MINUTES);
  linename=StringConcatenate(linename,"MP");
  ObjectCreate(linename, OBJ_TREND, 0, time1, maxprice, time2, maxprice);
  ObjectSet(linename, OBJPROP_RAY, false);
  ObjectSet(linename, OBJPROP_WIDTH, 3);  
  ObjectSet(linename, OBJPROP_COLOR, Yellow);
  
  if(volpercenttoggle)
  {
   volpercentage=volume[max]/(Period()/binperiod)*100;
   voltext=DoubleToStr(volpercentage,0);
   textname=StringConcatenate(linename,"label");
  
   midprice=0.5*(high+low);
   if(maxprice>=midprice) textprice= high+30*Point;
   else textprice=low-25*Point;
  
   ObjectCreate(textname, OBJ_TEXT, 0, Time[i], textprice);
   ObjectSetText(textname, voltext, 6, "Arial", Yellow);  
  }  
 }
 return(0);
}
//+------------------------------------------------------------------+ 
double NormDigits(double price)
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+

