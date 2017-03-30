//+----------------------------------------------------------------------+
//|                                                   Leveler Trader.mq4 |
//|                                                         David J. Lin |
//|Based on a Supply & Demand trading strategy                           |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |                                         |
//|Evanston, IL, June 29, 2007                                           |
//+----------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      ""

// User adjustable parameters:
extern int VolumeBin=53; // for tick charts
extern int TimeFrame=0;//PERIOD_H4;
extern int BufferPips=3; // pips penetration to invalidate a level
extern int BarMin=1;     // previous bars to define breakout height
extern int bufferLevelPips=25; // minimum BO bar high/low to define level height
extern double Fraction=0.25; // fraction of level height for midpoint to qualify
extern double Factor=1.5; // factor of level height to qualify as breakout
extern double RiskMin=1;
extern double RiskMax=10;

// Internal usage parameters:
bool ticks=false;
double Lots=0;
int Slippage=3;

double StopRisk=0.01;

double DLow,DHigh,SLow,SHigh;
bool NoRunLong,NoRunShort,Stop=false;
int MagicLong=1,MagicShort=2;
double bufferPoints;
int bias;

int  Display_Corner=0;        // 0=top left, 1=top right, 2=bottom left, 3=bottom right
color Display_Color=Black;    // color for Display Status labels
int xpos=5;                      // pixels from left to show Display Status
int ypos=23;                      // pixels from top to show Display Status 
string statusSuH,statusSuL,statusDeH,statusDeL;
color statusColor=Blue;
double lotsmin,lotsmax;
datetime otLong,otShort;
int blackout=1;               // bars to blackout after a trigger;
bool es,el;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----
 if(!GlobalVariableCheck("SEMAPHORE")) GlobalVariableSet("SEMAPHORE",0);

 lotsmin=NormLots(0.01);
 lotsmax=NormLots(50);
  
 bufferPoints=NormPoints(BufferPips);
 
 DisplayStatusInit();
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
//---- 
 DeleteObjects();
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
 DisplayStatus();
//----   
// DetermineLots();
 ManageOrders(); 
 MainLong();   
 MainShort();
 GetLevels();
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void MainLong()
{
 es=false;
 if(NoRunLong) return;
 if(DLow==0||DHigh==0) return;

 int checktime=iBarShift(NULL,0,otLong,false); 

 if(checktime<0||checktime>blackout) 
 {
  double triggerPrice=NormDigits(DHigh-bufferPoints);

  double spread,entryPrice,SL,TP,lots,risk;
  if(Bid<=triggerPrice&&Bid>=DLow)
  {
   spread=Ask-Bid;
   entryPrice=NormDigits(DHigh+bufferPoints+spread); 
   SL=NormDigits(DLow-bufferPoints);
  
   if(SLow>0) TP=NormDigits(SLow-bufferPoints);
   else if(SHigh>0) TP=NormDigits(SHigh-bufferPoints);
   else TP=NormDigits(entryPrice+RiskMin*(entryPrice-SL+NormPoints(1)));
  
   risk=(TP-entryPrice)/(entryPrice-SL);
  
   if(risk < RiskMin) return;
   if(risk > RiskMax) TP=NormDigits(entryPrice+RiskMin*(entryPrice-SL+NormPoints(1)));
//    TP=NormDigits(entryPrice+Risk*(DHigh-DLow+bufferPoints));  

   if(Lots>0) lots=Lots;
   else lots=DetermineLots(entryPrice,SL,1,StopRisk);

   SendPending(Symbol(),OP_BUYSTOP,NormLots(lots),entryPrice,Slippage,SL,TP,"LVL",MagicLong,0,Blue); 
   NoRunLong=true;
   otLong=TimeCurrent();
   es=true;
  }
 }
 return; 
}
//+------------------------------------------------------------------+
void MainShort()
{
 el=false;
 if(NoRunShort) return;
 if(SLow==0||SHigh==0) return; 
 
 int checktime=iBarShift(NULL,0,otShort,false); 

 if(checktime<0||checktime>blackout) 
 { 
  double triggerPrice=NormDigits(SLow+bufferPoints);

  double spread,entryPrice,SL,TP,lots,risk;
  if(Bid>=triggerPrice&&Bid<=SHigh)
  {
   spread=Ask-Bid; 
   entryPrice=NormDigits(SLow-bufferPoints); 
   SL=NormDigits(SHigh+spread+bufferPoints);
  
   if(DHigh>0) TP=NormDigits(DHigh+spread+bufferPoints);
   else if(DLow>0) TP=NormDigits(DLow+spread+bufferPoints);  
   else TP=NormDigits(entryPrice-RiskMin*(SL-entryPrice+NormPoints(1)));  

   risk=(entryPrice-TP)/(SL-entryPrice);

   if(risk < RiskMin) return;
   if(risk > RiskMax) TP=NormDigits(entryPrice-RiskMin*(SL-entryPrice+NormPoints(1))); 
//    TP=NormDigits(entryPrice-Risk*(SHigh-SLow+bufferPoints));   
 
   if(Lots>0) lots=Lots;
   else lots=DetermineLots(SL,entryPrice,1,StopRisk);
  
   SendPending(Symbol(),OP_SELLSTOP,NormLots(lots),entryPrice,Slippage,SL,TP,"LVS",MagicShort,0,Red); 
   NoRunShort=true;
   otShort=TimeCurrent();
   el=true;
  }
 }
 return; 
}
//+------------------------------------------------------------------+
void GetLevels()
{
 string ciLeveler;
 if(ticks)
 {
  ciLeveler="Leveler Ticks";

  SHigh=iCustom(NULL,TimeFrame,ciLeveler,VolumeBin,TimeFrame,BufferPips,BarMin,bufferLevelPips,Fraction,Factor,0,0);
  SLow =iCustom(NULL,TimeFrame,ciLeveler,VolumeBin,TimeFrame,BufferPips,BarMin,bufferLevelPips,Fraction,Factor,1,0);
  DHigh=iCustom(NULL,TimeFrame,ciLeveler,VolumeBin,TimeFrame,BufferPips,BarMin,bufferLevelPips,Fraction,Factor,2,0);
  DLow =iCustom(NULL,TimeFrame,ciLeveler,VolumeBin,TimeFrame,BufferPips,BarMin,bufferLevelPips,Fraction,Factor,3,0);
 }
 else
 {
  ciLeveler="Leveler";

  SHigh=iCustom(NULL,TimeFrame,ciLeveler,TimeFrame,BufferPips,BarMin,bufferLevelPips,Fraction,Factor,0,0);
  SLow =iCustom(NULL,TimeFrame,ciLeveler,TimeFrame,BufferPips,BarMin,bufferLevelPips,Fraction,Factor,1,0);
  DHigh=iCustom(NULL,TimeFrame,ciLeveler,TimeFrame,BufferPips,BarMin,bufferLevelPips,Fraction,Factor,2,0);
  DLow =iCustom(NULL,TimeFrame,ciLeveler,TimeFrame,BufferPips,BarMin,bufferLevelPips,Fraction,Factor,3,0);
 }

 return;
}
//+------------------------------------------------------------------+ 

void ManageOrders()
{
 NoRunLong=false;NoRunShort=false;
 int trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;

  if(OrderMagicNumber()==MagicLong)
  {
   NoRunLong=true;
   ManageLong();
  }
   
  if(OrderMagicNumber()==MagicShort)
  {  
   NoRunShort=true;
   ManageShort();
  }

 } 
 return;
}
//+------------------------------------------------------------------+
/*
void CancelPending(int flag)
{
 int target;
 switch(flag) 
 {
  case 1:
   target=OP_BUYSTOP;
  break;    
  case 2:
   target=OP_SELLSTOP;
  break;  
 }
 int trade,trades=OrdersTotal(); 

 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);

  if(OrderSymbol()!=Symbol()) continue;
  if(OrderType()!=target) continue;

  OrderDelete(OrderTicket());
 } 
 return;
}
*/
//+------------------------------------------------------------------+
void ManageLong()
{
 ExitOrder(el,es);
 if(Bid<DLow) ExitOrder(true,false,2);
 return;
}
//+------------------------------------------------------------------+
void ManageShort()
{
 ExitOrder(el,es);
 if(Bid>SHigh) ExitOrder(false,true,2);
 return;
}
//+------------------------------------------------------------------+
int SendPending(string sym, int type, double vol, double price, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=CLR_NONE)
{ 
// In no existing pending order, submit new pending order.   
 int err;
 GetSemaphore();
 for(int z=0;z<5;z++)
 {  
  if(OrderSend(sym,type,NormLots(vol),NormDigits(price),slip,NormDigits(sl),NormDigits(tp),comment,magic,exp,cl)<0)
  {  
   err = GetLastError();
   Print("OrderSend Pending failed, Error: ", err, " Magic Number: ", magic, " Type: ", type);
   Print("Price: ", price, " S/L ", sl, " T/P ", tp);
   if(err>4000) break;
   RefreshRates();
  }
  else
   break;
 }
 ReleaseSemaphore();
}
//+------------------------------------------------------------------+
/*
bool ModifyOrder(int ticket, double price, double sl, double tp, datetime exp, color cl=CLR_NONE) // by Mike
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
*/
//+------------------------------------------------------------------+
/*
int SendOrderLong(string sym, double vol, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=CLR_NONE)
{ 
 int err;
 GetSemaphore();
 for(int z=0;z<5;z++)
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
*/
//+------------------------------------------------------------------+
/*
int SendOrderShort(string sym, double vol, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=CLR_NONE)
{  
 int err;
 GetSemaphore();
 for(int z=0;z<5;z++)
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
*/
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
 return(MathMax(0.01,NormalizeDouble(lots,2)));
}
//+------------------------------------------------------------------+
/*
void DetermineLots()
{
 return;
}
*/
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
void DisplayStatusInit()
{
 int xoffset=25; // pixel offset between labels and values
// Status Display
   
 ObjectMakeLabel( "Bias", xpos, ypos );
  ObjectMakeLabel( "SuH", xpos, ypos+10 );
 ObjectMakeLabel( "SuL", xpos, ypos+20 );
 ObjectMakeLabel( "DeH", xpos, ypos+30 );
 ObjectMakeLabel( "DeL", xpos, ypos+40 );

 ObjectMakeLabel( "SuHv", xpos+xoffset, ypos+10 );
 ObjectMakeLabel( "SuLv", xpos+xoffset, ypos+20 );
 ObjectMakeLabel( "DeHv", xpos+xoffset, ypos+30 ); 
 ObjectMakeLabel( "DeLv", xpos+xoffset, ypos+40 ); 

 ObjectSetText( "Bias", "Bias", 8, "Times", statusColor );
 ObjectSetText( "SuH", "SuH", 8, "Times", statusColor );
 ObjectSetText( "SuL", "SuL", 8, "Times", statusColor );
 ObjectSetText( "DeH", "DeH", 8, "Times", statusColor );
 ObjectSetText( "DeL", "DeL", 8, "Times", statusColor ); 

 ObjectSetText( "SuHv", "Initializing", 8, "Times", statusColor );
 ObjectSetText( "SuLv", "Initializing", 8, "Times", statusColor );
 ObjectSetText( "DeHv", "Initializing", 8, "Times", statusColor );
 ObjectSetText( "DeLv", "Initializing", 8, "Times", statusColor ); 

 ObjectMakeLabel( "BiasL", xpos+xoffset, ypos );
 ObjectMakeLabel( "BiasS", xpos+xoffset+10, ypos ); 
 ObjectSetText( "BiasL", "L", 8, "Times", statusColor );
 ObjectSetText( "BiasS", "S", 8, "Times", statusColor ); 
 
}
//+------------------------------------------------------------------+
int ObjectMakeLabel( string n, int xoff, int yoff ) 
{
 ObjectCreate( n, OBJ_LABEL, 0, 0, 0 );
 ObjectSet( n, OBJPROP_CORNER, Display_Corner );
 ObjectSet( n, OBJPROP_XDISTANCE, xoff );
 ObjectSet( n, OBJPROP_YDISTANCE, yoff );
 ObjectSet( n, OBJPROP_BACK, true );
}
//+------------------------------------------------------------------+
void DisplayStatus()
{
 color statusColorL, statusColorS;

 if(Stop)
 {
  ObjectSetText( "BiasL", "L", 8, "Times", Red );
  ObjectSetText( "BiasS", "S", 8, "Times", Red ); 
  ObjectSetText( "SuHv", "Error", 8, "Times", Red);
  ObjectSetText( "SuLv", "Error", 8, "Times", Red);
  ObjectSetText( "DeHv", "Error", 8, "Times", Red);
  ObjectSetText( "DeLv", "Error", 8, "Times", Red);  
 }
 else
 {
  if(NoRunLong) statusColorL=Red;
  else statusColorL=Green;
 
  if(NoRunShort) statusColorS=Red;
  else statusColorS=Green;
 
  statusSuH=DoubleToStr(SHigh,Digits);
  statusSuL=DoubleToStr(SLow,Digits);  
  statusDeH=DoubleToStr(DHigh,Digits);
  statusDeL=DoubleToStr(DLow,Digits);   
  
  ObjectSetText( "BiasL", "L", 8, "Times", statusColorL );
  ObjectSetText( "BiasS", "S", 8, "Times", statusColorS ); 
  ObjectSetText( "SuHv", statusSuH, 8, "Times", Display_Color );
  ObjectSetText( "SuLv", statusSuL, 8, "Times", Display_Color);
  ObjectSetText( "DeHv", statusDeH, 8, "Times", Display_Color );
  ObjectSetText( "DeLv", statusDeL, 8, "Times", Display_Color); 
 }   
 return(0);
}
//+------------------------------------------------------------------+
void DeleteObjects()
{
 ObjectDelete("Bias");
 ObjectDelete("BiasL");
 ObjectDelete("BiasS"); 
 ObjectDelete("SuH");
 ObjectDelete("SuL");
 ObjectDelete("DeH");
 ObjectDelete("DeL");
 ObjectDelete("SuHv");
 ObjectDelete("SuLv");
 ObjectDelete("DeHv");
 ObjectDelete("DeLv");     
}
//+------------------------------------------------------------------+
double DetermineLots(double value1, double value2, int number, double factor)  // function to determine lot sizes based on available free margin
{
 double permitLoss=factor*AccountFreeMargin();
 double pipSL=(value1-value2)/Point;
 double valueSL=pipSL*MarketInfo(Symbol(),MODE_TICKVALUE);
 
 double lots=permitLoss/valueSL;
 lots=lots/number;
 
 if(lots<lotsmin) return(lotsmin);
 else if(lots>lotsmax) return(lotsmax);
 
 return(lots);
}


