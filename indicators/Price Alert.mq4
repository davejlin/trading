//+----------------------------------------------------------------------+
//|                                                      Price Alert.mq4 |
//|                                                         David J. Lin |
//|Written for Paul Dean (pdean123@embarqmail.com)                       |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, October 24, 2007                                        |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007, Paul Dean & David J. Lin"
#property link      ""
#property indicator_chart_window

// User adjustable parameters:
extern double TargetPrice1=-1;                 // price target 1 (use negative value to turn off)
extern double TargetPrice2=-1;                 // price target 2 (use negative value to turn off)
extern double TargetPrice3=-1;                 // price target 3 (use negative value to turn off)
extern double TargetPrice4=-1;                 // price target 4 (use negative value to turn off)
extern double TargetPrice5=-1;                 // price target 5 (use negative value to turn off)

extern string TextHeader="MT4 Price Alert!!"; // header of email message 
extern color LineColor=Lime;
extern int LineWidth=1;
// variables
bool flag1,flag2,flag3,flag4,flag5;
string str="Price Alert ";

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----
 if(TargetPrice1>0) {flag1=true;DrawLine(TargetPrice1);}
 else flag1=false;
 if(TargetPrice2>0) {flag2=true;DrawLine(TargetPrice2);}
 else flag2=false;
 if(TargetPrice3>0) {flag3=true;DrawLine(TargetPrice3);}
 else flag3=false;
 if(TargetPrice4>0) {flag4=true;DrawLine(TargetPrice4);}
 else flag4=false;
 if(TargetPrice5>0) {flag5=true;DrawLine(TargetPrice5);}
 else flag5=false;
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
 if(flag1&&Bid==NormDigits(TargetPrice1)) {AlertNow(TargetPrice1);flag1=false;}
 if(flag2&&Bid==NormDigits(TargetPrice2)) {AlertNow(TargetPrice2);flag2=false;}
 if(flag3&&Bid==NormDigits(TargetPrice3)) {AlertNow(TargetPrice3);flag3=false;}
 if(flag4&&Bid==NormDigits(TargetPrice4)) {AlertNow(TargetPrice4);flag4=false;}
 if(flag5&&Bid==NormDigits(TargetPrice5)) {AlertNow(TargetPrice5);flag5=false;}   
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+
void AlertNow(double price)
{
 string message=StringConcatenate(Symbol()," has reached ",price," at ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES));
 SendMessage(message);
 Alert(message);
}
//+------------------------------------------------------------------+
void SendMessage(string message)
{
 SendMail(TextHeader,message);
 return;
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