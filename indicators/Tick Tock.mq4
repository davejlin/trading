//+------------------------------------------------------------------+
//|                                                    Tick Tock.mq4 |
//|                                                     David J. Lin |
//|Coded by David J. Lin                                             |
//|dave.j.lin@sbcglobal.net                                          |
//|Evanston, IL, July 22, 2007                                       |
//+------------------------------------------------------------------+
#property copyright "2007 David J. Lin"
#property link      ""
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Red

extern int NTicks=1; 

double open[],close[],high[],low[];
int cnt,Nbars,index=0,tf=0; bool noRun=false;
color colorUp=Green,colorDn=Red;
//+------------------------------------------------------------------+
int init()
{  
 string name="Tick Tock("+NTicks+")";
 IndicatorShortName(name);

 SetIndexBuffer(0,open);
 SetIndexBuffer(1,close); 
 SetIndexBuffer(2,high);
 SetIndexBuffer(3,low);

 SetIndexLabel(0,"open");
 SetIndexLabel(1,"close"); 
 SetIndexLabel(2,"high");
 SetIndexLabel(3,"low");
 
 if(NTicks==1)
 { 
  SetIndexStyle(0,DRAW_LINE);
  SetIndexStyle(1,DRAW_LINE); 
  SetIndexStyle(2,DRAW_LINE); 
  SetIndexStyle(3,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(0,DRAW_NONE);
  SetIndexStyle(1,DRAW_NONE);
  SetIndexStyle(2,DRAW_NONE);
  SetIndexStyle(3,DRAW_NONE);
 }   
 cnt=0;Nbars=1;
 close[index]=iClose(NULL,tf,index);
 Draw();
 if (NTicks<1) noRun=true;
 return(0);
}
//+------------------------------------------------------------------+
int deinit()
{   
 Refresh();
 Comment("");
 return(0);
}
//+------------------------------------------------------------------+
int start()
{
 if(noRun) return(index);

 int i,j;
 if(close[index]==EMPTY_VALUE)
 {
  for(i=1;i<=Nbars+1;i++)
  {
   j=i-1;
   close[j]=close[i];
   open[j]=open[i];
   high[j]=high[i];
   low[j]=low[i];
  }
  Refresh();
  Draw();   
 }
 
 if(cnt==index)
 {   
  close[index]=iClose(NULL,tf,index);
  open[index]=close[index];
  high[index]=close[index];
  low[index]=close[index];
 }

 cnt++;

 close[index]=iClose(NULL,tf,index);
 if (iClose(NULL,tf,index)<low[index]) 
  low[index]=close[index];
 if (iClose(NULL,tf,index)>high[index]) 
  high[index]=close[index];

 DrawLast();
    
 if(cnt==NTicks)
 {
  Nbars++;
  for(i=Nbars+1;i>=0;i--)
  {   
   close[i+1]=close[i];
   open[i+1]=open[i];
   high[i+1]=high[i];
   low[i+1]=low[i];
  }
  cnt=0;
  Refresh();
  Draw();    
 }
    
 Comment("Tick count: "+cnt);
         
 return(0);
}
//+------------------------------------------------------------------+
void Draw()
{
 int i,window=0;

 for (i=0;i<=Nbars+1;i++)
 {  
  if (close[i]==EMPTY_VALUE) return;
  
  ObjectCreate("wick"+i,OBJ_TREND,window,iTime(NULL,tf,i),high[i],iTime(NULL,tf,i),low[i]);  
  ObjectCreate("body"+i,OBJ_TREND,window,iTime(NULL,tf,i),open[i],iTime(NULL,tf,i),close[i]);

  ObjectSet("wick"+i,OBJPROP_WIDTH,1);
  ObjectSet("body"+i,OBJPROP_WIDTH,3);
  ObjectSet("wick"+i,OBJPROP_RAY,FALSE);
  ObjectSet("body"+i,OBJPROP_RAY,FALSE);

  if (open[i]<close[i])
  {  
   ObjectSet("wick"+i,OBJPROP_COLOR,colorUp);  
   ObjectSet("body"+i,OBJPROP_COLOR,colorUp);
  }
  else
  {  
   ObjectSet("wick"+i,OBJPROP_COLOR,colorDn); 
   ObjectSet("body"+i,OBJPROP_COLOR,colorDn);
  }
 }
 return;
}
//+------------------------------------------------------------------+
void DrawLast()
{   
 ObjectSet("wick0",OBJPROP_PRICE1,high[index]);
 ObjectSet("wick0",OBJPROP_PRICE2,low[index]);
 ObjectSet("body0",OBJPROP_PRICE1,open[index]);
 ObjectSet("body0",OBJPROP_PRICE2,close[index]);
 
 if (open[index]>close[index])
 {  
  ObjectSet("wick0",OBJPROP_COLOR,colorDn); 
  ObjectSet("body0",OBJPROP_COLOR,colorDn);
 }
 else
 {  
  ObjectSet("wick0",OBJPROP_COLOR,colorUp); 
  ObjectSet("body0",OBJPROP_COLOR,colorUp);
 }
 return;
}
//+------------------------------------------------------------------+
void Refresh()
{  
 int i;
 for (i=0;i<=Nbars+1;i++)
 {  
  ObjectDelete("wick"+i); 
  ObjectDelete("body"+i);
 }
 return;
}
//+------------------------------------------------------------------+