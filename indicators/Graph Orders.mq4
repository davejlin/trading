//+----------------------------------------------------------------------+
//|                                                     Graph Orders.mq4 |
//|                                                         David J. Lin |
//|Graph open and closed orders between two dates w/ comment lines in    |
//|data window (mouse over the appropriate arrow to see the comment name.|
//|Also, multiple simultaneous orders occupy the same point.  You may    |
//|click-and-drag the arrow icon to reveal others under the top one.     | 
//|                                                                      |
//|NOTE: The orders must be listed in the Account History section of the |
//|      MT4 platform in order for them to be graphed by this indicator. |
//|      Use "Custom Period" and select "All history" if necessary.      |
//|                                                                      |
//|      The indicator will not automatically update:                    |
//|      You must re-apply for the most up-to-date graph.                |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|(dave.j.lin@sbcglobal.net)                                            |
//|Evanston, IL, March 12, 2007                                          |
//+----------------------------------------------------------------------+

#property copyright "David J. Lin"
#property link      ""

#property indicator_chart_window

extern datetime Begin=D'2007.01.01'; // date to begin graphing orders
extern datetime End=D'2007.12.31';   // date to end graphing orders
extern int magic=0; // magic number of desired order (0 to plot all orders)
//===========================================================================================
//===========================================================================================
int init() 
{
 // First check closed trades
 int trade;                         
 int trades=OrdersHistoryTotal();           
 for(trade=trades-1;trade>=0;trade--)
 {                                        
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);
  if(OrderSymbol()!=Symbol()) continue;
  if(magic!=0&&magic!=OrderMagicNumber())continue;  
  if(OrderOpenTime()>End) continue;
  if(OrderOpenTime()<Begin) break;
  Draw(1);
 }  

 // Next check open trades                       
 trades=OrdersTotal();           
 for(trade=trades-1;trade>=0;trade--)                                       
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol())continue;
  if(magic!=0&&magic!=OrderMagicNumber())continue;
  if(OrderOpenTime()>End) continue;
  if(OrderOpenTime()<Begin) break;
  Draw(2);
 }   
 return(0);
}
//===========================================================================================
//===========================================================================================
int deinit()
{
 ObjectsDeleteAll();
 return(0);
}
//===========================================================================================
//===========================================================================================
int start() 
{
 return(0);
}

//===========================================================================================
//===========================================================================================
void Draw(int flag)
{ 
 string text1,text2,text3;color clr;

 datetime opentime=OrderOpenTime();
 datetime closetime=OrderCloseTime(); 
 string time1=TimeToStr(opentime,TIME_DATE|TIME_MINUTES);
 string time2=TimeToStr(closetime,TIME_DATE|TIME_MINUTES); 
 double openprice=OrderOpenPrice();
 double closeprice=OrderClosePrice();
 string ordercomment=OrderComment();
 double orderlots=OrderLots();
 
 if(OrderType()==OP_BUY) 
 {
  text1=StringConcatenate(ordercomment,": Buy Open ",orderlots," ",time1);
  text3=StringConcatenate(ordercomment,": Buy Close ",orderlots," ",time2);  
  clr=Blue;
 }
 else if(OrderType()==OP_SELL)
 {
  text1=StringConcatenate(ordercomment,": Sell Open ",orderlots," ",time1);
  text3=StringConcatenate(ordercomment,": Sell Close ",orderlots," ",time2);  
  clr=Red;
 }
 else return;
  
 ObjectCreate(text1,OBJ_ARROW,0,opentime,openprice);
 ObjectSet(text1,OBJPROP_ARROWCODE,1);
 ObjectSet(text1,OBJPROP_COLOR,clr); 

 if(flag!=1) return;
 
 text2=StringConcatenate(ordercomment,": ",openprice,"-->",closeprice);
 ObjectCreate(text2,OBJ_TREND,0,opentime,openprice,closetime,closeprice);
 ObjectSet(text2,OBJPROP_STYLE,STYLE_DOT);
 ObjectSet(text2,OBJPROP_COLOR,clr);  
 ObjectSet(text2,OBJPROP_RAY,false);

 if(OrderStopLoss()!=OrderClosePrice()) clr=LimeGreen;

 ObjectCreate(text3,OBJ_ARROW,0,closetime,closeprice);
 ObjectSet(text3,OBJPROP_ARROWCODE,3);
 ObjectSet(text3,OBJPROP_COLOR,clr); 
 
 return;
}