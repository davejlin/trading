//+----------------------------------------------------------------------+
//|                                                        RSIRanger.mq4 |
//|                                                         David J. Lin |
//| RSI Range indicator based on the trading strategies of               |
//| Vince (forexportfolio@hotmail.com)                                   |
//|                                                                      |
//| Thumb = RSI moves up/down P1 points or more in H1 hour               |
//| Arrow = RSI moves up/down P2 points or more in H2 hours              |
//| Smiley/Frown = The RSI move carries it through the 50.00 line        |
//| Stop sign = RSI re-crosses 50.00 mark twice in H3 hours              |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|(d-lin@northwestern.edu)                                              |
//|Evanston, IL, November 5, 2006                                        |
//+----------------------------------------------------------------------+

#property copyright "David J. Lin"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1  Gold
#property indicator_width1 2
#property indicator_color2  Red
#property indicator_width2 2
#property indicator_color3  Gold
#property indicator_width3 2
#property indicator_color4  Red
#property indicator_width4 2
#property indicator_color5  Gold
#property indicator_width5 2
#property indicator_color6  Red
#property indicator_width6 2
#property indicator_color7  Blue
#property indicator_width7 2

extern int P1 = 5;               // points move for thumb
extern int P2 = 9;               // points move for arrow
extern int H1 = 1;               // hour allowed for N1 move
extern int H2 = 2;               // hours allowed for N2 move
extern int H3 =16;               // hours allowed for re-cross of 50.00 mark
extern int RSIPeriod=14;         // RSI period
extern int RSIPrice=PRICE_CLOSE; // RSI price 

double ThumbUp[], ThumbDown[], ArrowUp[], ArrowDown[], Stop[], CrossUp[], CrossDown[];
int Ncross;
//===========================================================================================
//===========================================================================================

int init() 
{
 SetIndexStyle(0, DRAW_ARROW);SetIndexStyle(1, DRAW_ARROW);
 SetIndexStyle(2, DRAW_ARROW);SetIndexStyle(3, DRAW_ARROW);
 SetIndexStyle(4, DRAW_ARROW);SetIndexStyle(5, DRAW_ARROW);  
 SetIndexStyle(6, DRAW_ARROW);    
 SetIndexBuffer(0, ThumbUp);SetIndexBuffer(1, ThumbDown);
 SetIndexBuffer(2, ArrowUp);SetIndexBuffer(3, ArrowDown);
 SetIndexBuffer(4, CrossUp);SetIndexBuffer(5, CrossDown); 
 SetIndexBuffer(6, Stop);
 SetIndexLabel(0, "Thumb Up");SetIndexLabel(1, "Thumb Down");
 SetIndexLabel(2, "Arrow Up");SetIndexLabel(1, "Arrow Down");
 SetIndexLabel(4, "Cross Up");SetIndexLabel(5, "Cross Down");
 SetIndexLabel(6, "Stop Sign"); 
 SetIndexArrow(0, 67);  // Thumb up
 SetIndexArrow(1, 68);  // Thumb down
 SetIndexArrow(2, 233); // Arrow up
 SetIndexArrow(3, 234); // Arrow down
 SetIndexArrow(4, 74);  // Smile cross up
 SetIndexArrow(5, 76);  // Frown cross down 
 SetIndexArrow(6, 253); // Stop sign
 return(0);
}

//===========================================================================================
//===========================================================================================

int start() 
{
 if(Bars<3) 
  return(0);
 
 for(int i=Bars-IndicatorCounted();i>=0;i--) 
 {
  if(iRSI(NULL,0,RSIPeriod,RSIPrice,i)>iRSI(NULL,0,RSIPeriod,RSIPrice,i+H1)+P1)
  {
   ThumbUp[i]=Low[i]-4*Point; 
   if(iRSI(NULL,0,RSIPeriod,RSIPrice,i)>=50&&iRSI(NULL,0,RSIPeriod,RSIPrice,i+H1)<=50)
    CrossUp[i]=High[i]+4*Point;
  }  
  if(iRSI(NULL,0,RSIPeriod,RSIPrice,i)<iRSI(NULL,0,RSIPeriod,RSIPrice,i+H1)-P1)
  {
   ThumbDown[i]=High[i]+4*Point;
   if(iRSI(NULL,0,RSIPeriod,RSIPrice,i)<=50&&iRSI(NULL,0,RSIPeriod,RSIPrice,i+H1)>=50)
    CrossDown[i]=Low[i]-4*Point;  
  }     
  if(iRSI(NULL,0,RSIPeriod,RSIPrice,i)>iRSI(NULL,0,RSIPeriod,RSIPrice,i+H2)+P2)
  {
   ArrowUp[i]=Low[i]-14*Point; 
   if(iRSI(NULL,0,RSIPeriod,RSIPrice,i)>=50&&iRSI(NULL,0,RSIPeriod,RSIPrice,i+H2)<=50)
    CrossUp[i]=High[i]+4*Point;
  }    
  if(iRSI(NULL,0,RSIPeriod,RSIPrice,i)<iRSI(NULL,0,RSIPeriod,RSIPrice,i+H2)-P2)
  {
   ArrowDown[i]=High[i]+14*Point;
   if(iRSI(NULL,0,RSIPeriod,RSIPrice,i)<=50&&iRSI(NULL,0,RSIPeriod,RSIPrice,i+H2)>=50)
    CrossDown[i]=Low[i]-4*Point;     
  }
  
  Ncross=0;
  for(int j=i;j<=i+H3;j++)
  {
   if(iRSI(NULL,0,RSIPeriod,RSIPrice,j)>=50&&iRSI(NULL,0,RSIPeriod,RSIPrice,j+1)<=50)
    Ncross++;
   else if(iRSI(NULL,0,RSIPeriod,RSIPrice,j)<=50&&iRSI(NULL,0,RSIPeriod,RSIPrice,j+1)>=50)
    Ncross++;
   if(Ncross>=3)
   {
    Stop[i]=0.5*(Low[i]+High[i]);    
    break;
   }
  } 

 }
 
 return(0);
}

//===========================================================================================
//===========================================================================================

