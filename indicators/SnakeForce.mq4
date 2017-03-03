//+------------------------------------------------------------------+
//|                                               SnakeInBorders.mq4 |
//|                                      "»Õƒ» ¿“Œ–€ ƒÀﬂ —¿ÃŒŒ¡Ã¿Õ¿" |
//|                           Bookkeeper, 2006, yuzefovich@gmail.com |
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



#property copyright ""
#property link      ""
//+------------------------------------------------------------------+
#property  indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  Lime
#property indicator_color2  Red
#property indicator_color3  Lime
#property indicator_color4  Red
//----
extern int  cPeriod=24; 
//----
double    ForceUp[];
double    ForceDown[];
double    ResistanceUp[];
double    ResistanceDown[];
double    Mart[];
//----
double Snake_Sum, Snake_Weight, Snake_Sum_Minus, Snake_Sum_Plus;
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
   SetIndexBuffer(4,Mart);
   SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,2);
   SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,2);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexLabel(2,NULL);
   SetIndexLabel(3,NULL);
   SetIndexLabel(4,NULL);
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);
   SetIndexDrawBegin(3,draw_begin);
   SetIndexDrawBegin(4,draw_begin);
   indperiod=1.0*cPeriod*Period();
   if(indperiod<60)
   {
      CommentStr=DoubleToStr(indperiod,0);
      CommentStr=" M"+CommentStr+", FORCE UP -DOWN ";
   }
   else
   {
      indperiod=indperiod/60;
      if(indperiod>=24)
      {
         val1=MathAbs(MathRound(indperiod/24)-indperiod/24);
         if(val1<0.01)
         {
            CommentStr=DoubleToStr(indperiod/24,0);
            CommentStr=" D"+CommentStr+", FORCE UP -DOWN ";
         }
          else
         {
            CommentStr=DoubleToStr(indperiod/24,1);
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
   IndicatorShortName("SnakeInBorders"+CommentStr);
   IndicatorDigits(Digits);
   return(0);
}
//----
void deinit()
{
}
//----
int start()
{
int FirstPos, ExtCountedBars=0,i;
   if(Bars<=50) return(0);
   if(cPeriod<21) return(0);
   ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   if (ExtCountedBars>0) ExtCountedBars--;
   FirstPos=Bars-ExtCountedBars-1;
   if(FirstPos>Bars-cPeriod-7)
   {
      FirstPos=Bars-cPeriod-7;
      Mart[FirstPos+cPeriod]=SnakeFirstCalc(FirstPos+cPeriod);
      for(i=FirstPos+cPeriod-1;i>FirstPos;i--) SnakeNextCalc(i);
   }
   Snake(FirstPos);
   return(0);
}
//----
void Snake(int Pos)
{
int i;
   if(Pos<6) Pos=6;
   Mart[Pos]=SnakeFirstCalc(Pos);
   Drawing(Pos);
   Pos--;
   while(Pos>=5)
   {
      Mart[Pos]=SnakeNextCalc(Pos);
      Drawing(Pos);
      Pos--;
   }
   while(Pos>0)
   {
      Mart[Pos]=SnakeFirstCalc(Pos);
      Drawing(Pos);
      Pos--;
   }
   if(Pos==0) 
   {
//      Mart[Pos]=iMA(NULL,0,6,0,MODE_LWMA,PRICE_TYPICAL,0);
      Mart[Pos]=iMA(NULL,0,6,0,MODE_LWMA,PRICE_CLOSE,0);
      Drawing(Pos);
   }
   return;
}
//----
double SnakePrice(int Shift)
{
//   return((2*Close[Shift]+High[Shift]+Low[Shift])/4);
   return(Close[Shift]);
}
//----
double SnakeFirstCalc(int Shift)
{
int i, j, w;
   Snake_Sum=0.0;
   if(Shift<5)
   {
      Snake_Weight=0.0;
      i=0;
      w=Shift+5;
      while(w>=Shift)
      {
         i++;
         Snake_Sum=Snake_Sum+i*SnakePrice(w);
         Snake_Weight=Snake_Weight+i;
         w--;
      }
      while(w>=0)
      {
         i--;
         Snake_Sum=Snake_Sum+i*SnakePrice(w);
         Snake_Weight=Snake_Weight+i;
         w--;
      }
   }
   else
   {
      Snake_Sum_Minus=0.0;
      Snake_Sum_Plus=0.0;
      for(j=Shift-5,i=Shift+5,w=1; w<=5; j++,i--,w++)
      {
         Snake_Sum=Snake_Sum+w*(SnakePrice(i)+SnakePrice(j));
         Snake_Sum_Minus=Snake_Sum_Minus+SnakePrice(i);
         Snake_Sum_Plus=Snake_Sum_Plus+SnakePrice(j);
      }
      Snake_Sum=Snake_Sum+6*SnakePrice(Shift);
      Snake_Sum_Minus=Snake_Sum_Minus+SnakePrice(Shift);
      Snake_Weight=36;
   }
   return(Snake_Sum/Snake_Weight);
}
//----
double SnakeNextCalc(int Shift)
{
   Snake_Sum_Plus=Snake_Sum_Plus+SnakePrice(Shift-5);
   Snake_Sum=Snake_Sum-Snake_Sum_Minus+Snake_Sum_Plus;
   Snake_Sum_Minus=Snake_Sum_Minus-SnakePrice(Shift+6)+SnakePrice(Shift);
   Snake_Sum_Plus=Snake_Sum_Plus-SnakePrice(Shift);
   return(Snake_Sum/Snake_Weight);
}
//----
void Drawing(int Shift)
{
double val,Dval,val1,val2,val11,val22,val3;
   val= 5*(Mart[Shift]-Mart[ArrayMinimum(Mart,cPeriod,Shift)])/9;
   Dval=5*(Mart[Shift]-
           Mart[Shift+1]+
           Mart[ArrayMinimum(Mart,cPeriod,Shift+1)]-
           Mart[ArrayMinimum(Mart,cPeriod,Shift)]   )/9;
   if(Dval>0) 
   {
      ForceUp[Shift]=NormDigits(val);
      ResistanceUp[Shift]=NormDigits(0);
   }
   else 
   {
      ForceUp[Shift]=NormDigits(0);
      ResistanceUp[Shift]=NormDigits(val);
   }
   val= 5*(Mart[Shift]-Mart[ArrayMaximum(Mart,cPeriod,Shift)])/9;
   Dval=5*(Mart[Shift]-
           Mart[Shift+1]+
           Mart[ArrayMaximum(Mart,cPeriod,Shift+1)]-
           Mart[ArrayMaximum(Mart,cPeriod,Shift)]   )/9;
   if(Dval<0) 
   {
      ForceDown[Shift]=NormDigits(val);
      ResistanceDown[Shift]=NormDigits(0);
   }
   else 
   {
      ForceDown[Shift]=NormDigits(0);
      ResistanceDown[Shift]=NormDigits(val);
   }
   return;
}
//+------------------------------------------------------------------+
double NormDigits(double price) // normalize digits 
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+

