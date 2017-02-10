//+------------------------------------------------------------------+
//|MTF_SnakeBorders                              #MTF_SnakeForce.mq4 |
//|                      Copyright © 2011, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------+
//| "This Indicator Is An Official Component Of:			                  |
//| "Angiebot Technologies TM"                                             |
//| "Angiebot Pro TM"							                                 |
//| "Angiebot Institutional TM"						                           |
//| "Angiebot Premium Investment Grade Technologies TM"			            |
//| "MIIT Macro Institutional Investment Trader TM"			               |
//| "BlackBox Industries For MT4/MT5"					                        |
//| "A20&2HFIT"	/ "A50&5HFIT" / "A80&5HFIT"				                  |
//+------------------------------------------------------------------------+
//|  Modified By:		 					                                       |
//| "Rod MT5 Harrell" 2008-2011						                           |
//|  549 - 66th Street, Oakland, California, 94609-1117, USA         	   |
//|  SirRodCA@aol.com / SirRodUS@aol.com				                        |
//|  +1-510-655-4966 (PST) 						                              |
//+------------------------------------------------------------------------+

#property copyright "Copyright © 2011, Rod MT5 Harrell, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property link      "Angiebot Premium Trade Technologies TM"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  Lime
#property indicator_color2  Red
#property indicator_color3  Lime
#property indicator_color4  Red
//----
extern int TimeFrame =0;
extern int  cPeriod=24; 
//----
double    ForceUp[];
double    ForceDown[];
double    ResistanceUp[];
double    ResistanceDown[];
//----
int init()
{
int    draw_begin;
double indperiod,val1,val2;
string CommentStr;
   draw_begin=3*cPeriod;
   IndicatorBuffers(5);
   SetIndexBuffer(0,ForceUp);
   SetIndexBuffer(1,ForceDown);
   SetIndexBuffer(2,ResistanceUp);
   SetIndexBuffer(3,ResistanceDown);
   SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,2);
   SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,2);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexLabel(2,NULL);
   SetIndexLabel(3,NULL);
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);
   SetIndexDrawBegin(3,draw_begin);
   indperiod=1.0*cPeriod*Period();
   if(indperiod<60)
   {
      CommentStr=DoubleToStr(indperiod,0);
      CommentStr=" M"+CommentStr+", FORCE UP -DOWN ";
   }
   else
   {
      indperiod=indperiod/100;
      if(indperiod>=50)
      {
         val1=MathAbs(MathRound(indperiod/50)-indperiod/50);
         if(val1<0.01)
         {
            CommentStr=DoubleToStr(indperiod/50,0);
            CommentStr=" D"+CommentStr+", FORCE UP -DOWN ";
         }
          else
         {
            CommentStr=DoubleToStr(indperiod/50,1);
            CommentStr=" D"+CommentStr+", FORCE UP -DOWN ";
         }
      }
      else
      {
         val1=MathAbs(MathRound(indperiod)-indperiod);
         if(val1<0.01)
         {
            CommentStr=DoubleToStr(indperiod,0);
            CommentStr=" H"+CommentStr+", FORCE UP -DOWN ";
         }
          else
         {
            CommentStr=DoubleToStr(indperiod,1);
            CommentStr=" H"+CommentStr+", FORCE UP -DOWN ";
         }
      }
   }
   
   //---- name for DataWindow and indicator subwindow label
   switch(TimeFrame)
   {
      case 1 : string TimeFrameStr="Period_M1"; break;
      case 5 : TimeFrameStr="Period_M5"; break;
      case 15 : TimeFrameStr="Period_M15"; break;
      case 30 : TimeFrameStr="Period_M30"; break;
      case 60 : TimeFrameStr="Period_H1"; break;
      case 240 : TimeFrameStr="Period_H4"; break;
      case 1440 : TimeFrameStr="Period_D1"; break;
      case 10080 : TimeFrameStr="Period_W1"; break;
      case 43200 : TimeFrameStr="Period_MN1"; break;
      default : TimeFrameStr="Current Timeframe";
   } 
   
    
   IndicatorShortName("SnakeForce["+TimeFrame+"]("+cPeriod+")"+CommentStr);
   IndicatorDigits(Digits);   
    return(0);
}
//----
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   int    i,shift,limit,y=0,counted_bars=IndicatorCounted();
    
// Plot defined timeframe on to current timeframe   
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame); 
   
   limit=Bars-counted_bars+TimeFrame/Period();
   for(i=0,y=0;i<limit;i++)
   {
   if (Time[i]<TimeArray[y]) y++;  
//---- main loop
    ForceUp[i]=iCustom(NULL,TimeFrame,"SnakeForce",cPeriod,0,y);
    ForceDown[i]=iCustom(NULL,TimeFrame,"SnakeForce",cPeriod,1,y);
    ResistanceUp[i]=iCustom(NULL,TimeFrame,"SnakeForce",cPeriod,2,y);
    ResistanceDown[i]=iCustom(NULL,TimeFrame,"SnakeForce",cPeriod,3,y);

}

  // Refresh buffers
//++++++++++++++++++++++++++++++++++++++
   if (TimeFrame>Period()) {
     int PerINT=TimeFrame/Period()+1;
     datetime TimeArr[]; ArrayResize(TimeArr,PerINT);
     ArrayCopySeries(TimeArr,MODE_TIME,Symbol(),Period()); 
     for(i=0;i<PerINT+1;i++) {if (TimeArr[i]>=TimeArray[0]) {
//----
 /******************************************************** 
    Refresh buffers:         buffer[i] = buffer[0];
 ********************************************************/  
    ForceUp[i]=ForceUp[0];
    ForceDown[i]=ForceDown[0];
    ResistanceUp[i]= ResistanceUp[0];
    ResistanceDown[i]=ResistanceDown[0];

//----
   } } }
//++++++++++++++++++++++++++++++++++++++++++++++++

//-----

return(0);
  }
//-------------------------------------------------------------+