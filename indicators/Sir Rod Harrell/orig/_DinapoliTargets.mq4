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
double ExtMapBuffer1[];
//double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexEmptyValue(0,0.0);
  //SetIndexDrawBegin(0, barn);
   //SetIndexStyle(0,DRAW_SECTION);
   SetIndexBuffer(0,ExtMapBuffer1);
   
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
// loop from first bar to current bar (with shift=0) 
      Swing_n=0;Swing=0;uzl=0; 
      BH =High[barn];BL=Low[barn];zu=barn;zd=barn; 

for (shift=barn;shift>=0;shift--) { 
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


   if (ObjectFind("Start Line") != 0) 
     {
      ObjectCreate("Start line",OBJ_HLINE,0,Time[0],Start);
      ObjectSet("Start line",OBJPROP_COLOR,Honeydew);
      ObjectSet("Start line",OBJPROP_WIDTH,1);
      ObjectSet("Start line",OBJPROP_STYLE,STYLE_DOT);
     }
     else
     {
     ObjectMove("Start line", 0,Time[0],Start);
     }

   if (ObjectFind("Stop Line") != 0) 
     {
      ObjectCreate("Stop line",OBJ_HLINE,0,Time[0],Stop);
      ObjectSet("Stop line",OBJPROP_COLOR,Red);
      ObjectSet("Stop line",OBJPROP_WIDTH,1);
      ObjectSet("Stop line",OBJPROP_STYLE,STYLE_DOT);
     }
     else
     {
     ObjectMove("Stop line", 0,Time[0],Stop);
     }
    
    if (ObjectFind("Target1 Line") != 0) 
     {
      ObjectCreate("Target1 line",OBJ_HLINE,0,Time[0],Target1);
      ObjectSet("Target1 line",OBJPROP_COLOR,Green);
      ObjectSet("Target1 line",OBJPROP_WIDTH,1);
      ObjectSet("Target1 line",OBJPROP_STYLE,STYLE_DOT);
     }
     else
     {
     ObjectMove("Target1 line", 0,Time[0],Target1);
     }

    if (ObjectFind("Target2 Line") != 0) 
     {
      ObjectCreate("Target2 line",OBJ_HLINE,0,Time[0],Target2);
      ObjectSet("Target2 line",OBJPROP_COLOR,Yellow);
      ObjectSet("Target2 line",OBJPROP_WIDTH,1);
      ObjectSet("Target2 line",OBJPROP_STYLE,STYLE_DOT);
     }
     else
     {
     ObjectMove("Target2 line", 0,Time[0],Target2);
     }
    
    if (ObjectFind("Target3 Line") != 0) 
     {
      ObjectCreate("Target3 line",OBJ_HLINE,0,Time[0],Target3);
      ObjectSet("Target3 line",OBJPROP_COLOR,DarkOrchid);
      ObjectSet("Target3 line",OBJPROP_WIDTH,1);
      ObjectSet("Target3 line",OBJPROP_STYLE,STYLE_DOT);
     }
     else
     {
     ObjectMove("Target3 line", 0,Time[0],Target3);
     }
   return(0);
  }
//+------------------------------------------------------------------+