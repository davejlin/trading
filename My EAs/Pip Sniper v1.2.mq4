//+----------------------------------------------------------------------+
//|                                                       Pip Sniper.mq4 |
//|                                                         David J. Lin |
//|Based on Jason Gospodarek's strategy using 2 MA break outs            |
//|Written for Dr. Jason Gospodarek <jgospoda@yahoo.com>                 |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, September 15, 2007                                      |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007, Jason Gospodarek & David J. Lin"
#property link      ""

// User adjustable parameters:

extern int LookBackPeriod=25;        // number of bars to look-back to determine swing high/low
extern int WindowPSAR=4;             // number of bars after cross for PSAR to become friendly & price to exceed swing high/low

extern int MAperiodS=5;              // short-term MA period (trigger)      
extern int MAperiodM=13;             // medium-term MA period (trigger)

extern double PSARStep=0.2;          // PSAR step
extern double PSARMax=0.2;           // PSAR max

extern double PART =0.020;           // percentage of account balance at risk per trade
extern double PARTA=0.120;           // percentage of account balance at risk per total account (aggregate open order risk in entire account)
                     
extern int TakeProfit1=25;           // pips initial TP for O1 (use negative number if not desired)
extern int TakeProfit2=50;           // pips initial TP for O2 (use negative number if not desired)
extern int TakeProfit3=-1;           // pips initial TP for O3 (use negative number if not desired)

extern int StopLoss=29;              // pips initial SL (use negative number if not desired)

                                     // Move Stops:  for O2 & O3, after reaching BE+SLProfit, move SL to BE+SLMove
extern int SLProfit=26;              // pips profit after which to move SL (use negative number if not desired)
extern int SLMove=9;                 // pips to move SL to BE+SLMove after SLProfit is reached

                                     // Trail: for every additional TrailProfit of profit above SLMove, lock in an additional TrailMove of profit
extern int TrailProfit=-1;           // pips desired trailing profit above SLProfit, engages after SLProfit is hit (use negative number if not desired)
extern int TrailMove=-1;             // pips desired trailing stop added onto previous stop, engages after SLProfit is hit

// MA parameter settings

int MAshiftS=0;
int MAmethodS=MODE_EMA;
int MApriceS=PRICE_CLOSE;

int MAshiftM=0;
int MAmethodM=MODE_EMA;
int MApriceM=PRICE_CLOSE;

int MAshiftL=0;
int MAmethodL=MODE_LWMA;
int MApriceL=PRICE_CLOSE;

// Internal usage parameters:
int Slippage=3,bo=1;
int lotsprecision=2;

double lotsmin,lotsmax,MaxNOrders;
bool LongExit,ShortExit;
int ot,lasttime;
string comment1,comment2,comment3;
int magic12,magic3;
int Norders;
color clrL=Blue,clrS=Red;
string strL="Pip Sniper L",strS="Pip Sniper S";
int code=1;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----
 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT);
 if(lotsmin==0.10) lotsprecision=1;
 MaxNOrders=PARTA/PART;
 magic12  =11000+Period(); 
 magic3   =11001+Period(); 
 string pd;
 switch(Period())
 {
  case 1:     pd="M1"; break;
  case 5:     pd="M5"; break;
  case 15:    pd="M15";break;
  case 30:    pd="M30";break;
  case 60:    pd="H1"; break;
  case 240:   pd="H4"; break;
  case 1440:  pd="D1"; break;
  case 10080: pd="W1"; break;
  case 40320: pd="M1"; break;
  default:    pd="Unknown";break;
 }
 comment1  =StringConcatenate(pd," Pip Sniper 1"); 
 comment2  =StringConcatenate(pd," Pip Sniper 2"); 
 comment3  =StringConcatenate(pd," Pip Sniper 3");
 
// First check closed trades
 int trade;                         
 int trades=OrdersHistoryTotal();           
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);

  if(OrderSymbol()!=Symbol())
   continue;

  int D1bars=iBarShift(NULL,PERIOD_D1,OrderCloseTime(),false);
  if(D1bars>30)
   continue;
   
  Status(OrderMagicNumber());
 }

// Now check open orders
                       
 trades=OrdersTotal();           
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol())
   continue;

  Status(OrderMagicNumber());
  if(OrderType()==OP_BUY)       DrawCross(OrderOpenPrice(),OrderOpenTime(),strL,clrL,code);
  else if(OrderType()==OP_SELL) DrawCross(OrderOpenPrice(),OrderOpenTime(),strS,clrS,code);
 }
 
 ManageOrders();
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
 return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
//----
 if(lasttime!=iTime(NULL,0,0))
 {
  SubmitOrders();
 } 
 ManageOrders();
 lasttime=iTime(NULL,0,0); 
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+
void SubmitOrders()
{
 LongExit=false;ShortExit=false; 

 double mas1,mam1,mas2,mam2;

 mas1=iMA(NULL,0,MAperiodS,MAshiftS,MAmethodS,MApriceS,1);
 mam1=iMA(NULL,0,MAperiodM,MAshiftM,MAmethodM,MApriceM,1);
 mas2=iMA(NULL,0,MAperiodS,MAshiftS,MAmethodS,MApriceS,2);
 mam2=iMA(NULL,0,MAperiodM,MAshiftM,MAmethodM,MApriceM,2);
 
 if(mas1<mam1&&mas2>mam2) LongExit=true;
 if(mas1>mam1&&mas2<mam2) ShortExit=true;

 if(Norders>=MaxNOrders) return;
 
 int i,j,shift,checktime=iBarShift(NULL,0,ot,false);
 if(checktime<bo) return;

 double target,lots,SL,TP,mal1;
 double prevHigh,prevLow; 
 bool trigger;

 double psar=iSAR(NULL,0,PSARStep,PSARMax,1);
 
 shift=iHighest(NULL,0,MODE_HIGH,LookBackPeriod,2);
 target=iHigh(NULL,0,shift);
 prevHigh=iHigh(NULL,0,1); 

 if(Bid>psar)
 { 
  if(prevHigh>target)
  {
   for(i=1;i<=WindowPSAR;i++)
   {
    mas1=iMA(NULL,0,MAperiodS,MAshiftS,MAmethodS,MApriceS,i);
    mam1=iMA(NULL,0,MAperiodM,MAshiftM,MAmethodM,MApriceM,i);
    mas2=iMA(NULL,0,MAperiodS,MAshiftS,MAmethodS,MApriceS,i+1);
    mam2=iMA(NULL,0,MAperiodM,MAshiftM,MAmethodM,MApriceM,i+1);
     
    if(mas1>mam1 && mas2<mam2)
    {
     trigger=true;     
     for(j=1;j<=i;j++)
     {      
      mas1=iMA(NULL,0,MAperiodS,MAshiftS,MAmethodS,MApriceS,j);
      mam1=iMA(NULL,0,MAperiodM,MAshiftM,MAmethodM,MApriceM,j);
      mas2=iMA(NULL,0,MAperiodS,MAshiftS,MAmethodS,MApriceS,j+1);
      mam2=iMA(NULL,0,MAperiodM,MAshiftM,MAmethodM,MApriceM,j+1); 
 
      if(mas1<mam1 && mas2>mam2)
      {       
       trigger=false;
       break;
      }
     }
     
     if(trigger)
     {
      if(iTime(NULL,0,i)>ot)
      {
       SL=StopLong(Ask,StopLoss);
       lots=DetermineLots(Ask,SL,3); 
       TP=TakeLong(Ask,TakeProfit1);
       SendOrderLong(Symbol(),lots,Slippage,SL,TP,comment1,magic12,0,Blue);
       TP=TakeLong(Ask,TakeProfit2);
       SendOrderLong(Symbol(),lots,Slippage,SL,TP,comment2,magic12,0,Blue);        
       TP=TakeLong(Ask,TakeProfit3);
       SendOrderLong(Symbol(),lots,Slippage,SL,TP,comment3,magic3,0,Blue);    
       ot=TimeCurrent();  
       return;
      }
     }
    }
   }
  } 
 }
 
 shift=iLowest(NULL,0,MODE_LOW,LookBackPeriod,2);
 target=iLow(NULL,0,shift);
 prevLow=iLow(NULL,0,1); 

 if(Bid<psar)
 {
  if(prevLow<target)
  { 
   for(i=1;i<=WindowPSAR;i++)
   {
    mas1=iMA(NULL,0,MAperiodS,MAshiftS,MAmethodS,MApriceS,i);
    mam1=iMA(NULL,0,MAperiodM,MAshiftM,MAmethodM,MApriceM,i);
    mas2=iMA(NULL,0,MAperiodS,MAshiftS,MAmethodS,MApriceS,i+1);
    mam2=iMA(NULL,0,MAperiodM,MAshiftM,MAmethodM,MApriceM,i+1);
  
    if(mas1<mam1 && mas2>mam2)
    {
     trigger=true;     
     for(j=1;j<=i;j++)
     {      
      mas1=iMA(NULL,0,MAperiodS,MAshiftS,MAmethodS,MApriceS,j);
      mam1=iMA(NULL,0,MAperiodM,MAshiftM,MAmethodM,MApriceM,j);
      mas2=iMA(NULL,0,MAperiodS,MAshiftS,MAmethodS,MApriceS,j+1);
      mam2=iMA(NULL,0,MAperiodM,MAshiftM,MAmethodM,MApriceM,j+1); 
 
      if(mas1>mam1 && mas2<mam2)
      {       
       trigger=false;
       break;
      }
     }
      
     if(trigger)
     {
      if(iTime(NULL,0,i)>ot)
      {
       SL=StopShort(Bid,StopLoss);
       lots=DetermineLots(SL,Bid,3);       
       TP=TakeShort(Bid,TakeProfit1);
       SendOrderShort(Symbol(),lots,Slippage,SL,TP,comment1,magic12,0,Red);  
       TP=TakeShort(Bid,TakeProfit2);
       SendOrderShort(Symbol(),lots,Slippage,SL,TP,comment2,magic12,0,Red);        
       TP=TakeShort(Bid,TakeProfit3);
       SendOrderShort(Symbol(),lots,Slippage,SL,TP,comment3,magic3,0,Red);        
       ot=TimeCurrent();
       return;
      }
     }
    }
   }
  }
 }
 return;
}
//+------------------------------------------------------------------+
void ManageOrders()
{
 Norders=0;
 double profit=0;
 int i,mn,trail,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);

  mn=OrderMagicNumber();
  if(mn==magic12 || mn==magic3)
  {
   Norders++; // count for *all* open orders of this method
   if(OrderSymbol()==Symbol())
   {
    int checktime=iBarShift(NULL,0,OrderOpenTime(),false);  

    if(SLProfit>0) 
    {
     profit=DetermineProfit();
     if(profit>=NormPoints(SLProfit))
     {   
      if(TrailProfit>0) QuantumTrailingStop(TrailProfit,TrailMove);    
      FixedStopsB(SLProfit,SLMove);
     }
    }   

    if(checktime<bo) continue;   
    
    if(OrderType()==OP_BUY)
    {
     if(LongExit) 
     {
      ExitOrder(true,false);    
      Norders--;
     }
    }
    else if(OrderType()==OP_SELL)
    {   
     if(ShortExit) 
     {
      ExitOrder(false,true);   
      Norders--;
     }
    }
   }
  } 
 }
 return;
}

//+------------------------------------------------------------------+

int SendOrderLong(string sym, double vol, int slip, double sl, double tp, string comment="", int m=0, datetime exp=0, color cl=CLR_NONE)
{  
 if(vol==0.00) return;
 int err;
 bool attempt=true;
 while(attempt)
 {
  if(IsTradeAllowed())
  {
   for(int z=0;z<10;z++)
   {  
    if(OrderSend(sym,OP_BUY,NormLots(vol),Ask,slip,NormDigits(sl),NormDigits(tp),comment,m,exp,cl)<0)
    {  
     err = GetLastError();
     Print("OrderSend Long failed, Error: ", err);
     Print("Ask: ", Ask, " S/L ", sl, " T/P ", tp);
     if(err>4000)
     { 
      attempt=false;
      break;
     }     
     RefreshRates();
    }
    else 
    {
     attempt=false;
     break;
    }
   }
  }
 }
 return(0);
}
//+------------------------------------------------------------------+

int SendOrderShort(string sym, double vol, int slip, double sl, double tp, string comment="", int m=0, datetime exp=0, color cl=CLR_NONE)
{  
 if(vol==0.00) return;
 int err;
 bool attempt=true;
 while(attempt)
 {
  if(IsTradeAllowed())
  {
   for(int z=0;z<10;z++)
   {  
    if(OrderSend(sym,OP_SELL,NormLots(vol),Bid,slip,NormDigits(sl),NormDigits(tp),comment,m,exp,cl)<0)
    {  
     err = GetLastError();
     Print("OrderSend Short failed, Error: ", err);
     Print("Bid: ", Bid, " S/L ", sl, " T/P ", tp);   
     if(err>4000)
     { 
      attempt=false;
      break;
     }     
     RefreshRates();
    }
    else 
    {
     attempt=false;
     break;
    }
   }
  }
 }
 return(0);
}

//+------------------------------------------------------------------+
bool CloseOrderLong(int ticket, double lots, int slip, color cl=CLR_NONE)
{ 
 bool attempt=true;
 while(attempt)
 {
  if(IsTradeAllowed())
  {
   for(int z=0;z<10;z++)
   {
    if(!OrderClose(ticket,NormLots(lots),Bid,slip,cl))
    {  
     int err = GetLastError();
     Print("OrderClose Long failed, Error: ", err, " Ticket #: ", ticket);
     Print("Bid: ", Bid);   
     if(err>4000)
     { 
      attempt=false;
      break;
     }     
     RefreshRates();
    }
    else
    {
     attempt=false;
     break;
    }
   }
  }
 }
 return(true);
} 
//+------------------------------------------------------------------+
bool CloseOrderShort(int ticket, double lots, int slip, color cl=CLR_NONE)
{
 bool attempt=true;
 while(attempt)
 {
  if(IsTradeAllowed())
  {
   for(int z=0;z<10;z++)
   {
    if(!OrderClose(ticket,NormLots(lots),Ask,slip,cl))
    {  
     int err = GetLastError();
     Print("OrderClose Short failed, Error: ", err, " Ticket #: ", ticket);
     Print("Ask: ", Ask);   
     if(err>4000)
     { 
      attempt=false;
      break;
     }     
     RefreshRates();
    }
    else
    {
     attempt=false;
     break;
    }
   }
  }
 }
 return(true);
} 
//+------------------------------------------------------------------+

void FixedStopsB(int PP,int PFS)
{
  if(PFS<=0) return;

  double stopcrnt,stopcal;
  double profit,profitpoint;

  stopcrnt=OrderStopLoss();
  profitpoint=NormPoints(PP);  

//Long               

  if(OrderType()==OP_BUY)
  {
   profit=Bid-OrderOpenPrice();
   
   if(profit>=profitpoint)
   {
    stopcal=TakeLong(OrderOpenPrice(),PFS);
    ModifyCompLong(stopcal,stopcrnt);   
   }
  }    
//Short 
  if(OrderType()==OP_SELL)
  {  
   profit=OrderOpenPrice()-Ask;
   
   if(profit>=profitpoint)
   {
    stopcal=TakeShort(OrderOpenPrice(),PFS);
    ModifyCompShort(stopcal,stopcrnt);
   }
  }  
 return(0);
} 
//+------------------------------------------------------------------+

void ModifyCompLong(double stopcal, double stopcrnt)
{
 stopcal=NormDigits(stopcal);
 stopcrnt=NormDigits(stopcrnt);

 if (stopcal==stopcrnt) return;
 
 if(stopcal>stopcrnt)
 {                     
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
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);     
 }
 else if(stopcal<stopcrnt&&stopcal!=0)
 {
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red); 
 }
 return;
}
//+------------------------------------------------------------------+
double StopLong(double price,int stop)
{
 if(stop<=0) return(0.0);
 return(NormDigits(price-NormPoints(stop))); 
}
//+------------------------------------------------------------------+
double StopShort(double price,int stop) 
{
 if(stop<=0) return(0.0);
 return(NormDigits(price+NormPoints(stop))); 
}
//+------------------------------------------------------------------+
double TakeLong(double price,int take)  
{
 if(take<=0) return(0.0);

 return(NormDigits(price+NormPoints(take))); 
}
//+------------------------------------------------------------------+
double TakeShort(double price,int take) 
{
 if(take<=0) return(0.0);  
 return(NormDigits(price-NormPoints(take))); 
}
//+------------------------------------------------------------------+
void QuantumTrailingStop(int TP, int TM) // for every additional TP of profit above SLMove, lock in an additional TM
{
 if(TP<=0) return;
  
 double stopcrnt,stopcal,profit,openprice; 
 int profitpips;
 
 stopcrnt= NormDigits(OrderStopLoss());
 openprice=NormDigits(OrderOpenPrice());
 profit=NormDigits(DetermineProfit());
             
 if(OrderType()==OP_BUY)
 {
  if(stopcrnt<openprice) return;
  profitpips=(stopcrnt-openprice)/Point;
  profitpips+=(SLProfit-SLMove)+TP;

  if(profit>=NormPoints(profitpips))
  {
   stopcal=stopcrnt+NormPoints(TM);
   if (stopcal==stopcrnt) return;
   ModifyCompLong(stopcal,stopcrnt); 
  }
 }    

 if(OrderType()==OP_SELL)
 {  
  if(stopcrnt>openprice) return; 
  profitpips=(openprice-stopcrnt)/Point;
  profitpips+=(SLProfit-SLMove)+TP;

  if(profit>=NormPoints(profitpips))
  {
   stopcal=stopcrnt-NormPoints(TM);

   if (stopcal==stopcrnt) return;  
   ModifyCompShort(stopcal,stopcrnt); 
  }
 }  
 
 return(0);
}

//+------------------------------------------------------------------+

bool ModifyOrder(int ticket, double price, double sl, double tp, datetime exp, color cl=CLR_NONE)
{ 
 bool attempt=true;
 while(attempt)
 {
  if(IsTradeAllowed())
  {
   if(OrderModify(ticket,price,sl,tp,exp,cl)==false)
   {  
    Print("OrderModify failed, Error: ",GetLastError(), " Ticket Number: ", ticket);
    Print("Old price: ", OrderOpenPrice(), " Old S/L ", OrderStopLoss(), " Old T/P ", OrderTakeProfit(), " Ask/Bid ",Ask,", ",Bid);
    Print(" New Price: ", price, " New S/L ", sl, " New T/P ", tp, " New Expiration ", exp);
   }
   attempt=false;
  }
 }
 return(true);
}
//+------------------------------------------------------------------+
double NormDigits(double price)
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+
double NormPoints(int pips)
{
 return(NormalizeDouble(pips*Point,Digits));
}
//+------------------------------------------------------------------+
double NormLots(double lots)
{
 return(MathMax(NormalizeDouble(lotsmin,lotsprecision),NormalizeDouble(lots,lotsprecision)));
}
//+------------------------------------------------------------------+
double DetermineLots(double value1, double value2, double number)  // function to determine lot sizes based on account balance
{
 double permitLoss=PART*AccountBalance();
 double pipSL=(value1-value2)/Point;
 double valueSL=pipSL*MarketInfo(Symbol(),MODE_TICKVALUE);
 
 double lots=permitLoss/valueSL;
 lots/=number;
 
 if(lots<lotsmin) return(lotsmin);
 else if(lots>lotsmax) return(lotsmax);
 
 return(lots);
}
//+------------------------------------------------------------------+
double DetermineProfit()
{
 if(OrderType()==OP_BUY)  
 {
  return(NormDigits(Bid-OrderOpenPrice()));
 } 
 else if(OrderType()==OP_SELL)
 { 
  return(NormDigits(OrderOpenPrice()-Ask)); 
 }
 return(0);
}
//+------------------------------------------------------------------+
void ExitOrder(bool flag_Long,bool flag_Short)
{
 if(OrderType()==OP_BUY&&flag_Long)
  CloseOrderLong(OrderTicket(),OrderLots(),Slippage,Lime);
 else if(OrderType()==OP_SELL&&flag_Short)
  CloseOrderShort(OrderTicket(),OrderLots(),Slippage,Lime);
 return;
}
//+------------------------------------------------------------------+
void Status(int mn)
{   
 if(mn==magic12 || mn==magic3) ot=OrderOpenTime();
 return;
}
//+------------------------------------------------------------------+
void DrawCross(double price, int time1, string str, color clr, int code)
{
 string name=StringConcatenate(str,time1);
 ObjectDelete(name);  
 ObjectCreate(name,OBJ_ARROW,0,time1,price);
 ObjectSet(name,OBJPROP_COLOR,clr);
 ObjectSet(name,OBJPROP_ARROWCODE,code); 
 ObjectSet(name,OBJPROP_WIDTH,1);
 return;
}
//+------------------------------------------------------------------+