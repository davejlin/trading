//+------------------------------------------------------------------+
//|                                             Dinapoli Targets.mq4 |
//|                                                     David J. Lin |
//|                                                                  |
//|Coded by David J. Lin                                             |
//|dave.j.lin@sbcglobal.net                                          |
//|Evanston, IL, June 26, 2007                                       |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007 David J. Lin"
//+------------------------------------------------------------------+
//|                                              DinapoliTargets.mq4 |
//|                                            mishanya_fx@yahoo.com |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "mishanya"
#property link      "mishanya_fx@yahoo.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Blue
//---- input parameters
extern int       barn=300;
extern int       Length=6;
//---- buffers
double v1[],v2[],v3[],v4[],v5[];
//double ExtMapBuffer1[];
//double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

IndicatorBuffers(5);
SetIndexBuffer(0,v1);
SetIndexStyle(0,DRAW_LINE,0,2,Honeydew);
SetIndexBuffer(1,v2);
SetIndexStyle(1,DRAW_LINE,0,2,Red);
SetIndexBuffer(2,v3);
SetIndexStyle(2,DRAW_LINE,0,2,Green);
SetIndexBuffer(3,v4);
SetIndexStyle(3,DRAW_LINE,0,2,Yellow);
SetIndexBuffer(4,v5);
SetIndexStyle(4,DRAW_LINE,0,2,DarkOrchid);
SetIndexLabel(0, "D Start");
SetIndexLabel(1, "D Stop");
SetIndexLabel(2, "D T1");
SetIndexLabel(3, "D T2");
SetIndexLabel(4, "D T3");

//SetIndexEmptyValue(0,0.0);
//SetIndexDrawBegin(0, barn);
//SetIndexStyle(0,DRAW_SECTION);
//SetIndexBuffer(0,ExtMapBuffer1);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {

   ObjectDelete("Start line");
   ObjectDelete("Stop line");
   ObjectDelete("Target1 line");
   ObjectDelete("Target2 line");
   ObjectDelete("Target3 line");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int shift,Swing,Swing_n,uzl,i,zu,zd,mv;
   double PointA,PointB,PointC,Target1,Target2,Target3,Fantnsy,CrazyDream,Start,Stop;
   double LL,HH,BH,BL,NH,NL; 
   double Uzel[10000][3]; 
   string text;

 //---- last counted bar will be recounted
 if(counted_bars>0) counted_bars--;
 else counted_bars=1;
 
 int limit = Bars - counted_bars;
 
 //---- computations for D1 high/low
for(int j=limit;j>=0;j--)
{

 if(j+barn+Length>Bars) continue;
 
// loop from first bar to current bar (with shift=0) 
      Swing_n=0;Swing=0;uzl=0; 
      BH =High[j+barn];BL=Low[j+barn];zu=barn;zd=barn; 
for (shift=j+barn;shift>=j;shift--) { 
      LL=10000000;HH=-100000000; 
   for (i=shift+Length;i>=shift+1;i--) { 
         if (Low[i]< LL) {LL=Low[i];} 
         if (High[i]>HH) {HH=High[i];} 
   } 


   if (Low[shift]<LL && High[shift]>HH){ 
      Swing=2; 
      if (Swing_n==1) {zu=shift+1;} 
      if (Swing_n==-1) {zd=shift+1;} 
   } else { 
      if (Low[shift]<LL) {Swing=-1;} 
      if (High[shift]>HH) {Swing=1;} 
   } 

   if (Swing!=Swing_n && Swing_n!=0) { 
   if (Swing==2) {
      Swing=-Swing_n;BH = High[shift];BL = Low[shift]; 
   } 
      uzl=uzl+1; 
   if (Swing==1) {
      Uzel[uzl][1]=zd;
      Uzel[uzl][2]=BL;
   } 
   if (Swing==-1) {
      Uzel[uzl][1]=zu;
      Uzel[uzl][2]=BH; 
   } 
      BH = High[shift];
      BL = Low[shift]; 
   } 

   if (Swing==1) { 
      if (High[shift]>=BH) {BH=High[shift];zu=shift;}} 
      if (Swing==-1) {
          if (Low[shift]<=BL) {BL=Low[shift]; zd=shift;}} 
      Swing_n=Swing; 
   } 
   for (i=1;i<=uzl;i++) { 
      //text=DoubleToStr(Uzel[i][1],0);
      //text=;
         mv=StrToInteger(DoubleToStr(Uzel[i][1],0));
      //ExtMapBuffer1[mv]=Uzel[i][2];
   } 

PointA = Uzel[uzl-2][2];
PointB = Uzel[uzl-1][2];
PointC = Uzel[uzl][2];

Comment(PointA," ",PointB," ",PointC);

Target1=NormalizeDouble((PointB-PointA)*0.618+PointC,4);
Target2=PointB-PointA+PointC;
Target3=NormalizeDouble((PointB-PointA)*1.618+PointC,4);
Fantnsy=NormalizeDouble((PointB-PointA)*2.618+PointC,4);
CrazyDream=NormalizeDouble((PointB-PointA)*4.618+PointC,4);
if (PointB<PointC)
{
Start= NormalizeDouble((PointB-PointA)*0.318+PointC,4)-(Ask-Bid);
Stop=PointC+2*(Ask-Bid);
}
if (PointB>PointC)
{
Start= NormalizeDouble((PointB-PointA)*0.318+PointC,4)+(Ask-Bid);
Stop=PointC-2*(Ask-Bid);
}
   v1[j]=Start;
   v2[j]=Stop;
   v3[j]=Target1;
   v4[j]=Target2;
   v5[j]=Target3;
 }
 return(0);
}
//+------------------------------------------------------------------+