//+------------------------------------------------------------------+
//+                                     NStraddleNews.mq4 (pseudonym)|
//|                                          NewsPeakTrader.mq4 V1.1 |
//|                                               Paul Hampton-Smith |
//+------------------------------------------------------------------+

#include <stdlib.mqh>
#include <utils.mqh>

extern double dblLots = 0.1;
extern datetime EventTimeUTC; // Event time in UTC. Ensure that global variable UTCtoServerTimeInMinutes is set
extern int nStraddleSecondsBeforeEvent = 30;
extern int nStraddleDurationSeconds = 60; // nStraddleDurationSeconds-nStraddleSecondsBeforeEvent is the lenth of time straddle will be in place after event
extern int nTrailingStop = 2; // client side trailing stop
extern int nInitialStop = 20; // used to set OrderStopLoss();
extern int nDormantSecondsBeforeEvent = 5; // length of time that straddle values are fixed before event
extern int nSlippage = 0; // set at relatively large value because news events create such rapid price movements
extern int nRetries = 10; // number of times entry stop will be loosened by 1 point in an effort to get it accepted
extern int nRetryDelay = 500; // mSec between initial pending order attempts
extern int nSystemID = 999; // magic number

bool bTradeCancelled = false;

int init() // called on load of EA
{
   datetime EventTimeServer = ServerTime(EventTimeUTC);   
   datetime StraddleTimeServer = EventTimeServer-nStraddleSecondsBeforeEvent;   
   datetime EventTimeLocal = LocalTime()-CurTime()+EventTimeServer;
   int nTicket, nLastError, nRetry;
   double dblEntryStop, dblInitialStop, dblProfitTarget;
   
   if (CurTime() > StraddleTimeServer+nStraddleDurationSeconds || OpenOrders(nSystemID) > 0) return(0);
   
   while (CurTime() < StraddleTimeServer)
   {
//      Comment("Waiting to issue straddle orders in ", TimeToStr(StraddleTimeServer-CurTime(), TIME_SECONDS), ", ", nStraddleSecondsBeforeEvent, " seconds before server time ", TimeToStr(EventTimeServer, TIME_DATE|TIME_MINUTES),", local time ", TimeToStr(EventTimeLocal, TIME_DATE|TIME_MINUTES));
      Sleep(500);
   }
   
   // check that a major price move hasn't occurred in last 5 minutes, eg if news leaked out early
   if ( MathAbs(iClose(Symbol(),PERIOD_M1,0) - iClose(Symbol(),PERIOD_M1,5)) > 20*Point )
   {
      bTradeCancelled = true;
//      Comment("News trade scheduled for ",TimeToStr(EventTimeUTC)," UTC has been cancelled because a large price move occurred beforehand");
      Print("News trade scheduled for ",TimeToStr(EventTimeUTC)," UTC has been cancelled because a large price move occurred beforehand");
      return(0);
   }
   
//   Comment("Issuing BUYSTOP straddle order");
   nLastError = 999;
   nTicket = 0;
   nRetry = 0;
   while ( (nLastError != 0 || nTicket == 0) && nRetry < nRetries)
   {
      RefreshRates(); // do this because the last tick might have been some time ago
      // dblEntryStop is initially set at what is supposed to be the closest allowable stop distance
      // if this value doesn't work, then progressively increase dblEntryStop until it is accepted
      dblEntryStop = ClosestBuySellStopPrice(OP_BUYSTOP) + nRetry*Point;
      dblInitialStop = dblEntryStop - nInitialStop*Point - (Ask-Bid);
      dblProfitTarget = 0;
      nTicket = OrderSend(Symbol(),OP_BUYSTOP,dblLots,dblEntryStop,nSlippage,dblInitialStop,dblProfitTarget,"NewsPeakTrader",nSystemID,0,Green);
      nLastError = GetLastError();

      Print(ErrorDescription(nLastError)," for buystop at ",dblEntryStop," InitialStop ",dblInitialStop," Bid ",Bid," Ask ",Ask," Close[0] ",Close[0]);

      if (nLastError!=0 || nTicket == 0) Sleep(nRetryDelay);
      nRetry++;
   }

//   Comment("Issuing SELLSTOP straddle order");
   nLastError = 999;
   nTicket = 0;
   nRetry = 0;
   while ( (nLastError != 0 || nTicket == 0) && nRetry < nRetries)
   {
      RefreshRates(); // do this because the last tick might have been some time ago
      // dblEntryStop is initially set at what is supposed to be the closest allowable stop distance
      // if this value doesn't work, then progressively decrease dblEntryStop until it is accepted
      dblEntryStop = ClosestBuySellStopPrice(OP_SELLSTOP) - nRetry*Point;
      dblInitialStop = dblEntryStop + nInitialStop*Point + (Ask-Bid);
      dblProfitTarget = 0;
      nTicket = OrderSend(Symbol(),OP_SELLSTOP,dblLots,dblEntryStop,nSlippage,dblInitialStop,dblProfitTarget,"NewsPeakTrader",nSystemID,0,Red);
      nLastError = GetLastError();

      Print(ErrorDescription(nLastError)," for sellstop at ",dblEntryStop," InitialStop ",dblEntryStop+nInitialStop*Point+(Ask-Bid)," Bid ",Bid," Ask ",Ask," Close[0] ",Close[0]);

      if (nLastError!=0 || nTicket == 0) Sleep(nRetryDelay);
      nRetry++;
   }

//   Comment(StraddleTimeServer+nStraddleDurationSeconds-CurTime()," seconds before deleting straddle");
   return(0);
}

int deinit()
{
//   Comment("Closing or deleting all orders");
   RefreshRates();
   CloseOrdersAtTime(0,nSystemID);
   DeleteStopOrders(nSystemID);
}

int start() // called for every tick
{
   if (bTradeCancelled) return(0); // Init() sets bTradeCancelled if a large price move occurred prematurely
   
   int nState, nTicket, nPosition, nLastError, nRetry;
   double dblEntryStop, dblInitialStop, dblProfitTarget;
   bool bResult;

   datetime EventTimeServer = ServerTime(EventTimeUTC);   
   datetime StraddleTimeServer = EventTimeServer-nStraddleSecondsBeforeEvent;   
   
/////////////////////////////////////////////
// Management of open positions
////////////////////////////////////////////   

   // TrailingStop is adjusted at client end. OrderStopLoss() remains at nInitialStop on server side
   CloseAfterPeak(nTrailingStop,nSlippage,nSystemID,EventTimeServer);

   // order triggered? Get rid of opposite stop order
   if (OpenOrders(nSystemID) > 0) DeleteStopOrders(nSystemID);

   // Delete straddle if not hit within short time of nStraddleDurationSeconds
   DeleteStopOrdersAtTime(StraddleTimeServer+nStraddleDurationSeconds, nSystemID);

   // Straddle is created at time StraddleTimeServer in Init(). If ticks arrive after straddle creation, 
   // try to keep it away from price activity until a short time before EventTime 
   if (CurTime() > StraddleTimeServer && CurTime() < EventTimeServer - nDormantSecondsBeforeEvent)
   {
//      Comment("Modifying BUYSTOP straddle order");
      bResult = false;
      nTicket = FindOrder(OP_BUYSTOP,nSystemID);
      nRetry = 0;
      dblEntryStop = ClosestBuySellStopPrice(OP_BUYSTOP);
      // dblEntryStop is initially set at what is supposed to be the closest allowable stop distance
      // if this value doesn't work, then progressively increase dblEntryStop until it is accepted
      while ( !bResult && nTicket != 0 && nRetry < nRetries)
      {
         dblInitialStop = dblEntryStop - nInitialStop*Point - (Ask-Bid);
         dblProfitTarget = 0;
         bResult = OrderModify(nTicket,dblEntryStop,dblInitialStop,dblProfitTarget,0,Green);
         nLastError = GetLastError();
         Print(ErrorDescription(nLastError)," for OrderModify buystop at ",dblEntryStop," InitialStop ",dblInitialStop," Bid ",Bid," Ask ",Ask," Close[0] ",Close[0]);
    
         nRetry++;
         dblEntryStop+=Point;
      }
   
//      Comment("Modifying SELLSTOP straddle order");
      bResult = false;
      nTicket = FindOrder(OP_SELLSTOP,nSystemID);
      nRetry = 0;
      dblEntryStop = ClosestBuySellStopPrice(OP_SELLSTOP);
      // dblEntryStop is initially set at what is supposed to be the closest allowable stop distance
      // if this value doesn't work, then progressively decrease dblEntryStop until it is accepted
      while (  !bResult && nTicket != 0 && nRetry < nRetries)
      {
         dblInitialStop = dblEntryStop + nInitialStop*Point + (Ask-Bid);
         dblProfitTarget = 0;
         bResult = OrderModify(nTicket,dblEntryStop,dblInitialStop,dblProfitTarget,0,Red);
         nLastError = GetLastError();
         Print(ErrorDescription(nLastError)," for OrderModify sellstop at ",dblEntryStop," InitialStop ",dblInitialStop," Bid ",Bid," Ask ",Ask," Close[0] ",Close[0]);
    
         nRetry++;
         dblEntryStop-=Point;
      }
   }

   // Provide info 
      
   if (CurTime() > StraddleTimeServer + nStraddleDurationSeconds && OpenOrders(nSystemID) == 0)
   {
//      Comment("After event at ", TimeToStr(EventTimeServer), " server time. No further action");
      return(0);
   }

   if (CurTime() > StraddleTimeServer)
   {
      if (OpenStopOrders(nSystemID) > 0)
      {
//         Comment(StraddleTimeServer+nStraddleDurationSeconds-CurTime()," seconds before deleting straddle");
      }
      else if (OpenOrders(nSystemID) > 0)
      {
//         Comment("Waiting to close order when price drops back by ",nTrailingStop," points");
      }
   }

   return(0);  
}

