//+----------------------------------------------------------------------+
//|                                                       Fractal OC.mq4 |
//|                                                         David J. Lin |
//| Fractal OC (Fractal based on Open & Close)                           |
//| written for geneva wheeless (gkw1018@yahoo.com)                      |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, September 4, 2007                                       |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007 David J. Lin"

#property indicator_chart_window
#property indicator_buffers 4

extern datetime StartDate=D'2007.09.01';

//---- buffers
double v0[],v1[],v2[],v3[];
color colorUp=Aqua;
color colorDn=Orange;
double barU[5],barD[5];
string stringAPUp="APU",   stringAPDn="APD";
string stringUp  ="APUgp", stringDn  ="APDgp";
string stringHUp ="HUgp",stringHDn ="HDgp"; // historical lines
int shift,maxindex,minindex,thistime;
double maxvalue,minvalue;
//----
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
int init()
{ 
 IndicatorBuffers(4);
 
 SetIndexStyle(0, DRAW_NONE);
 SetIndexBuffer(0, v0);
 SetIndexLabel(0, "Armpit Up");  

 SetIndexStyle(1, DRAW_NONE);
 SetIndexBuffer(1, v1);
 SetIndexLabel(1, "Armpit Dn");

 SetIndexStyle(2, DRAW_NONE);
 SetIndexBuffer(2, v2);
 SetIndexLabel(2, "AP Up Gap");  

 SetIndexStyle(3, DRAW_NONE);
 SetIndexBuffer(3, v3);
 SetIndexLabel(3, "AP Dn Gap"); 

 shift=iBarShift(NULL,0,StartDate,false);   
 if(shift>Bars) shift=Bars; 

 return(0);
}
//+------------------------------------------------------------------+
int deinit()
{
 int objtotal=ObjectsTotal()-1; string name;int i,pos,time1,time2;
 double price;

 for(i=objtotal;i>=0;i--) 
 {
  name=ObjectName(i);
  
  pos=StringFind(name,stringUp);
  if(pos>=0) ObjectDelete(name);

  pos=StringFind(name,stringDn);
  if(pos>=0) ObjectDelete(name);
  
  pos=StringFind(name,stringHUp);
  if(pos>=0) ObjectDelete(name);
  
  pos=StringFind(name,stringHDn);
  if(pos>=0) ObjectDelete(name);  

  pos=StringFind(name,stringAPUp);
  if(pos>=0) ObjectDelete(name);
  
  pos=StringFind(name,stringAPDn);
  if(pos>=0) ObjectDelete(name);  
 }
 return(0);
}  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{ 
 if(thistime==iTime(NULL,0,0)) return(0);
 thistime=iTime(NULL,0,0);
 
 int i,j,iap,imax,time1,counted=IndicatorCounted();
 double Fup,Fdn;
 if(counted>0) imax=1;
 else imax=shift-2;
 
 for(i=imax;i>=1;i--)
 { 
  Fup=iFractals(NULL,0,MODE_UPPER,i+2);
  if(Fup>0)  
  {
   FillArrays(i); 
   time1=iTime(NULL,0,i+maxindex);    
   DrawCross(i+maxindex,maxvalue,time1,stringAPUp,colorUp);
   iap=i+maxindex;
   for(j=i;j<=i+maxindex;j++) 
   {
    v0[j]=maxvalue; // backfill
    v1[j]=EMPTY_VALUE;
   } 
  }
  else 
  {
   iap=i;  
   v0[i]=v0[i+1];  
  }
  
  ArmpitGaps(iap,i,true);
    
  Fdn=iFractals(NULL,0,MODE_LOWER,i+2);
  if(Fdn>0)  
  {
   FillArrays(i);   
   time1=iTime(NULL,0,i+minindex);    
   DrawCross(i+minindex,minvalue,time1,stringAPDn,colorDn);   
   for(j=i;j<=i+minindex;j++) 
   {
    v1[j]=minvalue; // backfill 
    v0[j]=EMPTY_VALUE;   
   }
   iap=i+minindex;
  }
  else 
  {
   iap=i;  
   v1[i]=v1[i+1];
  }

  ArmpitGaps(iap,i,false);  

 }
 UpdateLines(); 
 return(0);
}
//+------------------------------------------------------------------+
int ArmpitGaps(int start, int end, bool flag) // separater routine due to dynamic re-writing nature of Fractals
{ 
 int i,k,imax,time1,time2;
 double value0,value1,open0,open1,close0,close1;
 double higher,lower,price,nextprice;
 bool newUp,newDn;
 
 for(i=start;i>=end;i--)
 {  
// Find Armpit Gaps: 
    
  if(flag)  // upper:
  {  
   value0=v0[i+1];
   value1=v0[i];
  
//  newUp=false;
   if(value0!=EMPTY_VALUE&&value1!=EMPTY_VALUE)
   {
    close0=iClose(NULL,0,i+1);
    close1=iClose(NULL,0,i);
    if(close1<close0)
    {
     open0=iOpen(NULL,0,i+1);
     lower=NormDigits(MathMin(open0,close0));
     open1=iOpen(NULL,0,i);    
     if(open1<lower) 
     {   
      time1=iTime(NULL,0,i+1);
      time2=iTime(NULL,0,1);      
      DeleteLine2(time1,stringUp); // to avoid re-write error 
      DrawLine(lower,time1,time2,stringUp,colorUp);   
//     newUp=true; 
      v2[i+1]=lower; 
     }
    }
   }
  
   close1=iClose(NULL,0,i);
   open1 =iOpen(NULL,0,i);
   higher =NormDigits(MathMax(close1,open1)); 
//  if(!newUp)
   {
    price=NormDigits(v2[i+1]);
    if(price!=EMPTY_VALUE)
    {
     if(higher>=price)
     {
      DeleteLine(i,price,stringUp,true);

      for(k=0;k<100;k++) // get rid of multiple violations/bar 
      {
       nextprice=NormDigits(FindLast(true));
       if(higher>=nextprice)
       {
        DeleteLine(i,nextprice,stringUp,true);
       } 
       else
       {
        v2[i]=nextprice;
        break;
       }     
      }
     
     }
     else v2[i]=v2[i+1];    
    }
   }
  }
  else // lower
  {
   value0=v1[i+1];
   value1=v1[i];
  
//  newDn=false;
   if(value0!=EMPTY_VALUE&&value1!=EMPTY_VALUE)
   {
    close0=iClose(NULL,0,i+1);
    close1=iClose(NULL,0,i);
    if(close1>close0)
    {
     open0=iOpen(NULL,0,i+1);
     higher=NormDigits(MathMax(open0,close0));
     open1=iOpen(NULL,0,i);    
     if(open1>higher) 
     {
      time1=iTime(NULL,0,i+1);
      time2=iTime(NULL,0,1);  
      DeleteLine2(time1,stringDn); // to avoid re-write error     
      DrawLine(higher,time1,time2,stringDn,colorDn);  
//     newDn=true;
      v3[i+1]=NormDigits(higher);      
     }
    }
   }
  
   close1=iClose(NULL,0,i);
   open1 =iOpen(NULL,0,i);
   lower =NormDigits(MathMin(close1,open1)); 
//  if(!newDn)
   {
    price=NormDigits(v3[i+1]);
    if(price!=EMPTY_VALUE)
    {
     if(lower<=price)
     {
      DeleteLine(i,price,stringDn,false);

      for(k=0;k<100;k++) // get rid of multiple violations/bar 
      {
       nextprice=NormDigits(FindLast(false));
       if(lower<=nextprice)
       {
        DeleteLine(i,nextprice,stringDn,false);
       } 
       else
       {
        v3[i]=nextprice;
        break;
       }     
      }
     
     }
     else v3[i]=v3[i+1];    
    }
   }
  
  }
 }
 
 UpdateLines(); 
 return(0);
} 
//+------------------------------------------------------------------+
void DrawLine(double price, int time1, int time2, string str, color clr)
{
 string name=StringConcatenate(str,TimeToStr(time1));
 if(!ObjectCreate(name,OBJ_TREND,0,time1,price,time2,price))
 {
  Print("Error Object Create: ",GetLastError()," ",name);
 }
 ObjectSet(name,OBJPROP_RAY,false);
 ObjectSet(name,OBJPROP_COLOR,clr);
 ObjectSet(name,OBJPROP_WIDTH,1);
// ObjectSet(name,OBJPROP_STYLE,STYLE_DASH);
 return;
}
//+------------------------------------------------------------------+
void DrawCross(int i, double price, int time1, string str, color clr)
{
 string name=StringConcatenate(str,TimeToStr(iTime(NULL,0,i)));
 ObjectCreate(name,OBJ_ARROW,0,time1,price);
 ObjectSet(name,OBJPROP_COLOR,clr);
 ObjectSet(name,OBJPROP_ARROWCODE,251); 
 ObjectSet(name,OBJPROP_WIDTH,1);
 return;
}
//+------------------------------------------------------------------+
void FillArrays(int i)
{
 int j; double open, close;
 for(j=0;j<=4;j++)
 {
  close=iClose(NULL,0,i+j);
  open=iOpen(NULL,0,i+j);
  if(close>open)
  {
   barU[j]=close;
   barD[j]=open;
  }
  else // includes possibility of equivalence
  {
   barU[j]=open;
   barD[j]=close;   
  }
 }

 double value1;
 maxindex=4;minindex=4;
 maxvalue=0;minvalue=99999999;
 for(j=4;j>=0;j--)
 {
  // Up:  highest "low"
  value1=barD[j];
  if(value1>maxvalue)
  {
   maxvalue=barD[j];
   maxindex=j;
  }

  // Down:  lowest "high"
  value1=barU[j];
  if(value1<minvalue)
  {
   minvalue=barU[j];
   minindex=j;
  }  
 } 
 return;
}
//+------------------------------------------------------------------+
double NormDigits(double price)
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+
void UpdateLines()
{
 int objtotal=ObjectsTotal()-1,pos1,pos2; string name;

 for(int i=objtotal;i>=0;i--) 
 {
  name=ObjectName(i);  
  pos1=StringFind(name,stringUp);
  pos2=StringFind(name,stringDn);
  
  if(pos1>=0 || pos2>=0)
  {
   ObjectSet(ObjectName(i),OBJPROP_TIME2,iTime(NULL,0,1));
  }
  
 }
 return;
}
//+------------------------------------------------------------------+
void DeleteLine(int index, double price, string str, bool bias)
{
 int objtotal=ObjectsTotal()-1; 
 string name;int i,pos,time1,time2;double price1;

 if(bias)
 {
  for(i=objtotal;i>=0;i--) // Up lines
  {
   name=ObjectName(i);
   pos=StringFind(name,str);
   if(pos<0) continue;
   price1=ObjectGet(name,OBJPROP_PRICE1);
   if(price==price1) 
   {
    time1=ObjectGet(name,OBJPROP_TIME1);
    time2=iTime(NULL,0,index);
    ObjectDelete(name);
    DeleteLine2(time1,stringHUp);
    DrawLine(price1,time1,time2,stringHUp,colorUp);
    return;
   }
  }
 }
 else
 {
  for(i=objtotal;i>=0;i--) // Dn lines
  {
   name=ObjectName(i);
   pos=StringFind(name,str);
   if(pos<0) continue;
   price1=ObjectGet(name,OBJPROP_PRICE1);
   if(price==price1) 
   {
    time1=ObjectGet(name,OBJPROP_TIME1);
    time2=iTime(NULL,0,index);    
    ObjectDelete(name);    
    DeleteLine2(time1,stringHDn);    
    DrawLine(price1,time1,time2,stringHDn,colorDn); 
    return;
   }
  } 
 }
 return;
}
//+------------------------------------------------------------------+
void DeleteLine2(int time, string str) // completely delete
{
 int objtotal=ObjectsTotal()-1; 
 string name;int i;
 string name2=StringConcatenate(str,TimeToStr(time));
 
 for(i=objtotal;i>=0;i--)
 {
  name=ObjectName(i);
  if(name==name2) 
  {
   ObjectDelete(name);
  }
 }
 return;
}
//+------------------------------------------------------------------+
double FindLast(bool flag)
{
 int i,objtotal=ObjectsTotal()-1,pos; string name; double price,keepprice;

 if(flag) // Up ... seeking next lowest
 {
  keepprice=9999999;
  for(i=objtotal;i>=0;i--) 
  {
   name=ObjectName(i);  
   pos=StringFind(name,stringUp);
   if(pos>=0) keepprice=MathMin(ObjectGet(name,OBJPROP_PRICE1),keepprice); 
  }
  if(keepprice==9999999) keepprice=EMPTY_VALUE;
 } 
 else // Down ... seeking next highest
 {
  keepprice=0;
  for(i=objtotal;i>=0;i--) 
  {
   name=ObjectName(i);  
   pos=StringFind(name,stringDn);
   if(pos>=0) keepprice=MathMax(ObjectGet(name,OBJPROP_PRICE1),keepprice); 
  } 
  if(keepprice==0) keepprice=EMPTY_VALUE;
 }
 return(NormDigits(keepprice));
}
//+------------------------------------------------------------------+