//+------------------------------------------------------------------+
//|                                       Price Alert Continuous.mq4 |
//|                                                     David J. Lin |
//| Continuous price alert for Jesper Pederson                       |
//| jesperdenmark@hotmail.com                                        |
//|                                                                  |
//| Modified by David J. Lin                                         |
//| dave.j.lin@gmail.com                                             |
//| Evanston, IL, November 14, 2010                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Jesper Pederson, David J. Lin"
#property link      ""
#property indicator_chart_window

// User adjustable parameters:
extern double TargetPrice=1.3870;
extern color AlertColor=Red;
extern int LineWidth=1; // use 0 or negative number to turn off line
extern color LineColor=Lime;
// variables
string str="Price Alert Continuous ";
string mainwinname;
bool flag;
double tripprice,lastbid;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----
 if(TargetPrice>0) 
 {
  flag=true;
  if(LineWidth>0) DrawLine(TargetPrice);
 }
 else flag=false;
 lastbid=iClose(NULL,0,0);
 mainwinname=StringConcatenate(str,"Window");
 tripprice=NormDigits(TargetPrice); 
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
//---- 
 int objtotal=ObjectsTotal()-1; string name;int i,pos;

 for(i=objtotal;i>=0;i--) 
 {
  name=ObjectName(i);
  
  pos=StringFind(name,str);
  if(pos>=0) ObjectDelete(name);   
 }
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
//----
 double price;
 if(flag)
 {
  price=iClose(NULL,0,0);
  if((lastbid<=tripprice && price>tripprice)||(lastbid>=tripprice && price<tripprice))
  {
   AlertNow();
   flag=false;
  }
 }
 else AlertNow();
 
 lastbid=price;
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+
void AlertNow()
{
 int i;
 color clr;
 string message=StringConcatenate(Symbol()," has crossed ",DoubleToStr(TargetPrice,Digits));
 Alert(message);
 ObjectDelete(mainwinname);
 ObjectCreate(mainwinname,OBJ_RECTANGLE,0,iTime(NULL,0,0),1000,iTime(NULL,0,Bars-1),0);  
 ObjectSet(mainwinname,OBJPROP_COLOR,AlertColor);
}
//+------------------------------------------------------------------+
double NormDigits(double price)
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+
void DrawLine(double price)
{
 if(LineWidth<0) return;
 string name=StringConcatenate(str," ",Symbol()," ",price);
 if(!ObjectCreate(name,OBJ_HLINE,0,0,price))
 {
  Print("Error Object Create: ",GetLastError());
 }
 ObjectSet(name,OBJPROP_COLOR,LineColor);
 ObjectSet(name,OBJPROP_WIDTH,LineWidth);
 return;
}