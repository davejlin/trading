//+----------------------------------------------------------------------+
//|                                             Supply Demand Trader.mq4 |
//|                                                         David J. Lin |
//|Based on a Supply & Demand trading strategy                           |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |                                         |
//|Evanston, IL, June 3, 2007                                            |
//+----------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      ""

// User adjustable parameters:

// Internal usage parameters:
int BufferPips=3;
double Lots=0.01;
int Slippage=3;

string DLOW,DHIGH,SLOW,SHIGH,BIAS;
double DLow,DHigh,SLow,SHigh;
bool Long,Short;
int MagicLong=1,MagicShort=2;
int StopLevel=5;
double bufferPips;
bool NoRunLong,NoRunShort,Stop;
int bias;

int  Display_Corner=0;        // 0=top left, 1=top right, 2=bottom left, 3=bottom right
color Display_Color=Black;    // color for Display Status labels
int xpos=5;                      // pixels from left to show Display Status
int ypos=23;                      // pixels from top to show Display Status 
string statusSuH,statusSuL,statusDeH,statusDeL;
color statusColor=Blue;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
 Stop=false;
 NoRunLong=false;
 NoRunShort=false;
//----
 if(!GlobalVariableCheck("SEMAPHORE")) GlobalVariableSet("SEMAPHORE",0);

 BIAS =StringConcatenate(Symbol(),"Bias"); 
 DLOW =StringConcatenate(Symbol(),"DemandLow"); 
 DHIGH=StringConcatenate(Symbol(),"DemandHigh");
 SLOW =StringConcatenate(Symbol(),"SupplyLow");
 SHIGH=StringConcatenate(Symbol(),"SupplyHigh");
 if(!GlobalVariableCheck(BIAS)) GlobalVariableSet(BIAS,0); 
 if(!GlobalVariableCheck(DLOW)) GlobalVariableSet(DLOW,0);
 if(!GlobalVariableCheck(DHIGH)) GlobalVariableSet(DHIGH,0);
 if(!GlobalVariableCheck(SLOW)) GlobalVariableSet(SLOW,0);
 if(!GlobalVariableCheck(SHIGH)) GlobalVariableSet(SHIGH,0);
 
 reinit(); 
 
 bufferPips=NormPoints(BufferPips);
 
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
 if(Stop) return;
//----   
// DetermineLots();
 ManageOrders(); 
 if(Long)  MainLong();   
 if(Short) MainShort();
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+
void reinit()
{
 DLow=NormDigits(GlobalVariableGet(DLOW));  
 DHigh=NormDigits(GlobalVariableGet(DHIGH)); 
 SLow=NormDigits(GlobalVariableGet(SLOW));  
 SHigh=NormDigits(GlobalVariableGet(SHIGH)); 

 ErrorCheck(DLow,DHigh,"Bad De Diff"); 
 ErrorCheck(SLow,SHigh,"Bad Su Diff"); 
 ErrorCheck(DHigh,SLow,"Bad SuDe Diff");

 statusSuH=DoubleToStr(SHigh,Digits);
 statusSuL=DoubleToStr(SLow,Digits);
 statusDeH=DoubleToStr(DHigh,Digits);
 statusDeL=DoubleToStr(DLow,Digits);   
 
 bias=GlobalVariableGet(BIAS);  
 
 switch(bias)
 {
  case 0: // no trade
   Long=false;
   Short=false;
   NoRunLong=true;
   NoRunShort=true;   
  break;
  case 1: // long
   Long=true;
   Short=false;
   NoRunLong=false;
   NoRunShort=true;   
  break;
  case 2: // short
   Long=false;
   Short=true;
   NoRunLong=true;
   NoRunShort=false;   
  break;
  case 3: // long & short
   Long=true;
   Short=true;
   NoRunLong=false;
   NoRunShort=false;   
  break;  
  default: // default = no trade
   Long=false;
   Short=false;
   NoRunLong=true;
   NoRunShort=true;   
  break;  
 }
 
 return;
}
//+------------------------------------------------------------------+
void ErrorCheck(double var1, double var2, string message)
{
 if(var1>=var2) 
 {
  Alert(Symbol()," ",message);
  NoRunLong=true;
  NoRunShort=true;
  Stop=true;
 }
 return;
}
//+------------------------------------------------------------------+
void MainLong()
{
 if(NoRunLong) return;
 double triggerPrice=NormDigits(DHigh-bufferPips);

 if(Bid<triggerPrice&&Bid>DLow)
 {
  double spread=Ask-Bid;
  double entryPrice=NormDigits(DHigh+bufferPips+spread); 
  double SL=NormDigits(DLow-bufferPips);
  double TP=NormDigits(SLow-bufferPips);
  SendPending(Symbol(),OP_BUYSTOP,NormLots(Lots),entryPrice,Slippage,SL,TP,"SuDe",1,0,Blue); 
  NoRunLong=true;
 }
 return; 
}
//+------------------------------------------------------------------+
void MainShort()
{
 if(NoRunShort) return;
 double triggerPrice=NormDigits(SLow+bufferPips);

 if(Bid>triggerPrice&&Bid<SHigh)
 {
  double spread=Ask-Bid; 
  double entryPrice=NormDigits(SLow-bufferPips); 
  double SL=NormDigits(SHigh+spread+bufferPips);
  double TP=NormDigits(DHigh+spread+bufferPips);
  SendPending(Symbol(),OP_SELLSTOP,NormLots(Lots),entryPrice,Slippage,SL,TP,"SuDe",2,0,Red); 
  NoRunShort=true;
 }
 return; 
}
//+------------------------------------------------------------------+ 

void ManageOrders()
{
 
 int trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;

  if(OrderMagicNumber()==MagicLong)
  {
   NoRunLong=true;
   
   if(OrderType()==OP_BUYSTOP) ManagePendingLong();
  }
   
  if(OrderMagicNumber()==MagicShort)
  {  
   NoRunShort=true;
   
   if(OrderType()==OP_SELLSTOP) ManagePendingShort();
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
void ManagePendingLong()
{
 if(Bid<DLow) ExitOrder(true,false,2);
 return;
}
//+------------------------------------------------------------------+
void ManagePendingShort()
{
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
 if(IsTesting()) return(MathMax(0.1,NormalizeDouble(lots,1)));
 else return(MathMax(0.01,NormalizeDouble(lots,2)));
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

