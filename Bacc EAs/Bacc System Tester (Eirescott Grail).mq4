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

bool flagChart=false; // whether to print out the full charts 
bool flagStats=false; // whether to print out chart stats
bool flagShoesScores=true; // whether to print out shoes vs scores stats
bool flagOverallStats=false; // whether to print out overall stats per batch of shoes
                             // note: global overall stats are always printed out
bool flagDebug=false; // whether to print out debug file

bool PBRAMode=true; // PB or RA mode: true = PB, false = RA

bool flagMM[2]={false,true}; // whether to use money management (stop loss, decade MM, halfwaypoint, practicalstoppoint)
bool flagDecadeMM[2]={false,true}; // whether to use decade money management (for every +10u won, trail stop by 10u) 

int StopLoss=-20;   // number of units to stop shoe & declare loss
int Nbatch=13;       // number of batches of shoes to test

int shoe[],shoeN[]; // shoe decisions & shoe number
int mav[]; // mav decisions
int sap[1,5],foe[1,5]; // SAP and FOE arrays

int ot[]; // P/B OTB4L vs TB4L array
int cs[]; // P/B chop vs streak (opposites vs. repeats) array

int mavmav[]; // P/B mav of mav decisions
int mavcs[]; // P/B chop vs streak (opposites vs. repeats) array

int value[]; // holds the PB or RA array values depending on PBRAMode
int mavarray[]; // holds the mav or mavmav array values depending on PBRAMode
int csarray[]; // holds the cs or mavcs array values depending on PBRAMode
int eventsarray[1,5]; // holds sap or foe array values depending on PBRAMode
int RAModeXtra; // extra decision to skip at game start depending on PBRAMode

int n; // number of decisions
int NShoe; // total number of shoes per set
int NShoe_Global; // total number of shoes global

int OutputFilehandle; // handle for chart output file 
int OutputFilehandle2; // handle for stats output file 
int OutputFilehandle3; // handle for overall stats output file
int OutputFilehandle4; // handle for global stats output file
int OutputFilehandle5; // handle for score vs shoes output file
int OutputFilehandle6; // handle for score vs shoes output file truncated
int OutputFilehandle7; // handle for debugging file 

int loop; // global loop for multiple files analysis
int loopMM; // global loop for multiple money management analysis
double totaldec; // total number of decisions in a the entire set of shoes, type double to calc ratio
double totaldec_Global; // total number of decisions in a the entire set of shoes, type double to calc ratio global 

int net[]; // total score per decision
int betP[],betB[]; // bets
int win[3,2],loss[3,2]; // number of wins and losses for P and B bets per shoe 
                        // 1st index: 0=shoe,1=overall set of shoes,2=global overall
                        // 2nd index: 0=P,1=B
int winwager[3,2],losswager[3,2]; // wagers of wins and losses for P and B bets per shoe
                        // 1st index: 0=shoe,1=overall set of shoes,2=global overall
                        // 2nd index: 0=P,1=B
int Bwin[3],Bwinwager[3]; // number of Banker wins for proper commish in RA mode 
                          // 1st index: 0=shoe,1=overall set of shoes,2=global overall
int wager=1; // value of wager
double cumulativenumber=0; // cumulative net score
double cumulativewager=0;  // cumulative net wager
int worst[2];// tracks worst drawdown score in a shoe
             // index: 0=value of score, 1=corresponding shoe number
int best[2]; // tracks best peak score in a shoe
             // index: 0=value of score, 1=corresponding shoe number
int shoeresults[3]; // number of wins (index=0), losses (index=1), and break-evens (index=2)

int shoescoresSpacing=25; // print out shoes vs score for every number of Spacing to truncate the list for spreadsheet compatibility
int shoescorescount=0;    // count for output shoe vs score
int stop; // index to carry the stop loss paramater
int decadeMM=1;           // index to keep track of current decade in decade money management
int decadeMMless=5;       // units less than current decade in decade money management to stop out (for example, if decadeMMxtra=5, then once profit hits 10u it will stop out at 10-5=5u)
int halfwaypoint[2]={1000,40};       // decision number to check halfwaypoint score
int halfwayscore=12;       // score at halfwaypoint should be above this or else quit
int practicalstoppoint[2]={1000,60}; // decision number to stop playing (Mark's practical stop point 
string filenameMM[2]={"Scott Grail no MM","Scott Grail full MM"}; // file name prefixes for MM loop

bool OTTmode; // OTB4L/TB4L mode flag, keeps track of OT or T mode for OTT method, true=OT, false=T
int Fmode; // Fn mode flag, keeps track of which side F is currently acting upon (-1: none, 0: B or A, 1: P or R)
int stopbetting[5]={0,0,100,5,5}; // array to hold run lengths to stop betting for System 40E (Ellis' version)
int cscount=0; // current chop/streak count (opposite/repeat)
int prefab[][4]; // 4 pre-fab sets for Scott's Grail
int masterset[8]={1,2,3,4,5,6,7,8}; // master set of 8 groups of 3
int grailsets[][7]; // group numbers of the grail sets per line of tries, starting with 4 prefab sets, maximum 3 more sets from actual decisions, don't need to store 7th set
bool grailnobet; // flag to stop betting in Scott's Grail method: stop after winning or matching sets
//=========================================================================
 
int init()
{
 for(loopMM=0;loopMM<2;loopMM++)
 {
  GlobalOpenFiles();
  Initialize(2); // global initialize  
  for(loop=1;loop<=Nbatch;loop++)
  {
   OpenFiles();
   Initialize(1); // local initialize
   Input(); 
   if(flagOverallStats) OverallStats();
   CloseFiles();  
  }
  OverallStats_Global();
  GlobalCloseFiles();
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
//=========================================================================
void Initialize(int index)
{
 wager=1;decadeMM=1;stop=StopLoss;
 OTTmode=true;
 Fmode=-1;
  
 for(int i=0;i<=index;i++) // clear the win/loss tracking arrays 
 {
  for(int j=0;j<=1;j++)
  {
   win[i,j]=0;
   loss[i,j]=0;
   winwager[i,j]=0;
   losswager[i,j]=0;
  }
  
  Bwin[i]=0;
  Bwinwager[i]=0;

 }
 
 if(index==1)
 {
  NShoe=0;
  MathSrand(TimeLocal()+(loop-1)*NShoe_Global);
 }

 if(index==2)
 {
  cumulativenumber=0;
  cumulativewager=0;
  NShoe_Global=0;

  for(i=0;i<=1;i++) // clear the best/worst tracking arrays 
  {
   best[i]=0;
   worst[i]=0;  
  }

  for(i=0;i<=2;i++) // clear the shoe results tracking arrays 
  {  
   shoeresults[i]=0;
  }
 }
 return;
}
//=========================================================================
void Input()
{
 string data;
 bool exit=false;
 int shoenum,lastshoenum=1;
 
 string filename=StringConcatenate(DoubleToStr(loop,0)," data.csv");
 int handle=FileOpen(filename,FILE_CSV|FILE_READ,',');

 if(handle>0)
 {
  n=0;
  while(!exit)
  {
   shoenum=StrToInteger(FileReadString(handle));
   data=FileReadString(handle);
   if(data!="END")
   {
    if(lastshoenum==shoenum)
    {
     IncrementShoeArray(data,shoenum);
    }
    else 
    {
     MavAnalysis();
     EventsAnalysis();
     AssignArrays();
     System();
     if(flagChart) OutputCharts();
     if(flagStats) OutputStats();   
     if(flagShoesScores) OutputShoesScores();    
     if(flagDebug) OutputDebug();   
     BestWorst();
     n=0;    
     Initialize(0);
     lastshoenum=shoenum;
     IncrementShoeArray(data,shoenum);
    }
   }
   else exit=true;
  }
 }

 FileClose(handle);  

 return;
}

//=========================================================================
void IncrementShoeArray(string data, int shoenum) // P=1, B=0
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
// For Mav of P/B:
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

// For Mav of Mav:
 ArrayResize(mavmav,n);
 // 1 = RDH mav, 0 = Anti-RDH mav

 if(mav[0]==mav[1]) mavmav[1]=1;
 else                 mavmav[1]=0;

 if(mav[2]==mav[1] && mavmav[1]==1) 
 {
  mavmav[0]=1;
  mavmav[2]=1;
 }
 else if(mav[2]!=mav[1] && mavmav[1]==1) 
 {
  mavmav[0]=1;
  mavmav[2]=0;
 }
 else if(mav[2]==mav[1] && mavmav[1]==0) 
 {
  mavmav[0]=0;
  mavmav[2]=0; 
 }
 else if(mav[2]!=mav[1] && mavmav[1]==0)
 {
  mavmav[0]=0;
  mavmav[2]=1;
 }
 
 for(i=3;i<n;i++)
 {
  if(mav[i]==mav[i-1]&&mavmav[i-1]==1) mavmav[i]=1;
  else if(mav[i]!=mav[i-1]&&mavmav[i-1]==1) mavmav[i]=0;
  else if(mav[i]!=mav[i-1]&&mav[i-1]!=mav[i-2]&&mav[i-2]!=mav[i-3]) mavmav[i]=1;
  else if(mav[i]==mav[i-1]&&mav[i-1]!=mav[i-2]&&mav[i-2]==mav[i-3]) mavmav[i]=1; 
  else if(mav[i]==mav[i-1]&&mav[i-1]==mav[i-2]) mavmav[i]=1; 
  else mavmav[i]=0;
 }
 
 return;
}
//=========================================================================
void EventsAnalysis()
{
 int FOECount=1,SAPCount=1,FOECurrent,SAPCurrent; // inter-shoe SAP and FOE global counts

 // sap and foe are the intra-shoe SAP and FOE arrays 
    
 ArrayResize(sap,n);
 ArrayResize(foe,n); 
 ArrayResize(cs,n); 
 ArrayResize(ot,n);
 
 ArrayResize(mavcs,n); 

 SAPCurrent=shoe[0];
 FOECurrent=mav[1];  // don't count i=1 because mav[0]=mav[1] by default 
 
 for(int j=0;j<5;j++) // initialize SAP and FOE 1st element
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
  
  mavcs[i]=0;

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
   EventsCounter(true,i,SAPCount);

   SAPCount=1; 
   SAPCurrent=shoe[i];
  }
  
  if(i>1)  // don't count i=1 because mav[0]=mav[1] by default 
  {  
   if(FOECurrent==mav[i])
   {
    FOECount++;
   }
   else
   {
    EventsCounter(false,i,FOECount);
     
    FOECount=1;
    FOECurrent=mav[i];
   }
   
  }    
  
  if(i>0)
  {
   if(shoe[i]==shoe[i-1]) cs[i]=-1; // PB streak
   else                   cs[i]=1; // PB chop

   if(mav[i]==mav[i-1]) mavcs[i]=-1; // RA streak
   else                 mavcs[i]=1; // RA chop
   
  }

  if(i>1)
  {
   if(shoe[i]==shoe[i-2]) ot[i]=0; // TB4L
   else                   ot[i]=1; // OTB4L
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
void OutputCharts()
{
 string outputline,MavString,PBString,SAPString,FOEString,OTString,CSString;
 int i,rcount=0,acount=0,pcount=0,bcount=0,ocount=0,tcount=0,ccount=0,scount=0;

 string ScoreP,ScoreB,ScoreString;
 
 if(OutputFilehandle>0)
 { 
  outputline=StringConcatenate("\nShoe Number: ",DoubleToStr(NShoe,0),"\n");
  FileWrite(OutputFilehandle,outputline);

  outputline=",,,,,,,,,,,F,O,E,,,S,A,P";
  FileWrite(OutputFilehandle,outputline);
  
  outputline="R,A,,P,B,,PS,BS,S,,I,II,III,IV,,I,II,III,IV,,O,T,,C,S";
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
    if(cs[i]<0) 
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
  
   if(betP[i]!=0) ScoreP=DoubleToStr(betP[i],0);
   else           ScoreP="";
   
   if(betB[i]!=0) ScoreB=DoubleToStr(betB[i],0);
   else           ScoreB="";     
     
   ScoreString=StringConcatenate(ScoreP,",",ScoreB,",",DoubleToStr(net[i],0));
  
   if(MavChart) outputline=StringConcatenate(MavString,",,",PBString,",,",ScoreString,",,",FOEString,",",SAPString,",,",OTString,",,",CSString);
   else outputline=StringConcatenate(PBString,",,",",,",ScoreString,",,",SAPString,",,",OTString,",,",CSString);
 
   FileWrite(OutputFilehandle,outputline);
  }

 }
 return;
}
//=========================================================================
void OutputStats()
{
 string outputstring;
 int i;
 double ratio,totalwin,totalloss,total;

// Stats per shoe:
 
 outputstring=StringConcatenate("\nShoe Number: ",DoubleToStr(NShoe,0),"\n");
 FileWrite(OutputFilehandle2,outputstring);

 WriteOut("Number ",win,loss,0,OutputFilehandle2);
 WriteOut("Wager ",winwager,losswager,0,OutputFilehandle2); 
 WriteOutPA(0,OutputFilehandle2);

 return;
}
//=========================================================================
void OutputShoesScores() // Score vs. Shoes:
{
 WriteOutPA(0,OutputFilehandle5,false);
 
 shoescorescount++; 
 if(shoescorescount==shoescoresSpacing) // for truncated score vs shoe output 
 {
  WriteOutPA(0,OutputFilehandle6,false);
  shoescorescount=0;
 }

 return;
}
//=========================================================================
void OutputDebug() // Score vs. Shoes:
{
 static string decisionstring,betstring;
 string outputstring=StringConcatenate("Batch: ",DoubleToStr(loop,0)," Shoe: ",DoubleToStr(NShoe,0),"\n");
 FileWrite(OutputFilehandle7,outputstring); 

 int i,j;
 for(i=0;i<n;i++)
 {
  outputstring=DoubleToStr(i+1,0); 
// Scott's Grail:
  //for(j=0; j<4; j++) outputstring=StringConcatenate(outputstring," ",DoubleToStr(prefab[i,j],0));
//  for(j=0; j<4; j++) outputstring=StringConcatenate(outputstring," ",convertSettoString(prefab[i,j]));

//  if(i%3==0) decisionstring=StringConcatenate(decisionstring," "); // space every 3rd hand for groupings
//  if(i%9==0) decisionstring=convertDectoString(value[i]); // every 9 hands (4 sets of 3)
//  else       decisionstring=StringConcatenate(decisionstring,convertDectoString(value[i]));

// Scott7 Grail:
  for(j=0; j<7; j++) outputstring=StringConcatenate(outputstring," ",convertSettoString(grailsets[i,j]));

  if(i%3==0) decisionstring=convertDectoString(value[i]); // every 3rd hand
  else       decisionstring=StringConcatenate(decisionstring,convertDectoString(value[i]));

 
  if(betP[i]!=0)      betstring=DoubleToStr(betP[i],0);
  else if(betB[i]!=0) betstring=DoubleToStr(betB[i],0);
  else                betstring="";
 
  outputstring=StringConcatenate(outputstring," ",decisionstring," ",betstring);
  FileWrite(OutputFilehandle7,outputstring); 
 }

 outputstring="\n";
 FileWrite(OutputFilehandle7,outputstring); 
 return;
}
//=========================================================================
void OverallStats()
{
 string outputstring;
 int i;

 outputstring=StringConcatenate("Total Shoes: ",DoubleToStr(NShoe,0));
 FileWrite(OutputFilehandle3,outputstring);

 WriteOut("Number ",win,loss,1,OutputFilehandle3);
 WriteOut("Wager ",winwager,losswager,1,OutputFilehandle3); 
 WriteOutPA(1,OutputFilehandle3);
 return;
}
//=========================================================================
void OverallStats_Global()
{
 string outputstring,spreadsheetstring,spreadsheetstring1,spreadsheetstring2,spreadsheetstring3;
 int i;
 double ratio,totalwin,totalloss,total;

 string filename=StringConcatenate(filenameMM[loopMM]," Global Overall_Stats.csv");
 OutputFilehandle4=FileOpen(filename,FILE_CSV|FILE_WRITE); 

 outputstring=StringConcatenate("Total Shoes: ",DoubleToStr(NShoe_Global,0));
 FileWrite(OutputFilehandle4,outputstring);

 spreadsheetstring1=WriteOut("Number ",win,loss,2,OutputFilehandle4);
 spreadsheetstring2=WriteOut("Wager ",winwager,losswager,2,OutputFilehandle4); 
 spreadsheetstring3=WriteOutPA(2,OutputFilehandle4);

 spreadsheetstring=StringConcatenate(spreadsheetstring3,",",spreadsheetstring1,",",spreadsheetstring2);
 
 outputstring=StringConcatenate("\nBest score: ",DoubleToStr(best[0],0)," in shoe number: ",DoubleToStr(best[1],0));
 FileWrite(OutputFilehandle4,outputstring);
 
 outputstring=StringConcatenate("Worst score: ",DoubleToStr(worst[0],0)," in shoe number: ",DoubleToStr(worst[1],0));
 FileWrite(OutputFilehandle4,outputstring);

 total=NShoe_Global; // need to convert to double for the ratio calc
 ratio=Divide(shoeresults[0],total);
 outputstring=StringConcatenate("\nShoes Won: ",DoubleToStr(shoeresults[0],0)," ",DoubleToStr(ratio,6));
 FileWrite(OutputFilehandle4,outputstring);

 spreadsheetstring=StringConcatenate(spreadsheetstring,",",DoubleToStr(shoeresults[0],0),",",DoubleToStr(ratio,6));

 ratio=Divide(shoeresults[1],total);
 outputstring=StringConcatenate("Shoes Lost: ",DoubleToStr(shoeresults[1],0)," ",DoubleToStr(ratio,6));
 FileWrite(OutputFilehandle4,outputstring);

 spreadsheetstring=StringConcatenate(spreadsheetstring,",",DoubleToStr(shoeresults[1],0),",",DoubleToStr(ratio,6));
 
 ratio=Divide(shoeresults[2],total);
 outputstring=StringConcatenate("Shoes Broke Even: ",DoubleToStr(shoeresults[2],0)," ",DoubleToStr(ratio,6));
 FileWrite(OutputFilehandle4,outputstring); 

 spreadsheetstring=StringConcatenate(spreadsheetstring,",",DoubleToStr(shoeresults[2],0),",",DoubleToStr(ratio,6));
 spreadsheetstring=StringConcatenate("\n",spreadsheetstring,",",DoubleToStr(best[0],0),",",DoubleToStr(best[1],0),",",DoubleToStr(worst[0],0),",",DoubleToStr(worst[1],0));

 FileWrite(OutputFilehandle4,spreadsheetstring); 
 
 FileClose(OutputFilehandle4); 

 return;
}

//=========================================================================
string WriteOut(string title, int arraywin[][], int arrayloss[][], int j, int handle)
{
 string outputstring, returnstring;
 int i;
 double ratio,totalwin,totalloss,total;
 
 totalwin=arraywin[j,0]+arraywin[j,1];
 totalloss=arrayloss[j,0]+arrayloss[j,1];
 total=totalwin-totalloss;

 outputstring=StringConcatenate(title,DoubleToStr(total,0),"\n");
 FileWrite(handle,outputstring);

 ratio=Divide(totalwin,totalwin+totalloss);
 outputstring=StringConcatenate(title," Wins : ",DoubleToStr(totalwin,0)," ",DoubleToStr(ratio,6));
 FileWrite(handle,outputstring);

 returnstring=StringConcatenate(DoubleToStr(total,0),",",DoubleToStr(totalwin,0),",",DoubleToStr(ratio,6));

 ratio=Divide(totalloss,totalwin+totalloss);
 outputstring=StringConcatenate(title," Loss : ",DoubleToStr(totalloss,0)," ",DoubleToStr(ratio,6),"\n");
 FileWrite(handle,outputstring); 

 returnstring=StringConcatenate(returnstring,",",DoubleToStr(totalloss,0),",",DoubleToStr(ratio,6));
 
 ratio=Divide(arraywin[j,0],totalwin);
 outputstring=StringConcatenate(title," Player Wins : ",DoubleToStr(arraywin[j,0],0)," ",DoubleToStr(ratio,6));
 FileWrite(handle,outputstring);

 returnstring=StringConcatenate(returnstring,",",DoubleToStr(arraywin[j,0],0),",",DoubleToStr(ratio,6));

 ratio=Divide(arraywin[j,1],totalwin);
 outputstring=StringConcatenate(title," Banker Wins : ",DoubleToStr(arraywin[j,1],0)," ",DoubleToStr(ratio,6),"\n");
 FileWrite(handle,outputstring); 

 returnstring=StringConcatenate(returnstring,",",DoubleToStr(arraywin[j,1],0),",",DoubleToStr(ratio,6));

 ratio=Divide(arrayloss[j,0],totalloss);
 outputstring=StringConcatenate(title," Player Loss : ",DoubleToStr(arrayloss[j,0],0)," ",DoubleToStr(ratio,6));
 FileWrite(handle,outputstring);

 returnstring=StringConcatenate(returnstring,",",DoubleToStr(arrayloss[j,0],0),",",DoubleToStr(ratio,6));

 ratio=Divide(arrayloss[j,1],totalloss);
 outputstring=StringConcatenate(title," Banker Loss : ",DoubleToStr(arrayloss[j,1],0)," ",DoubleToStr(ratio,6),"\n");
 FileWrite(handle,outputstring); 

 returnstring=StringConcatenate(returnstring,",",DoubleToStr(arrayloss[j,1],0),",",DoubleToStr(ratio,6));

 return(returnstring);
}
//=========================================================================
string WriteOutPA(int j, int handle, bool flag=true)
{
 double ratio,ratiowager;
 double totalwin,totalloss,total;
 double totalwinwager,totallosswager,totalwager;
 double windouble,winwagerdouble;
 double commish,commishwager;
 string outputstring,returnstring;

 windouble=Bwin[j];
 winwagerdouble=Bwinwager[j];

 commish=0.05*windouble;
 commishwager=0.05*winwagerdouble; 

 totalwin=win[j,0]+win[j,1];
 totalloss=loss[j,0]+loss[j,1];
 total=totalwin-totalloss-commish; // adjust for Banker's commissions
 
 totalwinwager=winwager[j,0]+winwager[j,1];
 totallosswager=losswager[j,0]+losswager[j,1];
 totalwager=totalwinwager-totallosswager-commishwager;

 ratio= Divide(total,totalwin+totalloss);
 ratiowager= Divide(totalwager,totalwinwager+totallosswager);
 
 if(flag) // P.A. reporting for overall & global stats:
 {
  outputstring=StringConcatenate("Net Number after commish: ",DoubleToStr(total,2),"  P.A.: ",DoubleToStr(ratio,6),"\nNet Wager after commish: ",DoubleToStr(totalwager,2)," P.A.: ",DoubleToStr(ratiowager,6));
  returnstring=StringConcatenate(DoubleToStr(total,2),",",DoubleToStr(ratio,6),",",DoubleToStr(totalwager,2),",",DoubleToStr(ratiowager,6));
 }
 else  // Score vs Shoe tally
 {
  cumulativenumber+=total;
  cumulativewager+=totalwager; 
  outputstring=StringConcatenate(DoubleToStr(NShoe_Global,0),",",DoubleToStr(total,2),",",DoubleToStr(ratio,6),",",DoubleToStr(cumulativenumber,2),",",DoubleToStr(totalwager,2),",",DoubleToStr(ratiowager,6),",",DoubleToStr(cumulativewager,2));
 }
 
 FileWrite(handle,outputstring);
 return(returnstring);
}
//=========================================================================
void OpenFiles()
{
 string filename;
 
 if(flagChart) 
 {
  filename=StringConcatenate(filenameMM[loopMM]," ",DoubleToStr(loop,0)," Charts.csv");
  OutputFilehandle=FileOpen(filename,FILE_CSV|FILE_WRITE|FILE_READ);
 }

 if(flagStats)
 {
  filename=StringConcatenate(filenameMM[loopMM]," ",DoubleToStr(loop,0)," Stats.csv");
  OutputFilehandle2=FileOpen(filename,FILE_CSV|FILE_WRITE);  
 }
 
 if(flagOverallStats)
 {
  filename=StringConcatenate(filenameMM[loopMM]," ",DoubleToStr(loop,0)," Overall Stats.csv");
  OutputFilehandle3=FileOpen(filename,FILE_CSV|FILE_WRITE); 
 } 
 return;
}
//=========================================================================
void GlobalOpenFiles()
{
 string filename;

 if(flagShoesScores)
 {
  filename=StringConcatenate(filenameMM[loopMM]," Score vs Shoes.csv");
  OutputFilehandle5=FileOpen(filename,FILE_CSV|FILE_WRITE|FILE_READ); 

  filename=StringConcatenate(filenameMM[loopMM]," Score vs Shoes truncated.csv");
  OutputFilehandle6=FileOpen(filename,FILE_CSV|FILE_WRITE|FILE_READ); 
 }
 
 if(flagDebug)
 {
  filename=StringConcatenate(filenameMM[loopMM]," Debug.csv");
  OutputFilehandle7=FileOpen(filename,FILE_CSV|FILE_WRITE|FILE_READ);  
 } 
 return;
}
//=========================================================================
void CloseFiles()
{
 if(flagChart) FileClose(OutputFilehandle);
 if(flagStats) FileClose(OutputFilehandle2);
 if(flagOverallStats) FileClose(OutputFilehandle3); 
 return;
}
//=========================================================================
void GlobalCloseFiles()
{
 if(flagShoesScores) 
 {
  FileClose(OutputFilehandle5); 
  FileClose(OutputFilehandle6);    
 }
 
 if(flagDebug) FileClose(OutputFilehandle7); 

 return;
}
//=========================================================================
void AssignArrays()
{
 MathSrand((loop*10000)+NShoe); // for Scott's Grail: unique prefabs per shoe, but uniform per overall run for comparison
 ArrayResize(prefab,n); // Scott's Grail
 ArrayResize(grailsets,n); // Scott's Grail 

 ArrayResize(betP,n);
 ArrayResize(betB,n); 
 ArrayResize(net,n); 

 ArrayResize(value,n); 
 ArrayResize(csarray,n); 
 ArrayResize(mavarray,n); 

 cscount=0;

 if(PBRAMode) // PB
 {
  ArrayCopy(value,shoe);
  ArrayCopy(mavarray,mav);   
  ArrayCopy(csarray,cs);  
  ArrayCopy(eventsarray,sap);   
  RAModeXtra=0; 
 }
 else  // RA
 {
  ArrayCopy(value,mav); 
  ArrayCopy(mavarray,mavmav);   
  ArrayCopy(csarray,mavcs);
  ArrayCopy(eventsarray,foe);   
  RAModeXtra=1; 
 }
 return;
}
//=========================================================================
void System()
{
 int target; // target 1=P, 0=B

// Eirescott's Birthday Paradox Grail, start at i=0
 for(int i=0;i<n;i++)
 {
  betP[i]=0;
  betB[i]=0;
  net[i]=0;  
  //target=ScottGrail(i);
  target=Scott7Grail(i);
  CheckTarget(target,i);   
 }
 
// for(int i=1;i<n;i++)
// {
//  betP[i]=0;
//  betB[i]=0;
//  net[i]=0; 
 
//  cscount+=csarray[i];

// System 40
//  target=System40(i);
  
// Random coin flip betting
//  target=random(1.999999);

// Fn (n=2 for original F2 by Ellis, including the min 3 bets per side
//  target=Fn(i,3);

// RDn (n=2 for original RD1/RD2 by Ellis, including the 1,2 rule)
//  target=RDn(i,3);

// TB4L
//   target=Repeat(i,2);
 
// OTB4L
//   target=Opposite(i,2);  

// OTT Strategy (OT until 2 loss, then T until 1 loss)
//  target=OTT(i,2,1);

// Player Banker Only 
//  target=0; // Banker only, Anti-RDH only  
//  target=1; // Player only, RDH only

// Repeat 
//  target=Repeat(i);

// Opposite
//  target=Opposite(i);  
  
// Repeat and go Opposite if last two were Opposite
//  target=RepeatOpposite(i); 
  
//  CheckTarget(target,i);   
// }
 return;
}
//=========================================================================
int Scott7Grail(int i)
{
 int r,j,target;
 int groupsection,matchtimes,matchj;
 static int numbergrailsets;

 if(i%3==0) // every 3 hands (7 sets of 3)
 {
  Shuffle();
  numbergrailsets=7;
  for(j=0;j<numbergrailsets;j++)
  {
   grailsets[i,j]=masterset[r+j];
  }
 }
 else
 {
  for(j=0;j<numbergrailsets;j++) grailsets[i,j]=grailsets[i-1,j]; // transfer info forward
 } 
 
 if(i%3==2) // make bet only on 3rd decision
 {
  groupsection=checkGrailSection(value[i-2],value[i-1]);

  matchtimes=0;
  matchj=0;
  for(j=0;j<numbergrailsets;j++)
  {
   if(groupsection==checkSetsSection(grailsets[i,j]))
   {
    matchtimes++;
    matchj=j;
   }
  }
  
  if(matchtimes==1) //unambiguous
  {
   target=check3rdDecision(grailsets[i,matchj]);
  }
  else target=999;
 }
 else target=999;

 //string outputstring=StringConcatenate("Batch: ",DoubleToStr(loop,0)," Shoe: ",DoubleToStr(NShoe,0)," i: ",DoubleToStr(i,0)," numbergrailsets: ",DoubleToStr(numbergrailsets,0)," newgrailset: ",DoubleToStr(newgrailset,0)," grailnobet: ",DoubleToStr(grailnobet,0)," j: ",DoubleToStr(j,0),"\n");
 //FileWrite(OutputFilehandle7,outputstring); 

 return(target);
}
//=========================================================================
int ScottGrail(int i)
{
 int r,j,target;
 int groupsection,matchtimes,matchj;
 static int numbergrailsets;

 if(i%9==0) // every 9 hands (4 sets of 3)
 {
  Shuffle();
  numbergrailsets=4;
  grailnobet=false;  
  r=random(4.999999); // choose a random array position from which to take values from the shuffled masterset array 

  for(j=0;j<numbergrailsets;j++)
  {
   prefab[i,j]=masterset[r+j];
   grailsets[i,j]=prefab[i,j]; // add to the grailsets
  }

 }
 else 
 {
  for(j=0;j<4;j++) prefab[i,j]=prefab[i-1,j]; // transfer info forward
 }
 
 if(i%3==2) // make bet only on 3rd decision
 {
  groupsection=checkGrailSection(value[i-2],value[i-1]);

  matchtimes=0;
  matchj=0;
  for(j=0;j<numbergrailsets;j++)
  {
   if(groupsection==checkSetsSection(grailsets[i,j]))
   {
    matchtimes++;
    matchj=j;
   }
  }
  
  if(grailnobet) target=999;
  else if(matchtimes==1) //unambiguous
  {
   target=check3rdDecision(grailsets[i,matchj]);
  }
  else target=999;
 }
 else target=999;

// add new grailset at the end of 3rd decision:

 if(i%9!=0 && i%3==0) // add a new grailset after every 3rd decision, no need when first one of each 9 (when you start over with a new grailset)
 {
  numbergrailsets++;
  int newgrailset=findGrailset(i);  
  grailsets[i,numbergrailsets-1]=newgrailset;

  for(j=0;j<numbergrailsets-1;j++) // check if new set repeats any existing ones: if so, stop betting
  {
   if(newgrailset==grailsets[i,j]) 
   {
    grailnobet=true;
    break;
   }
  }

 //string outputstring=StringConcatenate("Batch: ",DoubleToStr(loop,0)," Shoe: ",DoubleToStr(NShoe,0)," i: ",DoubleToStr(i,0)," numbergrailsets: ",DoubleToStr(numbergrailsets,0)," newgrailset: ",DoubleToStr(newgrailset,0)," grailnobet: ",DoubleToStr(grailnobet,0)," j: ",DoubleToStr(j,0),"\n");
 //FileWrite(OutputFilehandle7,outputstring); 
  
 }

 return(target);
}
//=========================================================================
int System40(int i)
{
 if(i<1+RAModeXtra) return(999);
   
 int target; string modestring;

 int runlength=countRunLength(i);
 int eventsLC=countEventsLC(i);
 
 if(cscount>=0) // choppy conditions: use System 40
 {
  if(runlength>=eventsLC) 
  {
   if(runlength<stopbetting[eventsLC]) target=Repeat(i); // OTR if events bigger than LC, 2s: don't stop, 3s: stop after 2 (5-in-a-row), 4s: stop after 1 (5-in-a-row)
   else target=999; // stop betting OTR after a certain number
  }
  else target=Opposite(i); 
  
  modestring="Sys40";
 }
 else // streaky conditions: use RD or F
 {
  double benchmark=MathFloor(0.25*(i-1)); // benchmark SAP/FOE value

  if(eventsarray[i-1,1]<=benchmark) 
  {
   target=RDn(i,2); // RD12 for low 1s
   modestring="RD12";
  }
  else // F-series
  {
   if(eventsLC==3) 
   {
    target=Fn(i,3); // F3 if 3s are LC
    modestring="F3";
   }
   else            
   {
    target=Fn(i,2);
    modestring="F2";
   }
  }
 }
 
 //string outputstring=StringConcatenate(DoubleToStr(NShoe,0),",",DoubleToStr(i,0),",",modestring);
 //FileWrite(OutputFilehandle7,outputstring);

 return(target);
}
//=========================================================================
int Fn(int i, int j=2, int k=3) // Ellis' original F strategy
{                               // F2 (default j=2, k=3): follow the 2s except bet minimum of k times per side
                                // F3 (j=3): follow the 3s
 if(i<j+RAModeXtra) return(999); 
 
 int index,target=999,repeated=0,currentside;

 for(index=0;index<=j-2;index++)
 {
  if(value[i-1-index]==value[i-2-index]) repeated++;
 }
 
 if(repeated==j-1)
 {
  currentside=value[i-1]; 
  if(Fmode<0) Fmode=currentside; // first time 
  else if(Fmode!=currentside)      
  {
   if(checkSideBet(i,Fmode,k)) Fmode=currentside; // minimum k bets per side before switching
  }
 }

 if(Fmode==1) target=1; // Player or R side
 else if(Fmode==0) target=0; // Banker or A side
 else target=999;

 return(target);
}
//=========================================================================
int RDn(int i, int j=2) // Ellis' original RD strategy
{                       // RD12 (default j=2): repeat except bet down when lose under a 1 or 1,2
                        // RD3 (j=3): bet down under a 1, 1,2 or 1,3
                        // RDn (j=n): bed down under a 1, 1,2, 1,3, .... up to 1,n
 if(i<1+RAModeXtra) return(999);
  
 int target,repeated,n,k,csm1,csmn,csk,im1,im2,im3,mavm1;
 
 im1=value[i-1];
 im2=value[i-2];  
 im3=value[i-3];
 mavm1=mavarray[i-1];
 
 if(im1!=im2&&im2!=im3&&mavm1==0) // bet down when lose under a 1
 {
  target=Opposite(i);
 }
 else 
 {  
  for(n=2;n<=MathMin(i,j);n++) // covers the cumulative case, ie if n=4, then bet down under 1,2, 1,3, and 1,4
  {
   csm1=csarray[i-1];
   csmn=csarray[i-1-n];
   if(csm1>0&&csmn>0) // bet down under a 1,n 
   {
    repeated=0;
    for(k=0;k<=n-2;k++)
    {
     csk=csarray[i-1-1-k];
     if(csk<0) repeated++;
    }
   
    if(repeated==n-1) return(Opposite(i)); // satisfied 1,N, so it's an Opposite
   }
  }
  target=Repeat(i); // if failed above loop & still here, then it's a Repeat
 }
 
 return(target);
}
//=========================================================================
int OTT(int i, int j, int k) // OTB4L and TB4L method (OT until j loss, then T until k loss)
{ 
 if(i<2) return(999); // need at least 2 if starting out in OT mode 
                      // OK for both P/B and R/A modes 
 
 if(i<j) return(Opposite(i,2)); // start in OT mode if j is bigger than 2
 
 int target;
 bool lost;
 
 if(OTTmode) // presently OT mode 
 {
  lost=checkLastLost(i,j);
  if(lost) OTTmode=false;
  else     OTTmode=true;
 }
 else // presently T mode 
 {
  lost=checkLastLost(i,k);
  if(lost) OTTmode=true;
  else     OTTmode=false;  
 }
 
 if(OTTmode) target=Opposite(i,2);
 else        target=Repeat(i,2);

 return(target);
}
//=========================================================================
int Repeat(int i, int j=1) // Repeat strategy
{                          // j=1: Repeat, j=2: TB4L
 if(i<j+RAModeXtra) return(999); // need at least 2 prior for TB4L
 
 int target=value[i-j];  
 return(target);
}
//=========================================================================
int Opposite(int i, int j=1) // Opposite strategy
{                            // j=1: Opposite, j=2: OTB4L
 if(i<j+RAModeXtra) return(999); // need at least 2 prior for OTB4L
 
 int target; 

 if(value[i-j]==1) target=0;
 else if(value[i-j]==0) target=1;

 return(target);
}
//=========================================================================
int RepeatOpposite(int i) // Repeat and go Opposite if last two were Opposite
{
 int target;
 bool flag;

 if(value[i-1]!=value[i-2]&&value[i-2]!=value[i-3]) flag=true; // PB
 else flag=false;
 
 if(i>2)
 {
  if(flag)
  {
   target=Opposite(i);
  }
  else
  {
   target=Repeat(i);  
  }
 }
 else
 {
  target=Repeat(i);  
 } 
 return(target);
}
//=========================================================================
void CheckTarget(int target, int i)
{
 if(target==999) // skip
 {
  TallyWager(-1,-1,i); //transfer net score data only
  return;
 }
 
 if(value[i]==target) Score(true,target,i); // win bet 
 else                 Score(false,target,i); // lose bet 

 return;
}
//=========================================================================
void Score(bool win, int target, int i)
{
 int wagertemp;
 
 if(flagMM[loopMM])
 {
  if(MoneyManagement(i)) return;
 }
 
 if(win) 
 {
  TallyWager(target,wager,i); //record old wager
  
  // calculate new wager
  if (wager==1) wager++; //M2
  else          
  {
   wagertemp=wager-2; //D2
   wager=MathMax(wagertemp,1);
  }
 }
 else 
 {
  TallyWager(target,-wager,i); //record old wager  
  
  // calculate new wager
  wager+=1; //U1
  //wager=MathMin(wager,3); // 3Hi
  //if(wager==4) wager=1; // 123
 } 
 return;
}
//=========================================================================
void TallyWager(int target, int w, int i)
{
 int j;
 
 if(target==1)
 {
  betP[i]=w;
  if(w>0) 
  {
   for(j=0;j<=2;j++)
   {
    win[j,0]++;
    winwager[j,0]+=w;

    TrackB(w,i,j); // track B wins in RA mode for proper commish

   } 
  }
  else        
  {
   for(j=0;j<=2;j++)
   {  
    loss[j,0]++;
    losswager[j,0]+=MathAbs(w);
   }
  }
 }
 else if(target==0) 
 {
  betB[i]=w;
  if(w>0) 
  {
   for(j=0;j<=2;j++)
   {   
    win[j,1]++;
    winwager[j,1]+=w;

    TrackB(w,i,j); // track B wins in RA mode for proper commish

   }
  }
  else        
  {
   for(j=0;j<=2;j++)
   {   
    loss[j,1]++;
    losswager[j,1]+=MathAbs(w);
   }
  }
 }
 else // hit stop loss, transfer data only
 {
  betP[i]=0;
  betB[i]=0;
 }

 if(i>0) net[i]=net[i-1]+betP[i]+betB[i];  
 else    net[i]=0;
 
 return;
}
//=========================================================================
void BestWorst()
{
 int value;
 value=net[ArrayMaximum(net)];

 if(value>best[0])
 {
  best[0]=value;
  best[1]=NShoe_Global;
 }

 value=net[ArrayMinimum(net)];

 if(value<worst[0])
 {
  worst[0]=value;
  worst[1]=NShoe_Global;
 } 

 if(net[n-1]>0)      shoeresults[0]++; // shoe won
 else if(net[n-1]<0) shoeresults[1]++; // shoe lost
 else                shoeresults[2]++; // shoe broke even

 return;
}
//=========================================================================
bool MoneyManagement(int i)
{
 if(flagDecadeMM[loopMM]) // decade money management
 {
  if(i>0&&net[i-1]>=10*decadeMM) // i-1 because net[i] has not been assigned yet
  {
   stop=(10*decadeMM)-decadeMMless;
   decadeMM++;
  }
 }
 
 if(i>0) 
 {
  if(net[i-1]<=stop || (i>halfwaypoint[loopMM] && net[i-1]<halfwayscore) || (i>practicalstoppoint[loopMM])) // i-1 because net[i] has not been assigned yet
  {
   TallyWager(-1,-1,i); //stop play due to hit stop loss
   return(true);
  }
 }
 
 return(false);
}
//=========================================================================
double Divide(double a, double b) // avoide divide by zero
{
 if(b==0) return(0);
 else     return(a/b);
}
//=========================================================================
void TrackB(int w, int i, int j) // must track Banker win in RA mode to properly calculate commish
{ 
 if(shoe[i]==0)
 {
  Bwin[j]++;
  Bwinwager[j]+=w;
 }
 return;
}
//=========================================================================
bool checkLastLost(int i,int j) // check if the last j decisions lost, returns true if lost last j decisions, false if not
{
 int index,lastbetresult;
 int lost=0;

 for(index=1;index<=j;index++)
 {
  lastbetresult=net[i-index]-net[i-index-1];
  if(lastbetresult<0) lost++;
 }

 if(lost==j) return(true);
 else return(false);
 
 return(false);
}
//=========================================================================
bool checkSideBet(int i, int side, int j) // check if the last j decisions on a side lost, returns true if lost last j decisions, false if not
{                                         // side=0: B or A, side=1: P or R
 int index;
 int Nbet=0;

 if(side==0)
 {
  for(index=1;index<=j;index++)
  {
   if(betB[i-index]!=0) Nbet++;
  }
 }
 else if(side==1)
 {
  for(index=1;index<=j;index++)
  {
   if(betP[i-index]!=0) Nbet++;
  }
 } 

 if(Nbet==j) return(true);
 else return(false);
 
 return(false);
}
//=========================================================================
double random(double base) // base = 1.999999 returns a 0 or 1 based on random 
{                          // base = 9.999999 returns a random integer between 0 and 9
 return(MathFloor(base*MathRand()/32767.0));
}
//=========================================================================
int countRunLength(int i) // returns the length of the most immediate run, max 4
{
 int index,runlength=1;
 
 for(index=0;index<=MathMin(i-2,4);index++) // for stopping count at 6
 {
  if(value[i-1-index]==value[i-2-index]) runlength++;
  else break;
 }
 
 return(runlength);
}
//=========================================================================
int countEventsLC(int i) // returns the present SAP or FOE LC
{                                      // don't return 1s:  only 2s, 3s, 4s
 int eventLC; // least common event
 int events[5]; // index 1,2,3,4 correspond to the counts of runs 1,2,3,4+
 int zerocount=0; // total count of zero events
 bool eventszero[5]; // keeps track of which event is still 0

 for(int j=0;j<=4;j++) 
 {
  events[j]=0;
  eventszero[j]=false;
 }

 for(j=1;j<=4;j++) // index 1,2,3,4 correspond to the counts of runs 1,2,3,4+  
 {
  events[j]=eventsarray[i-1,j];

  if(events[j]==0) 
  {
   zerocount++;
   eventszero[j]=true;
  }
 }

 if(zerocount==4) return(4); // if all events are still zero, return 4 as the LC (assume choppy conditions)
 else if(zerocount>0) // some events still zero
 {
  for(j=4;j>1;j--) 
  {
   if(eventszero[j]) return(j); // return the highest event with zero count
  }
 }

 eventLC=ArrayMinimum(events,3,2); // all events non-zero, so return least common (LC), ArrayMinimum returns position of this minimum element in the array, don't consider 1s
 return(eventLC);
}
//=========================================================================
void Shuffle() // shuffle the array of 8 groups of 3 PBs -
{              // we do this to make sure each of the 4 random pre-sets are unique
 int i,r,temp,value;
 int number=8;

 for(i=0; i<(number-1); i++) 
 {
  r = i + (MathRand() % (number-i)); // Random remaining position.
  temp = masterset[i]; 
  masterset[i] = masterset[r]; 
  masterset[r] = temp;
 }

// string outputstring=StringConcatenate(DoubleToStr(loop,0)," ",DoubleToStr(NShoe,0));
// for(int j=0; j<8; j++) outputstring=StringConcatenate(outputstring," ",DoubleToStr(masterset[j],0));
// FileWrite(OutputFilehandle7,outputstring); 
 return;
}
//=========================================================================
string convertSettoString(int v)
{
 switch(v)
 {
  case 1: return("PPP"); break;
  case 2: return("PPB"); break;
  case 3: return("PBP"); break;
  case 4: return("PBB"); break;
  case 5: return("BPP"); break;
  case 6: return("BPB"); break;  
  case 7: return("BBP"); break;
  case 8: return("BBB"); break;
  default: return("XXX"); break;
 } 
 return("XXX");
}
//=========================================================================
int check3rdDecision(int v) // returns the 3rd decision choice based on group assignment in convertSettoString()
{                           // even number groups: 3rd decision = B (0), odd numbered groups: 3rd decision = P (1)
 return(v%2);
}
//=========================================================================
string convertDectoString(int i)
{
 switch(i)
 {
  case 0: return("B"); break;
  case 1: return("P"); break;
  case -1: return("T"); break;
  default: return("X"); break;
 }
 return("X");
}
//=========================================================================
int checkGrailSection(int v1,int v2)
{
 if(v1==1) // P
 {
  if(v2==1)      return(1); // section 1: PP, possible groups 1 & 2
  else if(v2==0) return(2); // section 2: PB, possible groups 3 & 4
 }
 else // B
 {
  if(v2==1)      return(3); // section 3: BP, possible groups 5 & 6
  else if(v2==0) return(4); // section 4: BB, possible groups 7 & 8
 }
 return(0);
}
//=========================================================================
int checkSetsSection(int v)
{
// section 1: PP, possible groups 1 & 2
// section 2: PB, possible groups 3 & 4
// section 3: BP, possible groups 5 & 6
// section 4: BB, possible groups 7 & 8
 return(MathFloor(0.5*(v+1)));
} 
//=========================================================================
int findGrailset(int i) // return Grailset number of last 3 decisions
{                       // use i-1 as basis, since this is updated AFTER every 3rd decision
 if(value[i-3]==1) // P
 {
  if(value[i-2]==1) // P
  {
   if(value[i-1]==1) return(1); // P
   else            return(2); // B
  }
  else // B
  {
   if(value[i-1]==1) return(3); // P
   else            return(4); // B  
  }
 }
 else // B
 {
  if(value[i-2]==1) // P
  {
   if(value[i-1]==1) return(5); // P
   else            return(6); // B
  }
  else // B
  {
   if(value[i-1]==1) return(7); // P
   else            return(8); // B  
  } 
 }
 return(0);
}
//=========================================================================

