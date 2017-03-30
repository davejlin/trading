//+----------------------------------------------------------------------+
//|                                                        Lepore EA.mq4 |
//|                                                         David J. Lin |
//| Based on a trading strategy by Leo Lepore                            |
//| (forexleo@yahoo.com)                                                 |
//|                                                                      |
//| Coded by David J. Lin (dave.j.lin@sbcglobal.net)                     |
//| Evanston, IL, December 5, 2009                                       |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2009, Leo Lepore & David J. Lin"

// Internal usage parameters:
//---- input parameters
extern bool AllowTrades=true;       // true = take trades, false = don't take trades (custom indicator functionality)
extern bool ActivateAlert=true;     // true = activate alert upon valid entry signal
extern bool ActivateMail=true;      // true = send mail message upon valid entry signal
extern int MaxNumber=2;             // maximum number of triggers to trade per cycle
// Order 1
extern double Lots1=0.01;           // initial lots Order 1 (enter 0 if not wanted)
extern int TakeProfit1=50;          // pips initial TP Order 1 (enter 0 if not wanted)
extern int StopLoss1=0;           // pips initial SL Order 1 (enter 0 if not wanted)
// Order 2
extern double Lots2=0.01;           // initial lots Order 2 (enter 0 if not wanted)
extern int TakeProfit2=75;          // pips initial TP Order 2 (enter 0 if not wanted)
extern int StopLoss2=0;           // pips initial SL Order 2 (enter 0 if not wanted)
// Order 3
extern double Lots3=0.01;           // initial lots Order 3 (enter 0 if not wanted)
extern int TakeProfit3=100;         // pips initial TP Order 3 (enter 0 if not wanted)
extern int StopLoss3=0;           // pips initial SL Order 3 (enter 0 if not wanted)
// Pip Cross Filter
extern bool PipCrossFilter=true;   // true = use entry filter to limit pips from last fast/medium MA cross, false = don't use this entry filter
extern int PipCrossPips=50;         // pips from last fast/medium MA cross to filter entries (applies if PipCrossFilter=true)
// MA Lines Order Filter
extern bool MAFilter=true;     // true = all 3 MA lines must be in the correct order for entry, false = the 3 MA lines don't have to be in any specific order 
// Profit Level Adjust
extern bool ProfitLevelAdjust=false;// true = use ProfitLevels & MoveStops
extern int ProfitLevel1=20;         // pips ProfitLevel 1
extern int MoveStop1=1;             // pips MoveStop 1 (from entry price)
extern int ProfitLevel2=35;         // pips ProfitLevel 2 
extern int MoveStop2=15;            // pips MoveStop 2 (from entry price)
extern int ProfitLevel3=55;         // pips ProfitLevel 3
extern int MoveStop3=30;            // pips MoveStop 3 (from entry price)
// Exit Method: 2 MA Closes
extern bool Exit2MACloses=true;     // true = stop loss exit when 2 consecutive closes beyond 50 SMA, false = don't use this exit method
// Exit Method: pips from 50 SMA
extern bool ExitStopLoss50SMA=false;// true = stop loss exit StopLoss50SMA pips from 50 SMA, false = don't use this exit method
extern int StopLoss50SMA=10;        // pips from 50 SMA SL to exit (applies if ExitStopLoss50SMA=true)
extern bool ExitStopLoss50SMACLOSE=true; // true = use close as basis for ExitStopLoss50SMA function, false = use Bid as basis
// Exit Method: pips from previous candle high/low 
extern bool ExitPrevHighLow=false;  // true = stop loss exit PrevHighLow pips from previous candle's high/low 
extern int PrevHighLow=10;          // pips from previous candle's high/low to exit (applies if ExitPrevHighLow=true)
extern bool ExitPrevHighLowCLOSE=true; // true = use close as basis for ExitPrevHighLow function, false = use Bid as basis
// Exit Method: Fibonacci
extern bool ExitFib=true;          // true = take profit exit using Fibonnacci levels, false = don't use this exit method
extern double FibLevel1=1.00;       // 1st exit Fib level (1.00 = 100%) applies to Order 1
extern double FibLevel2=1.68;       // 2nd exit Fib level (1.68 = 168%) applies to Order 2
extern double FibLevel3=2.68;       // 3rd exit Fib level (2.68 = 268%) applies to Order 3
extern int FibMinSpan=25;           // pips minimum distance to qualify as a Fibonnacci span
extern int MinTP=10;                // pips minimum TP from entry price; (must be equal to or greater than broker minimum TP level)
// Time Filter settings:
extern bool Use_Hour_Trade=false;   // true = use time filter to activate EA only during certain hours 
extern int Start_Hour=8;            // start EA at this hour (platform time) 
extern int End_Hour=16;             // stop  EA at this hour (platform time)

//---- buffers
bool longsig,shortsig,triggered;
int Magic1=101,Magic2=102,Magic3=103;
string comment="Leo EA";
string ci1="Leo_Fractal";
string ci2="Leo_MA";
datetime ots,otl,lasttime;
double lotsmin,lotsmax;
double Fib1,Fib2,Fib3;
double StopLoss1Points,TakeProfit1Points,StopLoss2Points,TakeProfit2Points,StopLoss3Points,TakeProfit3Points;
double MAExit2Points,PipCrossPoints;
double ProfitLevel1Points,ProfitLevel2Points,ProfitLevel3Points;
double MoveStop1Points,MoveStop2Points,MoveStop3Points;
double PrevHighLowPoints,FibMinSpanPoints,MinTPPoints;
int lotsprecision,period1,period2,period3;
int nlong,nshort;
int Slippage=5;
int MAPeriod1=10,MAPeriod2=21,MAPeriod3=50;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//---- 

 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT); 

 if(lotsmin==1)         lotsprecision=0;
 else if(lotsmin==0.50) lotsprecision=1; // for PFG ECN
 else if(lotsmin==0.10) lotsprecision=1;
 else if(lotsmin==0.01) lotsprecision=2;
 else                   lotsprecision=1; 

 if(StringFind(Symbol(),"JPY")>0) 
 {
  if(Digits==3)
  {
   StopLoss1Points=NormPoints(StopLoss1*10);
   TakeProfit1Points=NormPoints(TakeProfit1*10);  
   StopLoss2Points=NormPoints(StopLoss2*10);
   TakeProfit2Points=NormPoints(TakeProfit2*10); 
   StopLoss3Points=NormPoints(StopLoss3*10);
   TakeProfit3Points=NormPoints(TakeProfit3*10);       
   MAExit2Points=NormPoints(StopLoss50SMA*10);
   PipCrossPoints=NormPoints(PipCrossPips*10);  
   ProfitLevel1Points=NormPoints(ProfitLevel1*10);
   ProfitLevel2Points=NormPoints(ProfitLevel2*10);
   ProfitLevel3Points=NormPoints(ProfitLevel3*10);   
   MoveStop1Points=NormPoints(MoveStop1*10);
   MoveStop2Points=NormPoints(MoveStop2*10);
   MoveStop3Points=NormPoints(MoveStop3*10);  
   PrevHighLowPoints=NormPoints(PrevHighLow*10); 
   FibMinSpanPoints=NormPoints(FibMinSpan*10);    
   MinTPPoints=NormPoints(MinTP*10);     
  }
  else
  {
   StopLoss1Points=NormPoints(StopLoss1);
   TakeProfit1Points=NormPoints(TakeProfit1);  
   StopLoss2Points=NormPoints(StopLoss2);
   TakeProfit2Points=NormPoints(TakeProfit2); 
   StopLoss3Points=NormPoints(StopLoss3);
   TakeProfit3Points=NormPoints(TakeProfit3); 
   MAExit2Points=NormPoints(StopLoss50SMA);  
   PipCrossPoints=NormPoints(PipCrossPips); 
   ProfitLevel1Points=NormPoints(ProfitLevel1);
   ProfitLevel2Points=NormPoints(ProfitLevel2);
   ProfitLevel3Points=NormPoints(ProfitLevel3);  
   MoveStop1Points=NormPoints(MoveStop1);
   MoveStop2Points=NormPoints(MoveStop2);
   MoveStop3Points=NormPoints(MoveStop3);  
   PrevHighLowPoints=NormPoints(PrevHighLow); 
   FibMinSpanPoints=NormPoints(FibMinSpan);   
   MinTPPoints=NormPoints(MinTP);              
  }  
 }
 else
 {
  if(Digits==5)
  {
   StopLoss1Points=NormPoints(StopLoss1*10);
   TakeProfit1Points=NormPoints(TakeProfit1*10);  
   StopLoss2Points=NormPoints(StopLoss2*10);
   TakeProfit2Points=NormPoints(TakeProfit2*10); 
   StopLoss3Points=NormPoints(StopLoss3*10);
   TakeProfit3Points=NormPoints(TakeProfit3*10);
   MAExit2Points=NormPoints(StopLoss50SMA*10);  
   PipCrossPoints=NormPoints(PipCrossPips*10);
   ProfitLevel1Points=NormPoints(ProfitLevel1*10); 
   ProfitLevel2Points=NormPoints(ProfitLevel2*10);
   ProfitLevel3Points=NormPoints(ProfitLevel3*10); 
   MoveStop1Points=NormPoints(MoveStop1*10);
   MoveStop2Points=NormPoints(MoveStop2*10);
   MoveStop3Points=NormPoints(MoveStop3*10);   
   PrevHighLowPoints=NormPoints(PrevHighLow*10);  
   FibMinSpanPoints=NormPoints(FibMinSpan*10); 
   MinTPPoints=NormPoints(MinTP*10);                   
  }
  else
  {
   StopLoss1Points=NormPoints(StopLoss1);
   TakeProfit1Points=NormPoints(TakeProfit1);  
   StopLoss2Points=NormPoints(StopLoss2);
   TakeProfit2Points=NormPoints(TakeProfit2); 
   StopLoss3Points=NormPoints(StopLoss3);
   TakeProfit3Points=NormPoints(TakeProfit3); 
   MAExit2Points=NormPoints(StopLoss50SMA); 
   PipCrossPoints=NormPoints(PipCrossPips);  
   ProfitLevel1Points=NormPoints(ProfitLevel1);
   ProfitLevel2Points=NormPoints(ProfitLevel2);
   ProfitLevel3Points=NormPoints(ProfitLevel3); 
   MoveStop1Points=NormPoints(MoveStop1);
   MoveStop2Points=NormPoints(MoveStop2);
   MoveStop3Points=NormPoints(MoveStop3);
   PrevHighLowPoints=NormPoints(PrevHighLow);  
   FibMinSpanPoints=NormPoints(FibMinSpan);
   MinTPPoints=NormPoints(MinTP);                
  }  
 } 

 switch(Period())
 {
  case 1:
          period1=PERIOD_M1;
          period2=PERIOD_M5;
          period3=PERIOD_M15;
  break;
  case 5:
          period1=PERIOD_M5;
          period2=PERIOD_M15;
          period3=PERIOD_M30;
  break;
  case 15:
          period1=PERIOD_M15;
          period2=PERIOD_M30;
          period3=PERIOD_H1;
  break;  
  case 30:
          period1=PERIOD_M30;
          period2=PERIOD_H1;
          period3=PERIOD_H4;
  break;  
  case 60:
          period1=PERIOD_H1;
          period2=PERIOD_H4;
          period3=PERIOD_D1;
  break;
  case 240:
          period1=PERIOD_H4;
          period2=PERIOD_D1;
          period3=PERIOD_W1;
  break;  
  case 1440:
          period1=PERIOD_D1;
          period2=PERIOD_W1;
          period3=PERIOD_MN1;
  break;  
  case 10080:
          period1=PERIOD_W1;
          period2=PERIOD_MN1;
          period3=PERIOD_MN1;
  break;  
  default:
          period1=PERIOD_MN1;
          period2=PERIOD_MN1;
          period3=PERIOD_MN1;
  break;  
 }
 
 lasttime=iTime(NULL,period1,0);

 nlong=0;nshort=0;triggered=false;
 longsig=true;shortsig=true;

 if(CheckNumberOrder()>0) triggered=true; 

 if(Use_Hour_Trade)
 {
  if(Start_Hour==End_Hour) Alert("Warning: Start_Hour equals End_Hour. Please change.");
 }
 
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
//---- 
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
//----   
 Main();
 ManageOrders();
  
 if(lasttime==iTime(NULL,period1,0)) return(0);
 lasttime=iTime(NULL,period1,0);
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void Main()
{ 
 double SL,TP;
 int ticket;

 double fractal0=iCustom(NULL,period1,ci1,0,0);
 double fractal1=iCustom(NULL,period1,ci1,1,0); 
   
 if(fractal0!=EMPTY_VALUE&&fractal0!=0)
 {
  longsig=true;shortsig=false;
  if(filter(true))
  {
   if(nshort>0) ResetSig();  
   if(nlong<MaxNumber) 
   {   
    if(AllowTrades)
    {
     ExitAllOrders(false);
     CalcFib(true);
     nlong++;nshort=0;triggered=true;

     if(Lots1>0)
     {
      ticket=SendOrderLong(Symbol(),Lots1,Slippage,0,0,comment,Magic1);    

      if(ExitFib) TP=Fib1;
      else        TP=TakeLong(Ask,TakeProfit1Points);  
     
      SL=StopLong(Ask,StopLoss1Points);
      AddSLTP(SL,TP,ticket); 
     }
     if(Lots2>0)
     {
      ticket=SendOrderLong(Symbol(),Lots2,Slippage,0,0,comment,Magic2);  

      if(ExitFib) TP=Fib2;
      else        TP=TakeLong(Ask,TakeProfit2Points);      
       
      SL=StopLong(Ask,StopLoss2Points); 
      AddSLTP(SL,TP,ticket); 
     }
     if(Lots3>0)
     {
      ticket=SendOrderLong(Symbol(),Lots3,Slippage,0,0,comment,Magic3);  

      if(ExitFib) TP=Fib3;
      else        TP=TakeLong(Ask,TakeProfit3Points);       
       
      SL=StopLong(Ask,StopLoss3Points); 
      AddSLTP(SL,TP,ticket); 
     }   
     otl=TimeCurrent();     
    }
    SendAlertMail(true);
   }
  }
 } 
 else if(fractal1!=EMPTY_VALUE&&fractal1!=0)
 {
  longsig=false;shortsig=true; 
  if(filter(false))
  {  
   if(nlong>0) ResetSig();  
   if(nshort<MaxNumber) 
   {
    if(AllowTrades)
    {   
     ExitAllOrders(true);
     CalcFib(false);  
     nlong=0;nshort++;triggered=true;      

     if(Lots1>0)
     {
      ticket=SendOrderShort(Symbol(),Lots1,Slippage,0,0,comment,Magic1);  
     
      if(ExitFib) TP=Fib1;
      else        TP=TakeShort(Bid,TakeProfit1Points);   

      SL=StopShort(Bid,StopLoss1Points);     
      AddSLTP(SL,TP,ticket);
     }
     if(Lots2>0)
     {
      ticket=SendOrderShort(Symbol(),Lots2,Slippage,0,0,comment,Magic2); 

      if(ExitFib) TP=Fib2;
      else        TP=TakeShort(Bid,TakeProfit2Points);      
      
      SL=StopShort(Bid,StopLoss2Points); 
      AddSLTP(SL,TP,ticket);
     }    
     if(Lots3>0)
     {
      ticket=SendOrderShort(Symbol(),Lots3,Slippage,0,0,comment,Magic3);  

      if(ExitFib) TP=Fib3;
      else        TP=TakeShort(Bid,TakeProfit3Points); 

      SL=StopShort(Bid,StopLoss3Points);  
      AddSLTP(SL,TP,ticket);
     }    
     ots=TimeCurrent();
    }
    SendAlertMail(false);     
   }
  }
 } 

 return; 
}
//+------------------------------------------------------------------+
void ManageOrders()
{ 
// if(CheckNumberOrder()==0) triggered=false;

 int magic,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 { 
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  magic=OrderMagicNumber();
  if(magic==Magic1||magic==Magic2||magic==Magic3)
  {
   ExitMA1();
   ExitMA2();
   ExitHighLow();
   LevelAdjust();
  }
 }
 return;
}
//+------------------------------------------------------------------+
bool filter(bool long)
{
 int Trigger[5], totN=5,i;
  
 for(i=0;i<totN;i++) Trigger[i]=-1;

 if(long) // long filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   {   
    case 0:
     if(iBarShift(NULL,period1,otl,false)>0) Trigger[i]=1;
    break;   
    case 1:
     if(MAFilter(true)) Trigger[i]=1;
    break;  
    case 2:
     if(PipXFilter(true)) Trigger[i]=1;
    break;    
    case 3:
     if(TimeFilter()) Trigger[i]=1;
    break;
    case 4:
     if(MALinesFilter(true)) Trigger[i]=1;
    break;
   }
   if(Trigger[i]<0) return(false);       
  } 
 }
 else // short filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   {   
    case 0:
     if(iBarShift(NULL,period1,ots,false)>0) Trigger[i]=1;
    break;        
    case 1:
     if(MAFilter(false)) Trigger[i]=1;
    break; 
    case 2:
     if(PipXFilter(false)) Trigger[i]=1;
    break;          
    case 3:
     if(TimeFilter()) Trigger[i]=1;
    break;   
    case 4:
     if(MALinesFilter(false)) Trigger[i]=1;
    break;       
   }
   if(Trigger[i]<0) return(false);    
  }
 }

 return(true);  // no anti-trigger:  so, return true (to order)
}
//+------------------------------------------------------------------+
bool MAFilter(bool long)
{
 double MA10=iCustom(NULL,period1,ci2,0,0);
 double MA11=iCustom(NULL,period1,ci2,1,0); 
 double MA20=iCustom(NULL,period2,ci2,0,0);
 double MA21=iCustom(NULL,period2,ci2,1,0);  
 double MA30=iCustom(NULL,period3,ci2,0,0);
 double MA31=iCustom(NULL,period3,ci2,1,0); 
 
 if(long)
 {
  if(MA10!=EMPTY_VALUE&&MA10!=0)
  {
   if(MA20!=EMPTY_VALUE&&MA20!=0)      return(true);
   else if(MA21!=EMPTY_VALUE&&MA21!=0) return(false);
   else if(MA30!=EMPTY_VALUE&&MA30!=0) return(true);
   else            return(false);
  }
  else             return(false);
 }
 else
 {
  if(MA11!=EMPTY_VALUE&&MA11!=0)
  {
   if(MA21!=EMPTY_VALUE&&MA21!=0)      return(true);
   else if(MA20!=EMPTY_VALUE&&MA20!=0) return(false);
   else if(MA31!=EMPTY_VALUE&&MA31!=0) return(true);
   else            return(false);   
  }
  else             return(false);  
 }
 return(false);
}
//+------------------------------------------------------------------+
bool PipXFilter(bool long)
{
 if(!PipCrossFilter) return(true);
 int i; double f1,f2,m1,m2,x; 
 
 if(long)
 {
  for(i=0;i<=Bars-1;i++)
  {
   f1=iCustom(NULL,period1,ci1,2,i);
   f2=iCustom(NULL,period1,ci1,2,i+1);
   m1=iCustom(NULL,period1,ci1,3,i);
   m2=iCustom(NULL,period1,ci1,3,i+1);  
   
   if(f1>m1&&f2<m2)
   {
    x=NormDigits(0.5*(f1+f2));
    if(Bid<=NormDigits(x+PipCrossPoints)) return(true);
    else return(false);
    
    break;
   }
  }
 }
 else
 {
  for(i=0;i<=Bars-1;i++)
  {
   f1=iCustom(NULL,period1,ci1,2,i);
   f2=iCustom(NULL,period1,ci1,2,i+1);
   m1=iCustom(NULL,period1,ci1,3,i);
   m2=iCustom(NULL,period1,ci1,3,i+1);  
   
   if(f1<m1&&f2>m2)
   {
    x=NormDigits(0.5*(f1+f2));
    if(Bid>=NormDigits(x-PipCrossPoints)) return(true);
    else return(false);
    
    break;
   }
  } 
 }
 
 return(false);
}
//+------------------------------------------------------------------+
bool MALinesFilter(bool long)
{
 if(!MAFilter) return(true);

 double MAfast=iMA(NULL,0,MAPeriod1,0,0,0,0);
 double MAmedium=iMA(NULL,0,MAPeriod2,0,0,0,0);
 double MAslow=iMA(NULL,0,MAPeriod3,0,0,0,0);
 
 if(long)
 {
  if(MAfast>MAmedium && MAmedium>MAslow) return(true);
  else                                   return(false);
 }
 else
 {
  if(MAfast<MAmedium && MAmedium<MAslow) return(true);
  else                                   return(false);
 }
 return(false);
}
//+------------------------------------------------------------------+
void CalcFib(bool long)
{
 if(!ExitFib) return;
 double fibspan,fibtp;
 double vl,vr,vc1,vc2;
 int i,j;
 
 if(long)
 {
  for(i=1;i<=Bars-1;i++)
  {
   vl=iHigh(NULL,period1,i+1);
   vc1=iHigh(NULL,period1,i);
   vr=iHigh(NULL,period1,i-1);
   if(vl<vc1&&vr<vc1) break;
  }
  for(j=i+1;j<=Bars-1;j++)
  {
   vl=iLow(NULL,period1,j+1);
   vc2=iLow(NULL,period1,j);
   vr=iLow(NULL,period1,j-1);
   if(vl>vc2&&vr>vc2&&NormDigits(vc1-vc2)>=FibMinSpanPoints) break;
  }
  
  fibspan=NormDigits(vc1-vc2);

  fibtp=NormDigits(vc2+(FibLevel1*fibspan));
  Fib1=FibTPCalc(true,fibtp);

  fibtp=NormDigits(vc2+(FibLevel2*fibspan));  
  Fib2=FibTPCalc(true,fibtp);

  fibtp=NormDigits(vc2+(FibLevel3*fibspan));  
  Fib3=FibTPCalc(true,fibtp);
 }
 else
 {
  for(i=1;i<=Bars-1;i++)
  {
   vl=iLow(NULL,period1,i+1);
   vc1=iLow(NULL,period1,i);
   vr=iLow(NULL,period1,i-1);
   if(vl>vc1&&vr>vc1) break;
  }
  for(j=i+1;j<=Bars-1;j++)
  {
   vl=iHigh(NULL,period1,j+1);
   vc2=iHigh(NULL,period1,j);
   vr=iHigh(NULL,period1,j-1);
   if(vl<vc2&&vr<vc2&&NormDigits(vc2-vc1)>=FibMinSpanPoints) break;
  }
  
  fibspan=NormDigits(vc2-vc1);
 
  fibtp=NormDigits(vc2-(FibLevel1*fibspan));
  Fib1=FibTPCalc(false,fibtp);
  
  fibtp=NormDigits(vc2-(FibLevel2*fibspan));
  Fib2=FibTPCalc(false,fibtp);
  
  fibtp=NormDigits(vc2-(FibLevel3*fibspan)); 
  Fib3=FibTPCalc(false,fibtp);  
 }
 
 return;
}
//+------------------------------------------------------------------+
double FibTPCalc(bool long,double ftp)
{
 if(long)
 {
  if(ftp>NormDigits(Ask+MinTPPoints)) return(ftp);
  else return(TakeLong(Ask,MinTPPoints));
 }
 else
 {
  if(ftp<NormDigits(Bid-MinTPPoints)) return(ftp);
  else return(TakeShort(Bid,MinTPPoints));
 }
 return(ftp);  
}
//+------------------------------------------------------------------+
bool ModifyOrder(int ticket, double price, double sl, double tp, datetime exp, color cl=CLR_NONE)
{ 
 GetSemaphore();

 if(OrderModify(ticket,price,sl,tp,exp,cl)==false)
 {  
  Print("OrderModify failed, Error: ",GetLastError(), " Ticket Number: ", ticket);
  Print("Old price: ", OrderOpenPrice(), " Old S/L ", OrderStopLoss(), " Old T/P ", OrderTakeProfit(), " Ask/Bid ",Ask,", ",Bid);
  Print(" New Price: ", price, " New S/L ", sl, " New T/P ", tp, " New Expiration ", exp);
 }
 ReleaseSemaphore();
}
//+------------------------------------------------------------------+
void ModifyCompLong(double stopcal, double stopcrnt)
{
 stopcal=NormDigits(stopcal);
 stopcrnt=NormDigits(stopcrnt);

 if (stopcal==stopcrnt) return;
 
 if(stopcal>stopcrnt)
 {
 
  if(stopcal>=Bid) // check whether s/l is too close to market
   return;
                     
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue); 
 }
 return;
}
//+------------------------------------------------------------------+
void ModifyCompShort(double stopcal, double stopcrnt)
{
 stopcal=NormDigits(stopcal);
 stopcrnt=NormDigits(stopcrnt);

 if (stopcal==stopcrnt) return;
  
 if(stopcrnt==0)
 {

  if(stopcal<=Ask) // check whether s/l is too close to market
   return; 
   
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);     
 }
 else if(stopcal<stopcrnt&&stopcal!=0)
 {

  if(stopcal<=Ask) // check whether s/l is too close to market
   return; 
 
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red); 
 }
 return;
}
//+------------------------------------------------------------------+
int SendOrderLong(string sym, double vol, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=Blue)
{ 
 int err,ticket;
 GetSemaphore();
 for(int z=0;z<5;z++)
 {  
  ticket=OrderSend(sym,OP_BUY,NormLots(vol),Ask,slip,NormDigits(sl),NormDigits(tp),comment,magic,exp,cl);
  if(ticket<0)
  {  
   err = GetLastError();
   Print("OrderSend Long failed, Error: ", err, " Magic Number: ", magic);
   Print("Ask: ", Ask, " S/L ", sl, " T/P ", tp);
   if(err>4000) break;
   RefreshRates();
  }
  else
   break;
 }
 ReleaseSemaphore();
 return(ticket);
}
//+------------------------------------------------------------------+
int SendOrderShort(string sym, double vol, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=Red)
{  
 int err,ticket;
 GetSemaphore();
 for(int z=0;z<5;z++)
 {  
  ticket=OrderSend(sym,OP_SELL,NormLots(vol),Bid,slip,NormDigits(sl),NormDigits(tp),comment,magic,exp,cl);
  if(ticket<0)
  {  
   err = GetLastError();
   Print("OrderSend Short failed, Error: ", err, " Magic Number: ", magic);
   Print("Bid: ", Bid, " S/L ", sl, " T/P ", tp);   
   if(err>4000) break;
   RefreshRates();
  }
  else
   break;
 }
 ReleaseSemaphore();
 return(ticket); 
}
//+------------------------------------------------------------------+
bool CloseOrderLong(int ticket, double lots, int slip, color cl=CLR_NONE)
{
 GetSemaphore();
 for(int z=0;z<10;z++)
 {
  if(!OrderClose(ticket,NormLots(lots),Bid,slip,cl))
  {  
   int err = GetLastError();
   Print("OrderClose Long failed, Error: ", err, " Ticket #: ", ticket);
   Print("Bid: ", Bid);   
   if(err>4000) break;
   RefreshRates();
  }
  else break;
 }
 ReleaseSemaphore();
} 
//+------------------------------------------------------------------+
bool CloseOrderShort(int ticket, double lots, int slip, color cl=CLR_NONE)
{
 GetSemaphore();
 for(int z=0;z<10;z++)
 {
  if(!OrderClose(ticket,NormLots(lots),Ask,slip,cl))
  {  
   int err = GetLastError();
   Print("OrderClose Short failed, Error: ", err, " Ticket #: ", ticket);
   Print("Ask: ", Ask);   
   if(err>4000) break;
   RefreshRates();
  }
  else break;
 }
 ReleaseSemaphore();
} 
//+------------------------------------------------------------------+
bool GetSemaphore()
{  
 if(!GlobalVariableCheck("SEMAPHORE")) GlobalVariableSet("SEMAPHORE",0);
 while(!IsStopped())
 {  
  if(GlobalVariableSetOnCondition("SEMAPHORE",1,0)==true) break;
  Sleep(500);
 }
 return(true);
}
//+------------------------------------------------------------------+
bool ReleaseSemaphore()
{
 GlobalVariableSet("SEMAPHORE",0);
 return(true);
}
//+------------------------------------------------------------------+
double NormPoints(int pips)
{
 return(NormDigits(pips*Point));
}
//+------------------------------------------------------------------+
double NormDigits(double price)
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+
double NormLots(double lots)
{
 if(lotsmin==0.50) // for PFG ECN
 {
  int lotmod=lots/lotsmin;
  lots=lotmod*lotsmin; // increments of 0.50 lots
 }

 return(MathMax(NormalizeDouble(lotsmin,lotsprecision),NormalizeDouble(lots,lotsprecision)));
}
//+------------------------------------------------------------------+
void ExitOrder(bool flag_Long,bool flag_Short,int cancelpending=1)
{
 switch(cancelpending)
 {
  case 1:
   if(OrderType()==OP_BUY&&flag_Long)
    CloseOrderLong(OrderTicket(),OrderLots(),Slippage,Lime);
   else if(OrderType()==OP_SELL&&flag_Short)
    CloseOrderShort(OrderTicket(),OrderLots(),Slippage,Lime);
   break;
  case 2:
   if((OrderType()==OP_BUYSTOP)&&flag_Long)
    OrderDelete(OrderTicket());
   else if((OrderType()==OP_SELLSTOP)&&flag_Short)
    OrderDelete(OrderTicket());
   break;  
 }
 return;
}
//+------------------------------------------------------------------+ 
void ExitAllOrders(bool long)
{
 int magic,trade,trades=OrdersTotal(); 
 if(long)
 {
  for(trade=trades-1;trade>=0;trade--)
  {
   OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
   if(OrderSymbol()!=Symbol()) continue;
   magic=OrderMagicNumber();
   if(magic==Magic1||magic==Magic2||magic==Magic3) ExitOrder(true,false);
  }
 }
 else
 {
  for(trade=trades-1;trade>=0;trade--)
  {
   OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
   if(OrderSymbol()!=Symbol()) continue;
   magic=OrderMagicNumber();
   if(magic==Magic1||magic==Magic2||magic==Magic3) ExitOrder(false,true);
  }
 } 
 
 triggered=false;

 return;
}
//+------------------------------------------------------------------+
double TakeLong(double price,double take)  // function to calculate takeprofit if long
{
 if(take==0) return(0);
 return(NormDigits(price+take)); 
             // plus, since the take profit is above us for long positions
}
//+------------------------------------------------------------------+
double TakeShort(double price,double take)  // function to calculate takeprofit if short
{
 if(take==0) return(0);
 return(NormDigits(price-take)); 
             // minus, since the take profit is below us for short positions
}
//+------------------------------------------------------------------+
double StopShort(double price,double stop) // function to calculate normal stoploss if short
{
 if(stop==0) return(0);
 return(NormDigits(price+stop)); 
             // plus, since the stop loss is above us for short positions
}
//+------------------------------------------------------------------+
double StopLong(double price,double stop) // function to calculate normal stoploss if long
{
 if(stop==0) return(0);
 return(NormDigits(price-stop)); 
             // minus, since the stop loss is below us for long positions
             // Point is 0.01 or 0.001 depending on currency, so stop*POINT is a way to convert pips into price with multiplication 
}
//+------------------------------------------------------------------+
double DetermineProfit()
{
 if(OrderType()==OP_BUY)  
  return(NormDigits(Bid-OrderOpenPrice()));
 else if(OrderType()==OP_SELL)
  return(NormDigits(OrderOpenPrice()-Ask)); 
 
 return(0); 
}
//+------------------------------------------------------------------+
void FixedStopsB(double PP,double PFS)
{
  double stopcrnt,stopcal;
  double profit,profitpoint;

  stopcrnt=OrderStopLoss();
  profitpoint=PP;  

//Long               
  if(OrderType()==OP_BUY)
  {
   profit=NormDigits(Bid-OrderOpenPrice());
   
   if(profit>=profitpoint)
   {
    stopcal=TakeLong(OrderOpenPrice(),PFS);
    ModifyCompLong(stopcal,stopcrnt);
   }
  }    
//Short 
  if(OrderType()==OP_SELL)
  {  
   profit=NormDigits(OrderOpenPrice()-Ask);
   
   if(profit>=profitpoint)
   {
    stopcal=TakeShort(OrderOpenPrice(),PFS);
    ModifyCompShort(stopcal,stopcrnt);  
   }
  }
    
 return;
} 

//+------------------------------------------------------------------+
void ExitMA1()
{  
 if(!Exit2MACloses) return;
 if(iBarShift(NULL,period1,OrderOpenTime())<2) return;
 
 double fractal41=iCustom(NULL,period1,ci1,4,1);
 double fractal42=iCustom(NULL,period1,ci1,4,2); 
 double close1=iClose(NULL,period1,1);
 double close2=iClose(NULL,period1,2); 
 double open1=iOpen(NULL,period1,1);
 double open2=iOpen(NULL,period1,2); 

 if(OrderType()==OP_BUY)       
 {
  if(close1<fractal41&&close2<fractal42&&close1<open1&&close2<open2) 
  {
   ExitAllOrders(true);
   Alert(Symbol()," exit longs 2 MA closes at Bid:",Bid,", Time:",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES));
  }
 }
 else if(OrderType()==OP_SELL)       
 {   
  if(close1>fractal41&&close2>fractal42&&close1>open1&&close2>open2) 
  {
   ExitAllOrders(false); 
   Alert(Symbol()," exit shorts 2 MA closes at Ask:",Ask,", Time:",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES));
  }   
 }
 return;
}
//+------------------------------------------------------------------+
void ExitMA2()
{  
 if(!ExitStopLoss50SMA) return;
 
 double fractal41=iCustom(NULL,period1,ci1,4,1);
 
 if(ExitStopLoss50SMACLOSE)
 {
  if(iBarShift(NULL,period1,OrderOpenTime())<1) return;
  if(OrderType()==OP_BUY)       
  {
   if(iClose(NULL,0,1)<=NormDigits(fractal41-MAExit2Points)) 
   {
    ExitAllOrders(true);
    Alert(Symbol()," exit longs from 50SMA at Bid:",Bid,", Time:",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES));
   }    
  }
  else if(OrderType()==OP_SELL)       
  {
   if(iClose(NULL,0,1)>=NormDigits(fractal41+MAExit2Points)) 
   {
    ExitAllOrders(false); 
    Alert(Symbol()," exit shorts from 50SMA at Ask:",Ask,", Time:",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES));
   }    
  }  
 }
 else
 {
  if(OrderType()==OP_BUY)       
  {
   if(Bid<=NormDigits(fractal41-MAExit2Points)) 
   {
    ExitAllOrders(true);
    Alert(Symbol()," exit longs from 50SMA at Bid:",Bid,", Time:",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES));
   }   
  }
  else if(OrderType()==OP_SELL)       
  {   
   if(Bid>=NormDigits(fractal41+MAExit2Points)) 
   {
    ExitAllOrders(false); 
    Alert(Symbol()," exit shorts from 50SMA at Ask:",Ask,", Time:",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES));
   }    
  }
 }
 return;
}
//+------------------------------------------------------------------+
void ExitHighLow()
{
 if(!ExitPrevHighLow) return;

 if(ExitPrevHighLowCLOSE)
 {
  if(iBarShift(NULL,period1,OrderOpenTime())<1) return;
  if(OrderType()==OP_BUY)       
  {
   if(iClose(NULL,0,1)<=NormDigits(iLow(NULL,period1,1)-PrevHighLowPoints)) 
   {
    ExitAllOrders(true);
    Alert(Symbol()," exit longs from Low at Bid:",Bid,", Time:",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES));
   }   
  }
  else if(OrderType()==OP_SELL)       
  {
   if(iClose(NULL,0,1)>=NormDigits(iHigh(NULL,period1,1)+PrevHighLowPoints)) 
   {
    ExitAllOrders(false);
    Alert(Symbol()," exit shorts from High at Ask:",Ask,", Time:",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES));
   }   
  }  
 }
 else
 {
  if(OrderType()==OP_BUY)       
  {
   if(Bid<=NormDigits(iLow(NULL,period1,1)-PrevHighLowPoints)) 
   {
    ExitAllOrders(true);
    Alert(Symbol()," exit longs from Low at Bid:",Bid,", Time:",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES));
   }    
  }
  else if(OrderType()==OP_SELL)       
  {
   if(Bid>=NormDigits(iHigh(NULL,period1,1)+PrevHighLowPoints)) 
   {
    ExitAllOrders(false);
    Alert(Symbol()," exit shorts from High at Ask:",Ask,", Time:",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES));
   }    
  }
 }
  
 return;
}
//+------------------------------------------------------------------+
void LevelAdjust()
{ 
 if(!ProfitLevelAdjust) return;

  double profit=DetermineProfit();
       if(profit>=ProfitLevel3Points) FixedStopsB(ProfitLevel3Points,MoveStop3Points);
  else if(profit>=ProfitLevel2Points) FixedStopsB(ProfitLevel2Points,MoveStop2Points);
  else if(profit>=ProfitLevel1Points) FixedStopsB(ProfitLevel1Points,MoveStop1Points); 
 return;
}
//+------------------------------------------------------------------+ 
void AddSLTP(double sl, double tp, int orderNumber)
{
 if(OrderSelect(orderNumber,SELECT_BY_TICKET)) 
  ModifyOrder(orderNumber,OrderOpenPrice(),sl,tp,0,CLR_NONE);
 return;
}

//+------------------------------------------------------------------+
int CheckNumberOrder()
{
 int magic,trade,trades=OrdersTotal(),total=0; 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  magic=OrderMagicNumber();
  if(magic==Magic1||magic==Magic2||magic==Magic3) total++;
 }
 return(total);
}
//+------------------------------------------------------------------+ 
bool TimeFilter()
{
 if(!Use_Hour_Trade) return(true);
 if(Start_Hour==End_Hour) 
 {
  Alert("Warning: Start_Hour equals End_Hour. Please change.");  
  return(false);
 }
 
 int timehour=TimeHour(iTime(NULL,period1,0)); 
 if(Start_Hour<End_Hour)
 {
  if(timehour<Start_Hour || timehour>=End_Hour) return(false);
  else                                          return(true);
 }
 else
 {
  if(timehour<Start_Hour && timehour>=End_Hour) return(false);
  else                                          return(true);
 }
 return(true);
}
//+------------------------------------------------------------------+
void ResetSig()
{
 nlong=0;nshort=0; 
 return;
}
//+------------------------------------------------------------------+
void SendAlertMail(bool long)
{
 string td=TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES);
 if(long)
 {
  if(ActivateAlert) Alert(Symbol()," Lepore EA entered long, Ask: ",Ask," at ",td);     
  if(ActivateMail) SendMail("Lepore EA Alert",Symbol()+" Lepore EA entered long, Ask: "+Ask+" at "+td); 
 }
 else
 {
  if(ActivateAlert) Alert(Symbol()," Lepore EA entered short, Bid: ",Bid," at",td);  
  if(ActivateMail) SendMail("Lepore EA Alert",Symbol()+" Lepore EA entered short, Bid: "+Bid+" at "+td);  
 }
 return;
}