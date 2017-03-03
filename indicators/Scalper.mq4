//+------------------------------------------------------------------+
//|                                                      Scalper.mq4 |
//| Scalper                                                          |
//| written for Jason Sweezey (soeasy69@rogers.com)                  |
//|                                                                  |
//| Coded by David J. Lin (dave.j.lin@sbcglobal.net)                 |
//| Evanston, IL, February 29, 2008                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008 David J. Lin"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime

extern int sigoffpips=10;        // pips signal offset
extern color SignalColor=Black;  // color of signal
extern bool WarningAlert=true;
//---- input parameters

//---- sound-file names
string WarningSound="TCAlert.wav";
//---- buffers
double SignalUp[],SignalDn[];
// internal parameters
double sigoffpoints,lasthigh,lastlow;
datetime thistime;
int lasthighi,lastlowi;
bool sigup=false,sigdn=false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
 IndicatorBuffers(2);

 string short_name="Scalper";
 IndicatorShortName(short_name);
 
        short_name="Scalper Sell";
 SetIndexBuffer(0,SignalUp); 
 SetIndexStyle(0,DRAW_ARROW,DRAW_ARROW,1,SignalColor);
 SetIndexArrow(0,108);
 SetIndexLabel(0,short_name);
 
        short_name="Scalper Buy";
 SetIndexBuffer(1,SignalDn); 
 SetIndexStyle(1,DRAW_ARROW,DRAW_ARROW,1,SignalColor);
 SetIndexArrow(1,108);
 SetIndexLabel(1,short_name); 
 
 sigoffpoints=NormDigits(sigoffpips*Point);
 ArrayInitialize(SignalUp,EMPTY_VALUE);
 ArrayInitialize(SignalDn,EMPTY_VALUE); 
 lasthigh=0;
 lastlow=999999;
 sigup=false;sigdn=false; 
 return(0);
}
//+------------------------------------------------------------------+
//| Scalper                                                          |
//+------------------------------------------------------------------+
int start()
{
 if(thistime==iTime(NULL,0,0)) return(-1);
 thistime=iTime(NULL,0,0);

 int i,index,cb=IndicatorCounted();
 double close1,close0,close,high,low;
 
 if(cb>0) index=1;
 else     index=Bars-1;
  
 for(i=index;i>=1;i--)
 {
  high=NormDigits(iHigh(NULL,0,i));
  if(high>=lasthigh) 
  {
   lasthigh=high;
   lasthighi=i;
  }
  
  low=NormDigits(iLow(NULL,0,i));
  if(low<=lastlow)   
  {
   lastlow=low;
   lastlowi=i;  
  }   
  
  if(!sigup)
  {  
   if(lasthighi>i+1)
   {  
    close0=NormDigits(iClose(NULL,0,lasthighi));
    close1=NormDigits(iClose(NULL,0,lasthighi-1));           
    close=NormDigits(iClose(NULL,0,i));   
    if(close1>close) 
    {
     SignalUp[lasthighi]=NormDigits(iHigh(NULL,0,lasthighi)+sigoffpoints);  
     lasthigh=NormDigits(iHigh(NULL,0,i));
     lastlow=NormDigits(iLow(NULL,0,i));   
     lasthighi=i;   
     lastlowi=i; 
     sigup=true;sigdn=false;      
    
     if(WarningAlert&&cb>0)
     {   
      Alert("Scalper Sell ",Symbol()," ",close);
      PlaySound(WarningSound);
     }
    }   
   }
  }
  else if(!sigdn)
  { 
   if(lastlowi>i+1)
   {  
    close0=NormDigits(iClose(NULL,0,lasthighi));     
    close1=NormDigits(iClose(NULL,0,lastlowi-1));       
    close=NormDigits(iClose(NULL,0,i));
    if(close1<close) 
    {  
     SignalDn[lastlowi]=NormDigits(iLow(NULL,0,lastlowi)-sigoffpoints);   
     lasthigh=NormDigits(iHigh(NULL,0,i));
     lastlow=NormDigits(iLow(NULL,0,i));
     lasthighi=i;   
     lastlowi=i;       
     sigup=false;sigdn=true; 
            
     if(WarningAlert&&cb>0)
     {   
      Alert("Scalper Buy ",Symbol()," ",close);
      PlaySound(WarningSound);
     }
    }
   } 
  }
 }
 if(cb==0) return;
 lasthighi++;
 lastlowi++;
 return(0);
}
//+------------------------------------------------------------------+
double NormDigits(double value)
{                            
 return(NormalizeDouble(value,Digits));
}                           
//+------------------------------------------------------------------+

