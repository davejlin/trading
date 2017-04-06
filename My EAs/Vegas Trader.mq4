//+----------------------------------------------------------------------+
//|                                                     Vegas Trader.mq4 |
//|                                                         David J. Lin |
//|Based on the Vegas trading strategy                                   |
//|Written for Todd Tolman (ttolman10@yahoo.com)                         |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |                                      |
//|Evanston, IL, July 6, 2007                                            |
//|Added Reverse-Trade function:  August 26, 2007                        |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007, David J. Lin"
#property link      ""

// User adjustable parameters:
extern double   Lot_size = 0.01;
extern int      Main_EMA = 12;
extern int      Main_EMA_Buffer = 5;
extern int      Main_EMA_LookBack=10;
extern int      Tunnel_EMA_A  = 144;
extern int      Tunnel_EMA_B	= 169;
extern int      Fib1 = 55;
extern int      Fib2 = 89;
extern int      Fib3 = 144;
extern int      Fib4 = 233;
extern int      Fib5 = 377;
extern int      Fib1_Stop = 20;
extern int      Fib2_Stop = 20;
extern int      Fib3_Stop = 20;
extern int      Fib4_Stop = 20;
extern int      Fib5_Stop = 233;
extern double   Fib1_Profit=1.00;
extern double   Fib2_Profit=1.00;
extern double   Fib3_Profit=1.00;
extern double   Fib4_Profit=1.00;
extern double   Fib5_Profit=1.00;
extern int      ReverseFibStart1=1;  // max: 5, min: 1, off: 0
extern int      ReverseFibStart2=3;  // max: 5, min: 1, off: 0
extern int      RFib5_Stop = 50;    // reverse trades
extern int      RFib4_Stop = 50;
extern int      RFib3_Stop = 50;
extern int      RFib2_Stop = 50;
extern int      RFib1_Stop = 50;
extern double   R1Fib4_Profit=1.00;  // reverse trades (for ReverseFibStart1)
extern double   R1Fib3_Profit=1.00;
extern double   R1Fib2_Profit=1.00;
extern double   R1Fib1_Profit=1.00;
extern double   R1Fib0_Profit=1.00;
extern double   R2Fib4_Profit=1.00;  // reverse trades (for ReverseFibStart2)
extern double   R2Fib3_Profit=1.00;
extern double   R2Fib2_Profit=1.00;
extern double   R2Fib1_Profit=1.00;
extern double   R2Fib0_Profit=1.00;
extern datetime Blackout_Calendar_Date_1=D'2007.12.25';
extern datetime Blackout_Calendar_Date_2=D'2008.01.01';
extern datetime Blackout_Calendar_Date_3=D'2008.12.25';
extern int      Blackout_Clock_Start=21; // GMT  (MST+6) inclusive (use negative value to turn off)
extern int      Blackout_Clock_End=3;    // GMT  (MST+6) inclusive (use negative value to turn off)
extern double   FreeMargin_Limit=100;      

// Internal usage parameters:

int Slippage=3,ndates=3,nlevels=5,bo=0;
double lotsmin,lotsmax,lotsT,lotsRT1,lotsRT2;
double mainEMAbuffer;
double matunnel[3],fibhigh[],fiblow[];
double fib[],fibstop[];
double Rfibstop[]; // reverse trades
double lots[],R1lots[],R2lots[];
datetime bodates[],lasttime;
bool OrderF,OrderR;
int magicF=43912,magicR1=43913,magicR2=43914;
string commentF="VegasF",commentR="VegasR";
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----
 int i;
 
 ArrayResize(bodates,ndates);
 ArrayResize(fib,nlevels);
 ArrayResize(fiblow,nlevels); 
 ArrayResize(fibstop,nlevels);
 ArrayResize(fibhigh,nlevels);
 ArrayResize(lots,nlevels); 

 ArrayResize(Rfibstop,nlevels);  // reverse trades
 ArrayResize(R1lots,nlevels); 
 ArrayResize(R2lots,nlevels);  
 
 lotsmin=NormLots(0.01);
 lotsmax=NormLots(50);

 lots[0]=NormLots(Fib1_Profit*Lot_size);
 lots[1]=NormLots(Fib2_Profit*Lot_size);
 lots[2]=NormLots(Fib3_Profit*Lot_size);
 lots[3]=NormLots(Fib4_Profit*Lot_size);
 lots[4]=NormLots(Fib5_Profit*Lot_size);

 lotsT=NormLots(0.00);
 for(i=0;i<nlevels;i++) 
 {
  lotsT=NormLots(lotsT+lots[i]);
 }
 
 R1lots[0]=NormLots(R1Fib0_Profit*Lot_size);  // reverse trades
 R1lots[1]=NormLots(R1Fib1_Profit*Lot_size);
 R1lots[2]=NormLots(R1Fib2_Profit*Lot_size);
 R1lots[3]=NormLots(R1Fib3_Profit*Lot_size);
 R1lots[4]=NormLots(R1Fib4_Profit*Lot_size);

 lotsRT1=NormLots(0.00);
 for(i=ReverseFibStart1-1;i>=0;i--) 
 {
  lotsRT1=NormLots(lotsRT1+R1lots[i]);
 }

 R2lots[0]=NormLots(R2Fib0_Profit*Lot_size);  // reverse trades
 R2lots[1]=NormLots(R2Fib1_Profit*Lot_size);
 R2lots[2]=NormLots(R2Fib2_Profit*Lot_size);
 R2lots[3]=NormLots(R2Fib3_Profit*Lot_size);
 R2lots[4]=NormLots(R2Fib4_Profit*Lot_size);

 lotsRT2=NormLots(0.00);
 for(i=ReverseFibStart2-1;i>=0;i--) 
 {
  lotsRT2=NormLots(lotsRT2+R2lots[i]);
 }
 
 mainEMAbuffer=NormPoints(Main_EMA_Buffer);
 
 fib[0]=NormPoints(Fib1);
 fib[1]=NormPoints(Fib2);
 fib[2]=NormPoints(Fib3);
 fib[3]=NormPoints(Fib4);
 fib[4]=NormPoints(Fib5); 
 fibstop[0]=NormPoints(Fib1_Stop);
 fibstop[1]=NormPoints(Fib2_Stop);
 fibstop[2]=NormPoints(Fib3_Stop);
 fibstop[3]=NormPoints(Fib4_Stop);
 fibstop[4]=NormPoints(Fib5_Stop); 
 Rfibstop[0]=NormPoints(RFib1_Stop);  // reverse trades
 Rfibstop[1]=NormPoints(RFib2_Stop);
 Rfibstop[2]=NormPoints(RFib3_Stop);
 Rfibstop[3]=NormPoints(RFib4_Stop);
 Rfibstop[4]=NormPoints(RFib5_Stop); 
 
 bodates[0]=Blackout_Calendar_Date_1;
 bodates[1]=Blackout_Calendar_Date_2;
 bodates[2]=Blackout_Calendar_Date_3;  
 
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
 GetLevels();
 ManageOrders();
 SubmitOrdersF();
 SubmitOrdersR(); 
 if(lasttime==Time[0]) return(0);
 lasttime=Time[0];
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

void SubmitOrdersF()
{
 if(BlackOuts()) return;
 if(OrderF) return;
 
 double phigh,plow,pma0,pma1,SL;int i;
 
 if(matunnel[0]>matunnel[1]) {phigh=matunnel[0];plow=matunnel[1];}
 else                        {phigh=matunnel[1];plow=matunnel[0];}
 pma0=matunnel[2];
  
 double open=iOpen(NULL,0,0); 
 double pdifflow =MathAbs(Bid-plow) -mainEMAbuffer; 
 double pdiffhigh=MathAbs(Bid-phigh)-mainEMAbuffer;
 double pdiffmain=MathAbs(Bid-pma0) -mainEMAbuffer;
 double TA=0.5*(phigh+plow);

 if(pdiffhigh<=0 && pdiffmain<=0)
 {
  if(pma0>=plow&&Bid>=phigh)
  {
   if(LookBackMA(1))
   {
    SL=TA-fibstop[0];
    SendOrderLong(Symbol(),lotsT,Slippage,SL,0,commentF,magicF,0,Blue);
    return;
   }
  }
 }

 if(pdifflow<=0 && pdiffmain<=0) 
 {
  if((pma0<=phigh&&Bid<=plow))
  {   
   if(LookBackMA(2))
   {
    SL=TA+fibstop[0];
    SendOrderShort(Symbol(),lotsT,Slippage,SL,0,commentF,magicF,0,Red);     
    return;
   }
  }
 }

 return;
}
//+------------------------------------------------------------------+
void SubmitOrdersR()
{
 if(BlackOuts()) return;
 if(OrderR) return;
 if(OrderF) return;
 
 double trigprice,SL;
 static double prevBid;

 trigprice=NormDigits(fiblow[ReverseFibStart1-1]);
 if(Bid==trigprice)
 {
  SL=trigprice-Rfibstop[ReverseFibStart1-1];
  SendOrderLong(Symbol(),lotsRT1,Slippage,SL,0,commentR,magicR1,0,Blue);
  return;
 }

 trigprice=NormDigits(fiblow[ReverseFibStart2-1]);
 if(Bid==trigprice)
 {
  SL=trigprice-Rfibstop[ReverseFibStart2-1];
  SendOrderLong(Symbol(),lotsRT2,Slippage,SL,0,commentR,magicR2,0,Blue);
  return;
 }

 trigprice=NormDigits(fibhigh[ReverseFibStart1-1]);
 if(Bid==trigprice)
 { 
  SL=trigprice+Rfibstop[ReverseFibStart1-1];
  SendOrderShort(Symbol(),lotsRT1,Slippage,SL,0,commentR,magicR1,0,Red);     
  return;
 }

 trigprice=NormDigits(fibhigh[ReverseFibStart2-1]);
 if(Bid==trigprice)
 { 
  SL=trigprice+Rfibstop[ReverseFibStart2-1];
  SendOrderShort(Symbol(),lotsRT2,Slippage,SL,0,commentR,magicR2,0,Red);     
  return;
 }
 
 return;
}
//+------------------------------------------------------------------+

void ManageOrders()
{
 OrderF=false; OrderR=false;
 int trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  
  switch(OrderMagicNumber())
  {
   case 43912:
   ManageVegasF();
   break;
   case 43913:
   ManageVegasR1();
   break;
   case 43914:
   ManageVegasR2();
   break;   
  }
 }
 return;
}
//+------------------------------------------------------------------+
void ManageVegasF() // forward trades
{
 OrderF=true;
 
 double currentlot=NormLots(lotsT); int i,j,trail;
 for(i=0;i<nlevels;i++)
 {
  if(currentlot==OrderLots()) break;
  currentlot=NormLots(currentlot-lots[i]);
 }
  
 if(OrderType()==OP_BUY)
 {     
  if(Bid>=fibhigh[i])
  {
   ExitOrder(true,false,lots[i]);

   for(j=OrdersTotal()-1;j>=0;j--) // re-cycle due to change in order number
   {
    OrderSelect(j,SELECT_BY_POS,MODE_TRADES);
    if(OrderSymbol()!=Symbol()) continue;    
    if(OrderMagicNumber()!=43912) continue;
    trail=(Bid-(fibhigh[i]-fibstop[i+1]))/Point;
    if(trail>0) TrailStop(trail);
    return;
   }
    
  }
  else if(i>0 && lasttime!=Time[0])
  {
   trail=(Bid-(fibhigh[i-1]-fibstop[i]))/Point;
   if(trail>0) TrailStop(trail);
  }
 }
 else if(OrderType()==OP_SELL)
 {
  if(Bid<=fiblow[i])
  {
   ExitOrder(false,true,lots[i]);

   for(j=OrdersTotal()-1;j>=0;j--) // re-cycle due to change in order number
   {
    OrderSelect(j,SELECT_BY_POS,MODE_TRADES);
    if(OrderSymbol()!=Symbol()) continue;  
    if(OrderMagicNumber()!=43912) continue;    
    trail=((fiblow[i]+fibstop[i+1])-Ask)/Point;
    if(trail>0) TrailStop(trail);     
    return;
   }
  } 
  else if(i>0 && lasttime!=Time[0]) 
  {
   trail=((fiblow[i-1]+fibstop[i])-Ask)/Point;
   if(trail>0) TrailStop(trail);
  }   
 } 
 return;
}
//+------------------------------------------------------------------+
void ManageVegasR1() // reversed trades
{
 OrderR=true;
 
 double plow,phigh;
 double currentlot=NormLots(lotsRT1); int i,j,trail;
 for(i=ReverseFibStart1-1;i>=0;i--)
 {
  if(currentlot==OrderLots()) break;
  currentlot=NormLots(currentlot-R1lots[i]);
 }
  
 if(OrderType()==OP_BUY)
 {     
  if(i>0)
  { 
   if(Bid>=fiblow[i-1])
   {
    ExitOrder(true,false,R1lots[i]);

    for(j=OrdersTotal()-1;j>=0;j--) // re-cycle due to change in order number
    {
     OrderSelect(j,SELECT_BY_POS,MODE_TRADES);
     if(OrderSymbol()!=Symbol()) continue;    
     if(OrderMagicNumber()!=43913) continue;
     trail=(Bid-(fiblow[i-1]-Rfibstop[i]))/Point;
     if(trail>0) TrailStop(trail);
     return;
    }
    
   }
   else if(i<ReverseFibStart1-1 && lasttime!=Time[0])
   {
    trail=(Bid-(fiblow[i]-Rfibstop[i]))/Point;
    if(trail>0) TrailStop(trail);
   }
  }
  else // tunnel
  {
   if(matunnel[0]>matunnel[1]) plow=matunnel[1];
   else                        plow=matunnel[0];
   
   if(Bid>=plow) ExitOrder(true,false,R1lots[0]);
   else if(lasttime!=Time[0])
   {
    trail=(Bid-(fiblow[0]-Rfibstop[0]))/Point;
    if(trail>0) TrailStop(trail);    
   }
  }
 }
 else if(OrderType()==OP_SELL)
 {
  if(i>0)
  {
   if(Bid<=fibhigh[i-1])
   {
    ExitOrder(false,true,R1lots[i]);

    for(j=OrdersTotal()-1;j>=0;j--) // re-cycle due to change in order number
    {
     OrderSelect(j,SELECT_BY_POS,MODE_TRADES);
     if(OrderSymbol()!=Symbol()) continue;  
     if(OrderMagicNumber()!=43913) continue;    
     trail=((fibhigh[i-1]+Rfibstop[i-1])-Ask)/Point;
     if(trail>0) TrailStop(trail);     
     return;
    }
   } 
   else if(i<ReverseFibStart1-1 && lasttime!=Time[0]) 
   {
    trail=((fibhigh[i]+Rfibstop[i])-Ask)/Point;
    if(trail>0) TrailStop(trail);
   }   
  }
  else // tunnel
  {
   if(matunnel[0]>matunnel[1]) phigh=matunnel[0];
   else                        phigh=matunnel[1];
   
   if(Bid<=phigh) ExitOrder(false,true,R1lots[0]);
   else if(lasttime!=Time[0])
   {
    trail=((fibhigh[0]+Rfibstop[0])-Ask)/Point;
    if(trail>0) TrailStop(trail);    
   } 
  }
 } 
 return;
}
//+------------------------------------------------------------------+
void ManageVegasR2() // reversed trades
{
 OrderR=true;
 
 double plow,phigh;
 double currentlot=NormLots(lotsRT2); int i,j,trail;
 for(i=ReverseFibStart2-1;i>=0;i--)
 {
  if(currentlot==OrderLots()) break;
  currentlot=NormLots(currentlot-R2lots[i]);
 }
  
 if(OrderType()==OP_BUY)
 {     
  if(i>0)
  { 
   if(Bid>=fiblow[i-1])
   {
    ExitOrder(true,false,R2lots[i]);

    for(j=OrdersTotal()-1;j>=0;j--) // re-cycle due to change in order number
    {
     OrderSelect(j,SELECT_BY_POS,MODE_TRADES);
     if(OrderSymbol()!=Symbol()) continue;    
     if(OrderMagicNumber()!=43914) continue;
     trail=(Bid-(fiblow[i-1]-Rfibstop[i]))/Point;
     if(trail>0) TrailStop(trail);
     return;
    }
    
   }
   else if(i<ReverseFibStart2-1 && lasttime!=Time[0])
   {
    trail=(Bid-(fiblow[i]-Rfibstop[i]))/Point;
    if(trail>0) TrailStop(trail);
   }
  }
  else // tunnel
  {
   if(matunnel[0]>matunnel[1]) plow=matunnel[1];
   else                        plow=matunnel[0];
   
   if(Bid>=plow) ExitOrder(true,false,R2lots[0]);
   else if(lasttime!=Time[0])
   {
    trail=(Bid-(fiblow[0]-Rfibstop[0]))/Point;
    if(trail>0) TrailStop(trail);    
   }
  }
 }
 else if(OrderType()==OP_SELL)
 {
  if(i>0)
  {
   if(Bid<=fibhigh[i-1])
   {
    ExitOrder(false,true,R2lots[i]);

    for(j=OrdersTotal()-1;j>=0;j--) // re-cycle due to change in order number
    {
     OrderSelect(j,SELECT_BY_POS,MODE_TRADES);
     if(OrderSymbol()!=Symbol()) continue;  
     if(OrderMagicNumber()!=43914) continue;    
     trail=((fibhigh[i-1]+Rfibstop[i-1])-Ask)/Point;
     if(trail>0) TrailStop(trail);     
     return;
    }
   } 
   else if(i<ReverseFibStart2-1 && lasttime!=Time[0]) 
   {
    trail=((fibhigh[i]+Rfibstop[i])-Ask)/Point;
    if(trail>0) TrailStop(trail);
   }   
  }
  else // tunnel
  {
   if(matunnel[0]>matunnel[1]) phigh=matunnel[0];
   else                        phigh=matunnel[1];
   
   if(Bid<=phigh) ExitOrder(false,true,R2lots[0]);
   else if(lasttime!=Time[0])
   {
    trail=((fibhigh[0]+Rfibstop[0])-Ask)/Point;
    if(trail>0) TrailStop(trail);    
   } 
  }
 } 
 return;
}
//+------------------------------------------------------------------+
bool BlackOuts()
{
 int i;

 if(AccountFreeMargin()<FreeMargin_Limit) return(true);

 if(Blackout_Clock_Start>=0&&Blackout_Clock_End>=0)
 {
  if(Blackout_Clock_End>Blackout_Clock_Start)
  {
   if(Hour()>=Blackout_Clock_Start&&Hour()<=Blackout_Clock_End) return(true);
  }
  else
  {
   if(Hour()>=Blackout_Clock_Start||Hour()<=Blackout_Clock_End) return(true);
  }
 }
 
 int thisday=Day(); 
 int thismonth=Month();
 int thisyear=Year();

 for(i=0;i<ndates;i++)
 {
  if(thisyear==TimeYear(bodates[i])&&thismonth==TimeMonth(bodates[i])&&thisday==TimeDay(bodates[i]))
   return(true);
 }
  
 return(false);
}

//+------------------------------------------------------------------+
void GetLevels()
{
 int i;
 matunnel[0]=iMA(NULL,0,Tunnel_EMA_A,0,MODE_EMA,PRICE_CLOSE,0);
 matunnel[1]=iMA(NULL,0,Tunnel_EMA_B,0,MODE_EMA,PRICE_CLOSE,0);
 matunnel[2]=iMA(NULL,0,Main_EMA    ,0,MODE_EMA,PRICE_CLOSE,0);
 
 double TA=NormDigits(0.5*(matunnel[0]+matunnel[1]));
 
 for(i=0;i<nlevels;i++)
 {
  fibhigh[i]=NormDigits(TA+fib[i]);
  fiblow[i] =NormDigits(TA-fib[i]);
 }
 
 return;
}

//+------------------------------------------------------------------+
bool LookBackMA(int flag)
{
 double t1,t2,th,tl,ma;int i;

 switch(flag)
 {
  case 1:
  for(i=1;i<=Main_EMA_LookBack;i++)
  {

   t1=iMA(NULL,0,Tunnel_EMA_A,0,MODE_EMA,PRICE_CLOSE,i);
   t2=iMA(NULL,0,Tunnel_EMA_B,0,MODE_EMA,PRICE_CLOSE,i);
   ma=iMA(NULL,0,Main_EMA    ,0,MODE_EMA,PRICE_CLOSE,i);

   if(t1>t2) {th=t1;tl=t2;}
   else      {th=t2;tl=t1;}

   if(ma>th) return(false);
  }
  break;
  case 2:
  for(i=1;i<=Main_EMA_LookBack;i++)
  {

   t1=iMA(NULL,0,Tunnel_EMA_A,0,MODE_EMA,PRICE_CLOSE,i);
   t2=iMA(NULL,0,Tunnel_EMA_B,0,MODE_EMA,PRICE_CLOSE,i);
   ma=iMA(NULL,0,Main_EMA    ,0,MODE_EMA,PRICE_CLOSE,i);

   if(t1>t2) {th=t1;tl=t2;}
   else      {th=t2;tl=t1;}
  
   if(ma<tl) return(false);
  }
  break; 
 }
 return(true);
}

//+------------------------------------------------------------------+

int SendOrderLong(string sym, double vol, int slip, double sl, double tp, string comment="", int m=0, datetime exp=0, color cl=CLR_NONE)
{ 
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
 return;
}

//+------------------------------------------------------------------+

int SendOrderShort(string sym, double vol, int slip, double sl, double tp, string comment="", int m=0, datetime exp=0, color cl=CLR_NONE)
{  
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
 return;
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
 return;
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
 return;
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
 return;
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
 if(lots==0) return(NormalizeDouble(0,2));
 
 return(MathMax(0.01,NormalizeDouble(lots,2)));
}
//+------------------------------------------------------------------+
void ExitOrder(bool flag_Long,bool flag_Short, double lots)
{
 if(lots==0) lots=OrderLots();
 if(OrderType()==OP_BUY&&flag_Long)
  CloseOrderLong(OrderTicket(),lots,Slippage,Lime);
 else if(OrderType()==OP_SELL&&flag_Short)
  CloseOrderShort(OrderTicket(),lots,Slippage,Lime);
 return;
}
//+------------------------------------------------------------------+
void TrailStop(int TS)
{
 double stopcrnt,stopcal; 
 double profit;
 
 stopcrnt=NormDigits(OrderStopLoss());
             
 if(OrderType()==OP_BUY)
 {
  stopcal=TrailLong(Bid,TS);
  if (stopcal==stopcrnt) return;
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue);  
 }    

 if(OrderType()==OP_SELL)
 {  
  stopcal=TrailShort(Ask,TS);
  if (stopcal==stopcrnt) return;  
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);   
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


