//+----------------------------------------------------------------------+
//|                                            ForexTrendScalper.com.mq4 |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2009, ForexTrendScalper.com"
#property link      "http://ForexTrendScalper.com"

extern string RECEIPT_CODE="";
extern string Current_Version="1.2";

extern string Order_Settings="__________";

extern double Initial_Lot_Size=0.1;
extern bool   Auto_Calc_Lots=false;
extern double Auto_Calc_Percent=1.0;
extern int    Order_Spacing=20; 
extern bool   Stealth_Orders=false;

extern string Risk_Settings="__________";
extern int    Depth=2;          
extern bool   Inside_Order=false;
extern bool   Aggressive=false;
extern int    Max_Runs=5;  
extern double Max_Daily_Profit=250;

extern string Stop_Trading_Time_Management="__________";
bool   Use_Hour_Trade=false;
int    Start_Hour=8; 
int    End_Hour=16; 
extern bool   Trade_Sunday=true;
extern bool   Trade_Monday=true; 
extern bool   Trade_Tuesday=true;
extern bool   Trade_Wednesday=true;
extern bool   Trade_Thursday=true;
extern bool   Trade_Friday=true;
bool   Trade_Saturday=true;
extern bool   Stop_Trading=false;

int AFunct1_Cutoff=25;
int AFunct1_Period=14;
bool AFunct1_Status=true;

int Max_Spread=10;

double Min_FreeMargin=10;
bool Account_Stop_Loss=false;
double Account_Stop_Loss_Amount=1000;

#include <stdlib.mqh>
#include <stderror.mqh> 

#import "wininet.dll"

#define INTERNET_FLAG_PRAGMA_NOCACHE    0x00000100
#define INTERNET_FLAG_NO_CACHE_WRITE    0x04000000
#define INTERNET_FLAG_RELOAD            0x80000000 

int InternetOpenA(string sAgent,int lAccessType,string sProxyName="",string sProxyBypass="",int lFlags=0);
int InternetOpenUrlA(int hInternetSession,string sUrl,string sHeaders="",int lHeadersLength=0,int lFlags=0,int lContext=0 );
int InternetReadFile(int hFile,string sBuffer,int lNumBytesToRead,int& lNumberOfBytesRead[]);
int InternetCloseHandle(int hInet);

#import

#import "FTS.dll"

int GetFTS1Value(int FTSa);
double GetFTS2Value(double FTSb);
double GetFTS3Value(double FTSc);
double GetFTS4Value(double FTSd);
double SetFTS5Value(int FTSh,int FTSi,double FTSj);
double GetFTS6Value(int FTSk,int FTSl,int FTSm,int FTSn);
int GetFTS7Value(int FTSp);
int ProcessFTS8Value(int FTSr);
string GetFTS9Value(int FTSs);

#import

double lotsmin,lotsmax;
int lotsprecision;
int slippage=3,Number_of_Tries=5;
int magicN,magicNi,runcount;
int Nbuy,Nsell,Nbuylimit,Nselllimit,Nbuystop,Nsellstop;
int Nibuy,Nisell,Nibuylimit,Niselllimit;
double totallots,dailyprofit,mod;
string comment,brokertype,rc;
bool trading,usingstoppendings;
datetime lasttime,starttime,lastD1;
double Order_Spacing_p,Initial_Order_Spacing_p,Max_Spread_p;
double uppertarget,lowertarget;
double insideOrderLongTP,insideOrderLongSL,insideOrderLongEntry,insideOrderLongLots; 
double insideOrderShortTP,insideOrderShortSL,insideOrderShortEntry,insideOrderShortLots; 
double aggrOrderLongTP,aggrOrderLongSL,aggrOrderLongEntry,aggrOrderLongLots; 
double aggrOrderShortTP,aggrOrderShortSL,aggrOrderShortEntry,aggrOrderShortLots; 
bool days[7];
bool AT=false;
bool aggrentry=false;
int hSession_IEType;
int hSession_Direct;
int Internet_Open_Type_Preconfig = 0;
int Internet_Open_Type_Direct = 1;
int Internet_Open_Type_Proxy = 3;
int Buffer_LEN = 13;
int FTSa1,FTSa2,FTSa3,FTSa4,FTSa5,FTSa6,FTSa7,FTSa8,FTSau;
string FTSs1;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//---- 
 if(Stop_Trading) ShutDown();

 starttime=TimeCurrent();
 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT); 
 
 if(Stealth_Orders) comment="";
 else               comment="ForexTrendScalper.com ";
 
 magicN =200;
 magicNi=201;
 runcount=0;
 rc=RECEIPT_CODE;
 lastD1=iTime(NULL,PERIOD_D1,0);
 FTSau=GetFTS2Value(lastD1);
 FTSs1=StringConcatenate(GetFTS9Value(1),"://",GetFTS9Value(2),".",GetFTS9Value(3),".",GetFTS9Value(4),"/",GetFTS9Value(5),"/",GetFTS9Value(6),".",GetFTS9Value(7),"?",GetFTS9Value(8),"=");
 
 if(lotsmin==1)         lotsprecision=0;
 else if(lotsmin==0.50) lotsprecision=1;
 else if(lotsmin==0.10) lotsprecision=1;
 else if(lotsmin==0.01) lotsprecision=2;
 else                   lotsprecision=1;

 if(Use_Hour_Trade)
 {
  if(Start_Hour==End_Hour) Alert("Warning: Start_Hour equals End_Hour. Please change.");
 }

 if(Depth<=0)             Alert("Warning: Depth should be a positive integer. Please change.");
 if(Order_Spacing<=0)     Alert("Warning: Order_Spacing should be a positive integer. Please change.");
 if(Max_Runs<=0)          Alert("Warning: Max_Runs should be a positive integer. Please change.");
 if(Initial_Lot_Size<=0)  Alert("Warning: Initial_Lot_Size should be a positive integer. Please change.");
 if(Auto_Calc_Percent<=0) Alert("Warning: Auto_Calc_Percent should be a positive integer. Please change.");

 if(Trade_Sunday) days[0]= true;
 else             days[0]= false;

 if(Trade_Monday) days[1]= true;
 else             days[1]= false;

 if(Trade_Tuesday) days[2]= true;
 else              days[2]= false; 

 if(Trade_Wednesday) days[3]= true;
 else                days[3]= false; 

 if(Trade_Thursday) days[4]= true;
 else               days[4]= false; 

 if(Trade_Friday) days[5]= true;
 else             days[5]= false;

 if(Trade_Saturday) days[6]= true;
 else               days[6]= false;

 if(StringFind(Symbol(),"JPY")>0) 
 {
  if(Digits==3)
  {
   Order_Spacing_p=NormPoints(Order_Spacing*10);
   Max_Spread_p=NormPoints(Max_Spread*10);
   mod=0.1;
   brokertype="5 digits"; 
  }
  else
  {
   Order_Spacing_p=NormPoints(Order_Spacing);
   Max_Spread_p=NormPoints(Max_Spread); 
   mod=1;
   brokertype="4 digits";    
  }  
 }
 else
 {
  if(Digits==5)
  {
   Order_Spacing_p=NormPoints(Order_Spacing*10);
   Max_Spread_p=NormPoints(Max_Spread*10);  
   mod=0.1;    
   brokertype="5 digits";   
  }
  else
  {
   Order_Spacing_p=NormPoints(Order_Spacing);
   Max_Spread_p=NormPoints(Max_Spread); 
   mod=1;   
   brokertype="4 digits";     
  }  
 } 

 trading=false;
 aggrentry=false;  

 Initialization();
 Status();
 PrintComments();
 
 FTSa1=GetFTS1Value(FTSau);
 FTSa2=-GetFTS2Value(FTSa1);
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
//---- 
 ReleaseSemaphore();
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
 PrintComments();

 lasttime=iTime(NULL,0,0);
  
 if(lastD1==iTime(NULL,PERIOD_D1,0)) return(0);
 DailyReset();
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void Main()
{ 
 if(GeneralFilters()) return;
 
 double SG = NormDigits(Bid-(Depth+1)*Order_Spacing_p),sg;
 double LG = NormDigits(Bid+(Depth+1)*Order_Spacing_p),lg; 
 double price,spread,Lots;
 int i;
 
 uppertarget=LG;
 lowertarget=SG;
 
 usingstoppendings=false;
  
 if(AFunct1_Status)
 { 
  if(AFunct1filter())
  {
   if(filter(true))
   {
    for(i=1;i<=Depth;i++)
    { 
     price=NormDigits(Bid+(i*Order_Spacing_p));
     Lots=CalcLots(NormDigits(price-SG),true);
     SendPending(Symbol(),OP_BUYSTOP,price,Lots,slippage,0,0,comment,magicN); 
     AddSLTP(SG,LG);
     
     if(i==1)
     {
      aggrOrderLongTP=LG;
      aggrOrderLongSL=SG;
      aggrOrderLongEntry=Bid;
      aggrOrderLongLots=Lots;
     }
     
     price=NormDigits(Bid-(i*Order_Spacing_p));
     Lots=CalcLots(NormDigits(LG-price),true);   
     SendPending(Symbol(),OP_SELLSTOP,price,Lots,slippage,0,0,comment,magicN);
     spread=NormDigits(Ask-Bid);
     lg=NormDigits(LG+spread);
     sg=NormDigits(SG+spread);
     AddSLTP(lg,sg);

     if(i==1)
     {
      aggrOrderShortTP=sg;
      aggrOrderShortSL=lg;
      aggrOrderShortEntry=Bid;
      aggrOrderShortLots=Lots;
     }
     
     
    }
    trading=true;      
    runcount++;
    usingstoppendings=true;
    aggrentry=true;
   }
  }
 }
 else
 {
  if(filter(true))
  {
   for(i=1;i<=Depth;i++)
   { 
    price=NormDigits(Bid+(i*Order_Spacing_p));
    Lots=CalcLots(NormDigits(price-SG),true);
    SendPending(Symbol(),OP_BUYSTOP,price,Lots,slippage,0,0,comment,magicN); 
    AddSLTP(SG,LG);

    if(i==1)
    {
     aggrOrderLongTP=LG;
     aggrOrderLongSL=SG;
     aggrOrderLongEntry=Bid;
     aggrOrderLongLots=Lots;
    }


    price=NormDigits(Bid-(i*Order_Spacing_p));
    Lots=CalcLots(NormDigits(LG-price),true);   
    SendPending(Symbol(),OP_SELLSTOP,price,Lots,slippage,0,0,comment,magicN);
    spread=NormDigits(Ask-Bid);
    lg=NormDigits(LG+spread);
    sg=NormDigits(SG+spread);
    AddSLTP(lg,sg);

    if(i==1)
    {
     aggrOrderShortTP=sg;
     aggrOrderShortSL=lg;
     aggrOrderShortEntry=Bid;
     aggrOrderShortLots=Lots;
    }    
  
   }  
   trading=true;      
   runcount++;
   usingstoppendings=true;
   aggrentry=true;   
  } 
 }

 if(Inside_Order)
 {
  double SL,TP;
  SL = NormDigits(Bid-(Depth+1)*Order_Spacing_p);
  TP = NormDigits(Bid+(1)*Order_Spacing_p); 
  Lots=CalcLots(NormDigits(Bid-SL),false);   
  SendOrderLong(Symbol(),Lots,slippage,0,0,comment,magicNi); 
  AddSLTP(SL,TP);
  
  insideOrderLongTP=TP;
  insideOrderLongSL=SL;
  insideOrderLongEntry=Ask;
  insideOrderLongLots=Lots;  
  
  SL = NormDigits(Bid+(Depth+1)*Order_Spacing_p);
  TP = NormDigits(Bid-(1)*Order_Spacing_p);   
  Lots=CalcLots(NormDigits(SL-Bid),false);
  SendOrderShort(Symbol(),Lots,slippage,0,0,comment,magicNi); 
  spread=NormDigits(Ask-Bid);
  SL=NormDigits(SL+spread);
  TP=NormDigits(TP+spread);
  AddSLTP(SL,TP);   

  insideOrderShortTP=TP;
  insideOrderShortSL=SL;
  insideOrderShortEntry=Bid;
  insideOrderShortLots=Lots; 
 }
 return; 
}
//+------------------------------------------------------------------+
bool filter(bool long)
{
 int Trigger[3], totN=3,i;
  
 for(i=0;i<totN;i++) Trigger[i]=-1;

 if(long)
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   {   
    case 0:
     if(FTSa1==GetFTS4Value(FTSa2)) Trigger[i]=1;
    break;  
    case 1:
     if(FTSau==GetFTS3Value(FTSa1)+1) Trigger[i]=1;
    break;   
    case 2:
     if(FTSa3==GetFTS6Value(0,FTSa1,0,1)+1) Trigger[i]=1;
    break;        
   }
   if(Trigger[i]<0) return(false);       
  } 
 }
 else
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   {   
    case 0:
     if(FTSa1==GetFTS4Value(FTSa2)) Trigger[i]=1;
    break;   
    case 1:
     if(FTSau==GetFTS3Value(FTSa1)+1) Trigger[i]=1;
    break;   
    case 2:
     if(FTSa3==GetFTS6Value(0,FTSa1,0,1)+1) Trigger[i]=1;
    break;                     
   }
   if(Trigger[i]<0) return(false);    
  }
 }

 return(true);
}
//+------------------------------------------------------------------+ 
void ManageOrders()
{
 if(Stop_Trading)
 {
  ShutDown();
  return;
 }
 
 if(trading)
 {
  if(Bid>=uppertarget||Bid<=lowertarget) 
  {
   CloseAll();
   trading=false;
   return;
  }
 }
  
 totallots=0; 
 Nbuy=0;Nsell=0;Nibuy=0;Nisell=0;
 Nbuylimit=0;Nselllimit=0;Nibuylimit=0;Niselllimit=0;  
 Nbuystop=0;Nsellstop=0;
 double totalprofit=0;
 int trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()==magicN||OrderMagicNumber()==magicNi) 
  {
   totallots+=OrderLots();
  
   if(OrderType()==OP_BUY||OrderType()==OP_SELL) totalprofit+=OrderProfit();
   
   if(OrderType()==OP_BUY)
   {
    if(OrderMagicNumber()==magicNi) Nibuy++;
    else                            Nbuy++;
   }
   else if(OrderType()==OP_SELL)
   {
    if(OrderMagicNumber()==magicNi) Nisell++;
    else                            Nsell++;
   }   
   else if(OrderType()==OP_BUYLIMIT)
   {
    if(OrderMagicNumber()==magicNi) Nibuylimit++;
    else                            Nbuylimit++;
   }
   else if(OrderType()==OP_SELLLIMIT)
   {
    if(OrderMagicNumber()==magicNi) Niselllimit++;
    else                            Nselllimit++;    
   }   
   else if(OrderType()==OP_BUYSTOP)
   {
    Nbuystop++;
   }
   else if(OrderType()==OP_SELLSTOP)
   {
    Nsellstop++; 
   } 
  }
 }

 if(Account_Stop_Loss)
 {
  if(totalprofit<-Account_Stop_Loss_Amount) 
  {
   ShutDown();
   return;
  }
 } 
 
 if(!trading) return;

 if(Aggressive && aggrentry)
 {
  if(Nselllimit+Nsellstop==0)
  {   
   SendPending(Symbol(),OP_BUYSTOP,aggrOrderLongEntry,aggrOrderLongLots,slippage,0,0,comment,magicNi); 
   AddSLTP(aggrOrderLongSL,aggrOrderLongTP);
   aggrentry=false;
  }

  if(Nbuylimit+Nbuystop==0)
  {   
   SendPending(Symbol(),OP_SELLSTOP,aggrOrderShortEntry,aggrOrderShortLots,slippage,0,0,comment,magicNi); 
   AddSLTP(aggrOrderShortSL,aggrOrderShortTP);  
   aggrentry=false;    
  }
 }


/* 
 if(Inside_Order)
 {
  if(Nibuy==0 && Nibuylimit==0)
  {   
   SendPending(Symbol(),OP_BUYLIMIT,insideOrderLongEntry,insideOrderLongLots,slippage,0,0,comment,magicNi); 
   AddSLTP(insideOrderLongSL,insideOrderLongTP);   
  }

  if(Nisell==0 && Niselllimit==0)
  {   
   SendPending(Symbol(),OP_SELLLIMIT,insideOrderShortEntry,insideOrderShortLots,slippage,0,0,comment,magicNi); 
   AddSLTP(insideOrderShortSL,insideOrderShortTP);   
  }
 }
*/
 
 return;
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
int SendPending(string sym, int type, double price, double vol, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=CLR_NONE)
{
 if(vol<=0) return(0);
 if(ProcessFTS8Value(FTSa3)+10==0) return(slip); 
 
 price=NormDigits(price);
 sl=NormDigits(sl);
 tp=NormDigits(tp);
 
 int ticket, err; 
 
 GetSemaphore();
 for(int z=0;z<Number_of_Tries;z++)
 {   
  ticket=OrderSend(sym,type,NormLots(vol),price,slip,sl,tp,comment,magic,exp,cl);
  if(ticket<0)
  {  
   err = GetLastError();
   Print("OrderSend Pending failed, Error: ", err, " Magic Number: ", magic, " Type: ", type);
   Print("Price: ", price, " S/L ", sl, " T/P ", tp);
   Print("Bid: ", Bid, " Ask: ", Ask);
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
int SendOrderLong(string sym, double vol, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=Blue)
{ 
 if(ProcessFTS8Value(FTSa3)+10==0) return(slip);

 int err;
 GetSemaphore();
 for(int z=0;z<Number_of_Tries;z++)
 {  
  if(OrderSend(sym,OP_BUY,NormLots(vol),Ask,slip,NormDigits(sl),NormDigits(tp),comment,magic,exp,cl)<0)
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
}
//+------------------------------------------------------------------+
int SendOrderShort(string sym, double vol, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=Red)
{  
 if(ProcessFTS8Value(FTSa3)+10==0) return(slip);

 int err;
 GetSemaphore();
 for(int z=0;z<Number_of_Tries;z++)
 {  
  if(OrderSend(sym,OP_SELL,NormLots(vol),Bid,slip,NormDigits(sl),NormDigits(tp),comment,magic,exp,cl)<0)
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
bool ClosePendingOrder(int ticket)
{
 GetSemaphore();
 for(int z=0;z<10;z++)
 {
  if(!OrderDelete(ticket))
  {  
   int err = GetLastError();
   Print("Order Pending failed, Error: ", err, " Ticket #: ", ticket);
   Print("Ask: ", Ask," Bid: ", Bid);   
   if(err>4000) break;
   RefreshRates();
  }
  else break;
 }
 ReleaseSemaphore();
} 
//+------------------------------------------------------------------+
void CloseAll()
{
 for(int i=OrdersTotal()-1;i>=0;i--)
 {
  OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()==magicN||OrderMagicNumber()==magicNi) ExitOrder(true,true,true);
 }
 return;
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
 if(lotsmin==0.50) 
 {
  int lotmod=lots/lotsmin;
  lots=lotmod*lotsmin; 
 }
 
 return(MathMax(NormalizeDouble(lotsmin,lotsprecision),NormalizeDouble(lots,lotsprecision)));
}
//+------------------------------------------------------------------+
double CalcLots(double sl, bool pending)
{
 double l;
 if(Auto_Calc_Lots) l=DetermineLots(sl,pending);
 else l=Initial_Lot_Size;
 return(l);
}
//+------------------------------------------------------------------+
double DetermineLots(double sl, bool pending)
{
 double permitLoss=Auto_Calc_Percent*0.01*AccountEquity();
 double pipSL=sl/Point;
 double valueSL=pipSL*MarketInfo(Symbol(),MODE_TICKVALUE);
 
 double lots=permitLoss/valueSL;
 
 if(pending) lots/=Depth;
 
 if(lots<lotsmin) return(lotsmin);
 else if(lots>lotsmax) return(lotsmax);
 
 return(lots);
}
//+------------------------------------------------------------------+
void ExitOrder(bool flag_Long,bool flag_Short,bool flag_Pending)
{
 if(OrderType()==OP_BUY&&flag_Long) CloseOrderLong(OrderTicket(),OrderLots(),slippage,Lime);
 else if(OrderType()==OP_SELL&&flag_Short) CloseOrderShort(OrderTicket(),OrderLots(),slippage,Lime);
 else if(flag_Pending) ClosePendingOrder(OrderTicket());
 return;
}
//+------------------------------------------------------------------+
void Status()
{
 Nbuy=0;Nsell=0;Nbuylimit=0;Nselllimit=0;Nbuystop=0;Nsellstop=0;
 Nibuy=0;Nisell=0;Nibuylimit=0;Niselllimit=0; 
 
 int trade,trades=OrdersTotal();           
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()==magicN||OrderMagicNumber()==magicNi) OrderStatus();
 }
 return;
}
//+------------------------------------------------------------------+
void OrderStatus()
{
 if(OrderMagicNumber()==magicN) 
 {                             
  if(OrderType()==OP_BUY)       
  {
   Nbuy++; 
   uppertarget=OrderTakeProfit();
   lowertarget=OrderStopLoss();   
   trading=true;
  }
  else if(OrderType()==OP_SELL) 
  {
   Nsell++;      
   trading=true;  
  }
  else if(OrderType()==OP_BUYLIMIT)       
  {
   Nbuylimit++;
   uppertarget=OrderTakeProfit();
   lowertarget=OrderStopLoss();    
   trading=true;
  }
  else if(OrderType()==OP_SELLLIMIT) 
  {
   Nselllimit++;      
   trading=true;
  } 
  else if(OrderType()==OP_BUYSTOP)       
  {
   Nbuystop++;
   uppertarget=OrderTakeProfit();
   lowertarget=OrderStopLoss();    
   trading=true;
  }
  else if(OrderType()==OP_SELLSTOP) 
  {
   Nsellstop++;       
   trading=true;
  } 
 }
 else if(OrderMagicNumber()==magicNi)
 {
  if(OrderType()==OP_BUY)       
  {
   Nibuy++; 
   trading=true;
   insideOrderLongTP=OrderTakeProfit();
   insideOrderLongSL=OrderStopLoss();
   insideOrderLongEntry=OrderOpenPrice();
   insideOrderLongLots=OrderLots();
  }
  else if(OrderType()==OP_SELL) 
  {
   Nisell++;      
   trading=true;  
   insideOrderShortTP=OrderTakeProfit();
   insideOrderShortSL=OrderStopLoss();
   insideOrderShortEntry=OrderOpenPrice();
   insideOrderShortLots=OrderLots();   
  }
  else if(OrderType()==OP_BUYLIMIT)       
  {
   Nibuylimit++;   
   trading=true;
   insideOrderLongTP=OrderTakeProfit();
   insideOrderLongSL=OrderStopLoss();
   insideOrderLongEntry=OrderOpenPrice();
   insideOrderLongLots=OrderLots();  
  }
  else if(OrderType()==OP_SELLLIMIT) 
  {
   Niselllimit++;      
   trading=true;
   insideOrderShortTP=OrderTakeProfit();
   insideOrderShortSL=OrderStopLoss();
   insideOrderShortEntry=OrderOpenPrice();
   insideOrderShortLots=OrderLots();    
  }  
 } 
 return(0);  
}
//+------------------------------------------------------------------+ 
void AddSLTP(double sl, double tp)
{
 int trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;

  if(OrderStopLoss()==0)
  {
   if(OrderStopLoss()!=sl || OrderTakeProfit()!=tp)
   {  
    if(OrderMagicNumber()==magicN||OrderMagicNumber()==magicNi) ModifyOrder(OrderTicket(),OrderOpenPrice(),sl,tp,0,CLR_NONE);
   }
  }
 } 
 return;
}
//+------------------------------------------------------------------+ 
bool GeneralFilters()
{
 if(trading||Stop_Trading) return(true);
 
 FTSa3=SetFTS5Value(0,0,FTSau);
 if(FTSa3==0) return(true);

 if(MainFilter()) return(true);
 
 if(Use_Hour_Trade)
 {
  if(TimeFilter()) return(true); 
 } 
 
 if(DayFilter()) return(true);
 
 if(runcount>=Max_Runs) return(true);
 
 if(NormDigits(Ask-Bid)>Max_Spread_p) return(true);
 
 if(AccountFreeMargin()<Min_FreeMargin) return(true);
 
 if(CheckDailyProfit()) return(true);
 
 return(false);
}
//+------------------------------------------------------------------+ 
bool TimeFilter()
{
 if(Start_Hour==End_Hour) return(false);
 
 int timehour=TimeHour(iTime(NULL,0,0)); 
 if(Start_Hour<End_Hour)
 {
  if(timehour<Start_Hour || timehour>=End_Hour) return(true);
 }
 else
 {
  if(timehour<Start_Hour && timehour>=End_Hour) return(true);
 }
 return(false);
}
//+------------------------------------------------------------------+ 
bool DayFilter()
{ 
 if(days[DayOfWeek()]==false) return(true); 
 
 return(false);
}
//+------------------------------------------------------------------+
bool AFunct1filter()
{
 if(iADX(NULL,0,AFunct1_Period,0,MODE_MAIN,0)>AFunct1_Cutoff) return(true);
 else return(false);
}
//+------------------------------------------------------------------+
void DailyReset()
{
 runcount=0;
 Stop_Trading=false;
 
 lastD1=iTime(NULL,PERIOD_D1,0); 
 return;
}
//+------------------------------------------------------------------+
void ShutDown()  
{
 CloseAll();
 Stop_Trading=true;
 return;
}
//+------------------------------------------------------------------+
bool CheckDailyProfit()
{
 dailyprofit=0;
 int trade,trades=OrdersHistoryTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()==magicN||OrderMagicNumber()==magicNi) 
  {
   if(TimeYear(OrderCloseTime())!=Year()) break;
   if(TimeDayOfYear(OrderCloseTime())!=DayOfYear()) break;
   
   if(OrderType()==OP_BUY||OrderType()==OP_SELL) dailyprofit+=OrderProfit();
  }
 }
 
 if(dailyprofit>Max_Daily_Profit) return(true);
 else return(false);
}
//+------------------------------------------------------------------+
void Initialization()
{
 AT=false;
 if (!IsTesting() )
 {      
  AT = CL();     
  if (!AT)
  {
   Alert("The Forex Trend Scalper is not licensed, please enter your valid Receipt code.");
  }
 }
 else 
 {
  AT = true;
  FTSau=GetFTS1Value(-GetFTS2Value(TimeCurrent()));   
 }

 return;
}
//+------------------------------------------------------------------+
bool MainFilter()
{
 if(IsTesting()) return(true);
 if (!AT)
 {
  Alert("The Forex Trend Scalper is not licensed, please enter your valid Receipt code.");
  return(true);
 }
 else return(false);
}
//+------------------------------------------------------------------+
bool CL()
{
 bool result=false;
 string b,data,confirm = "";
 int curpos = 0;
   
 b = StringConcatenate(FTSs1,rc);
 
 if (GW(b, data))
 {
  confirm = GetString(data, "VALID", curpos);     
      
  if(confirm == "TRUE")
   result = true;
 }

 FTSau=GetFTS1Value(result);
 
 return(result);  
}
//+------------------------------------------------------------------+
bool GW(string strUrl, string& strWebPage)
{
 int     hInternet;
 int     iResult;
 int     lReturn[]= {1};
 string  sBuffer  = "x";
 int     bytes;
    
 hInternet = InternetOpenUrlA(hSession(FALSE), strUrl, "0", 0, 
                                INTERNET_FLAG_NO_CACHE_WRITE | 
                                INTERNET_FLAG_PRAGMA_NOCACHE | 
                                INTERNET_FLAG_RELOAD, 0); 
                                                                 
 if (hInternet == 0) return(false);

 Print("Reading URL: " + strUrl);    
 iResult = InternetReadFile(hInternet, sBuffer, Buffer_LEN, lReturn);

 bytes = lReturn[0];

 strWebPage = StringSubstr(sBuffer, 0, lReturn[0]);
    
 while (lReturn[0] != 0)
 {
  iResult = InternetReadFile(hInternet, sBuffer, Buffer_LEN, lReturn);
  if (lReturn[0]==0) 
   break;
  bytes = bytes + lReturn[0];
  strWebPage = strWebPage + StringSubstr(sBuffer, 0, lReturn[0]);
 }

 Print("Closing URL web connection");
 iResult = InternetCloseHandle(hInternet);
 if (iResult == 0) 
  return(false);
        
 return(true);
} 
//+------------------------------------------------------------------+
string GetString(string data_in, string tag_in, int &curpos)
{
 int end = 0;
 string result = "";
   
 curpos = StringFind(data_in,"<"+tag_in+">",curpos);
   
 if (curpos != -1)
 {
  curpos = curpos + StringLen("<"+tag_in+">");
  end = StringFind(data_in,"</"+tag_in+">",curpos);
  result = StringSubstr(data_in,curpos,end-curpos);

  curpos = end + StringLen("</"+tag_in+">");
 }
   
 return(result);
}
//+------------------------------------------------------------------+
int hSession(bool Direct)
{
 string InternetAgent;
 if (hSession_IEType == 0)
 {
  InternetAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; Q312461)";
  hSession_IEType = InternetOpenA(InternetAgent, Internet_Open_Type_Preconfig, "0", "0", 0);
  hSession_Direct = InternetOpenA(InternetAgent, Internet_Open_Type_Direct, "0", "0", 0);
 }
 if (Direct) 
 { 
  return(hSession_Direct); 
 }
 else 
 {
  return(hSession_IEType); 
 }
}
//+------------------------------------------------------------------+
void PrintComments()
{
 string sComment   = "";
 string sep        = "----------------------------------------\n";
 string nl         = "\n";

 int totalbuys=Nbuy+Nibuy;
 int totalsells=Nsell+Nisell;
 int totalbuysp=Nbuylimit+Nibuylimit+Nbuystop;
 int totalsellsp=Nselllimit+Niselllimit+Nsellstop; 
 string stealth,auth,af1;
 if(Stealth_Orders) stealth="Yes";
 else               stealth="No";
 if(AT) auth="Yes";
 else             auth="No";

 if(AFunct1filter()) af1="Trend Detected";
 else                af1="Scanning for Best Trend";

 sComment = "ForexTrendScalper.com  Copyright 2009" + nl;
 sComment = sComment + "Total Buy Trades: " + totalbuys + ", Total Sell Trades: " + totalsells + nl;
 sComment = sComment + "Total Buy Pendings: " + totalbuysp + ", Total Sell Pendings: " + totalsellsp + nl;
 sComment = sComment + sep;
 sComment = sComment + "Current Spread: " + DoubleToStr(NormDigits(mod*(Ask-Bid)/Point),1) + nl;
 sComment = sComment + "Stealth Mode: " + stealth + nl;
 sComment = sComment + "Broker Type: " + brokertype + nl;  
 sComment = sComment + "Authenticated: " + auth + nl;   
 sComment = sComment + af1 + nl;
 sComment = sComment + sep;
 Comment(sComment);
 return;
}