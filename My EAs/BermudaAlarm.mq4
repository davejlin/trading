
// BermudaAlarm.mq4 

// This alarm EA emits an audible signal when the current bid price exceeds +/- N pips 
// from the previous bar's close price.

// coded by David J. Lin (d-lin@northwestern.edu), Evanston, IL, September 4, 2006 

#property copyright "David J. Lin, 2006"

extern int Account=0;
extern double N = 7;

bool runnable=true;
bool init=true;


int init()
{
 return(0);
}

int deinit()
{
 return(0);
}

//===========================================================================================
//===========================================================================================

int start()
{
//Runnable
 if(runnable!=true)
  return(-1);
  
//Init
 if(init==true)
 {
  init=false;

  if(IsTesting()==false&&Account!=AccountNumber())
  {
   runnable=false;
   Alert("*** WARNING: Please check Account Number! ***");
   return(-1);
  }
 }//Init  
  double prevclose = iClose(NULL,0,1);
  double diff = MathAbs((Bid-prevclose)/Point);

  Comment("Prev Close: ",prevclose," Current Bid: ",Bid," Pip Diff: ",diff);

  if (diff >= N) 
  { Alert("BERMUDA ALERT!! for ",Symbol()," at ",TimeToStr(CurTime())," Pip Diff: ",diff);
    PlaySound("trumpets.wav");
  }
}

//===========================================================================================
//===========================================================================================

