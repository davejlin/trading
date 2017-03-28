//+----------------------------------------------------------------------+
//|                                                       Diagnostic.mq4 |
//|                                                         David J. Lin |
//|                                                                      |
//|                                                                      |
//| Coded by David J. Lin                                                |
//| dave.j.lin@sbcglobal.net                                             |
//| Evanston, IL, February 16, 2009                                         |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2009, David J. Lin"
#property link      ""
//=========================================================================
datetime starttime;
int j;

int init()
{
 int handle=FileOpen("Diagnostic.txt",FILE_CSV|FILE_WRITE);
 if(handle>0)
 {
  FileWrite(handle,"This is a document generated to diagnose MT4 platform time settings.");
  FileWrite(handle,"Please send this document to David J. Lin at dave.j.lin@sbcglobal.net");
  FileWrite(handle,AccountNumber(),AccountName(),AccountServer(),AccountCompany());
  
  starttime=TimeCurrent();
  
  FileWrite(handle,"starttime = ",starttime);


  for(j=0;j<=10;j++)
  {
   FileWrite(handle,"time = ",j," ",iTime(NULL,0,j));
  }

  FileClose(handle);
 }
 return(0);
}
int deinit()
{
 return(0);
}
int start()
{
 return(0);
}