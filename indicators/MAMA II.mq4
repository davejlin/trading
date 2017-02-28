//+------------------------------------------------------------------+
//|                                                       MAMA II.mq4|
//| written for Jason (soeasy69@rogers.com)                          |
//|                                                                  |
//| Coded by David J. Lin (dave.j.lin@sbcglobal.net)                 |
//| Evanston, IL, December 15, 2007                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007 Jason Sweeney & David J. Lin"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Gold
#property indicator_color2 Blue
#property indicator_color4 Lime
#property indicator_color5 Magenta
//---- input parameters
extern double FastLimit = 0.5;
extern double SlowLimit = 0.05;
extern int maxbars=150000;
extern bool AlertAlarm=true;
extern bool AlertEmail=true;

// Time lines
extern int Start_Hour=17;
extern int Start_Minute=0;
extern int End_Hour=23;
extern int End_Minute=0;
extern color LineColor=DarkViolet;
extern int LineStyle=STYLE_DOT;

extern int maxarrows=4; // maximum number of arrows within time-lines

// Alarm settings
bool Alert_US=true;
int US_Start_Hour=17;
int US_Start_Minute=0;
int US_Stop_Hour=23;
int US_Stop_Minute=00;
bool Alert_Asian=false;
int Asian_Start_Hour=0;
int Asian_Start_Minute=0;
int Asian_Stop_Hour=7;
int Asian_Stop_Minute=0;
bool Alert_Europe=false;
int Europe_Start_Hour=7;
int Europe_Start_Minute=0;
int Europe_Stop_Hour=15;
int Europe_Stop_Minute=0;

//---- buffers
string CrossSound="TCAlert.wav";
double FABuffer[];
double MABuffer[];
double MAiBuffer[];
double up[],dn[];
int lasttime,NArrows;
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
double mamainit;
string period;
string MAMAIIName="MAMAII";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
 string short_name;
//---- indicator line
 SetIndexStyle(0, DRAW_LINE, 0, 1);
 SetIndexStyle(1, DRAW_LINE, 0, 1);
 SetIndexStyle(2, DRAW_NONE, 0, 1); 
 SetIndexBuffer(0, MABuffer);
 SetIndexBuffer(1, FABuffer);
 SetIndexBuffer(2, MAiBuffer); 
 SetIndexLabel(0, "MAMA");
 SetIndexLabel(1, "FAMA");
 SetIndexLabel(2, "MAMAi"); 
 SetIndexStyle(3, DRAW_ARROW, 0, 1);
 SetIndexArrow(3, 159);
 SetIndexStyle(4, DRAW_ARROW, 0, 1);
 SetIndexArrow(4, 159);
 SetIndexBuffer(3, up);
 SetIndexBuffer(4, dn);
 SetIndexLabel(3, "Up");
 SetIndexLabel(4, "Down");
 SetIndexDrawBegin(0, 50);
 SetIndexDrawBegin(1, 50); 
 SetIndexDrawBegin(2, 50);
 SetIndexDrawBegin(3, 50);  
 short_name = "MAMA II"; 
 IndicatorShortName(short_name);
  
 if(maxbars>Bars) maxbars=Bars;
 if(maxbars < 5) norun=true;    
 SmFactTot=SmFact1+SmFact2+SmFact3+SmFact4;
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
int deinit()
{
 int objtotal=ObjectsTotal()-1; string name;int i,pos;

 for(i=objtotal;i>=0;i--) 
 {
  name=ObjectName(i);
  
  pos=StringFind(name,MAMAIIName);
  if(pos>=0) ObjectDelete(name);   
 }
 return(0);
}  
//+------------------------------------------------------------------+
//| MAMA II                                                          |
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
   if(lasttime==iTime(NULL,0,i)) return(0);
   lasttime=iTime(NULL,0,i);

   if(counted_bars==0) return(0);  // need counted_bars condition to avoid double-counting last bar's data upon initial pass
   else MESA(1); // new bar, so refresh last bar's data one last time BEFORE array update   

   TimeLine(i);
   
   if(NArrows<maxarrows) CrossCheck(i);  
  }
  else
  {
   TimeLine(i);  
   
   if(NArrows<maxarrows) CrossCheck(i);
  }

  UpdateArrays();
 }
 return(0);
}
//+------------------------------------------------------------------+
void MESA(int i)
{
 int j;

 for(j=0;j<4;j++) // Jason's opening value of MESA (for 2nd-bar considerations:  take opening value of MESA, not closing value)
 {
  if(j==0) Price[j+1] = NormDigits(0.5*(Open[i+j] + Open[i+j])); // open value
  else     Price[j+1] = NormDigits(0.5*(High[i+j] + Low[i+j])); 
 }
 
 MESACore(); 
 MAiBuffer[i] = MAMA[1];
  
 for(j=0;j<4;j++) Price[j+1] = NormDigits(0.5*(High[i+j] + Low[i+j])); // normal MESA

 MESACore();
 MABuffer[i] = MAMA[1];
 FABuffer[i] = FAMA[1]; 
 
 return;
}
//+------------------------------------------------------------------+
void MESACore()
{
 double jI, jQ, DeltaPhase, alpha, ttime; 
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
void CrossCheck(int index)
{
 if(!TimeCheck(index)) return;
 
 double mama1=MABuffer[index+1];
 double mamai=MAiBuffer[index+1];
 double mama0=MAiBuffer[index];
 double close1=NormDigits(iClose(NULL,0,index+1));
 double open1=NormDigits(iOpen(NULL,0,index+1));
 double open0=NormDigits(iOpen(NULL,0,index)); 
 
 string message,time; double range;
 if(open1<=mamai && close1>=mama1 && open0>=mama0)
 {
  range=iATR(NULL,0,10,index);
  up[index]=open0-0.5*range;
  NArrows++;
  if(index==0)
  {
   if(AlertTimeFilter())
   {  
    time=TimeToStr(Time[0]); 
    message=StringConcatenate(Symbol()," ",period," MAMA II Up-Cross!! at ",time,"  Open=",open0,"  MAMA=",mama0);    
    SendMessage(message);
   }
  }
 }
 
 if(open1>=mamai && close1<=mama1 && open0<=mama0)
 {
  range=iATR(NULL,0,10,index); 
  dn[index]=open0+0.5*range;
  NArrows++;  
  if(index==0)
  {
   if(AlertTimeFilter())
   {
    time=TimeToStr(Time[0]);    
    message=StringConcatenate(Symbol()," ",period," MAMA II Down-Cross!! at ",time,"  Open=",open0,"  MAMA=",mama0);    
    SendMessage(message);    
   }
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
//+------------------------------------------------------------------+
void TimeLine(int i)
{
 datetime time=Time[i];
 if(TimeHour(time)==Start_Hour && TimeMinute(time)==Start_Minute)   
 {
  NArrows=0;
  DrawLine(i);
 }
 else if(TimeHour(time)==End_Hour && TimeMinute(time)==End_Minute)  
 {
  DrawLine(i);
 }
 return;
}
//+------------------------------------------------------------------+
bool TimeCheck(int i)
{
 datetime time=Time[i];
 if(Start_Hour>End_Hour)
 {
  if(TimeHour(time)==Start_Hour)
  {
   if(TimeMinute(time)>=Start_Minute) return(true);
  }
  else if(TimeHour(time)>Start_Hour&&TimeHour(time)<End_Hour) return(true);
  else if(TimeHour(time)==End_Hour)
  {
   if(TimeMinute(time)<=End_Minute) return(true);
  }
 }
 else
 {
  if(TimeHour(time)==Start_Hour)
  {
   if(TimeMinute(time)>=Start_Minute) return(true);
  }  
  else if(TimeHour(time)>Start_Hour||TimeHour(time)<End_Hour) return(true);
  else if(TimeHour(time)==End_Hour)
  {
   if(TimeMinute(time)<=End_Minute) return(true);
  }
 }
 return(false);
}
//+------------------------------------------------------------------+
void DrawLine(int i)
{
 datetime time=iTime(NULL,0,i);
 string name= StringConcatenate(MAMAIIName,TimeYear(time),".",TimeMonth(time),".",TimeDay(time),".",TimeHour(time),".",TimeMinute(time));
 if(ObjectFind(name)==0) return;
 double price=iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_LOWER,i);
 if (!ObjectCreate(name,OBJ_TREND,0,time,0,time,price,0,0))
 {
  Print("MT4 error: cannot draw the line. Error ",GetLastError());
 }
 else
 {
  ObjectSet(name,OBJPROP_COLOR,LineColor);    
  ObjectSet(name,OBJPROP_STYLE,LineStyle);
  ObjectSet(name,OBJPROP_RAY,false);
  ObjectSet(name,OBJPROP_BACK,false);
 }  
 return;
}
//+------------------------------------------------------------------+
void SendMessage(string message)
{
 if(AlertAlarm) 
 {     
  Alert(message);
  PlaySound(CrossSound);  
 }
 if (AlertEmail) SendMail("MAMA II Alert!",message);
 return;
}