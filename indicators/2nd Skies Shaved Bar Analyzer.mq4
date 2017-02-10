//+------------------------------------------------------------------+
//|                               2nd Skies Shaved Bar Analyzer.mq4  |
//| 2nd Skies Shaved Bar Analyzer                                    |
//| written for Chris Capre, 2ndSkies.com (Info@2ndSkies.com)        |
//|                                                                  |
//| Coded by David J. Lin (dave.j.lin@sbcglobal.net)                 |
//| Evanston, IL, December 12, 2009                                   |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009 Chris Capre, David J. Lin"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

extern double Percentage=5; // percentage of total range close within high/low to qualify as shaved bar 

//---- buffers
double perc;
int size=8;
double Ntotup[],Ntotdn[];
double NBup[],NBdn[],NCup[],NCdn[];
double Bup[],Bdn[],Cup[],Cdn[];
bool initial;
color clrL=Blue, clrS=Red;
int   codeL=233,codeS=234;
double AUp[],ADn[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
 IndicatorBuffers(0);
 
 string short_name="Shaved Bar Analyzer";
 IndicatorShortName(short_name);
 
 ArrayResize(Ntotup,size);
 ArrayResize(Ntotdn,size);
 ArrayResize(NBup,size);
 ArrayResize(NBdn,size);
 ArrayResize(NCup,size); 
 ArrayResize(NCdn,size);   
 ArrayResize(Bup,size);
 ArrayResize(Bdn,size);
 ArrayResize(Cup,size); 
 ArrayResize(Cdn,size);  

 for(int i=0;i<size;i++)
 {
  Ntotup[i]=0.;
  Ntotdn[i]=0.;
  NBup[i]=0.;
  NBdn[i]=0.;
  NCup[i]=0.;
  NCdn[i]=0.;
  Bup[i] =0.;
  Bdn[i] =0.;
  Cup[i] =0.;
  Cdn[i] =0.;
 }
 
 perc=0.01*Percentage;
 
 SetIndexStyle(0,DRAW_ARROW,codeL,2,clrL);
 SetIndexArrow(0,codeL);
 SetIndexBuffer(0,AUp);
 SetIndexLabel(0,"Up");
 SetIndexStyle(1,DRAW_ARROW,codeS,2,clrS);
 SetIndexArrow(1,codeS);
 SetIndexBuffer(1,ADn);
 SetIndexLabel(1,"Down"); 
 
 initial=false;
  
 return(0);
}
//+------------------------------------------------------------------+
//| Trail Line                                                       |
//+------------------------------------------------------------------+
int start()
{
 if(initial) return(0);

 int i,limit=(Bars-1)-size;
 double open,close,high,low,span,cutoff,close2,high2,low2;
 
 for(i=limit;i>=1;i--)
 { 
  close=iClose(NULL,0,i);
  open=iOpen(NULL,0,i);
  high=iHigh(NULL,0,i);
  low =iLow(NULL,0,i);
  if(close>open)
  {
   span=NormDigits(high-low);
   cutoff=NormDigits(high-(perc*span));
   if(close>=cutoff)
   {
    Ntotup[0]++;
    CheckNum(true,i);
    ADn[i]=high+NormPoints(50);

    close2=iClose(NULL,0,i-1);
    high2=iHigh(NULL,0,i-1);
    if(high2>high) 
    {
     NBup[0]++;
     Bup[0]+=NormDigits(high2-high);
     CheckBreak(true,i);
    }
    if(close2>close) 
    {
     NCup[0]++;
     Cup[0]+=NormDigits(close2-close);
     CheckClose(true,i);
    }    
   }
  }
  else if(close<open)
  {
   span=NormDigits(high-low);
   cutoff=NormDigits(low+(perc*span));
   if(close<=cutoff)
   {
    Ntotdn[0]++;   
    CheckNum(false,i);    
    AUp[i]=low-NormPoints(50);

    close2=iClose(NULL,0,i-1);
    low2=iLow(NULL,0,i-1);
    if(low2<low) 
    {
     NBdn[0]++;
     Bdn[0]+=NormDigits(low-low2);
     CheckBreak(false,i);     
    }
    if(close2<close) 
    {
     NCdn[0]++;
     Cdn[0]+=NormDigits(close-close2);
     CheckClose(false,i);     
    }
    
   }   
  }
 } // for i
 
 LogData();
  
 initial=true;

 return(0);
}
//+------------------------------------------------------------------+
void CheckNum(bool long, int i)
{
 int ipo=i+1,j,k,count; 
 double closek,openk;
 
 if(long)
 {
  for(j=1;j<size-1;j++)
  {
   count=0;
   for(k=ipo;k<=ipo+j-1;k++)
   {
    closek=iClose(NULL,0,k);
    openk=iOpen(NULL,0,k);  
    if(closek>openk) count++;
   }
   if(count==j) Ntotup[j]++;
  }
  
  if(iClose(NULL,0,ipo)<iOpen(NULL,0,ipo)) Ntotup[size-1]++; // 1 prior contrary
  
 }
 else
 {
  for(j=1;j<size-1;j++)
  {
   count=0;
   for(k=ipo;k<=ipo+j-1;k++)
   {
    closek=iClose(NULL,0,k);
    openk=iOpen(NULL,0,k);  
    if(closek<openk) count++;
   }
   if(count==j) Ntotdn[j]++;
  } 

  if(iClose(NULL,0,ipo)>iOpen(NULL,0,ipo)) Ntotdn[size-1]++; // 1 prior contrary
  
 }
 return;
}
//+------------------------------------------------------------------+
void CheckBreak(bool long, int i)
{
 int ipo=i+1,j,k,count; 
 double high,high2,low,low2,closek,openk;
 
 if(long)
 {
  for(j=1;j<size-1;j++)
  {
   count=0;
   for(k=ipo;k<=ipo+j-1;k++)
   {
    closek=iClose(NULL,0,k);
    openk=iOpen(NULL,0,k);  
    if(closek>openk) count++;
   }
   if(count==j) 
   {
    high=iHigh(NULL,0,i);   
    high2=iHigh(NULL,0,i-1);    
    NBup[j]++;
    Bup[j]+=NormDigits(high2-high);
   }
  }

  if(iClose(NULL,0,ipo)<iOpen(NULL,0,ipo))  // 1 prior contrary
  {
   high=iHigh(NULL,0,i);   
   high2=iHigh(NULL,0,i-1);    
   NBup[size-1]++;
   Bup[size-1]+=NormDigits(high2-high);
  }
  
 }
 else
 {
  for(j=1;j<size-1;j++)
  {
   count=0;
   for(k=ipo;k<=ipo+j-1;k++)
   {
    closek=iClose(NULL,0,k);
    openk=iOpen(NULL,0,k);  
    if(closek<openk) count++;
   }
   if(count==j) 
   {
    low=iLow(NULL,0,i);   
    low2=iLow(NULL,0,i-1);    
    NBdn[j]++;
    Bdn[j]+=NormDigits(low-low2);
   }
  } 
  
  if(iClose(NULL,0,ipo)>iOpen(NULL,0,ipo))  // 1 prior contrary
  {
   low=iLow(NULL,0,i);   
   low2=iLow(NULL,0,i-1);    
   NBdn[size-1]++;
   Bdn[size-1]+=NormDigits(low-low2);
  }
  
 }
 return;
}
//+------------------------------------------------------------------+
void CheckClose(bool up, int i)
{ 
 int ipo=i+1,j,k,count; 
 double close,close2,closek,openk;

 close=iClose(NULL,0,i);   
 close2=iClose(NULL,0,i-1);  
 
 if(up)
 {
  for(j=1;j<size-1;j++)
  {
   count=0;
   for(k=ipo;k<=ipo+j-1;k++)
   {
    closek=iClose(NULL,0,k);
    openk=iOpen(NULL,0,k); 
    if(closek>openk) count++;
   }
   if(count==j) 
   {  
    NCup[j]++;
    Cup[j]+=NormDigits(close2-close);
   }
  }

  if(iClose(NULL,0,ipo)<iOpen(NULL,0,ipo))  // 1 prior contrary
  {   
   NCup[size-1]++;
   Cup[size-1]+=NormDigits(close2-close);
  }
  
 }
 else
 {
  for(j=1;j<size-1;j++)
  {
   count=0;
   for(k=ipo;k<=ipo+j-1;k++)
   {
    closek=iClose(NULL,0,k);
    openk=iOpen(NULL,0,k);    
    if(closek<openk) count++;
   }
   if(count==j) 
   {
    NCdn[j]++;
    Cdn[j]+=NormDigits(close-close2);
   }
  } 

  if(iClose(NULL,0,ipo)>iOpen(NULL,0,ipo))  // 1 prior contrary
  {   
   NCdn[size-1]++;
   Cdn[size-1]+=NormDigits(close-close2);
  }
  
 }
 return;
}
//+------------------------------------------------------------------+
void LogData()
{
 double bars=Bars-1;

 string timename;
 switch(Period())
 {
  case 1: timename="M1";
  break;
  case 5: timename="M5";
  break;
  case 15: timename="M15";
  break;  
  case 30: timename="M30";
  break;  
  case 60: timename="H1";
  break;
  case 240: timename="H4";
  break;  
  case 1440: timename="D1";
  break;  
  case 10080: timename="W1";
  break;  
  default: timename="MN";
  break;  
 }

 string v1,v2,v3,v4,v5,v6,v7,v8;

 string filename=StringConcatenate("ShavedBar_Analysis_",Symbol(),"_",timename,"_",Percentage,".csv");
 int handle=FileOpen(filename,FILE_CSV|FILE_WRITE,',');
 
 for(int i=0;i<size;i++)
 {
  if(Ntotup[i]!=0) v1=DoubleToStr(NBup[i]/Ntotup[i]*100.,1);
  else             v1="NULL";

  if(Ntotup[i]!=0) v2=DoubleToStr(NCup[i]/Ntotup[i]*100.,1);
  else             v2="NULL";

  if(Ntotup[i]!=0) v3=DoubleToStr(Bup[i]/Ntotup[i]/Point,0);
  else             v3="NULL";

  if(Ntotup[i]!=0) v4=DoubleToStr(Cup[i]/Ntotup[i]/Point,0);
  else             v4="NULL";

  if(Ntotdn[i]!=0) v5=DoubleToStr(NBdn[i]/Ntotdn[i]*100.,1);
  else             v5="NULL";

  if(Ntotdn[i]!=0) v6=DoubleToStr(NCdn[i]/Ntotdn[i]*100.,1);
  else             v6="NULL";

  if(Ntotdn[i]!=0) v7=DoubleToStr(Bdn[i]/Ntotdn[i]/Point,0);
  else             v7="NULL";

  if(Ntotdn[i]!=0) v8=DoubleToStr(Cdn[i]/Ntotdn[i]/Point,0);
  else             v8="NULL"; 

  FileWrite(handle," ");
  if(i!=size-1) FileWrite(handle,i+" prior bars same direction closes:");
  else          FileWrite(handle,"1 prior bars different direction closes:");
  FileWrite(handle," ");

  FileWrite(handle,"% break up","% close up","ave break up","ave close up"); 
  FileWrite(handle,v1,v2,v3,v4);
                  
  FileWrite(handle,"% break dn","% close dn","ave break dn","ave close dn"); 
  FileWrite(handle,v5,v6,v7,v8);
 }

 FileWrite(handle," ");
 FileWrite(handle,"Bars total");
 FileWrite(handle,DoubleToStr(bars,0));

 FileClose(handle);
 
 return;
}

//+------------------------------------------------------------------+
double NormDigits(double a)
{
 return(NormalizeDouble(a,Digits));
}
//+------------------------------------------------------------------+
double NormPoints(int pips)
{
 return(NormDigits(pips*Point));
}
//+------------------------------------------------------------------+

