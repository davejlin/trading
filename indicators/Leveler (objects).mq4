//+----------------------------------------------------------------------+
//|                                                          Leveler.mq4 |
//|                                                         David J. Lin |
//|                                                                      |
//| Searches for peak supply/demand levels based on heavy bars           |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, June 29, 2007                                           |
//+----------------------------------------------------------------------+
#property copyright "2007 David J. Lin"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 4

//---- input parameters
extern int BufferPips=3; // pips penetration to invalidate a level
extern int BarMin=3;     // previous bars to define breakout height
extern double Fraction=0.35; // fraction of level height for midpoint to qualify
extern int TimeFrame=PERIOD_H1;
 
//---- buffers
color supplyCLR=Red;
color demandCLR=LimeGreen;
double bufferLevelPips=20; // minimum BO bar high/low to define level height
double bufferPoints,bufferlevelPoints;
double sH[],sL[],dH[],dL[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//----
 bufferPoints=NormPoints(BufferPips);
 bufferlevelPoints=NormPoints(bufferLevelPips);
 IndicatorBuffers(4);
 SetIndexBuffer(0,sH);
 SetIndexBuffer(1,sL); 
 SetIndexBuffer(2,dH);
 SetIndexBuffer(3,dL); 
  
 SetIndexStyle(0,DRAW_LINE,0,2,Red);
 SetIndexStyle(1,DRAW_LINE,0,2,Red);
 SetIndexStyle(2,DRAW_LINE,0,2,LimeGreen);
 SetIndexStyle(3,DRAW_LINE,0,2,LimeGreen);

 SetIndexLabel(0, "SH");
 SetIndexLabel(1, "SL");
 SetIndexLabel(2, "DH");
 SetIndexLabel(3, "DL");
 
 IndicatorShortName("Leveler("+TimeFrame+")"); 
 
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
 int i,j,counted_bars,limit1,limit2,shift;datetime bartime;
 double atrshort,atrlong,atrratio,buffer,open,close,high,low,price,price1,price2;
 double highj,lowj,closej,closeH,closeL,openH,openL,vhigh,vlow,vdiff;
 double open1,open2,close1,close2,vupper,vlower,vbuffer,midpoint;
 string time,linename,label,label1,label2;
 color CLR; bool peakSupply,peakDemand,invalid;

// if(bartime==iTime(NULL,TimeFrame,0)) return;
// bartime=iTime(NULL,TimeFrame,0); 

 counted_bars = IndicatorCounted(); // IndicatorCounted() returns the count of unchanged bars minus one
// if(counted_bars>0) counted_bars++;
// else counted_bars=1;

 if(counted_bars==0) 
 {
  limit1=iBars(NULL,TimeFrame)-1;
  limit2=iBarShift(NULL,TimeFrame,Time[0],false);
 }
 else 
 {
  limit1=iBarShift(NULL,TimeFrame,Time[0],false);
  limit2=limit1;
 }
 
 for(i=limit1;i>=limit2;i--)
 { 
   
  if(i>iBars(NULL,TimeFrame)-4-BarMin) continue;   

  open=iOpen(NULL,TimeFrame,i);
  close=iClose(NULL,TimeFrame,i);
  high=iHigh(NULL,TimeFrame,i);
  low=iLow(NULL,TimeFrame,i); 
  
  GetLevels(i);
  
// Destroy old levels

  if(ObjectsTotal()>0)
  {
   for(j=ObjectsTotal()-1;j>=0;j--)
   {
    linename=ObjectName(j);
    CLR=ObjectGet(linename,OBJPROP_COLOR);
    price=ObjectGet(linename,OBJPROP_PRICE1);
    if(CLR==supplyCLR && close>NormDigits(price+bufferPoints)) ObjectDelete(linename);
    else if(CLR==demandCLR && close<NormDigits(price-bufferPoints)) ObjectDelete(linename);
   } 
  }
  
// Create new levels

  shift=iHighest(NULL,TimeFrame,MODE_CLOSE,BarMin,i+3);
  closeH=iClose(NULL,TimeFrame,shift);
  shift=iLowest(NULL,TimeFrame,MODE_CLOSE,BarMin,i+3);
  closeL=iClose(NULL,TimeFrame,shift); 

  shift=iHighest(NULL,TimeFrame,MODE_OPEN,BarMin,i+3);
  openH=iOpen(NULL,TimeFrame,shift);
  shift=iLowest(NULL,TimeFrame,MODE_OPEN,BarMin,i+3);
  openL=iOpen(NULL,TimeFrame,shift);
  
  vhigh=MathMax(closeH,openH);
  vlow=MathMin(closeL,openL);
  vdiff=vhigh-vlow;

  vbuffer=Fraction*vdiff;
  vupper=NormDigits(vhigh-vbuffer);
  vlower=NormDigits(vlow+vbuffer);
  
  invalid=false;
  for(j=i+3;j<=i+3+BarMin;j++)
  {
   midpoint=NormDigits(0.5*(iOpen(NULL,TimeFrame,j)+iClose(NULL,TimeFrame,j)));
   if (midpoint<vlower || midpoint>vupper)
   {
    invalid=true;
    break;
   }
  }

  if(invalid) continue;
  
  close1=iClose(NULL,TimeFrame,i+1); 
  close2=iClose(NULL,TimeFrame,i+2); 
  open1=iOpen(NULL,TimeFrame,i+1);
  open2=iOpen(NULL,TimeFrame,i+2);  

  peakDemand=false;peakSupply=false;
  
  if(close1>vhigh&&close2>vhigh&&open1>vhigh&&close>vhigh) peakDemand=true;
  if(close1<vlow&&close2<vlow&&open1<vlow&&close<vlow) peakSupply=true;

  if(peakDemand || peakSupply)
  {

   time=TimeToStr(iTime(NULL,TimeFrame,i),TIME_DATE|TIME_MINUTES);

   price1=vhigh;
   price2=vlow;
  
   if(peakDemand) 
   {
    CLR=demandCLR;
    label1=StringConcatenate("DH ",time);
    label2=StringConcatenate("DL ",time);
    if(vdiff<bufferlevelPoints)
     price2=NormDigits(vlow-(bufferlevelPoints-vdiff));
   }
   
   if(peakSupply) 
   {
    CLR=supplyCLR;
    label1=StringConcatenate("SH ",time);
    label2=StringConcatenate("SL ",time);
    if(vdiff<bufferlevelPoints)
     price1=NormDigits(vhigh+(bufferlevelPoints-vdiff));    
   }
  
   ObjectCreate(label1, OBJ_HLINE, 0, iTime(NULL,TimeFrame,i), price1);
   ObjectSet(label1, OBJPROP_WIDTH, 1);  
   ObjectSet(label1, OBJPROP_COLOR, CLR);
   ObjectSetText(label1,label1);  
   
   ObjectCreate(label2, OBJ_HLINE, 0, iTime(NULL,TimeFrame,i), price2);
   ObjectSet(label2, OBJPROP_WIDTH, 1);  
   ObjectSet(label2, OBJPROP_COLOR, CLR);
   ObjectSetText(label2,label2);    
  } 
 }
 return(0);
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
void GetLevels(int index)
{
 string linename1,linename2,date1,date2;
 string SH="SH", SL="SL", DH="DH", DL="DL";
 double price; bool done;
 int i,j;
 
 sH[index]=0;
 sL[index]=0;
 dH[index]=0;
 dL[index]=0;
 
 if(ObjectsTotal()>0)
 {
  for(i=ObjectsTotal()-1;i>=0;i--)
  {
   linename1=ObjectName(i);
   
   if(StringFind(linename1,SL)==0)  // closest supply low
   {
    date1=StringSubstr(linename1,3,16);
    done=false;
    for(j=ObjectsTotal()-1;j>=0;j--)
    {
     linename2=ObjectName(j);
     
     if(StringFind(linename2,SH)==0)  // closest supply high
     {
      date2=StringSubstr(linename2,3,16); 

      
      if(date1==date2)
      {
       sL[index]=ObjectGet(linename1,OBJPROP_PRICE1);      
       sH[index]=ObjectGet(linename2,OBJPROP_PRICE1);
      }
      else
      {
       sL[index]=0.00; // not a pair    
       sH[index]=ObjectGet(linename2,OBJPROP_PRICE1);  // needed for pending cancel
      }
      
      done=true;
      break;
     }
    }
    
    if(done) break;

   }
  } 
 
  for(i=ObjectsTotal()-1;i>=0;i--)
  {
   linename1=ObjectName(i);
   
   if(StringFind(linename1,DL)==0)
   {
    date1=StringSubstr(linename1,3,16);
    done=false;
    for(j=ObjectsTotal()-1;j>=0;j--)
    {
     linename2=ObjectName(j);
     
     if(StringFind(linename2,DH)==0)
     {
      date2=StringSubstr(linename2,3,16); 
      
      if(date1==date2)
      {
       dL[index]=NormDigits(ObjectGet(linename1,OBJPROP_PRICE1));      
       dH[index]=NormDigits(ObjectGet(linename2,OBJPROP_PRICE1));
      }
      else
      {
       dL[index]=NormDigits(ObjectGet(linename1,OBJPROP_PRICE1));  // needed for pending cancel
       dH[index]=NormDigits(0.00);  // not a pair
      }
      
      done=true;
      break;
     }
    }
  
    if(done) break;

   }
  }  
 }
 
// Print(SHigh," ",SLow," ",DHigh," ",DLow);
 return;
}
//+------------------------------------------------------------------+ 