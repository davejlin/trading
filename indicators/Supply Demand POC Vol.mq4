//+----------------------------------------------------------------------+
//|                                                Supply Demand POC.mq4 |
//|                                                         David J. Lin |
//|                                                                      |
//| Displays supply & demand POC (point-of-control) & cluster lines      |
//| as defined by Sam Seiden <njstrader@yahoo.com>                       | 
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, May 10, 2007                                            |
//+----------------------------------------------------------------------+
#property copyright "2007 David J. Lin"
#property link      ""

#property indicator_chart_window

//---- input parameters
extern int binpips=1;
extern int TimePeriod=PERIOD_M1;
extern bool volpercenttoggle=false;
extern color Color=Blue;
//---- buffers
// Price & Volume arrays, actual & possible price & volume points
double actualprice[],actualvolume[],price[],volume[]; 
double binincrement;
datetime time1,time2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//----
 Comment("Supply Demand POC \nVolume Bin Pips: "+binpips);

 binincrement=binpips*NormDigits(Point);
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
//----
 ObDeleteObjectsByPrefix("POV");
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
 int i,j,k,max,counted_bars,limit,BarShiftM1Start,BarShiftM1End,rangeShift,rangePips;
 double high,low,lowprice,typprice,currentprice,maxprice,midprice,textprice,range,increment,volpercentage;
 string linename,textname,voltext;

 if (Period()<=1) return(0); // must be greater than M1 to function
 
 counted_bars = IndicatorCounted(); // IndicatorCounted() returns the count of unchanged bars minus one
 if(counted_bars>0) counted_bars--;
 else counted_bars=1;
 
 limit=Bars-counted_bars;

 for(i=limit;i>=0;i--)
 { 

// resize, initialize, & load actual price & volume arrays
  if(i==0)
  {
   BarShiftM1Start=iBarShift(NULL,TimePeriod,Time[i],  false);
   BarShiftM1End=0;
  }
  else
  {   
   BarShiftM1Start=iBarShift(NULL,TimePeriod,Time[i],  false);
   BarShiftM1End  =iBarShift(NULL,TimePeriod,Time[i-1],false);
  }
  
  if(BarShiftM1Start==BarShiftM1End) continue;  // if M1 data is more limited than present timeframe

  rangeShift=BarShiftM1Start-BarShiftM1End;

  ArrayResize(actualprice,rangeShift); 
  ArrayResize(actualvolume,rangeShift);
  ArrayInitialize(actualprice,0);
  ArrayInitialize(actualvolume,0);

  k=0;
  for(j=BarShiftM1Start;j>BarShiftM1End;j--) // cycle through prices
  {

   typprice=0.25*(iHigh(NULL,TimePeriod,j)+iLow(NULL,TimePeriod,j)+iClose(NULL,TimePeriod,j)+iClose(NULL,TimePeriod,j)); // close weighted 
//   typprice=(iHigh(NULL,TimePeriod,j)+iLow(NULL,TimePeriod,j)+iClose(NULL,TimePeriod,j))/3.0; // typical
//   typprice=0.5*(iHigh(NULL,TimePeriod,j)+iLow(NULL,TimePeriod,j)); // median
//   typprice=iClose(NULL,TimePeriod,j); // close

   actualprice[k]=NormDigits(typprice);
   actualvolume[k]=iVolume(NULL,TimePeriod,j);
   k++;
  }
  
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
   currentprice+=binincrement; // includes possible binning based on pips; binpips=1 is effectively no binning
   currentprice=NormDigits(currentprice);
  }   

  for(j=0;j<rangePips;j++)
  {
   for(k=0;k<rangeShift;k++) // cycle through prices
   {
    if(actualprice[k]>=price[j]&&actualprice[k]<price[j+1]) // bracket the price to allow for binning
     volume[j]+=actualvolume[k];  // tally volume
     
   }   
  }

// Checking the curious 2-level POC on April 6, 2007 for EURUSD
//  if(TimeMonth(Time[i])==4&&TimeDay(Time[i])==6)
//  {
//  for(j=0;j<rangePips;j++)
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
  
  linename=StringConcatenate("POV",i);  
  textname=StringConcatenate(linename,"label");

  if(i==0)
  {
   ObjectDelete(linename);
   ObjectDelete(textname);
  }

  ObjectCreate(linename, OBJ_TREND, 0, time1, maxprice, time2, maxprice);
  ObjectSet(linename, OBJPROP_RAY, false);
  ObjectSet(linename, OBJPROP_WIDTH, 1);  
  ObjectSet(linename, OBJPROP_COLOR, Color);
  
  if(volpercenttoggle)
  {
   volpercentage=volume[max]/iVolume(NULL,0,i)*100;
   voltext=DoubleToStr(volpercentage,0);
  
   midprice=0.5*(high+low);
   if(maxprice>=midprice) textprice= high+20*Point;
   else textprice=low-15*Point;
  
   ObjectCreate(textname, OBJ_TEXT, 0, Time[i], textprice);
   ObjectSetText(textname, voltext, 6, "Arial", White);  
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
void ObDeleteObjectsByPrefix(string Prefix)
  {
   int L = StringLen(Prefix);
   int i = 0; 
   while(i < ObjectsTotal())
     {
       string ObjName = ObjectName(i);
       if(StringSubstr(ObjName, 0, L) != Prefix) 
         { 
           i++; 
           continue;
         }
       ObjectDelete(ObjName);
     }
  }

