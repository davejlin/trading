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
#property indicator_color1 Red
#property indicator_color2 LimeGreen

//---- input parameters
extern int VolumeBin=53; // for tick charts
extern int TimeFrame=0;//PERIOD_H4;
extern int BufferPips=3; // pips penetration to invalidate a level
extern int BarMin=2;     // previous bars to define breakout height
extern int bufferLevelPips=20; // minimum BO bar high/low to define level height
extern double Fraction=0.25; // fraction of level height for midpoint to qualify
extern double Factor=2; // factor of level height to qualify as breakout
//---- buffers

double newfactor=1.0;  // factor of bufferlevelPoints to qualify for a new level

color supplyCLR=Red;
color demandCLR=LimeGreen;

double bufferPoints,bufferlevelPoints;
double sH[],sL[],dH[],dL[]; // indicator buffer
double sh[500],sl[500],dh[500],dl[500]; // stores values sequentially
string SH[500],SL[500],DL[500],DH[500]; // stores object names sequentially
int Nsh,Nsl,Ndh,Ndl; // current count 
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
  
 SetIndexStyle(0,DRAW_LINE,0,2,supplyCLR);
 SetIndexStyle(1,DRAW_LINE,0,2,supplyCLR);
 SetIndexStyle(2,DRAW_LINE,0,2,demandCLR);
 SetIndexStyle(3,DRAW_LINE,0,2,demandCLR);

 SetIndexLabel(0, "sH");
 SetIndexLabel(1, "sL");
 SetIndexLabel(2, "dH");
 SetIndexLabel(3, "dL");
 
 IndicatorShortName("Leveler("+TimeFrame+")"); 
 
 for(int i=0;i<100;i++)
 {
  sh[i]=0;sl[i]=0;dh[i]=0;dl[i]=0;  
 }
 
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
 int i,j,counted_bars,limit,shift3;datetime bartime;
 double atrshort,atrlong,atrratio,buffer,open,close,high,low,price,price1,price2;
 double openj,closej,closeH,closeL,openH,openL,vhigh,vlow,vdiff;
 double open1,open2,close1,close2,vupper,vlower,vbuffer,midpoint;
 double pdiff1,pdiff2;
 string time,linename,label,label1,label2;
 color CLR; bool peakSupply,peakDemand,invalid;

// if(bartime==iTime(NULL,TimeFrame,0)) return;
// bartime=iTime(NULL,TimeFrame,0); 

 counted_bars = IndicatorCounted(); // IndicatorCounted() returns the count of unchanged bars minus one
// if(counted_bars>0) counted_bars++;
// else counted_bars=1;

 if(counted_bars==0) limit=Bars-1;
 else limit=0;
 
 for(i=limit;i>=0;i--)
 { 
  
  if(i>Bars-4-BarMin) continue;   

  high=iCustom(NULL,TimeFrame,"Tick Charter",VolumeBin,0,i);
  low=iCustom(NULL,TimeFrame,"Tick Charter",VolumeBin,1,i);
  open=iCustom(NULL,TimeFrame,"Tick Charter",VolumeBin,2,i);
  close=iCustom(NULL,TimeFrame,"Tick Charter",VolumeBin,3,i);
  
  sH[i]=sh[Nsh];
  sL[i]=sl[Nsl];
  dH[i]=dh[Ndh];
  dL[i]=dl[Ndl];

// Destroy old levels

  if(sh[Nsh]>0)
  {
   if(high>NormDigits(sh[Nsh]+bufferPoints))
   {
    sH[i]=0;
    sh[Nsh]=0;
    DeleteObject(SH[Nsh]);
    Nsh--;
   }  
  } 
  
  if(sl[Nsl]>0)
  {
   if(high>NormDigits(sl[Nsl]+bufferPoints))
   {
    sL[i]=0;
    sl[Nsl]=0;
    DeleteObject(SL[Nsl]);
    Nsl--;
   }  
  }

  if(dh[Ndh]>0)
  {
   if(low<NormDigits(dh[Ndh]-bufferPoints))
   {
    dH[i]=0;
    dh[Ndh]=0;
    DeleteObject(DH[Ndh]);
    Ndh--;
   }  
  }  

  if(dl[Ndl]>0)
  {
   if(low<NormDigits(dl[Ndl]-bufferPoints))
   {
    dL[i]=0;
    dl[Ndl]=0;
    DeleteObject(DL[Ndl]);
    Ndl--;
   }  
  }

// Create new levels
  closeH=0;closeL=99999;openH=0;openL=99999;
  
  shift3=i+1;
  for(j=shift3;j<=shift3+BarMin;j++)
  {
   openj=iCustom(NULL,TimeFrame,"Tick Charter",VolumeBin,2,j);  
   closej=iCustom(NULL,TimeFrame,"Tick Charter",VolumeBin,3,j);
   if(closej>closeH) closeH=closej;
   if(closej<closeL) closeL=closej;
   if(openj>openH) openH=openj;
   if(openj<openL) openL=openj;
  }
  
  vhigh=MathMax(closeH,openH);
  vlow=MathMin(closeL,openL);
  vdiff=vhigh-vlow;

  vbuffer=Fraction*vdiff;
  vupper=NormDigits(vhigh-vbuffer);
  vlower=NormDigits(vlow+vbuffer);
  
  invalid=false;
  for(j=shift3;j<=shift3+BarMin;j++)
  {
   openj=iCustom(NULL,TimeFrame,"Tick Charter",VolumeBin,2,j);  
   closej=iCustom(NULL,TimeFrame,"Tick Charter",VolumeBin,3,j);  
   midpoint=NormDigits(0.5*(openj+closej));
   if (midpoint<vlower || midpoint>vupper)
   {
    invalid=true;
    break;
   }
  }

  if(invalid) continue;
  
  close1=iCustom(NULL,TimeFrame,"Tick Charter",VolumeBin,3,i+1);  
  close2=iCustom(NULL,TimeFrame,"Tick Charter",VolumeBin,3,i+2);  
  open1=iCustom(NULL,TimeFrame,"Tick Charter",VolumeBin,2,i+1); 
  open2=iCustom(NULL,TimeFrame,"Tick Charter",VolumeBin,2,i+2); 

  peakDemand=false;peakSupply=false;
  
  if(close>vhigh+Factor*vdiff) peakDemand=true;
  if(close<vlow-Factor*vdiff) peakSupply=true;

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

    pdiff1=MathAbs(dH[i]-price1);
    pdiff2=MathAbs(dL[i]-price2);

    if(pdiff1<newfactor*bufferlevelPoints) continue; 
    if(pdiff2<newfactor*bufferlevelPoints) continue;
     
    Ndh++;Ndl++; 
    dH[i]=price1;
    dL[i]=price2;    
    dh[Ndh]=price1;
    dl[Ndl]=price2;
    DH[Ndh]=label1;
    DL[Ndl]=label2;
   }
   
   if(peakSupply) 
   {
    CLR=supplyCLR;
    label1=StringConcatenate("SH ",time);
    label2=StringConcatenate("SL ",time);
    if(vdiff<bufferlevelPoints)
     price1=NormDigits(vhigh+(bufferlevelPoints-vdiff)); 
 
    pdiff1=MathAbs(sH[i]-price1);
    pdiff2=MathAbs(sL[i]-price2);

    if(pdiff1<newfactor*bufferlevelPoints) continue; 
    if(pdiff2<newfactor*bufferlevelPoints) continue;
     
    Nsh++;Nsl++; 
    sH[i]=price1;
    sL[i]=price2;    
    sh[Nsh]=price1;
    sl[Nsl]=price2;
    SH[Nsh]=label1;
    SL[Nsl]=label2; 
   }
  
   ObjectCreate(label1, OBJ_HLINE, 0, Time[i], price1);
   ObjectSet(label1, OBJPROP_WIDTH, 1);  
   ObjectSet(label1, OBJPROP_COLOR, CLR);
   ObjectSetText(label1,label1);  
   
   ObjectCreate(label2, OBJ_HLINE, 0, Time[i], price2);
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
void DeleteObject(string name)
{
 string linename;
 for(int j=ObjectsTotal()-1;j>=0;j--)
 {
  linename=ObjectName(j);
  if(linename==name) 
  {
   ObjectDelete(linename);
   return;
  }
 }
 return;
}