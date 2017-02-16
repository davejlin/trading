//+------------------------------------------------------------------+
//|                                                        FRAMA.mq4 |
//| Trail Line                                                       |
//| written for Jason (soeasy69@rogers.com)                          |
//|                                                                  |
//| Coded by David J. Lin (dave.j.lin@sbcglobal.net)                 |
//| Evanston, IL, July 25, 2007                                      |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007 David J. Lin"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red

//---- input parameters
extern int  N=16;    // should be an even integer

color LineColor=Red;

//---- buffers
double FRAMABuffer[];
int Nhalf,tf=0;
double Coeff1=4.6, Coeff2=1.0;
int init()
{
 SetIndexBuffer(0,FRAMABuffer);
 SetIndexStyle(0,DRAW_LINE,0,2,LineColor);
 SetIndexEmptyValue(0,0.0); 
 Nhalf=0.5*N;
 return(0);
}

int deinit()
{
 return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
 double alpha,N1,N2,N3,D,H1,L1,H2,L2,H3,L3;
 int index,shift;
 
 int counted_bars=IndicatorCounted();
 if (counted_bars==0) index=iBars(NULL,tf)-N;
 else if (counted_bars>0) index=iBars(NULL,tf)-counted_bars;
      
 for (int i=index;i>=0;i--)
 {
  shift=iHighest(NULL,tf,MODE_HIGH,Nhalf,i);
  H1=iHigh(NULL,tf,shift);
  shift=iLowest(NULL,tf,MODE_LOW,Nhalf,i);
  L1=iLow(NULL,tf,shift);
  shift=iHighest(NULL,tf,MODE_HIGH,Nhalf,i+Nhalf);
  H2=iHigh(NULL,tf,shift);
  shift=iLowest(NULL,tf,MODE_LOW,Nhalf,i+Nhalf);
  L2=iLow(NULL,tf,shift);
  shift=iHighest(NULL,tf,MODE_HIGH,N,i);
  H3=iHigh(NULL,tf,shift);
  shift=iLowest(NULL,tf,MODE_LOW,N,i);
  L3=iLow(NULL,tf,shift);

  N1=(H1-L1)/Nhalf;
  N2=(H2-L2)/Nhalf;
  N3=(H3-L3)/N;
  
  if(N1>0&&N2>0&&N3>0) D=(MathLog(N1+N2)-MathLog(N3))/MathLog(2.0);

  alpha=MathExp(-Coeff1*(D-Coeff2));

  if(alpha<-0.01) alpha=0.01;
  if(alpha>1.0) alpha=1.0;
  
  FRAMABuffer[i]=alpha*(0.5*(iHigh(NULL,tf,i)+iLow(NULL,tf,i)))+(1.0-alpha)*FRAMABuffer[i+1];
 }

 return(0);
}
//+------------------------------------------------------------------+