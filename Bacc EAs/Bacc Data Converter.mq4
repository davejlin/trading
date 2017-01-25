//+----------------------------------------------------------------------+
//|                                              Bacc Data Converter.mq4 |
//|                                                         David J. Lin |
//| Converts data format into format needed for Bacc Tester              |
//|                                                                      |
//| Coded by David J. Lin                                                |
//| dave.j.lin@gmail.com                                                 |
//| Evanston, IL, October 4, 2010                                        |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2010, David J. Lin"
#property link      ""
//=========================================================================

int shoe[],shoeN[]; // shoe decisions & shoe number

int n; // number of decisions
int NShoe; // total number of shoes
int OutputFilehandle; // handle for main output file 
//=========================================================================

int init()
{
 OpenFiles();
 Input(); 
 CloseFiles();
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
//=========================================================================

void Input()
{
 string data;
 bool exit=false;
 int shoenum,lastshoenum=1;
 NShoe=0;
// string filename=StringConcatenate("Dave ",DoubleToStr(loop,0)," Separate data.csv");

// int handle=FileOpen("Random Coin Flip 1000 data.csv",FILE_CSV|FILE_READ,','); // no shoe-number format 
 int handle=FileOpen("Wizard of Odds 8-deck 1000 1-1000 data.csv",FILE_CSV|FILE_READ,','); // no shoe-number format 
 //int handle=FileOpen(filename,FILE_CSV|FILE_READ,',');  // Dave's virtual shoe files

 if(handle>0)
 {
  n=0;
  while(!exit)
  {
   //shoenum=StrToInteger(FileReadString(handle)); // Zumma files
   data=FileReadString(handle);
   //if(data!="999") // random coin flip
   if(data!="END")
   {
    //if(n<72) // random coin flip 
    if(data!="E") // no shoe-number format 
    //if(lastshoenum==shoenum) // Zumma files
    {
     IncrementShoeArray(data,shoenum);
    }
    else 
    {
     Output();
     //data=FileReadString(handle); // if end of shoe line has line break 
     n=0;
     lastshoenum=shoenum;
     //IncrementShoeArray(data,shoenum); // Zumma files
    }
   }
   else exit=true;
  }
 }

 FileClose(handle);  

 return;
}

//=========================================================================
void IncrementShoeArray(string data, int shoenum)
{
 n++;

 ArrayResize(shoe,n);   
 if(data=="P") shoe[n-1]=1;
 else if(data=="B") shoe[n-1]=0;
 else if(data=="T") shoe[n-1]=-1;

 ArrayResize(shoeN,n);
 shoeN[n-1]=shoenum;
 return;
}

//=========================================================================
void Output()
{
 string decision,outputline="";
 int i;
 NShoe++;
 
 if(OutputFilehandle>0)
 { 
  for(i=0;i<n;i++)
  {
   decision=CheckShoe(i);  
   outputline=StringConcatenate(outputline,DoubleToStr(NShoe,0),",",decision,",");  
  }
  FileWrite(OutputFilehandle,outputline);
  
  if(NShoe==1000) // end cap
  {
   outputline=StringConcatenate(DoubleToStr(NShoe+1,0),",E,",DoubleToStr(NShoe+1,0),",END");  
   FileWrite(OutputFilehandle,outputline);
  }
 }
 return;
}

//=========================================================================
string CheckShoe(int i)
{
 if(shoe[i]>0) return("P");
 else if(shoe[i]<0) return("T");
 else return("B");

 return("X");
}
//=========================================================================
void OpenFiles()
{
 string filename="Converted data.csv";
 OutputFilehandle=FileOpen(filename,FILE_CSV|FILE_WRITE|FILE_READ);
 
 return;
}
//=========================================================================
void CloseFiles()
{
 FileClose(OutputFilehandle);
 return;
}
//=========================================================================

