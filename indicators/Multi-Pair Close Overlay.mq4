//+----------------------------------------------------------------------+
//|                                         Multi-Pair Close Overlay.mq4 |
//|                                                         David J. Lin |
//| Multi-Pair Close Overlay                                             |
//|                                                                      |
//| Coded for Sérgio Spilari Filho <sergio@ssfconsultoriafinanceira.com> |
//| Coded by David J. Lin (dave.j.lin@gmail.com)                         |
//| Evanston, IL, June 2, 2013                                           |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2013,  Sérgio Spilari Filho and David J. Lin"

#include <stderror.mqh>

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Magenta
#property indicator_color4 Yellow

extern string Pair_1_Symbol = "";
extern string Pair_2_Symbol = "";
extern string Pair_3_Symbol = "";
extern string Pair_4_Symbol = "";

extern bool Pair_1_Invert = false;
extern bool Pair_2_Invert = false;
extern bool Pair_3_Invert = false;
extern bool Pair_4_Invert = false;

extern color Pair_1_Color = Red;
extern color Pair_2_Color = Blue;
extern color Pair_3_Color = Magenta;
extern color Pair_4_Color = Yellow;

extern bool DisplayPriceComment = true;

double ExtMapBuffer1[],ExtMapBuffer2[],ExtMapBuffer3[],ExtMapBuffer4[];
int nBarsChart,firstBarChart,lastBarChart;
double chartHigh,chartLow,chartCenter;
string Pair1Close,Pair2Close,Pair3Close,Pair4Close;
string Pair1Name,Pair2Name,Pair3Name,Pair4Name;
int precision;

int init() 
{
 IndicatorShortName("Multi-Pair Close Overlay");
 
 SetIndexBuffer(0,ExtMapBuffer1);
 SetIndexBuffer(1,ExtMapBuffer2);
 SetIndexBuffer(2,ExtMapBuffer3);
 SetIndexBuffer(3,ExtMapBuffer4);   

 SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,Pair_1_Color);
 SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1,Pair_2_Color);
 SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1,Pair_3_Color);
 SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,1,Pair_4_Color);
 
 SetIndexLabel(0,"Pair 1");
 SetIndexLabel(1,"Pair 2");
 SetIndexLabel(2,"Pair 3");
 SetIndexLabel(3,"Pair 4");
 
 string InvertString="(inv): ";
 string NormalString="      : ";
 
 Pair1Name = Pair_1_Symbol;
 if(Pair_1_Invert) Pair1Name = "1. "+Pair1Name+InvertString;
 else              Pair1Name = "1. "+Pair1Name+NormalString;

 Pair2Name = Pair_2_Symbol;
 if(Pair_2_Invert) Pair2Name = "2. "+Pair2Name+InvertString;
 else              Pair2Name = "2. "+Pair2Name+NormalString; 

 Pair3Name = Pair_3_Symbol;
 if(Pair_3_Invert) Pair3Name = "3. "+Pair3Name+InvertString;
 else              Pair3Name = "3. "+Pair3Name+NormalString;

 Pair4Name = Pair_4_Symbol;
 if(Pair_4_Invert) Pair4Name = "4. "+Pair4Name+InvertString;  
 else              Pair4Name = "4. "+Pair4Name+NormalString;      
 
 precision = 8;
 
 return(0);
}

int deinit()
{
 return(0);
}

int start()
{
 Refresh();
 DrawPairs();
 UpdateComment();  
 return(0);
}

void DrawPairs()
{
 if(Pair_1_Symbol!="")
   DrawPair(Pair_1_Symbol,Pair_1_Invert,ExtMapBuffer1,Pair1Close);

 if(Pair_2_Symbol!="")
   DrawPair(Pair_2_Symbol,Pair_2_Invert,ExtMapBuffer2,Pair2Close);

 if(Pair_3_Symbol!="")
   DrawPair(Pair_3_Symbol,Pair_3_Invert,ExtMapBuffer3,Pair3Close);

 if(Pair_4_Symbol!="")
   DrawPair(Pair_4_Symbol,Pair_4_Invert,ExtMapBuffer4,Pair4Close);
 
 return;
}

void DrawPair(string pair, bool invert, double &array[], string &close)
{
 int pairDigits = MarketInfo(pair,MODE_DIGITS);
 
 if(CheckError(pair))
  return(0);
 
 double pairHigh = indexHigh(invert,pair);
 double pairLow = indexLow(invert,pair);
 
 if(pairHigh-pairLow>0)
 {
  double ChartPairRatio = (chartHigh-chartLow)/(pairHigh-pairLow);

  for(int i=lastBarChart;i<lastBarChart+nBarsChart;i++) {

   double pairCenter = 0.5*(pairHigh+pairLow);   
   double pairClose = indexClose(invert,pair,i); 
   
   pairClose-=pairCenter;
   
   array[i] = chartCenter+(ChartPairRatio*pairClose);
  }
  close = DoubleToStr(indexClose(invert,pair,lastBarChart),precision);  
 }
 return(0);
}

void Refresh()
{
 RefreshRates();
 ChartRefresh();
 ArrayRefresh();
 return;
}

void ChartRefresh()
{
 Pair1Close="";
 Pair2Close="";
 Pair3Close="";
 Pair4Close=""; 
 
 nBarsChart = WindowBarsPerChart()+1;
 firstBarChart = WindowFirstVisibleBar();
 lastBarChart = firstBarChart-nBarsChart+1;
   
 if(lastBarChart<0){
  lastBarChart = 0;
  nBarsChart = firstBarChart+1;
 }

 chartHigh = High[iHighest(NULL,0,MODE_HIGH,nBarsChart,lastBarChart)];
 chartLow = Low[iLowest(NULL,0,MODE_LOW, nBarsChart,lastBarChart)];
 chartCenter = 0.5*(chartHigh+chartLow);
 return;
}

void ArrayRefresh()
{ 
 ArrayInitialize(ExtMapBuffer1,EMPTY_VALUE);
 ArrayInitialize(ExtMapBuffer2,EMPTY_VALUE);
 ArrayInitialize(ExtMapBuffer3,EMPTY_VALUE);
 ArrayInitialize(ExtMapBuffer4,EMPTY_VALUE);   
 return;
}

double indexClose(bool invert, string sym, int i)
{
 if(invert)
 {
  return(Recip(iClose(sym,0,i)));
 }
 else
 {
  return(iClose(sym,0,i));
 }
}

double indexHigh(bool invert, string sym)
{
 if(invert)
 {
  return (Recip(iLow(sym,0,iLowest(sym,0,MODE_LOW,nBarsChart,lastBarChart))));
 }
 else
 {
  return (iHigh(sym,0,iHighest(sym,0,MODE_HIGH,nBarsChart,lastBarChart)));
 }
}

double indexLow(bool invert, string sym)
{
 if(invert)
 {
  return (Recip(iHigh(sym,0,iHighest(sym,0,MODE_HIGH,nBarsChart,lastBarChart))));
 }
 else
 {
  return (iLow(sym,0,iLowest(sym,0,MODE_LOW,nBarsChart,lastBarChart)));
 }
}

bool CheckError(string pair)
{
 int error=GetLastError();

 if(error==ERR_NO_ERROR)
  return (false);
   
 return(true);
}

double Recip(double value)
{
 return(1.0/value);
}

void UpdateComment()
{
 if(!DisplayPriceComment)
  return;
  
 string info="";
 
 if(Pair_1_Symbol!="")
  info = StringConcatenate(Pair1Name," ",Pair1Close+"\n");

 if(Pair_2_Symbol!="")
  info = StringConcatenate(info,Pair2Name," ",Pair2Close+"\n");

 if(Pair_3_Symbol!="")
  info = StringConcatenate(info,Pair3Name," ",Pair3Close+"\n");

 if(Pair_4_Symbol!="")
  info = StringConcatenate(info,Pair4Name," ",Pair4Close);

 Comment(info);
 return;
}