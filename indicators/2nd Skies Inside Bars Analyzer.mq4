//+------------------------------------------------------------------+
//|                               2nd Skies Inside Bars Analyzer.mq4 |
//| 2nd Skies Inside Bars Analyzer                                   |
//| written for Chris Capre, 2ndSkies.com (Info@2ndSkies.com)        |
//|                                                                  |
//| Coded by David J. Lin (dave.j.lin@sbcglobal.net)                 |
//| Evanston, IL, August 30, 2009                                    |
//| 11/28/09 fixed zero-divide problem                               |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009 David J. Lin"

#property indicator_chart_window
#property indicator_buffers 0

extern int Xpips=0;

//---- buffers

double Xpnts;
double nbreakupup,nbreakupdn,nbreakdndn,nbreakdnup,nbreakdjup,nbreakdjdn;
double ncloseupup,ncloseupdn,nclosedndn,nclosednup,nclosedjup,nclosedjdn;
double total_AB,total_BC; // total_AB = major IB events AB, total_BC = minor IB bars within AB
double total_up,total_dn,total_dj; // total_up = A up bar, total_dn = A dn bar, total_doji = A doji 
double total_ABC; // total_ABC = total number of ABC break/closes where A-B-C occurs in 3-bar fashion
double breakUpdist,breakDndist,closeUpdist,closeDndist; // average distance of breaks, closes
bool initial;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
 IndicatorBuffers(0);

 string short_name="Inside Bars Analyzer";
 IndicatorShortName(short_name);
     
 Xpnts=NormDouble(Xpips*Point); 
 total_AB=0;
 total_BC=0;
 total_ABC=0;
 total_up=0;
 total_dn=0; 
 total_dj=0; 
 nbreakupup=0;
 nbreakupdn=0; 
 nbreakdndn=0;
 nbreakdnup=0; 
 nbreakdjup=0;
 nbreakdjdn=0; 
 ncloseupup=0;
 ncloseupdn=0; 
 nclosedndn=0;
 nclosednup=0; 
 nclosedjup=0;
 nclosedjdn=0;
 breakUpdist=0;
 breakDndist=0;
 closeUpdist=0;
 closeDndist=0; 
 initial=false;
 
 return(0);
}
//+------------------------------------------------------------------+
//| Trail Line                                                       |
//+------------------------------------------------------------------+
int start()
{
 if(initial) return(0);
 
 int i,j,limit=Bars-2; // Bars-2 for i+1
 double high1,high2,high3,low1,low2,low3,close1,close3,open1;

 for(i=limit;i>0;i--) // i>0 since 3 bar minimum for IB-break formation 
 { 
  high1=iHigh(NULL,0,i+1); // bar A
  low1=iLow(NULL,0,i+1);   // bar A
  high2=iHigh(NULL,0,i);   // bar B
  low2=iLow(NULL,0,i);     // bar B
  
  if (high1>=high2 && low1<=low2)
  {
   close1=iClose(NULL,0,i+1); // i+1 is correct here, bar A
   open1=iOpen(NULL,0,i+1); // i+1 is correct here, bar A 

   total_AB++; // keep count of major IB instances (all Bar AB instances)

   if(close1>open1)      total_up++; // keep count of major IB instances (up Bar AB instances)
   else if(close1<open1) total_dn++; // keep count of major IB instances (down Bar AB instances)
   else                  total_dj++; // keep count of major IB instances (neutral Bar AB instances)

   for(j=i-1;j>=0;j--)
   {
    high3=iHigh(NULL,0,j);   // bar C
    low3=iLow(NULL,0,j);     // bar C
    
    if (high1>=high3 && low1<=low3) 
    {
     total_BC++; // keep count of all IBs
     continue; // another inside bar of bar A
    }
    
    if(j==i-1) total_ABC++;
       
    close3=iClose(NULL,0,j); // j is correct here, bar C

// up A break 

    if(close1>open1&&high3>NormDouble(high1+Xpnts))  
    { 
     nbreakupup++;
     breakUpdist+=NormDouble(high3-high1);
    }
    
    if(close1>open1&&low3<NormDouble(low1-Xpnts))    
    {     
     nbreakupdn++;
     breakDndist+=NormDouble(low1-low3);
    }

// down A break 
  
    if(close1<open1&&low3<NormDouble(low1-Xpnts))     
    {
     nbreakdndn++;
     breakDndist+=NormDouble(low1-low3);
    }
           
    if(close1<open1&&high3>NormDouble(high1+Xpnts))
    {    
     nbreakdnup++;    
     breakUpdist+=NormDouble(high3-high1);
    }

// doji A break 

    if(close1==open1&&high3>NormDouble(high1+Xpnts))
    {    
     nbreakdjup++;    
     breakUpdist+=NormDouble(high3-high1);
    } 
    
    if(close1==open1&&low3<NormDouble(low1-Xpnts))     
    {
     nbreakdjdn++;
     breakDndist+=NormDouble(low1-low3);
    }
           
// up A close
       
    if(close1>open1&&close3>NormDouble(high1+Xpnts)) 
    { 
     ncloseupup++;
     closeUpdist+=NormDouble(high3-high1);
    }
    
    if(close1>open1&&close3<NormDouble(low1-Xpnts)) 
    {
     ncloseupdn++;    
     closeDndist+=NormDouble(low1-low3);
    }

// down A close
    
    if(close1<open1&&close3<NormDouble(low1-Xpnts))  
    {
     nclosedndn++;
     closeDndist+=NormDouble(low1-low3);
    } 
     
    if(close1<open1&&close3>NormDouble(high1+Xpnts))  
    {
     nclosednup++; 
     closeUpdist+=NormDouble(high3-high1);
    }   

// doji A close
       
    if(close1==open1&&close3>NormDouble(high1+Xpnts)) 
    { 
     nclosedjup++;
     closeUpdist+=NormDouble(high3-high1);
    }
    
    if(close1==open1&&close3<NormDouble(low1-Xpnts)) 
    {
     nclosedjdn++;    
     closeDndist+=NormDouble(low1-low3);
    }
    
    i=j; // reset i
    break;
   }
  }
 }
 
 LogData();
  
 initial=true;

 return(0);
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

 string v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16,v17;
 double tot;

 if(total_up!=0) v1=DoubleToStr(nbreakupup*100./total_up,1);
 else            v1="NULL";
 
 if(total_up!=0) v2=DoubleToStr(nbreakupdn*100./total_up,1);
 else            v2="NULL";

 if(total_dn!=0) v3=DoubleToStr(nbreakdndn*100./total_dn,1);
 else            v3="NULL"; 
 
 if(total_dn!=0) v4=DoubleToStr(nbreakdnup*100./total_dn,1);
 else            v4="NULL";

 if(total_dj!=0) v5=DoubleToStr(nbreakdjdn*100./total_dj,1);
 else            v5="NULL";

 if(total_dj!=0) v6=DoubleToStr(nbreakdjup*100./total_dj,1); 
 else            v6="NULL";

 if(total_up!=0) v7=DoubleToStr(ncloseupup*100./total_up,1);
 else            v7="NULL";

 if(total_up!=0) v8=DoubleToStr(ncloseupdn*100./total_up,1);
 else            v8="NULL";

 if(total_dn!=0) v9=DoubleToStr(nclosedndn*100./total_dn,1);
 else            v9="NULL";

 if(total_dn!=0) v10=DoubleToStr(nclosednup*100./total_dn,1);
 else            v10="NULL";

 if(total_dj!=0) v11=DoubleToStr(nclosedjdn*100./total_dj,1);
 else            v11="NULL";

 if(total_dj!=0) v12=DoubleToStr(nclosedjup*100./total_dj,1);
 else            v12="NULL";           

 if(total_AB!=0) v13=DoubleToStr(total_ABC*100/total_AB,1);
 else            v13="NULL";

 tot=nbreakupup+nbreakdnup;
 if(tot!=0) v14=DoubleToStr(breakUpdist/tot/Point,0);
 else       v14="NULL"; 
 
 tot=nbreakdndn+nbreakupdn;
 if(tot!=0) v15=DoubleToStr(breakDndist/tot/Point,0);
 else       v15="NULL";

 tot=ncloseupup+nclosednup;
 if(tot!=0) v16=DoubleToStr(closeUpdist/tot/Point,0);
 else       v16="NULL";

 tot=nclosedndn+ncloseupdn;
 if(tot!=0) v17=DoubleToStr(closeDndist/tot/Point,0);
 else       v17="NULL";

 string filename=StringConcatenate("IB_Analysis_",Symbol(),"_",timename,".csv");
 int handle=FileOpen(filename,FILE_CSV|FILE_WRITE,','); 

 FileWrite(handle,"UBU","UBD","DBD","DBU","dBU","dBD","UCU","UCD","DCD","DCU","dCU","dCD");
 
 FileWrite(handle,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12);
                  
 FileWrite(handle,"Up","Dn","doji");
 FileWrite(handle,DoubleToStr(total_up*100/bars,1),
                  DoubleToStr(total_dn*100/bars,1),
                  DoubleToStr(total_dj*100/bars,1));

 FileWrite(handle,"AB","IBs","ABC");
 
 FileWrite(handle,DoubleToStr(total_AB*100/bars,1),
                  DoubleToStr((total_AB+total_BC)*100/bars,1),
                  v13);

 FileWrite(handle,"BUp","BDn","CUp","CDn");

 FileWrite(handle,v14,v15,v16,v17);

 FileWrite(handle,"Bars total");
 FileWrite(handle,DoubleToStr(bars,0));

 FileClose(handle);
 
 return;
}
//+------------------------------------------------------------------+
double NormDouble(double a)
{
 return(NormalizeDouble(a,Digits));
}
//+------------------------------------------------------------------+

