//+----------------------------------------------------------------------+
//|                                             Margin Balance Graph.mq4 |
//|                                                         David J. Lin |
//|Graphs the max/min/average of account margin in separate window       |
//| coded for Paul Z <spider8@netspace.net.au>                           |
//| Added Balance functionality for myself (December 3, 2007)            |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, October 6, 2007                                         |
//+----------------------------------------------------------------------+
#property copyright "2007 David J. Lin"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Lime
#property indicator_color3 Red
//#property indicator_minimum 0

//---- input parameters
extern int Margin_Option=3;   // 0 = Margin used, 1 = Free Margin, 2 = Margin Level (percentage), 3 = Balance
extern bool AllPairs=false;    // true = all currency pairs, false = chart currency pair
extern double Deposit=50000;  // the initial deposit
//---- buffers
double max[],ave[],min[];
int lasttime;
double mmax,mave,mmin,margin;
bool first=true;
int    oob[];      // index of opening bar
int    oty[];      // order type
double olo[];      // lot
string osy[];      // symbol
double oop[];      // opening price
int    ocb[];      // index of closing bar 
double ocp[];      // closing price
double osw[];      // swap
double opr[];      // profit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
// Print(MarketInfo("EURUSD",MODE_MARGINREQUIRED));
 IndicatorDigits(2);
 IndicatorBuffers(3);

 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,max);

 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,ave);

 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,min);
 
 SetIndexLabel(0, "Maximum Margin");
 SetIndexLabel(1, "Average Margin");
 SetIndexLabel(2, "Minimum Margin");

 IndicatorShortName("Margin Balance Graph");

 if(Margin_Option<0) Margin_Option=0;
 if(Margin_Option>3) Margin_Option=0;

 mmax=0;
 mmin=999999;

 lasttime=iTime(NULL,0,0);
 first=true; 
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
//----

//----
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start()
{
 if(first) Initialize();
 
 
 if(!AllPairs) return(-1);
 
 for(int i=0;i<=0;i++)
 {
  switch(Margin_Option)
  {
   case 0:  margin=AccountMargin();                      break;
   case 1:  margin=AccountFreeMargin();                  break;
   case 2:  if(AccountMargin()>0) margin=100.*AccountEquity()/AccountMargin(); break;
   case 3:  margin=AccountBalance();                     break;
   default: margin=AccountMargin();                      break;
  }
 
  if(margin>mmax) mmax=margin;
  if(margin<mmin) mmin=margin;
 
  max[i]=Norm(mmax);
  min[i]=Norm(mmin);
  ave[i]=Norm(0.50*(mmax+mmin));
 
  if(lasttime==iTime(NULL,0,i)) return(0);
  lasttime=iTime(NULL,0,i);
 
  max[i+1]=Norm(mmax);
  min[i+1]=Norm(mmin);
  ave[i+1]=Norm(0.50*(mmax+mmin));
 
  mmax=0; mmin=999999;
 }
 return(0);
}
//+------------------------------------------------------------------+ 
double Norm(double value)
{
 return(NormalizeDouble(value,2));
}
//+-----------------------------------------------------------------
void Initialize()
{
 ArrayInitialize(max,EMPTY_VALUE);
 ArrayInitialize(min,EMPTY_VALUE);
 ArrayInitialize(ave,EMPTY_VALUE); 
 first=false;
 
  double b, e, p, t, m, eq;
  int    i, j, k;
// - ---
  ReadDeals();
  if (oob[0] < 0) 
    return;
  k = ArraySize(oob);
  
// - ---

  for (i = oob[0]; i >= 1; i--)
  {
    b = Deposit; 
    e = 0;
    m = 0;
    for (j = 0; j < k; j++)
    {
      if (i <= oob[j] && i >= ocb[j])
      {
        m+=olo[j]*MarketInfo(osy[j],MODE_MARGINREQUIRED); // margin
        p = MarketInfo(osy[j], MODE_POINT);
        t = MarketInfo(osy[j], MODE_TICKVALUE);
        if (t == 0) 
          t = 10;
        if (p == 0)
        { 
          if (StringFind(osy[j], "JPY") <0) 
            p = 0.0001; 
          else 
            p = 0.01;
        }
        if (oty[j] == OP_BUY) 
          e += osw[j] + (iClose(osy[j], 0, i) - oop[j]) / p*olo[j]*t;
        else 
          e += osw[j] + (oop[j] - iClose(osy[j], 0, i)) / p*olo[j]*t;
      } 
      else if (i <= ocb[j])
      { 
        b += osw[j] + opr[j];
      }
    }
    // b+e is equity
    eq=b+e;
    switch(Margin_Option)
    {
     case 0:          ave[i]=Norm(m);         break;
     case 1:          ave[i]=Norm(eq-m);      break;
     case 2:  if(m>0) ave[i]=Norm(100.*eq/m); break;
     case 3:          ave[i]=Norm(b);         break;
     default:         ave[i]=Norm(m);         break;
    }
  }
 
 return;
}
// +------------------------------------------------------------------+
// |  Reading of transactions                                         |
// +------------------------------------------------------------------+
void ReadDeals()
{
  ArrayResize(oob, 0);
  ArrayResize(oty, 0);
  ArrayResize(olo, 0);
  ArrayResize(osy, 0);
  ArrayResize(oop, 0);
  ArrayResize(ocb, 0);
  ArrayResize(ocp, 0);
  ArrayResize(osw, 0);
  ArrayResize(opr, 0);
  int h = OrdersHistoryTotal(), i, k;
// - ---
  for (i = 0; i < h; i++)  // read closed orders
  {
    if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
    {

     if(!AllPairs)
     {
      if(OrderSymbol()!=Symbol()) continue;
     }

      {
        if (OrderType() == OP_BUY || OrderType() == OP_SELL)
        {
          k = ArraySize(oob);
          ArrayResize(oob, k + 1);
          ArrayResize(oty, k + 1);
          ArrayResize(olo, k + 1);
          ArrayResize(osy, k + 1);
          ArrayResize(oop, k + 1);
          ArrayResize(ocb, k + 1);
          ArrayResize(ocp, k + 1);
          ArrayResize(osw, k + 1);
          ArrayResize(opr, k + 1);
          oob[k] = iBarShift(NULL, 0, OrderOpenTime()); // index of opening bar
          oty[k] = OrderType();       // type
          olo[k] = OrderLots();       // lot
          osy[k] = OrderSymbol();     // symbol
          oop[k] = OrderOpenPrice();  // opening price
          ocb[k] = iBarShift(NULL, 0, OrderCloseTime()); // index of closing bar
          ocp[k] = OrderClosePrice(); // closing price 
          osw[k] = OrderSwap();       // swap
          opr[k] = OrderProfit();     // profit
        }
      }
    }
  }
  h = OrdersTotal();
// - ---
  for (i = 0; i < h; i++)  // read active orders
  {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
     if(!AllPairs)
     {
      if(OrderSymbol()!=Symbol()) continue;
     }
         
      {
        if (OrderType() == OP_BUY || OrderType() == OP_SELL)
        {
          k = ArraySize(oob);
          ArrayResize(oob, k + 1);
          ArrayResize(oty, k + 1);
          ArrayResize(olo, k + 1);
          ArrayResize(osy, k + 1);
          ArrayResize(oop, k + 1);
          ArrayResize(ocb, k + 1);
          ArrayResize(ocp, k + 1);
          ArrayResize(osw, k + 1);
          ArrayResize(opr, k + 1);
          oob[k] = iBarShift(NULL, 0, OrderOpenTime ()); // index of opening bar
          oty[k] = OrderType();      // type
          olo[k] = OrderLots();      // lot
          osy[k] = OrderSymbol();    // symbol
          oop[k] = OrderOpenPrice(); // opening price
          ocb[k] = 0;                // index of closing bar (no closing bar yet)
          ocp[k] = 0;                // closing price (no closing price yet)
          osw[k] = OrderSwap();      // swap
          opr[k] = OrderProfit();    // profit
        }
      }
    }
  }
}
// +------------------------------------------------------------------+