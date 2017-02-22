#property  copyright "Emerald King"
#property  link "mailto:info@emerald-king.com"

// Alert function added by David J. Lin, September 14, 2008
// dave.j.lin@sbcglobal.net

#property  indicator_separate_window
#property  indicator_level2  0.75
#property  indicator_level3  0.45
#property  indicator_level4  0.15

extern   double   gamma = 0.7;
extern   int      CountBars = 950;

extern bool   AlertEmail=true;
extern bool   AlertAlarm=true;
extern int    AlarmRepetition=3;
extern double AlarmThreshold=0.7000;

double   var_88 = 0;
double   var_96 = 0;
double   var_104 = 0;
double   var_112 = 0;
double   var_120 = 0;
double   var_128 = 0;
double   var_136 = 0;
double   var_144 = 0;
double   var_152 = 0;
double   var_160 = 0;
double   var_168 = 0;
double   arr_176[];

datetime lasttime;

//+------------------------------------------------------------------+

int init()
{
SetIndexBuffer(0,arr_176);
return(0);
}

//+------------------------------------------------------------------+

int deinit()
{
return(0);
}

//+------------------------------------------------------------------+

int start()
{
if (CountBars > Bars) CountBars = Bars;
SetIndexDrawBegin(0,Bars - CountBars);

int i;
int counted_bars = IndicatorCounted();

for (i = CountBars - 1; i >= 0; i--)
   {
   var_120 = var_88;
   var_128 = var_96;
   var_136 = var_104;
   var_144 = var_112;
   var_88 = (1 - gamma) * Close[i] + gamma * var_120;
   var_96 = -gamma * var_88 + var_120 + gamma * var_128;
   var_104 = -gamma * var_96 + var_128 + gamma * var_136;
   var_112 = -gamma * var_104 + var_136 + gamma * var_144;
   var_160 = 0;
   var_168 = 0;
   if (var_88 >= var_96) var_160 = var_88 - var_96; else var_168 = var_96 - var_88;
   if (var_96 >= var_104) var_160 = var_160 + var_96 - var_104; else var_168 = var_168 + var_104 - var_96;
   if (var_104 >= var_112) var_160 = var_160 + var_104 - var_112; else var_168 = var_168 + var_112 - var_104;
   if (var_160 + var_168 != 0.0) var_152 = var_160 / (var_160 + var_168);
   arr_176[i] = var_152;
   }
 
 if(AlertAlarm || AlertEmail)
 {
       if(arr_176[1]>=AlarmThreshold&&arr_176[0]<=AlarmThreshold) SendMessage(AlarmThreshold,arr_176[0]);
  else if(arr_176[1]<=AlarmThreshold&&arr_176[0]>=AlarmThreshold) SendMessage(AlarmThreshold,arr_176[0]);
  
 }  
   
return(0);
}
//+------------------------------------------------------------------+
void SendMessage(string bias, double v1)
{
 if(lasttime==iTime(NULL,0,0)) return(0);
 lasttime=iTime(NULL,0,0);

 string td=TimeToStr(iTime(NULL,0,0),TIME_DATE|TIME_MINUTES);     
 string message=StringConcatenate(Symbol()," Laguerre has crossed ", bias, " at ",td,". Laguerre value=",v1);
 for(int i=1;i<=AlarmRepetition;i++)
 {
  if (AlertAlarm) Alert(message);
  if (AlertEmail) SendMail("MT4 Laguerre Alert!",message);
 }
 return;
}
//+------------------------------------------------------------------+