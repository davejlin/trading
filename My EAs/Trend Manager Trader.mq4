//+----------------------------------------------------------------------+
//|                                             Trend Manager Trader.mq4 |
//|                                                         David J. Lin |
//|Based on the TrendManager indicator                                   |
//|Written for Leo Lepore (forexleo@yahoo.com)                           |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, July 17-July 23, 2007                                   |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007, David J. Lin"
#property link      ""

// User adjustable parameters:
extern double Lots1 = 1;       // use negative whole numbers for percentage of margin (e.g. -20 for 20% margin per trade)
extern int TakeProfit1=-1;     // pips desired TP (use negative number if no TP is desired)
extern double Lots2 = 1;       // use negative whole numbers for percentage of margin (e.g. -20 for 20% margin per trade)
extern int TakeProfit2=-1;     // pips desired TP (use negative number if no TP is desired)
extern int StopLoss=-1;        // pips desired SL (use negative number if no SL is desired)
extern int TrailStop=-1;       // pips desired trailing stop (use negative number if no trail is desired)
extern int SLProfit=-1;        // pips profit after which to move SL  (use negative number if not desired)
extern int SLMove=1;           // pips to move SL to BE+SLMove after SLProfit is reached
extern double TotalProfit=-1;  // dollar amount after which to close all orders (use negative value if not desired)
extern double PairProfit=-1;   // dollar amount after which to close a given pair's orders (use negative value if not desired)
extern double TextTotalProfit=-1; // dollar amount total profit after which to send email alert (use negative value if not desired)
extern double TextPairProfit=-1;  // dollar amount pair profit after which to send email alert (use negative value if not desired)
extern int Trade_Start=-1;     // GMT  inclusive (use negative value to turn off)
extern int Trade_End=-1;       // GMT  inclusive (use negative value to turn off)
extern double OffZone_High=-1; // upper price of price zone in which to deactivate EA inclusive (use negative value to turn off)
extern double OffZone_Low=-1;  // lower price of price zone in which to deactivate EA inclusive (use negative value to turn off)
extern int LongTermTrend=0;    // use period in M1 bars (1440 = D1, 240 = H4, 60 = H1, etc), or enter 0 for NO Long-term Trend determination
extern bool LongTermTrend1Max=true;  // when using LongTermTrend: true = only allow 1 order at a time, false = multiple orders allowed at a time 
extern bool UseRSI=false;
extern bool UseiTrend=false;
extern int iTrendWindow=3;     // number of previous bars for iTrend cross confirmation
extern double RSIBuyLow=50;
extern double RSIBuyHigh=60;
extern double RSISellLow=40;
extern double RSISellHigh=50;

// Internal usage parameters:
int Slippage=3,bo;
int lotsprecision=2;
double lotsmin,lotsmax,rMargin,PercentMargin1,PercentMargin2,ot;
bool LongOrder,ShortOrder,Margin1=false,Margin2=false;
bool LongExit,ShortExit;
bool Up,DUp;
string comment="TrendM";
// string ciTM="TrendManager";
// string ciiT="i_Trend-v2(032707)";
int RSIPeriod=21;
int RSIPrice=PRICE_CLOSE;

int Norders;
// TrendManager parameters:

int TM_var_84 = 7;
double TM_var_start_4 = 1.6;
double TM_var_start_12 = 50;

// iTrend parameters:
int iT_Bands_Mode_0_2 = 0;
int iT_Power_Price_0_6 = 0;
int iT_Price_Type_0_3 = 0;
int iT_Bands_Period = 20;
int iT_Bands_Deviation = 2;
int iT_Power_Period = 13;
int iT_CountBars = 300;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----
 if(LongTermTrend!=PERIOD_MN1&&LongTermTrend!=PERIOD_W1 &&
    LongTermTrend!=PERIOD_D1 &&LongTermTrend!=PERIOD_H4 &&
    LongTermTrend!=PERIOD_H1 &&LongTermTrend!=PERIOD_M30&&
    LongTermTrend!=PERIOD_M15&&LongTermTrend!=PERIOD_M5 &&
    LongTermTrend!=PERIOD_M1 &&LongTermTrend!=0) 
  LongTermTrend=PERIOD_D1;
         
 if(LongTermTrend!=0 && LongTermTrend<=Period()) LongTermTrend=0;
         
 if(LongTermTrend>0) bo=1;
 else bo=0;
 
 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT);
 rMargin=MarketInfo(Symbol(),MODE_MARGINREQUIRED);

 if(lotsmin==0.10) lotsprecision=1;
 
 if(Lots1<0) 
 {
  Lots1=MathAbs(Lots1);
  PercentMargin1=0.01*Lots1;
  Margin1=true;
 } 

 if(Lots2<0) 
 {
  Lots2=MathAbs(Lots2);
  PercentMargin2=0.01*Lots2;
  Margin2=true;
 } 

 double vH,vL;
 
 for(int i=1;i<=100;i++) // initialize timeframe trend
 {
 
  vH=TrendManagerUp(0,i);
  vL=TrendManagerDn(0,i);
   
//  vH=iCustom(NULL,0,ciTM,0,i);
//  vL=iCustom(NULL,0,ciTM,1,i); 
 
  if(vH<vL) {Up=true;break;}
  if(vH>vL) {Up=false;break;}
 }

 for(i=1;i<=100;i++) // initialize D1 trend
 {

  vH=TrendManagerUp(LongTermTrend,i);
  vL=TrendManagerDn(LongTermTrend,i); 
 
//  vH=iCustom(NULL,LongTermTrend,ciTM,0,i);
//  vL=iCustom(NULL,LongTermTrend,ciTM,1,i); 
 
  if(vH<vL) {DUp=true;break;}
  if(vH>vL) {DUp=false;break;}
 }
 HideTestIndicators(true);
 ManageOrders();
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
 SubmitOrders();
 ManageOrders();
 ExitOrders(); 
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

void SubmitOrders()
{
 LongExit=false; ShortExit=false;
  
 if(LongTermTrend>0)
 {

  double vHD0=TrendManagerUp(LongTermTrend,0);
  double vLD0=TrendManagerDn(LongTermTrend,0); 

//  double vHD0=iCustom(NULL,LongTermTrend,ciTM,0,0);
//  double vLD0=iCustom(NULL,LongTermTrend,ciTM,1,0);

  if(vHD0<vLD0)
  {
   if(!DUp)
   {
    ShortExit=true;
    DUp=true;
   }
  }

  if(vHD0>vLD0)
  {
   if(DUp)
   {
    LongExit=true;
    DUp=false;
   }
  } 
 }
   
 double lots,vHi,vLi,SL,TP; 
 bool LongTrigger=false,ShortTrigger=false;
 
 double vH0=TrendManagerUp(0,0);
 double vL0=TrendManagerDn(0,0);
 
// double vH0=iCustom(NULL,0,ciTM,0,0);
// double vL0=iCustom(NULL,0,ciTM,1,0); 

 if(vH0<vL0)
 {
  if(!Up)
  {
   LongTrigger=true;
   Up=true;
  }
 }

 if(vH0>vL0)
 {
  if(Up)
  {
   ShortTrigger=true;
   Up=false;
  }
 } 

 int i,checktime=iBarShift(NULL,0,ot,false);
 if(checktime<bo) return;
 
 if(LongTermTrend>0)
 { 
 
  if(LongTermTrend1Max)
  {
   if(!LongOrder||!ShortOrder) return;
  }
 
  if(DUp)
  {
   if(LongTrigger)
   {
    if(Filter(true))
    {
     if(Margin1) lots=DetermineLots(PercentMargin1);
     else lots=Lots1;  

     SL=StopLong(Ask,StopLoss);
     TP=TakeLong(Ask,TakeProfit1);
     SendOrderLong(Symbol(),lots,Slippage,SL,TP,comment,0,0,Blue);

     if(Margin2) lots=DetermineLots(PercentMargin2);
     else lots=Lots2; 
          
     TP=TakeLong(Ask,TakeProfit2);
     SendOrderLong(Symbol(),lots,Slippage,SL,TP,comment,0,0,Blue);     
     ShortExit=true;
     ot=TimeCurrent();
    }
   }
  }
 
  if(!DUp)
  {
   if(ShortTrigger)
   { 
    if(Filter(false))
    {  
     if(Margin1) lots=DetermineLots(PercentMargin1);
     else lots=Lots1;
     
     SL=StopShort(Bid,StopLoss);
     TP=TakeShort(Bid,TakeProfit1);
     SendOrderShort(Symbol(),lots,Slippage,SL,TP,comment,0,0,Red);  

     if(Margin2) lots=DetermineLots(PercentMargin2);
     else lots=Lots2;
     
     TP=TakeShort(Bid,TakeProfit2);
     SendOrderShort(Symbol(),lots,Slippage,SL,TP,comment,0,0,Red);  
        
     LongExit=true;     
     ot=TimeCurrent();
    }
   }
  }

 }
 else
 { 
  
  if(LongOrder)
  {
   if(LongTrigger)
   {
    if(Filter(true))
    {
     if(Margin1) lots=DetermineLots(PercentMargin1);
     else lots=Lots1;  

     SL=StopLong(Ask,StopLoss);
     TP=TakeLong(Ask,TakeProfit1);
     SendOrderLong(Symbol(),lots,Slippage,SL,TP,comment,0,0,Blue);

     if(Margin2) lots=DetermineLots(PercentMargin2);
     else lots=Lots2; 
          
     TP=TakeLong(Ask,TakeProfit2);
     SendOrderLong(Symbol(),lots,Slippage,SL,TP,comment,0,0,Blue);  
     
     ShortExit=true;    
     ot=TimeCurrent();
    }
   }
  }
 
  if(ShortOrder)
  {
   if(ShortTrigger)
   { 
    if(Filter(false))
    {  
     if(Margin1) lots=DetermineLots(PercentMargin1);
     else lots=Lots1;
     
     SL=StopShort(Bid,StopLoss);
     TP=TakeShort(Bid,TakeProfit1);
     SendOrderShort(Symbol(),lots,Slippage,SL,TP,comment,0,0,Red);  

     if(Margin2) lots=DetermineLots(PercentMargin2);
     else lots=Lots2;
     
     TP=TakeShort(Bid,TakeProfit2);
     SendOrderShort(Symbol(),lots,Slippage,SL,TP,comment,0,0,Red); 

     LongExit=true;         
     ot=TimeCurrent();
    }
   }
  }

 }
 
 return;
}

//+------------------------------------------------------------------+

void ManageOrders()
{
 LongOrder=true;
 ShortOrder=true;
 Norders=0;
 double profit=0;
 int i,j,trail,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;

  profit+=OrderProfit();

  if(OrderType()==OP_BUY)
  {
   LongOrder=false;  
   Norders++; 
   if(LongExit) 
   {
    ExitOrder(true,false);    
    LongOrder=true;
    Norders--;
   }
  }
  else if(OrderType()==OP_SELL)
  {
   ShortOrder=false;
   Norders++;
   if(ShortExit) 
   {
    ExitOrder(false,true);   
    ShortOrder=true;
    Norders--;
   }
  }
  
  if(SLProfit>0) 
  {
   FixedStopsB(SLProfit,SLMove);
   if(DetermineProfit()>NormPoints(SLProfit))
   {
    if(TrailStop>0) TrailingStop(TrailStop);
   }
  }
 } 

 if(PairProfit>0)
 {
  if(profit>=PairProfit)
  {
   for(i=OrdersTotal()-1;i>=0;i--)
   {
    if(OrderSymbol()!=Symbol()) continue;    
    OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

    if(OrderType()==OP_BUY)       CloseOrderLong(OrderTicket(),OrderLots(),Slippage,Lime);
    else if(OrderType()==OP_SELL) CloseOrderShort(OrderTicket(),OrderLots(),Slippage,Lime);
   } 
  }
 }

 if(TextPairProfit>0)
 {
  if(profit>=TextPairProfit) 
  {
   string message=StringConcatenate(Symbol()," has reached ",profit," of profit!");
   SendMessage(message);
   Alert(message);
  }
 }
 
 return;
}
//+------------------------------------------------------------------+
void ExitOrders()
{
 double ActualProfit=AccountProfit();

 if(TotalProfit>0)
 { 
  if(ActualProfit>=TotalProfit)
  { 
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
    OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

    if(OrderType()==OP_BUY)       CloseOrderLong(OrderTicket(),OrderLots(),Slippage,Lime);
    else if(OrderType()==OP_SELL) CloseOrderShort(OrderTicket(),OrderLots(),Slippage,Lime);
   }   
  }
 }
 
 if(TextTotalProfit>0)
 {
  if(ActualProfit>=TextTotalProfit)
  {  
   string message=StringConcatenate("Total profit has reached ",ActualProfit," of profit!");
   SendMessage(message);
  }
  Alert(message);   
 }
 
 return;
}
//+------------------------------------------------------------------+
bool Filter(bool long)
{
 int Trigger[4], totN=4, i,j;
 double value1,value2,value3,value4;
 
 for(i=0;i<totN;i++) Trigger[i]=-1;

 if(long) // long filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   { 
    case 0:
     if(UseRSI)
     {
      value1=iRSI(NULL,0,RSIPeriod,RSIPrice,0); 
      if(value1>RSIBuyLow && value1<RSIBuyHigh) Trigger[i]=1;
     }
     else Trigger[i]=1;
     break;  
    case 1:
     if(UseiTrend)
     {
      for(j=0;j<=iTrendWindow;j++)
      {
       value1=iTrendGreen(j);
       value2=iTrendRed(j);
       value3=iTrendGreen(j+1);
       value4=iTrendRed(j+1);
       
//       value1=iCustom(NULL,0,ciiT,iT_Bands_Mode_0_2,iT_Power_Price_0_6,iT_Price_Type_0_3,iT_Bands_Period,iT_Bands_Deviation,iT_Power_Period,iT_CountBars,0,j);    
//       value2=iCustom(NULL,0,ciiT,iT_Bands_Mode_0_2,iT_Power_Price_0_6,iT_Price_Type_0_3,iT_Bands_Period,iT_Bands_Deviation,iT_Power_Period,iT_CountBars,1,j);
//       value3=iCustom(NULL,0,ciiT,iT_Bands_Mode_0_2,iT_Power_Price_0_6,iT_Price_Type_0_3,iT_Bands_Period,iT_Bands_Deviation,iT_Power_Period,iT_CountBars,0,j+1);    
//       value4=iCustom(NULL,0,ciiT,iT_Bands_Mode_0_2,iT_Power_Price_0_6,iT_Price_Type_0_3,iT_Bands_Period,iT_Bands_Deviation,iT_Power_Period,iT_CountBars,1,j+1);

       if(value1>value2&&value3<=value4) {Trigger[i]=1;break;}
      }
     }
     else Trigger[i]=1;
     break;
    case 2:
     if(!CheckTime()) Trigger[i]=1;
     break;
    case 3:
     if(OffZone_High>0 && OffZone_Low>0)
     {
      if(Bid>=OffZone_High || Bid<=OffZone_Low) Trigger[i]=1;
     }
     else Trigger[i]=1;
     break; 
   }
  }
 }
 else // short filters
 {
  for(i=0;i<totN;i++)
  { 
   switch(i)
   {  
    case 0:
     if(UseRSI)
     {    
      value1=iRSI(NULL,0,RSIPeriod,RSIPrice,0); 
      if(value1>RSISellLow && value1<RSISellHigh) Trigger[i]=1;
     }
     else Trigger[i]=1;
     break;
    case 1:
     if(UseiTrend)
     {
      for(j=0;j<=iTrendWindow;j++)
      {
       value1=iTrendGreen(j);
       value2=iTrendRed(j);
       value3=iTrendGreen(j+1);
       value4=iTrendRed(j+1);      
       
//       value1=iCustom(NULL,0,ciiT,iT_Bands_Mode_0_2,iT_Power_Price_0_6,iT_Price_Type_0_3,iT_Bands_Period,iT_Bands_Deviation,iT_Power_Period,iT_CountBars,0,j);    
//       value2=iCustom(NULL,0,ciiT,iT_Bands_Mode_0_2,iT_Power_Price_0_6,iT_Price_Type_0_3,iT_Bands_Period,iT_Bands_Deviation,iT_Power_Period,iT_CountBars,1,j);
//       value3=iCustom(NULL,0,ciiT,iT_Bands_Mode_0_2,iT_Power_Price_0_6,iT_Price_Type_0_3,iT_Bands_Period,iT_Bands_Deviation,iT_Power_Period,iT_CountBars,0,j+1);    
//       value4=iCustom(NULL,0,ciiT,iT_Bands_Mode_0_2,iT_Power_Price_0_6,iT_Price_Type_0_3,iT_Bands_Period,iT_Bands_Deviation,iT_Power_Period,iT_CountBars,1,j+1);

       if(value1<value2&&value3>=value4) {Trigger[i]=1;break;}
      }
     }
     else Trigger[i]=1;
     break; 
    case 2:
     if(!CheckTime()) Trigger[i]=1;
     break;
    case 3:
     if(OffZone_High>0 && OffZone_Low>0)
     {    
      if(Bid>=OffZone_High || Bid<=OffZone_Low) Trigger[i]=1;
     }
     else Trigger[i]=1;
     break;                                                         
   } 
  }
 }
  
 for(i=0;i<totN;i++) 
  if(Trigger[i]<0) return(false); // one anti-trigger is sufficient to not trigger at all, so return false (to order)

 return(true);  // no anti-trigger:  so, return true (to order)
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
   for(int z=0;z<5;z++)
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
   for(int z=0;z<5;z++)
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
double StopLong(double price,int stop) // function to calculate normal stoploss if long
{
 if(stop<=0) return(0.0);
 return(NormDigits(price-NormPoints(stop))); 
}
//+------------------------------------------------------------------+
double StopShort(double price,int stop) // function to calculate normal stoploss if short
{
 if(stop<=0) return(0.0);
 return(NormDigits(price+NormPoints(stop))); 
}
//+------------------------------------------------------------------+
double TakeLong(double price,int take)  // function to calculate takeprofit if long
{
 if(take<=0) return(0.0);

 return(NormDigits(price+NormPoints(take))); 
}
//+------------------------------------------------------------------+
double TakeShort(double price,int take)  // function to calculate takeprofit if short
{
 if(take<=0) return(0.0); // if no take profit
 return(NormDigits(price-NormPoints(take))); 
}
//+------------------------------------------------------------------+
void TrailingStop(int TS)
{
 if(TS<=0) return;
 
 double stopcrnt,stopcal; 
 double profit;
 
 stopcrnt=NormDigits(OrderStopLoss());
             
 if(OrderType()==OP_BUY)
 {
  stopcal=TrailLong(Bid,TS);
  if (stopcal==stopcrnt) return;
  ModifyCompLong(stopcal,stopcrnt);  
 }    

 if(OrderType()==OP_SELL)
 {  
  stopcal=TrailShort(Ask,TS);
  if (stopcal==stopcrnt) return;  
  ModifyCompShort(stopcal,stopcrnt); 
 } 
 
 return(0);
}
//+------------------------------------------------------------------+
double TrailLong(double price,int trail)
{
 return(NormDigits(price-NormPoints(trail))); 
}
//+------------------------------------------------------------------+
double TrailShort(double price,int trail)
{
 return(NormDigits(price+NormPoints(trail))); 
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
double DetermineLots(double prcnt)
{
 double pMargin=prcnt*AccountFreeMargin();
 double lots=pMargin/rMargin;
 if(lots<lotsmin) return(lotsmin);
 else if(lots>lotsmax) return(lotsmax);
 return(lots);
}
//+------------------------------------------------------------------+
double DetermineProfit()
{
 if(OrderType()==OP_BUY)  
 {
  return(Bid-OrderOpenPrice());
 } 
 else if(OrderType()==OP_SELL)
 { 
  return(OrderOpenPrice()-Ask); 
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
void SendMessage(string message)
{
 SendMail("MT4 Profit Alert!",message);
 return;
}
//+------------------------------------------------------------------+
bool CheckTime()
{
 if(Trade_Start>=0&&Trade_End>=0)
 {
  if(Trade_End>Trade_Start)
  {
   if(Hour()>=Trade_Start&&Hour()<=Trade_End) return(false);
  }
  else
  {
   if(Hour()>=Trade_Start||Hour()<=Trade_End) return(false);
  }
 }
 else return(false);
 
 return(true);
}
//+------------------------------------------------------------------+
double TrendManagerDn(int timeframe, int i)
{
 int shift;
 double var_start_36,var_start_44,var_start_76,var_start_84;
 shift=iHighest(NULL,timeframe,MODE_HIGH,TM_var_84,i);
 var_start_36 = iHigh(NULL,timeframe,shift);
 shift=iLowest(NULL,timeframe,MODE_LOW,TM_var_84,i);
 var_start_44 = iLow(NULL,timeframe,shift);
 var_start_76 = var_start_44 - (var_start_36 - var_start_44) * 0.01*TM_var_start_4;
 var_start_84 = var_start_36 - (var_start_36 - var_start_44) * 0.01*TM_var_start_12;
 return(var_start_84);
}
//+------------------------------------------------------------------+
double TrendManagerUp(int timeframe, int i)
{
 int j=i+2,shift;
 double var_start_36,var_start_44,var_start_76,var_start_84;
 shift=iHighest(NULL,timeframe,MODE_HIGH,TM_var_84,j);
 var_start_36 = iHigh(NULL,timeframe,shift);
 shift=iLowest(NULL,timeframe,MODE_LOW,TM_var_84,j);
 var_start_44 = iLow(NULL,timeframe,shift);
 var_start_76 = var_start_44 - (var_start_36 - var_start_44) * 0.01*TM_var_start_4;
 var_start_84 = var_start_36 - (var_start_36 - var_start_44) * 0.01*TM_var_start_12;
 return(var_start_84);
}
//+------------------------------------------------------------------+
double iTrendGreen(int i)  // return green-line value of iTrend indicator
{
 double var_start_24;
 switch(iT_Price_Type_0_3)
 {
  case 0: var_start_24 = iClose(NULL,0,i);break;
  case 1: var_start_24 = iOpen(NULL,0,i); break;
  case 2: var_start_24 = iHigh(NULL,0,i); break;
  case 3: var_start_24 = iLow(NULL,0,i);  break;
  default:var_start_24 = iClose(NULL,0,i);break;
 }
 return(var_start_24 - iBands(NULL,0,iT_Bands_Period,iT_Bands_Deviation,0,iT_Bands_Mode_0_2,iT_Power_Price_0_6,i));
}
//+------------------------------------------------------------------+
double iTrendRed(int i)  // return red-line value of iTrend indicator
{
 double var_start_24;
 switch(iT_Price_Type_0_3)
 {
  case 0: var_start_24 = iClose(NULL,0,i);break;
  case 1: var_start_24 = iOpen(NULL,0,i); break;
  case 2: var_start_24 = iHigh(NULL,0,i); break;
  case 3: var_start_24 = iLow(NULL,0,i);  break;
  default:var_start_24 = iClose(NULL,0,i);break;
 }
 return(-(iBearsPower(NULL,0,iT_Power_Period,iT_Power_Price_0_6,i) + iBullsPower(NULL,0,iT_Power_Period,iT_Power_Price_0_6,i)));
}