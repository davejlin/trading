#property  copyright "Copyright © 2005, Rachamim"

// Alert function added by David J. Lin, September 14, 2008
// dave.j.lin@sbcglobal.net

#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  MidnightBlue
#property  indicator_color2  Red

extern   int      float = 75;
extern   int      sh = 1;

extern bool   AlertEmail=true;
extern bool   AlertAlarm=true;
extern int    AlarmRepetition=3;

double   arr_84[];
double   arr_88[];
string   var_92;
int      var_100;
double   SummVol1;
double   SummVol2;
double   var_120;
double   var_128;
double   Range;
int      var_144;
int      var_148;
int      var_152;
int      MaxIndex;
int      MinIndex;
int      var_164;
int      var_168;
int      I;
int      J;
datetime lasttime;
//+------------------------------------------------------------------+

int init()
{
SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,4);
SetIndexBuffer(0,arr_84);
SetIndexStyle(1,DRAW_LINE);
SetIndexBuffer(1,arr_88);

for (int i = 0; i <= Bars - 1; i++)
   {
   arr_84[i] = 0;
   arr_88[i] = 0;
   }

IndicatorShortName("FL");
IndicatorShortName(var_92);
SetIndexLabel(0,var_92);
return(0);
}

//+------------------------------------------------------------------+

int start()
{
double var_start_0;
double var_start_8;
double var_start_16;
double var_start_24;
double var_start_32;
double var_start_40;

for (I = sh; I >= sh; I--)
   {
   SummVol1 = 0;
   SummVol2 = 0;
   var_144 = iHighest(NULL,0,MODE_HIGH,float,I);
   var_148 = iLowest(NULL,0,MODE_LOW,float,I);
   var_120 = High[var_144];
   var_128 = Low[var_148];
   Range = var_120 - var_128;
   var_152 = MathAbs(var_148 - var_144);
   if (var_144 < var_148)
      {
      MaxIndex = var_148;
      MinIndex = var_144;
      }
         else
      {
      MaxIndex = var_144;
      MinIndex = var_148;
      }
   if ((MaxIndex != var_164) || (MinIndex != var_168))
      {
      var_164 = MaxIndex;
      var_168 = MinIndex;
      for (J = MaxIndex; J >= MinIndex; J--)
         {
         SummVol2 = SummVol2 + Volume[J];
         }
      for (J = MaxIndex; J >= I; J--)
         {
         SummVol1 = SummVol1 + Volume[J];
         if (SummVol1 >= SummVol2) SummVol1 = 0;
         arr_84[J] = SummVol1 / 1000.0;
         arr_88[J] = SummVol2 / 1000.0;
         var_start_0 = var_120;
         var_start_8 = var_128;
         var_start_16 = var_144;
         var_start_24 = var_148;
         var_start_32 = SummVol2 - SummVol1;
         var_start_40 = SummVol2;
         ObjectDelete("MyLabel101");
         ObjectCreate("MyLabel101",OBJ_LABEL,WindowFind("FL"),0,0);
         ObjectSetText("MyLabel101",DoubleToStr(var_start_0,Digits),15,"Arial Bold",SteelBlue);
         ObjectSet("MyLabel101",OBJPROP_CORNER,0);
         ObjectSet("MyLabel101",OBJPROP_XDISTANCE,80);
         ObjectSet("MyLabel101",OBJPROP_YDISTANCE,13);
         ObjectDelete("MyLabel21");
         ObjectCreate("MyLabel21",OBJ_LABEL,WindowFind("FL"),0,0);
         ObjectSetText("MyLabel21",DoubleToStr(var_start_8,Digits),15,"Arial Bold",SteelBlue);
         ObjectSet("MyLabel21",OBJPROP_CORNER,0);
         ObjectSet("MyLabel21",OBJPROP_XDISTANCE,195);
         ObjectSet("MyLabel21",OBJPROP_YDISTANCE,13);
         ObjectDelete("MyLabel22");
         ObjectCreate("MyLabel22",OBJ_LABEL,WindowFind("FL"),0,0);
         ObjectSetText("MyLabel22",DoubleToStr(float,Digits - 4),12,"Arial Bold",SlateGray);
         ObjectSet("MyLabel22",OBJPROP_CORNER,0);
         ObjectSet("MyLabel22",OBJPROP_XDISTANCE,157);
         ObjectSet("MyLabel22",OBJPROP_YDISTANCE,13);
         ObjectCreate("labFL23",OBJ_LABEL,WindowFind("FL"),0,0);
         ObjectSetText("labFL23","BarHIGH ",9,"Arial Bold",SteelBlue);
         ObjectSet("labFL23",OBJPROP_CORNER,0);
         ObjectSet("labFL23",OBJPROP_XDISTANCE,82);
         ObjectSet("labFL23",OBJPROP_YDISTANCE,3);
         ObjectCreate("labFL24",OBJ_LABEL,WindowFind("FL"),0,0);
         ObjectSetText("labFL24","BarLOW ",9,"Arial Bold",SteelBlue);
         ObjectSet("labFL24",OBJPROP_CORNER,0);
         ObjectSet("labFL24",OBJPROP_XDISTANCE,195);
         ObjectSet("labFL24",OBJPROP_YDISTANCE,3);
         ObjectCreate("labFL25",OBJ_LABEL,WindowFind("FL"),0,0);
         ObjectSetText("labFL25","Float",9,"Arial Bold",SlateGray);
         ObjectSet("labFL25",OBJPROP_CORNER,0);
         ObjectSet("labFL25",OBJPROP_XDISTANCE,157);
         ObjectSet("labFL25",OBJPROP_YDISTANCE,3);
         ObjectDelete("labFL26");
         ObjectCreate("labFL26",OBJ_LABEL,WindowFind("FL"),0,0);
         ObjectSetText("labFL26",DoubleToStr(var_start_16,Digits - 4),9,"Arial Bold",SteelBlue);
         ObjectSet("labFL26",OBJPROP_CORNER,0);
         ObjectSet("labFL26",OBJPROP_XDISTANCE,130);
         ObjectSet("labFL26",OBJPROP_YDISTANCE,3);
         ObjectDelete("labFL27");
         ObjectCreate("labFL27",OBJ_LABEL,WindowFind("FL"),0,0);
         ObjectSetText("labFL27",DoubleToStr(var_start_24,Digits - 4),9,"Arial Bold",SteelBlue);
         ObjectSet("labFL27",OBJPROP_CORNER,0);
         ObjectSet("labFL27",OBJPROP_XDISTANCE,245);
         ObjectSet("labFL27",OBJPROP_YDISTANCE,3);
         ObjectDelete("labFL28");
         ObjectCreate("labFL28",OBJ_LABEL,WindowFind("FL"),0,0);
         ObjectSetText("labFL28",DoubleToStr(var_start_32,0),12,"Arial Bold",SlateGray);
         ObjectSet("labFL28",OBJPROP_CORNER,0);
         ObjectSet("labFL28",OBJPROP_XDISTANCE,330);
         ObjectSet("labFL28",OBJPROP_YDISTANCE,13);
         ObjectDelete("labFL29");
         ObjectCreate("labFL29",OBJ_LABEL,WindowFind("FL"),0,0);
         ObjectSetText("labFL29",DoubleToStr(var_start_40,0),12,"Arial Bold",SlateGray);
         ObjectSet("labFL29",OBJPROP_CORNER,0);
         ObjectSet("labFL29",OBJPROP_XDISTANCE,270);
         ObjectSet("labFL29",OBJPROP_YDISTANCE,13);
         ObjectCreate("labFL30",OBJ_LABEL,WindowFind("FL"),0,0);
         ObjectSetText("labFL30","Float Vol",9,"Arial Bold",SlateGray);
         ObjectSet("labFL30",OBJPROP_CORNER,0);
         ObjectSet("labFL30",OBJPROP_XDISTANCE,270);
         ObjectSet("labFL30",OBJPROP_YDISTANCE,3);
         ObjectCreate("labFL31",OBJ_LABEL,WindowFind("FL"),0,0);
         ObjectSetText("labFL31","Left",9,"Arial Bold",SlateGray);
         ObjectSet("labFL31",OBJPROP_CORNER,0);
         ObjectSet("labFL31",OBJPROP_XDISTANCE,330);
         ObjectSet("labFL31",OBJPROP_YDISTANCE,3);
         ObjectDelete("swingtop");
         ObjectDelete("swingbottom");
         ObjectDelete("CVSTART");
         ObjectDelete("CVEND");
         ObjectDelete("swingend");
         ObjectDelete("swingend2");
         ObjectDelete("swingend3");
         ObjectDelete("swingend4");
         ObjectDelete("swingend5");
         ObjectDelete("swingend6");
         ObjectDelete("swingend7");
         ObjectDelete("swingend8");
         ObjectDelete("swingend9");
         ObjectCreate("swingtop",OBJ_TREND,0,Time[MaxIndex],var_120,Time[1],var_120);
         ObjectSet("swingtop",OBJPROP_COLOR,White);
         ObjectSet("swingtop",OBJPROP_STYLE,STYLE_DOT);
         ObjectSet("swingtop",OBJPROP_WIDTH,1);
         ObjectCreate("swingbottom",OBJ_TREND,0,Time[MaxIndex],var_128,Time[1],var_128);
         ObjectSet("swingbottom",OBJPROP_COLOR,White);
         ObjectSet("swingbottom",OBJPROP_STYLE,STYLE_DOT);
         ObjectSet("swingbottom",OBJPROP_WIDTH,1);
         ObjectCreate("CVSTART",OBJ_TREND,0,Time[MaxIndex],var_120,Time[MaxIndex],var_128);
         ObjectSet("CVSTART",OBJPROP_COLOR,Lime);
         ObjectSet("CVSTART",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("CVSTART",OBJPROP_WIDTH,2);
         ObjectCreate("CVEND",OBJ_TREND,0,Time[MinIndex],var_120,Time[MinIndex],var_128);
         ObjectSet("CVEND",OBJPROP_COLOR,Red);
         ObjectSet("CVEND",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("CVEND",OBJPROP_WIDTH,2);
         if (MinIndex - var_152 > 0)
            {
            ObjectCreate("swingend",OBJ_TREND,0,Time[MinIndex - var_152 + 5],var_120,Time[MinIndex - var_152 + 5],var_128);
            ObjectSet("swingend",OBJPROP_COLOR,Lime);
            ObjectSet("swingend",OBJPROP_STYLE,STYLE_DOT);
            }
               else
            {
            ObjectDelete("swingend");
            }
         if (MinIndex - var_152 * 2 > 0)
            {
            ObjectCreate("swingend2",OBJ_TREND,0,Time[MinIndex - var_152 * 2 + 5],var_120,Time[MinIndex - var_152 * 2 + 5],var_128);
            ObjectSet("swingend2",OBJPROP_COLOR,Lime);
            ObjectSet("swingend2",OBJPROP_STYLE,STYLE_DOT);
            }
               else
            {
            ObjectDelete("swingend2");
            }
         if (MinIndex - var_152 * 3 > 0)
            {
            ObjectCreate("swingend3",OBJ_TREND,0,Time[MinIndex - var_152 * 3 + 5],var_120,Time[MinIndex - var_152 * 3 + 5],var_128);
            ObjectSet("swingend3",OBJPROP_COLOR,Lime);
            ObjectSet("swingend3",OBJPROP_STYLE,STYLE_DOT);
            }
               else
            {
            ObjectDelete("swingend3");
            }
         if (MinIndex - var_152 * 4 > 0)
            {
            ObjectCreate("swingend4",OBJ_TREND,0,Time[MinIndex - var_152 * 4 + 5],var_120,Time[MinIndex - var_152 * 4 + 5],var_128);
            ObjectSet("swingend4",OBJPROP_COLOR,Lime);
            ObjectSet("swingend4",OBJPROP_STYLE,STYLE_DOT);
            }
               else
            {
            ObjectDelete("swingend4");
            }
         if (MinIndex - var_152 * 5 > 0)
            {
            ObjectCreate("swingend5",OBJ_TREND,0,Time[MinIndex - var_152 * 5 + 5],var_120,Time[MinIndex - var_152 * 5 + 5],var_128);
            ObjectSet("swingend5",OBJPROP_COLOR,Lime);
            ObjectSet("swingend5",OBJPROP_STYLE,STYLE_DOT);
            }
               else
            {
            ObjectDelete("swingend5");
            }
         if (MinIndex - var_152 * 6 > 0)
            {
            ObjectCreate("swingend6",OBJ_TREND,0,Time[MinIndex - var_152 * 6 + 5],var_120,Time[MinIndex - var_152 * 6 + 5],var_128);
            ObjectSet("swingend6",OBJPROP_COLOR,Lime);
            ObjectSet("swingend6",OBJPROP_STYLE,STYLE_DOT);
            }
               else
            {
            ObjectDelete("swingend6");
            }
         if (MinIndex - var_152 * 7 > 0)
            {
            ObjectCreate("swingend7",OBJ_TREND,0,Time[MinIndex - var_152 * 7 + 5],var_120,Time[MinIndex - var_152 * 7 + 5],var_128);
            ObjectSet("swingend7",OBJPROP_COLOR,Lime);
            ObjectSet("swingend7",OBJPROP_STYLE,STYLE_DOT);
            }
               else
            {
            ObjectDelete("swingend7");
            }
         if (MinIndex - var_152 * 8 > 0)
            {
            ObjectCreate("swingend8",OBJ_TREND,0,Time[MinIndex - var_152 * 8 + 5],var_120,Time[MinIndex - var_152 * 8 + 5],var_128);
            ObjectSet("swingend8",OBJPROP_COLOR,Lime);
            ObjectSet("swingend8",OBJPROP_STYLE,STYLE_DOT);
            }
               else
            {
            ObjectDelete("swingend8");
            }
         if (MinIndex - var_152 * 9 > 0)
            {
            ObjectCreate("swingend9",OBJ_TREND,0,Time[MinIndex - var_152 * 9 + 5],var_120,Time[MinIndex - var_152 * 9 + 5],var_128);
            ObjectSet("swingend9",OBJPROP_COLOR,Lime);
            ObjectSet("swingend9",OBJPROP_STYLE,STYLE_DOT);
            }
               else
            {
            ObjectDelete("swingend9");
            }
         }
      }
   }

 if(AlertAlarm || AlertEmail)
 { 
  if(arr_84[1]==0) SendMessage();
 }

return(0);  
}

//+------------------------------------------------------------------+
void SendMessage()
{
 if(lasttime==iTime(NULL,0,0)) return(0);
 lasttime=iTime(NULL,0,0);
 
 string td=TimeToStr(iTime(NULL,0,0),TIME_DATE|TIME_MINUTES);     
 string message=StringConcatenate(Symbol()," Float has created a new histogram at ",td,".");
 for(int i=1;i<=AlarmRepetition;i++)
 {
  if (AlertAlarm) Alert(message);
  if (AlertEmail) SendMail("MT4 Float Alert!",message);
 }
 return;
}
//+------------------------------------------------------------------+