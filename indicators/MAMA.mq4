//+------------------------------------------------------------------+
//|                                                          MAMA.mq4|
//| written for Jason (soeasy69@rogers.com)                          |
//|                                                                  |
//| Coded by David J. Lin (dave.j.lin@sbcglobal.net)                 |
//| Evanston, IL, July 18, 2007                                      |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007 David J. Lin"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue
//---- input parameters
extern double FastLimit = 0.5;
extern double SlowLimit = 0.05;
extern int maxbars=5000;

// Alarm settings
bool CrossAlarm=true;
int  CrossDelay=2;
bool Alert_US=true;
int US_Start_Hour=15;
int US_Start_Minute=0;
int US_Stop_Hour=23;
int US_Stop_Minute=59;
bool Alert_Asian=true;
int Asian_Start_Hour=0;
int Asian_Start_Minute=0;
int Asian_Stop_Hour=7;
int Asian_Stop_Minute=0;
bool Alert_Europe=true;
int Europe_Start_Hour=7;
int Europe_Start_Minute=0;
int Europe_Stop_Hour=15;
int Europe_Stop_Minute=0;

//---- buffers
string CrossSound="TCAlert.wav";
double FABuffer[];
double MABuffer[];
int lasttime;
bool norun=false;
double Speed=0.80;
double FAMAFact=0.25;
double PhaseFact=57.29577951; // 360/2pi
double PhaseConstant=6.283185307; // 2pi
double SmFact1=4;
double SmFact2=3;
double SmFact3=2;
double SmFact4=1;
double Fact1=0.0962;
double Fact2=0.5769;
double Fact3=0.075;
double Fact4=0.54;
double Period2Fact1=1.5;
double Period2Fact2=0.67;
double Period2Fact3=6.0;
double Period2Fact4=50.0;
double PeriodFact1=0.20;
double PeriodFact2=0.80;
double SmPeriodFact1=0.33;
double SmPeriodFact2=0.67;
double Price[5], Smooth[8], Detrender[8], Q1[8], I1[8], I2[3], Q2[3];
double Re[3], Im[3], SmoothPeriod[3], Period_[3], Phase[3], MAMA[3], FAMA[3];
double SmFactTot;
string period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
 string short_name;
//---- indicator line
 SetIndexStyle(0, DRAW_LINE, 0, 2);
 SetIndexStyle(1, DRAW_LINE, 0, 2);
 SetIndexBuffer(0, MABuffer);
 SetIndexBuffer(1, FABuffer);
//---- name for DataWindow and indicator subwindow label
 short_name = "MAMA";
 IndicatorShortName(short_name);
 SetIndexLabel(0, "MAMA");
 SetIndexLabel(1, "FAMA");
//----
 SetIndexDrawBegin(0, 50);
 SetIndexDrawBegin(1, 50);
 if(maxbars>Bars) maxbars=Bars;
 if(maxbars < 5) norun=true;    
 SmFactTot=SmFact1+SmFact2+SmFact3+SmFact4;
 if(CrossDelay<0) CrossDelay=0;
 switch(Period())
 {
  case 1: period="M1";break;
  case 5: period="M5";break;
  case 15: period="M15";break;
  case 30: period="M30";break;
  case 60: period="H1";break;
  case 240: period="H4";break;
  case 1440:period="D1";break;
  case 10080: period="W1";break;
  case 43200: period="M1";break;
  default: period="Unknown";break;
 }
//----
 return(0);
}
//+------------------------------------------------------------------+
//| MAMA                                                             |
//+------------------------------------------------------------------+
int start()
{
 if(norun) return(0);

 int i,limit, counted_bars = IndicatorCounted();

 if(counted_bars==0) limit=maxbars-1;
 else limit=0;

 for(i=limit;i>=0;i--)
 {
  MESA(i); 
        
  if(i==0)
  {      
   if(lasttime==Time[0]) return(0);
   lasttime=Time[0];

   if(counted_bars==0) return(0);  // need counted_bars condition to avoid double-counting last bar's data upon initial pass
   else MESA(1); // new bar, so refresh last bar's data one last time BEFORE array update   

   if(CrossAlarm) CrossCheck();  
  }

  UpdateArrays();
 }
 return(0);
}
//+------------------------------------------------------------------+
void MESA(int i)
{
 int j;
 double jI, jQ, DeltaPhase, alpha, ttime;  
 
 for(j=0;j<4;j++) Price[j+1] = NormDigits(0.5*(High[i+j] + Low[i+j])); 

 Smooth[1] = (SmFact1*Price[1] + SmFact2*Price[2] + SmFact3*Price[3] + SmFact4*Price[4])/SmFactTot; 
 Detrender[1] = (Fact1*Smooth[1] + Fact2*Smooth[3] - Fact2*Smooth[5] - Fact1*Smooth[7])*(Fact3*Period_[2] + Fact4); 
// {Compute InPhase and Quadrature components} 
 Q1[1] = (Fact1*Detrender[1] + Fact2*Detrender[3] - Fact2*Detrender[5] - Fact1*Detrender[7])*(Fact3*Period_[2] + Fact4); 
 I1[1] = Detrender[4]; 
// {Advance the phase of I1 and Q1 by 90 degrees} 
 jI = (Fact1*I1[1] + Fact2*I1[3] - Fact2*I1[5] - Fact1*I1[7])*(Fact3*Period_[2] + Fact4); 
 jQ = (Fact1*Q1[1] + Fact2*Q1[3] - Fact2*Q1[5] - Fact1*Q1[7])*(Fact3*Period_[2] + Fact4); 
// {Phasor addition for 3 bar averaging)} 
 I2[1] = I1[1] - jQ; 
 Q2[1] = Q1[1] + jI; 
// {Smooth the I and Q components before applying the discriminator} 
 I2[1] = PeriodFact1*I2[1] + PeriodFact2*I2[2]; 
 Q2[1] = PeriodFact1*Q2[1] + PeriodFact2*Q2[2]; 
// {Homodyne Discriminator} 
 Re[1] = I2[1]*I2[2] + Q2[1]*Q2[2]; 
 Im[1] = I2[1]*Q2[2] - Q2[1]*I2[2]; 
 Re[1] = PeriodFact1*Re[1] + PeriodFact2*Re[2]; 
 Im[1] = PeriodFact1*Im[1] + PeriodFact2*Im[2]; 
  
 if(Im[1] != 0 && Re[1] != 0) Period_[1]= PhaseConstant / MathArctan(Im[1] / Re[1]); 

 if(Period_[1] > Period2Fact1*Period_[2]) Period_[1] = Period2Fact1*Period_[2]; 
 if(Period_[1] < Period2Fact2*Period_[2]) Period_[1] = Period2Fact1*Period_[2]; 
 if(Period_[1] < Period2Fact3) Period_[1] = Period2Fact3; 
 if(Period_[1] > Period2Fact4) Period_[1] = Period2Fact4; 

 Period_[1] = PeriodFact1*Period_[1] + PeriodFact2*Period_[2]; 
 SmoothPeriod[1] = SmPeriodFact1*Period_[1] + SmPeriodFact2*SmoothPeriod[2]; 
 
 if(I1[1] != 0) Phase[1] = PhaseFact*MathArctan(Q1[1] / I1[1]); 
  
 DeltaPhase = (Phase[2] - Phase[1]); 

 if(DeltaPhase < 1) DeltaPhase = 1; 
  
 alpha = Speed / DeltaPhase; 
  
 if(alpha < SlowLimit) alpha = SlowLimit; 
 if(alpha > FastLimit) alpha = FastLimit; 
  
 MAMA[1] = NormDigits(alpha*Price[1] + (1 - alpha)*MAMA[2]); 
 FAMA[1] = NormDigits(FAMAFact*alpha*MAMA[1] + (1 - FAMAFact*alpha)*FAMA[2]);
 
 MABuffer[i] = MAMA[1];
 FABuffer[i] = FAMA[1]; 

 return;
}
//+------------------------------------------------------------------+ 
void UpdateArrays()
{
 int i;
 for(i=1;i<7;i++)
 {
  Smooth[i+1] = Smooth[i];
  Detrender[i+1] = Detrender[i];
  Q1[i+1] = Q1[i];
  I1[i+1] = I1[i];
 }

 Q2[2] = Q2[1]; 
 I2[2] = I2[1]; 
 Re[2] = Re[1]; 
 Im[2] = Im[1]; 
 SmoothPeriod[2] = SmoothPeriod[1]; 
 Phase[2] = Phase[1]; 
 Period_[2] = Period_[1]; 
 MAMA[2] = MAMA[1]; 
 FAMA[2] = FAMA[1]; 
 return;
}
//+------------------------------------------------------------------+  
void CrossCheck()
{
 double mama1=MABuffer[1];
 double fama1=FABuffer[1];
 double mamaX=MABuffer[CrossDelay];
 double famaX=FABuffer[CrossDelay];
 
 int i,hour; string time;
 if(mama1>fama1 && mamaX<=famaX)
 {
 
  if(mamaX==famaX) // in case of hugging lines
  {
   for(i=CrossDelay+1;i<=100;i++)
   {
    if(MABuffer[i]>FABuffer[i])      return;
    else if(MABuffer[i]<FABuffer[i]) break;
   }
  }
    
  for(i=1;i<CrossDelay;i++)
  {
   if(MABuffer[i]<FABuffer[i]) return;
  }
  time=TimeToStr(Time[0]);
  if(AlertTimeFilter())
  {  
   Alert(Symbol()," ",period," MAMA Up-Cross!! at ",time);
   PlaySound(CrossSound);  
  }
 }
 
 if(mama1<fama1 && mamaX>=famaX)
 {

  if(mamaX==famaX) // in case of hugging lines
  {
   for(i=CrossDelay+1;i<=100;i++)
   {
    if(MABuffer[i]<FABuffer[i])      return;
    else if(MABuffer[i]>FABuffer[i]) break;
   }
  }
  
  for(i=1;i<CrossDelay;i++)
  {
   if(MABuffer[i]>FABuffer[i]) return;
  } 
  time=TimeToStr(Time[0]);  
  if(AlertTimeFilter())
  {
   Alert(Symbol()," ",period," MAMA Down-Cross!! at ",time);
   PlaySound(CrossSound);  
  }
 }
 return;
}
//+------------------------------------------------------------------+  
double NormDigits(double value)
{                            
 return(NormalizeDouble(value,Digits));
}                           
//+------------------------------------------------------------------+
bool AlertTimeFilter()
{
 int hour=Hour(),min=Minute();

 if(Alert_Asian) 
 {
  if(hour>=Asian_Start_Hour && min>=Asian_Start_Minute)
  {
   if(hour<=Asian_Stop_Hour)
   {
    if(hour<Asian_Stop_Hour) return(true);
    else if(hour==Asian_Stop_Hour && min<=Asian_Stop_Minute) return(true);
   }
  }
 }

 if(Alert_Europe) 
 {
  if(hour>=Europe_Start_Hour && min>=Europe_Start_Minute)
  {
   if(hour<=Europe_Stop_Hour)
   {
    if(hour<Europe_Stop_Hour) return(true);
    else if(hour==Europe_Stop_Hour && min<=Europe_Stop_Minute) return(true);
   }
  }
 }

 if(Alert_US) 
 {
  if(hour>=US_Start_Hour && min>=US_Start_Minute)
  {
   if(hour<=US_Stop_Hour)
   {
    if(hour<US_Stop_Hour) return(true); 
    else if(hour==US_Stop_Hour && min<=US_Stop_Minute) return(true); 
   }
  }
 }
 
 return(false);
} 

