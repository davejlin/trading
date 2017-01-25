//+----------------------------------------------------------------------+
//|                                                      Bacc Tester.mq4 |
//|                                                         David J. Lin |
//|                                                                      |
//|                                                                      |
//| Coded by David J. Lin                                                |
//| dave.j.lin@gmail.com                                                 |
//| Evanston, IL, September 27, 2010                                     |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2010, David J. Lin"
#property link      ""
//=========================================================================
bool CountTies=false; // whether to include ties (Ties are deduced from total decisions for the overall statistics)
bool MavChart=true; // whether to analyze & output Mav Chart 
bool countFinalEvent=true; // whether to count the final (unconfirmed) final SAP/FOE event

int Nbatch=4;       // number of batches of shoes to test

int shoe[],shoeN[]; // shoe decisions & shoe number
int mav[]; // mav decisions
int sap[1,5],foe[1,5]; // SAP and FOE arrays
int FOER[30],FOEA[30],SAPP[30],SAPB[30]; // FOE & SAP counts
int FOER_Global[30],FOEA_Global[30],SAPP_Global[30],SAPB_Global[30]; // FOE & SAP counts global
int eventsMax=30; // maximum events number to track
int ot[]; // OTB4L vs TB4L array 
int cs[]; // chop vs streak (opposites vs. repeats) array

int n; // number of decisions
int NShoe; // total number of shoes
int NShoe_Global; // total number of shoes global
int R=0,A=0,P=0,B=0,T=0; // number of wins for RDH, Anti-RDH, Player, Banker, Ties
int R_Global=0,A_Global=0,P_Global=0,B_Global=0,T_Global=0; // number of wins for RDH, Anti-RDH, Player, Banker, Ties global
int OutputFilehandle; // handle for main output file 
int OutputFilehandle2; // handle for overall stats output file 
int OutputFilehandle3; // handle for global stats output file

int loop; // global loop for multiple files analysis
double totaldec; // total number of decisions in a the entire set of shoes, type double to calc ratio
double totaldec_Global; // total number of decisions in a the entire set of shoes, type double to calc ratio global 
//=========================================================================

int init()
{
 for(loop=1;loop<=Nbatch;loop++)
 {
  OpenFiles();
  Input(); 
  OverallStats();
  CloseFiles();  
 }
 OverallStats_Global();
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

 NShoe=0;totaldec=0;
 P=0;B=0;A=0;R=0;

 ArrayInitialize(SAPP,0);
 ArrayInitialize(SAPB,0);
 ArrayInitialize(FOER,0);
 ArrayInitialize(FOEA,0); 
 
 string filename=StringConcatenate(DoubleToStr(loop,0)," data.csv");

// int handle=FileOpen("Random Coin Flip 1000 data.csv",FILE_CSV|FILE_READ,','); // no shoe-number format 
// int handle=FileOpen("Wizard of Odds 8-deck 1000 500-1000 data.csv",FILE_CSV|FILE_READ,','); // no shoe-number format 
 int handle=FileOpen(filename,FILE_CSV|FILE_READ,',');  // Dave's virtual shoe files

 if(handle>0)
 {
  n=0;
  while(!exit)
  {
   shoenum=StrToInteger(FileReadString(handle)); // Zumma files
   data=FileReadString(handle);
   //if(data!="999") // random coin flip
   if(data!="END")
   {
    //if(n<72) // random coin flip 
    //if(data!="E") // no shoe-number format 
    if(lastshoenum==shoenum) // Zumma files
    {
     IncrementShoeArray(data,shoenum);
    }
    else 
    {
     MavAnalysis();
     EventsAnalysis();
     //Output();
     //data=FileReadString(handle); // if end of shoe line has line break 
     n=0;
     lastshoenum=shoenum;
     IncrementShoeArray(data,shoenum); // Zumma files
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
 n++;totaldec++;totaldec_Global++;

 ArrayResize(shoe,n);   
 if(data=="P") shoe[n-1]=1;
 else if(data=="B") shoe[n-1]=0;
 else if(data=="T") 
 {
  if(CountTies)
  {
   shoe[n-1]=-1;
  }
  else 
  {
   n--;
  }
 }
 ArrayResize(shoeN,n);
 shoeN[n-1]=shoenum;
 return;
}
//=========================================================================
void MavAnalysis()
{
 ArrayResize(mav,n);
 // 1 = RDH, 0 = Anti-RDH
 int i;

 if(shoe[0]==shoe[1]) mav[1]=1;
 else                 mav[1]=0;

 if(shoe[2]==shoe[1] && mav[1]==1) 
 {
  mav[0]=1;
  mav[2]=1;
 }
 else if(shoe[2]!=shoe[1] && mav[1]==1) 
 {
  mav[0]=1;
  mav[2]=0;
 }
 else if(shoe[2]==shoe[1] && mav[1]==0) 
 {
  mav[0]=0;
  mav[2]=0; 
 }
 else if(shoe[2]!=shoe[1] && mav[1]==0)
 {
  mav[0]=0;
  mav[2]=1;
 }
 
 for(i=3;i<n;i++)
 {
  if(shoe[i]==shoe[i-1]&&mav[i-1]==1) mav[i]=1;
  else if(shoe[i]!=shoe[i-1]&&mav[i-1]==1) mav[i]=0;
  else if(shoe[i]!=shoe[i-1]&&shoe[i-1]!=shoe[i-2]&&shoe[i-2]!=shoe[i-3]) mav[i]=1;
  else if(shoe[i]==shoe[i-1]&&shoe[i-1]!=shoe[i-2]&&shoe[i-2]==shoe[i-3]) mav[i]=1; 
  else if(shoe[i]==shoe[i-1]&&shoe[i-1]==shoe[i-2]) mav[i]=1; 
  else mav[i]=0;
 }
 return;
}
//=========================================================================
void EventsAnalysis()
{
 int FOECount=1,SAPCount=1,FOECurrent,SAPCurrent; // inter-shoe SAP and FOE global counts

 // sap and foe are the intra-shoe SAP and FOE arrays 
 // SAPP, SAPB, FOER, and FOEA are the inter-shoe SAP and FOE global counter arrays 
    
 ArrayResize(sap,n);
 ArrayResize(foe,n); 
 ArrayResize(cs,n); 
 ArrayResize(ot,n);

 SAPCurrent=shoe[0];
 FOECurrent=mav[1];  // don't count i=1 because mav[0]=mav[1] by default 
 
 for(int j=0;j<4;j++) // initialize SAP and FOE 1st element
 {
  sap[0,j]=0;
  foe[0,j]=0;
 }

 for(int i=1;i<n;i++)
 {  
  sap[i,0]=0; // reset 
  foe[i,0]=0; // reset 
  cs[i]=0;
  ot[i]=0;  

  for(j=1;j<5;j++) // transfer all intra-shoe SAP and FOE arrays forward 
  {
   sap[i,j]=sap[i-1,j];
   foe[i,j]=foe[i-1,j];
  }
 
  if(SAPCurrent==shoe[i])
  {
   SAPCount++;
  }
  else
  {
   if(SAPCurrent==1) {SAPP[SAPCount]++;SAPP_Global[SAPCount]++;}
   else              {SAPB[SAPCount]++;SAPB_Global[SAPCount]++;}

   EventsCounter(true,i,SAPCount);

   SAPCount=1; 
   SAPCurrent=shoe[i];
  }
  
  if(i>1) // don't count i=1 because mav[0]=mav[1] by default 
  {  
   if(FOECurrent==mav[i])
   {
    FOECount++;
   }
   else
   {
    if(FOECurrent==1) {FOER[FOECount]++;FOER_Global[FOECount]++;}
    else              {FOEA[FOECount]++;FOEA_Global[FOECount]++;}

    EventsCounter(false,i,FOECount);
     
    FOECount=1;
    FOECurrent=mav[i];

   }    
  }
     
  if(countFinalEvent)
  {  
   if(i==n-1) // final decision in shoe, so tally last event
   {
    if(SAPCurrent==1) {SAPP[SAPCount]++;SAPP_Global[SAPCount]++;}
    else              {SAPB[SAPCount]++;SAPB_Global[SAPCount]++;}    
    
    if(FOECurrent==1) {FOER[FOECount]++;FOER_Global[FOECount]++;}
    else              {FOEA[FOECount]++;FOEA_Global[FOECount]++;}      
   }
  }
  
  if(i>0)
  {
   if(shoe[i]==shoe[i-1]) cs[i]=0; // streak
   else                   cs[i]=1; // chop
  }

  if(i>1)
  {
   if(shoe[i]==shoe[i-2]) ot[i]=0; // TB4L
   else                   ot[i]=1; // OTB4L
  }

  
 }

 for(i=0;i<n;i++)
 {  
  if(shoe[i]==1) // PBT count
  {
   P++;
   P_Global++;
  }
  else if(shoe[i]==0)          
  {
   B++;   
   B_Global++;
  }
  else 
  {
   T++;
  }

  if(mav[i]==1) // RA count
  {
   R++;
   R_Global++;
  } 
  else if(mav[i]==0)
  {
   A++;
   A_Global++;
  }
 }

 NShoe++;
 NShoe_Global++;
 return;  
}
//=========================================================================
void EventsCounter(bool SAPFlag, int i, int count)
{
 if(SAPFlag) // SAP
 {
  sap[i,0]=1; // toggle
  switch(count)
  {
   case 1: sap[i,1]++; // 1s weight: 1
   break;
   case 2: sap[i,2]+=2; // 2s weight: 2  
   break;   
   case 3: sap[i,3]+=4; // 3s weight: 4 
   break;   
   default: sap[i,4]+=4; // 4+s weight: 4 
   break;   
  }
 }
 else // FOE
 {
  foe[i,0]=1; // toggle
  switch(count)
  {
   case 1: foe[i,1]++; // 1s weight: 1
   break;
   case 2: foe[i,2]+=2; // 2s weight: 2  
   break;   
   case 3: foe[i,3]+=4; // 3s weight: 4  
   break;   
   default: foe[i,4]+=4; // 4+s weight: 4 
   break;   
  } 
 }
 return;
}
//=========================================================================
void Output()
{
 string outputline,MavString,PBString,SAPString,FOEString,OTString,CSString;
 int i,rcount=0,acount=0,pcount=0,bcount=0,ocount=0,tcount=0,ccount=0,scount=0;

 
 if(OutputFilehandle>0)
 { 
  outputline=StringConcatenate("\nShoe Number: ",DoubleToStr(NShoe,0),"\n");
  FileWrite(OutputFilehandle,outputline);

  outputline=",,,,,,,F,O,E,,,S,A,P";
  FileWrite(OutputFilehandle,outputline);
  
  outputline="R,A,,P,B,,I,II,III,IV,,I,II,III,IV,,O,T,,C,S";
  FileWrite(OutputFilehandle,outputline);

  outputline="";
  FileWrite(OutputFilehandle,outputline);
    
  for(i=0;i<n;i++)
  {
   
   if(MavChart)
   {
    if(mav[i]==1) // RA count
    {
     rcount++;
     MavString=StringConcatenate(DoubleToStr(rcount,0),","," ");
//     MavString=StringConcatenate("R",","," ");     
    }
    else if(mav[i]==0)          
    {
     acount++;
     MavString=StringConcatenate(" ",",",DoubleToStr(acount,0));
//     MavString=StringConcatenate(" ",",","A");      
    }
    else MavString=StringConcatenate(" ",","," ");
   }

   if(shoe[i]==1) // PB count
   {
    pcount++;
    PBString=StringConcatenate(DoubleToStr(pcount,0),", ");    
//     PBString="P,";
   }
   else if(shoe[i]==0)          
   {
    bcount++;
    PBString=StringConcatenate(" ,",DoubleToStr(bcount,0));
//     PBString=",B";    
   }
   else 
   {
    PBString="T,T";
   }

   if(foe[i,0]==1) // FOE count
   {
    FOEString=StringConcatenate(DoubleToStr(foe[i,1],0),",",DoubleToStr(foe[i,2],0),",",DoubleToStr(foe[i,3],0),",",DoubleToStr(foe[i,4],0),",");
   }
   else FOEString=",,,,"; // to add buffer for SAP
    
   if(sap[i,0]==1) // SAP count
   {
    SAPString=StringConcatenate(DoubleToStr(sap[i,1],0),",",DoubleToStr(sap[i,2],0),",",DoubleToStr(sap[i,3],0),",",DoubleToStr(sap[i,4],0));
   }
   else SAPString=",,,";
        
   if(i>1) // OTB4L/TB4L count
   {
    if(ot[i]==0) 
    {
     tcount++;
     OTString=StringConcatenate(",",DoubleToStr(tcount,0));
    }
    else 
    {
     ocount++;
     OTString=StringConcatenate(DoubleToStr(ocount,0),",");      
    }
   }
   else OTString=",";
    
   if(i>0) // chop/streak count
   {
    if(cs[i]==0) 
    {
     scount++;
     CSString=StringConcatenate(",",DoubleToStr(scount,0));
    }
    else 
    {
     ccount++;
     CSString=StringConcatenate(DoubleToStr(ccount,0),",");      
    }
   }
  
   if(MavChart) outputline=StringConcatenate(MavString,",,",PBString,",,",FOEString,",",SAPString,",,",OTString,",,",CSString);

   FileWrite(OutputFilehandle,outputline);
  }

 }
 return;
}

//=========================================================================

void OverallStats()
{
 string outputstring;
 int i,total[30];
 double ratio;

 outputstring=StringConcatenate("Total Shoes: ",DoubleToStr(NShoe,0));
 FileWrite(OutputFilehandle2,outputstring);
 outputstring=StringConcatenate("Total P+B+T: ",DoubleToStr(totaldec,0));
 FileWrite(OutputFilehandle2,outputstring);
 ratio = P/totaldec;
 outputstring=StringConcatenate("Player wins: ",DoubleToStr(P,0)," ",DoubleToStr(ratio,6));
 FileWrite(OutputFilehandle2,outputstring);
 ratio = B/totaldec; 
 outputstring=StringConcatenate("Banker wins: ",DoubleToStr(B,0)," ",DoubleToStr(ratio,6));
 FileWrite(OutputFilehandle2,outputstring); 
 ratio = MathAbs(totaldec-P-B)/totaldec;  
 outputstring=StringConcatenate("Tie wins: ",DoubleToStr(MathAbs(totaldec-P-B),0)," ",DoubleToStr(ratio,6));
 FileWrite(OutputFilehandle2,outputstring); 
 outputstring=StringConcatenate("RDH wins: ",DoubleToStr(R,0));
 FileWrite(OutputFilehandle2,outputstring);
 outputstring=StringConcatenate("Anti-RDH wins: ",DoubleToStr(A,0));
 FileWrite(OutputFilehandle2,outputstring); 
 FileWrite(OutputFilehandle2," ");

 WriteOut(SAPP,"Total SAP P:, ",OutputFilehandle2);
 WriteOut(SAPB,"Total SAP B:, ",OutputFilehandle2);
 WriteOut(FOER,"Total FOE R:, ",OutputFilehandle2); 
 WriteOut(FOEA,"Total FOE A:, ",OutputFilehandle2); 

 for(i=1;i<eventsMax;i++) total[i]=SAPP[i]+SAPB[i];
 
 WriteOut(total,"Total SAP P+B:, ",OutputFilehandle2); 
 
 for(i=1;i<eventsMax;i++) total[i]=FOER[i]+FOEA[i];
 
 WriteOut(total,"Total FOE R+A:, ",OutputFilehandle2); 

 return;
}
//=========================================================================
void OverallStats_Global()
{
 string outputstring;
 int i,total[30];
 double ratio;

 string filename="Global Overall_Stats.csv";
 OutputFilehandle3=FileOpen(filename,FILE_CSV|FILE_WRITE); 

 outputstring=StringConcatenate("Total Shoes: ",DoubleToStr(NShoe_Global,0));
 FileWrite(OutputFilehandle3,outputstring);
 outputstring=StringConcatenate("Total P+B+T: ",DoubleToStr(totaldec_Global,0));
 FileWrite(OutputFilehandle3,outputstring);
 ratio = P_Global/totaldec_Global;
 outputstring=StringConcatenate("Player wins: ",DoubleToStr(P_Global,0)," ",DoubleToStr(ratio,6));
 FileWrite(OutputFilehandle3,outputstring);
 ratio = B_Global/totaldec_Global; 
 outputstring=StringConcatenate("Banker wins: ",DoubleToStr(B_Global,0)," ",DoubleToStr(ratio,6));
 FileWrite(OutputFilehandle3,outputstring); 
 ratio = MathAbs(totaldec_Global-P_Global-B_Global)/totaldec_Global;  
 outputstring=StringConcatenate("Tie wins: ",DoubleToStr(MathAbs(totaldec_Global-P_Global-B_Global),0)," ",DoubleToStr(ratio,6));
 FileWrite(OutputFilehandle3,outputstring); 
 outputstring=StringConcatenate("RDH wins: ",DoubleToStr(R_Global,0));
 FileWrite(OutputFilehandle3,outputstring);
 outputstring=StringConcatenate("Anti-RDH wins: ",DoubleToStr(A_Global,0));
 FileWrite(OutputFilehandle3,outputstring); 
 FileWrite(OutputFilehandle3," ");

 WriteOut(SAPP_Global,"Total SAP P:, ",OutputFilehandle3);
 WriteOut(SAPB_Global,"Total SAP B:, ",OutputFilehandle3);
 WriteOut(FOER_Global,"Total FOE R:, ",OutputFilehandle3); 
 WriteOut(FOEA_Global,"Total FOE A:, ",OutputFilehandle3); 

 for(i=1;i<eventsMax;i++) total[i]=SAPP_Global[i]+SAPB_Global[i];
 
 WriteOut(total,"Total SAP P+B:, ",OutputFilehandle3); 
 
 for(i=1;i<eventsMax;i++) total[i]=FOER_Global[i]+FOEA_Global[i];
 
 WriteOut(total,"Total FOE R+A:, ",OutputFilehandle3); 

 FileClose(OutputFilehandle3); 

 return;
}
//=========================================================================
void WriteOut(int array[],string title, int filehandle)
{
 string outputstring;
 double sum,ratio; 
 int i;

 sum=0;
 for(i=1;i<eventsMax;i++)
 {
  sum+=array[i]; 
 }

 FileWrite(filehandle,""); 

 for(i=1;i<eventsMax;i++)
 {
  if(i==1) ratio=array[i]/MathMax(sum,1);
  else     ratio=array[i]/MathMax(array[i-1],1);
  outputstring=StringConcatenate(DoubleToStr(i,0),"s:, ",DoubleToStr(array[i],0),",",DoubleToStr(ratio,6));
  FileWrite(filehandle,outputstring);
 }
 
 outputstring=StringConcatenate(title,DoubleToStr(sum,0));
 FileWrite(filehandle,outputstring);

 return;
}
//=========================================================================
void OpenFiles()
{
 string filename=StringConcatenate(DoubleToStr(loop,0)," Main_Output.csv");
 OutputFilehandle=FileOpen(filename,FILE_CSV|FILE_WRITE|FILE_READ);

 filename=StringConcatenate(DoubleToStr(loop,0)," Overall_Stats.csv");
 OutputFilehandle2=FileOpen(filename,FILE_CSV|FILE_WRITE);  

 return;
}
//=========================================================================
void CloseFiles()
{
 FileClose(OutputFilehandle);
 FileClose(OutputFilehandle2);
 return;
}
//=========================================================================

