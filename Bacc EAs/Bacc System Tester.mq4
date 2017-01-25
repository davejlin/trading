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
bool flagShoesScores=false; // whether to print out shoes vs scores stats
bool flagOverallStats=false; // whether to print out overall stats per batch of shoes
                             // note: global overall stats are always printed out
bool flagDebug=false; // whether to print out debug file

bool flagDisparityFreq=false; // whether to analyze Disparity Frequency stats
bool flagWLIARS=true; // whether to analyze Wins & Losses in a Row (WIARS & LIARS) stats
bool flagAs=true; // whether to analyze Archer's As stats

bool PBRAMode=true; // PB or RA mode: true = PB, false = RA

bool flagMM[2]={false,true}; // whether to use money management (stop loss, decade MM, halfwaypoint, practicalstoppoint)
bool flagDecadeMM[2]={false,true}; // whether to use decade money management (for every +10u won, trail stop by 10u) 

int StopLoss=-20;   // number of units to stop shoe & declare loss
int Nbatch=13;       // number of batches of shoes to test

int BetSelection=0; // bet selection method, 0=flat, 1=U1D2M2, 2=Martingale, 3=Oscar's Grind

int shoe[100]; // shoe decisions & shoe number
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
int disparray[][2]; // holds disparity P/B or R/A depending on PBRAMode, second index: 0=P or R count, 1=B or A count

int RAModeXtra; // extra decision to skip at game start depending on PBRAMode

int n; // number of decisions per shoe
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

int net[]; // total score per decision
int netside[][2]; // total score per side for Brannan's Ultimate method, 0=B, 1=P (to be consistent with target value) 
int bet[][2]; // bets, 2nd index 0=Banker, 1=Player
int last2bet[2,2]; // last two P and B bets for Brannan's Ultimate method, 1st index 0=P, 1=B, 2nd index 0=2nd-to-last score, 1=last score
int last2paper[2,2]; // last two P and B paper bets for Brannan's Ultimate method, 1st index 0=P, 1=B, 2nd index 0=2nd-to-last score, 1=last score
int win[3,2],loss[3,2]; // number of wins and losses for P and B bets per shoe 
                        // 1st index: 0=shoe,1=overall set of shoes,2=global overall
                        // 2nd index: 0=B,1=P
int winwager[3,2],losswager[3,2]; // wagers of wins and losses for P and B bets per shoe
                        // 1st index: 0=shoe,1=overall set of shoes,2=global overall
                        // 2nd index: 0=B,1=P
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
string filenameMM[2]={"SSP WLIARS noMM 102600","SSP WLIARS fullMM 102600"}; // file name prefixes for MM loop

int stophand=100; // hand at which to stop betting (for W/LIARS bet frequency dependence study)

bool OTTmode; // OTB4L/TB4L mode flag, keeps track of OT or T mode for OTT method, true=OT, false=T
int Fmode; // Fn mode flag, keeps track of which side F is currently acting upon (-1: none, 0: B or A, 1: P or R)
int stopbetting[5]={0,0,100,5,5}; // array to hold run lengths to stop betting for System 40E (Ellis' version)
int cscount=0; // current chop/streak count (opposite/repeat)

int PFreq[2,100]; // tally frequency of P/R (1st index = 0: P, 1st index = 1: R) 
int BFreq[2,100]; // tally frequency of B/A (1st index = 0: B, 1st index = 1: A)
int PBDisparityFreq[2,200]; // tally frequency of PB/RA Disparity (1st index = 0: PB, 1st index = 1: RA)

int sideDisparity; // which side has disparity: 1 = P or R, 0 = B or A 

int MavGlobalDispMin=4;  // minimum value of global disparity needed to activate a side in Maverick
int MavLocalDispMin=3;   // minimum value of local disparity needed to activate a side in Maverick
int MavLocalDispLookback=7;  // number of decisions to lookback for local disparity in Maverick
int TriggerPresent=-1; // present trigger for Maverick4 (Trigger Version) & 24K & Brannan Ultimate
bool breakcycle=false; // break out of the cycle after 5 consec losses for 24K

bool stopbet[2,4]; // stop betting P,B sides for Brannan's Ultimate, 1st index: 0=B, 1=P (to be consistent with target value); 2nd index: 0=2-consec-loss-on-a-side, 1=down -3u on a side, 2=max drawdown;
int paper[][2]; // paper bets for Brannan's Ultimate
int highscore[2]; // highscore for Brannan's Ultimate
int maxdrawdown[2]={5,5}; // units maximum drawdown for Brannan's Ultimate, 0=B, 1=P
int nethighscore; // high score overall (per both sides)
int trailstop; // units to trail nethighscore (per both sides);
int WIARS[50]; // wins in a row
int LIARS[50]; // losses in a row
int TB4T[50]; // number of times before 2 wins-in-a-row for parlay
double totalNBets=0; // total number of bets in data set 
double totalN=0; // total number of decision (P or B) in data set 
int lastwager; // last wager for Oscar's Grind bet progression

int As[4]; // Archer's As stats
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
 TriggerPresent=-1;
 breakcycle=false;
 lastwager=1;

 for(int i=0;i<=1;i++) // for Brannan's Ultimate method
 { 
  for(int j=0;j<=1;j++) 
  {
   last2bet[i,j]=0;
   last2bet[i,j]=0;
   last2paper[i,j]=0;
   last2paper[i,j]=0;   
  } 
 }

 for(i=0;i<=1;i++) // for Brannan's Ultimate method
 { 
  for(j=0;j<=3;j++) stopbet[i,j]=false;
 }
 highscore[0]=0;highscore[1]=0;
 maxdrawdown[0]=5;maxdrawdown[1]=5;
 nethighscore=0;
 trailstop=1000;
  
 for(i=0;i<=index;i++) // clear the win/loss tracking arrays 
 {
  for(j=0;j<=1;j++)
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
  totalNBets=0;
  totalN=0;  

  for(i=0;i<=1;i++) // clear the best/worst tracking arrays 
  {
   best[i]=0;
   worst[i]=0;  
  }

  for(i=0;i<=2;i++) // clear the shoe results tracking arrays 
  {  
   shoeresults[i]=0;
  }
  
  for(i=0;i<50;i++) // clear the LIARS, WIARS, and TB4T arrays 
  {
   LIARS[i]=0;
   WIARS[i]=0;
   TB4T[i]=0; 
  }
  As[0]=0;As[1]=0;As[2]=0;As[3]=0;
 }
 
 return;
}
//=========================================================================
void Input()
{
 string data,entry;
 bool exit=false;
 int shoenum,lastshoenum=1;
 
 string filename=StringConcatenate("linebreak/",DoubleToStr(loop,0)," data.csv");
 int handle=FileOpen(filename,FILE_CSV|FILE_READ,',');

 if(handle>0)
 {
  n=0;
  while(!exit)
  {
   entry=FileReadString(handle);
   if(entry!="")  // if linebreak separates each shoe  
   {
    shoenum=StrToInteger(entry);
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
      DisparityAnalysis();
      System();
      if(flagWLIARS) WLIARS();
      if(flagAs) As();      
      if(flagChart) OutputCharts();
      if(flagStats) OutputStats();   
      if(flagShoesScores) OutputShoesScores();    
      if(flagDebug) OutputDebug();   
      BestWorst();
      if(flagDisparityFreq) DisparityFrequency();
      n=0;    
      Initialize(0);
      lastshoenum=shoenum;
      IncrementShoeArray(data,shoenum);
     }
    }
    else exit=true;
   }
  }
 }
 FileClose(handle);  

 return;
}

//=========================================================================
void IncrementShoeArray(string data, int shoenum) // P=1, B=0
{
 n++;

 if(data=="P") 
 {
  shoe[n-1]=1;
  totalN++;
 }
 else if(data=="B") 
 {
  shoe[n-1]=0;
  totalN++;
 }
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
// Comment(NShoe_Global);
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
  
   if(bet[i,1]!=0) ScoreP=DoubleToStr(bet[i,1],0);
   else            ScoreP="";
   
   if(bet[i,0]!=0) ScoreB=DoubleToStr(bet[i,0],0);
   else            ScoreB="";     
     
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
  WriteOutPA(0,OutputFilehandle6,false,false);
  shoescorescount=0;
 }

 return;
}
//=========================================================================
void OutputDebug()
{
 int i;
 string outputstring=StringConcatenate("Batch: ",DoubleToStr(loop,0)," Shoe: ",DoubleToStr(NShoe,0),"\n");
 FileWrite(OutputFilehandle7,outputstring); 

 for(i=0;i<n;i++)
 {
  outputstring=StringConcatenate(DoubleToStr(i,0)," ",DoubleToStr(netside[i,1],0)," ",DoubleToStr(netside[i,0],0)," ",DoubleToStr(paper[i,1],0)," ",DoubleToStr(paper[i,0],0));
  FileWrite(OutputFilehandle7,outputstring); 
 }
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

 if(flagDisparityFreq)
 { 
  outputstring="P,B,R,A Frequencies: ";
  FileWrite(OutputFilehandle4,outputstring); 

  for(i=0;i<100;i++)
  {
   outputstring=StringConcatenate(DoubleToStr(i,0),",",DoubleToStr(PFreq[0,i],0),",",DoubleToStr(BFreq[0,i],0),",",DoubleToStr(PFreq[1,i],0),",",DoubleToStr(BFreq[1,i],0));
   FileWrite(OutputFilehandle4,outputstring);  
  }

  outputstring="PB, RA Disparity Frequencies: ";
  FileWrite(OutputFilehandle4,outputstring); 

  for(i=0;i<200;i++)
  {
   outputstring=StringConcatenate(DoubleToStr(i-100,0),",",DoubleToStr(PBDisparityFreq[0,i],0),",",DoubleToStr(PBDisparityFreq[1,i],0));
   FileWrite(OutputFilehandle4,outputstring);  
  }
 }

 if(flagWLIARS)
 {
  double ave_bets_shoe=totalNBets/NShoe_Global;
   
  double ave_dec_per_shoe=totalN/NShoe_Global;
  double effective_num_shoes=totalNBets/ave_dec_per_shoe; 
   
  outputstring=StringConcatenate("\nTotal Number of Bets:,",DoubleToStr(totalNBets,0),",Ave Decisions Per Shoe:,",DoubleToStr(ave_dec_per_shoe,2),",Effective Number of Shoes:,",DoubleToStr(effective_num_shoes,2),",Average Bets per Shoe:,",DoubleToStr(ave_bets_shoe,2));
  FileWrite(OutputFilehandle4,outputstring); 

  outputstring="\nIAR,LFreq,LIAR,LIARS,WFreq,WIAR,WIARS,TB4T";
  FileWrite(OutputFilehandle4,outputstring);

  int j;
  double liarsplus,wiarsplus;

  for(i=1;i<50;i++)
  {
   liarsplus=0;wiarsplus=0;
   for(j=i;j<50;j++) liarsplus+=LIARS[j];
   for(j=i;j<50;j++) wiarsplus+=WIARS[j];
   
   liarsplus=Divide(liarsplus,effective_num_shoes); // normalized 
   wiarsplus=Divide(wiarsplus,effective_num_shoes); // normalized 

   outputstring=StringConcatenate(DoubleToStr(i,0),",",DoubleToStr(LIARS[i],0),",",DoubleToStr(Divide(LIARS[i],effective_num_shoes),6),",",DoubleToStr(liarsplus,6),",",DoubleToStr(WIARS[i],0),",",DoubleToStr(Divide(WIARS[i],effective_num_shoes),6),",",DoubleToStr(wiarsplus,6),",",DoubleToStr(TB4T[i],0)); // normalized

   //liarsplus=Divide(liarsplus,NShoe_Global); // unnormalized
   //wiarsplus=Divide(wiarsplus,NShoe_Global); // unnormalized

   //outputstring=StringConcatenate(DoubleToStr(i,0),",",DoubleToStr(LIARS[i],0),",",DoubleToStr(Divide(LIARS[i],NShoe_Global),6),",",DoubleToStr(liarsplus,6),",",DoubleToStr(WIARS[i],0),",",DoubleToStr(Divide(WIARS[i],NShoe_Global),6),",",DoubleToStr(wiarsplus,6),",",DoubleToStr(TB4T[i],0)); // unnormalized


   FileWrite(OutputFilehandle4,outputstring);
  }
 }

 if(flagAs)
 {
  outputstring="\nArcher As Stats: ";
  FileWrite(OutputFilehandle4,outputstring);
 
  for(i=0;i<4;i++)
  { 
   outputstring=StringConcatenate(DoubleToStr(i,0),",",DoubleToStr(As[i],0));
   FileWrite(OutputFilehandle4,outputstring);   
  }
 }
 
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
 
 ratio=Divide(arraywin[j,1],totalwin);
 outputstring=StringConcatenate(title," Player Wins : ",DoubleToStr(arraywin[j,1],0)," ",DoubleToStr(ratio,6));
 FileWrite(handle,outputstring);

 returnstring=StringConcatenate(returnstring,",",DoubleToStr(arraywin[j,1],0),",",DoubleToStr(ratio,6));

 ratio=Divide(arraywin[j,0],totalwin);
 outputstring=StringConcatenate(title," Banker Wins : ",DoubleToStr(arraywin[j,0],0)," ",DoubleToStr(ratio,6),"\n");
 FileWrite(handle,outputstring); 

 returnstring=StringConcatenate(returnstring,",",DoubleToStr(arraywin[j,0],0),",",DoubleToStr(ratio,6));

 ratio=Divide(arrayloss[j,1],totalloss);
 outputstring=StringConcatenate(title," Player Loss : ",DoubleToStr(arrayloss[j,1],0)," ",DoubleToStr(ratio,6));
 FileWrite(handle,outputstring);

 returnstring=StringConcatenate(returnstring,",",DoubleToStr(arrayloss[j,1],0),",",DoubleToStr(ratio,6));

 ratio=Divide(arrayloss[j,0],totalloss);
 outputstring=StringConcatenate(title," Banker Loss : ",DoubleToStr(arrayloss[j,0],0)," ",DoubleToStr(ratio,6),"\n");
 FileWrite(handle,outputstring); 

 returnstring=StringConcatenate(returnstring,",",DoubleToStr(arrayloss[j,0],0),",",DoubleToStr(ratio,6));

 return(returnstring);
}
//=========================================================================
string WriteOutPA(int j, int handle, bool flag=true, bool flag2=true) // flag2 to prevent double-counting when printing out truncated shoe vs score 
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
  if(flag2)
  {
   cumulativenumber+=total;
   cumulativewager+=totalwager; 
  }
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
 ArrayResize(bet,n);
 ArrayResize(net,n); 
 ArrayResize(netside,n); 
 ArrayResize(paper,n);  

 ArrayResize(value,n); 
 ArrayResize(csarray,n); 
 ArrayResize(mavarray,n); 
 ArrayResize(disparray,n); 

 cscount=0;

 if(PBRAMode) // PB
 {
  ArrayCopy(value,shoe,0,0,n);
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
 
 for(int i=0;i<n;i++)
 {
  bet[i,0]=0;
  bet[i,1]=0;
  net[i]=0; 
  netside[i,0]=0;  
  netside[i,1]=0; 
 
  cscount+=csarray[i-1];

// Brannan Ultimate Baccarat
//  target=BrannanUltimate(i);
//  CheckTarget(target,i,false); // special separate-side consideration
  
// 24K
//  target=Gold24K(i);

// Maverick - Triggers Maverick
//  target=Maverick4(i);
// Maverick - Modes Maverick
//  target=Maverick3(i);
// Maverick - Lazy Man's Maverick
//  target=Maverick2(i);
// Maverick - Disparity
//  target=Maverick1(i);

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
//  if(i<stophand) target=0; // Banker only, Anti-RDH only 
//  else           target=999; 
//  target=0;
  target=1; // Player only, RDH only

// Repeat 
//  target=Repeat(i);

// Opposite
//  target=Opposite(i);  
  
// Repeat and go Opposite if last two were Opposite
//  target=RepeatOpposite(i); 
  
  CheckTarget(target,i);   
 }
 return;
}
//=========================================================================
int BrannanUltimate(int i)
{
 if(i<3+RAModeXtra) return(999);

 int j;

 for(j=0;j<=1;j++) // stop/re-start conditions
 {
  if(stopbet[j,0]) // release 2 consec loss on a side 
  {
   if(netside[i-1,j]>=0) // side in profit
   { 
    if(last2paper[j,1]>0) // 1 paper win on a side
    {
     stopbet[j,0]=false;
     last2bet[j,0]=0;
     last2bet[j,1]=0;     
    }
   }
   else // side not in profit
   {
    if(last2paper[j,0]>0&&last2paper[j,1]>0) // 2 paper wins on a side
    {
     stopbet[j,0]=false; 
     last2bet[j,0]=0;
     last2bet[j,1]=0;     
    }
   }
  }
  else // set stop 2-consec-losses-on-a-side or 3-consec-losses overall
  {
   if(last2bet[j,0]<0&&last2bet[j,1]<0) stopbet[j,0]=true; // 2 consec losses on a side
   // if(checkConsecLosses(i,3)) // 3-consec-losses overall: this rule seems completely redundant
  }
  
  if(stopbet[j,1]) // release down-3u-on-a-side stop
  {
   if(paper[i-1,j]>=0) stopbet[j,1]=false; // back to even on paper wins
  }
  else  // set stop when down -3u on a side
  {
   if(netside[i-1,j]<=-3&&paper[i-1,j]<0) stopbet[j,1]=true;  // down net -3u on a side and down on paper plays
  }  

  if(stopbet[j,2]) // maximum drawdown on a side
  {
   // if switchsides stopbet[j,2]=false;
  }
  else
  {
   if(highscore[j]>=4) maxdrawdown[j]=4;
   if(netside[i-1,j]<=highscore[j]-maxdrawdown[j]) stopbet[j,2]=true;
  }

  if(stopbet[j,3]) // maximum drawdown on both side (joint)
  {
   // if switchsides stopbet[j,3]=false;
  }
  else
  {
   if(nethighscore>=10)    trailstop=5;
   else if(nethighscore>8) trailstop=6;
   if(net[i-1]<=nethighscore-trailstop) stopbet[j,3]=true;
   if(i>60&&net[i-1]==1) stopbet[j,3]=true; // after hand 60, exit at +1
  }  
  
 }
 
 if(TriggerPresent<0) // Minority to Majority Betting switching rule
 {
  if(netside[i-1,0]<0&&netside[i-1,1]<0)
  {
   if(paper[i-1,0]<0&&paper[i-1,1]<0)
   {
    if(paper[i-1,0]+paper[i-1,1]<=-4) 
    {
     TriggerPresent=1; // switch to Majority Betting
     
     for(j=0;j<=1;j++) // clear out stops & adjust drawdowns
     {
      maxdrawdown[j]=7;
      last2bet[j,0]=0;
      last2bet[j,1]=0;
      for(int k=0;k<=2;k++) // only up to k=2, not k=3 (because it is a global stop)
      {
       stopbet[j,k]=false;
      }
     }
    }
   }
  }
 }
 
 int target;
 int count[2];count[0]=0;count[1]=0;
 CheckTOT(i,count);
 //OutputDebug(i,count);  
 if(TriggerPresent<0) // Minority Betting
 {
  if(count[0]<=count[1]) target=Opposite(i,2); // OTB4L
  else                   target=Repeat(i,2);   // TB4L
 }
 else // Majority Betting
 {
  if(count[0]>=count[1]) target=Opposite(i,2); // OTB4L
  else                   target=Repeat(i,2);   // TB4L 
 }
 return(target);
}
//=========================================================================
int Gold24K(int i)
{
 if(i<48||i>65) return(999);
 if(breakcycle) return(999);
 
 int target; 
 static bool stopwin=false; // tracks if won per group

 if(i==48||i==54||i==60) // on hand 49, 55, or 61 evaluate singles vs columns vs balanced tendency
 {
 
  if(checkConsecLosses(i,5)) // no bets after lose a complete cycle of 5 bets
  {
   breakcycle=true;
   return(999);
  }
 
  int e1=eventsarray[i-1][1];
  int e2=(eventsarray[i-1][2]/2) + ((eventsarray[i-1][3]+eventsarray[i-1][4])/4);

  if(e1-e2>=2) TriggerPresent=1;
  else if(e2-e1>=2) TriggerPresent=4;
  else TriggerPresent=-1;
  
  stopwin=false; // reset stopwin flag
  wager=1; // reset wagers to 1
  
  return(999); // don't bet hand 49, 55, or 61
 }

 if(net[i-1]>net[i-2]) stopwin=true; // if won, set stopwin flag, but don't set it false until next group arrives 
 if(stopwin) return(999); // won, so stop until next group
 
 switch(TriggerPresent)
 {
  case(1): target=Repeat(i); // Repeat
  break;
  case(4): target=Opposite(i); // Opposites
  break;
  default: target=999;
  break;
 } 
 
 return(target);
}
//=========================================================================
int Maverick4(int i) // triggers Mav: R
{
 if(i<2+RAModeXtra) return(999);
 int target;
 
 if(checkConsecLosses(i,2)) TriggerPresent=-1;
 
 if(TriggerPresent<0)
 { 
  if(StickTrigger(i,4))      TriggerPresent=F2orF3(i); // target=Fn(i);     // JJJJS or more = Fn
  else if(StickTrigger(i,3)) TriggerPresent=1;         // target=Repeat(i); // JJJS = Repeat
  else if(StickTrigger(i,2)) TriggerPresent=F2orF3(i); // target=Fn(i);     // JJS = Fn
  else if(value[i-1]!=value[i-2]&&value[i-2]!=value[i-3]) TriggerPresent=4; // target=Opposite(i); // OTR On the Run
  else if(no1sEvents(i,3))   TriggerPresent=1;         // target=Repeat(i); // Repeat no 1s in last 3 events
  else TriggerPresent=-1; // no trigger
 }

 switch(TriggerPresent)
 {
  case(1): target=Repeat(i); // Follow the Leader: Repeat
  break;
  case(2): target=Fn(i); // F2
  break;
  case(3): target=Fn(i,3); // F3
  break;
  case(4): target=Opposite(i); // Opposites (OTR On the Run)
  break;
  default: target=999;
  break;
 }
 return(target);
}
//=========================================================================
int Maverick3(int i) // Modes Mav: R
{
 if(i<7+RAModeXtra) return(999); // conservative: wait out first 8 plays

 int target;

 if(MavDisparity(i,MavLocalDispLookback)) // high disparity
 { 
  Fmode=sideDisparity; // set the side to start F2 on
  target=Fn(i,2);
 }
 else
 {
  int e1=eventsarray[i-1][1];
  int e2=eventsarray[i-1][2];
  int e3=eventsarray[i-1][3];
  int e4=eventsarray[i-1][4];
 
  e3=2*((e3+e4)/4); // Mark's new FOE counting lumps 3+s with weight of 2

  if(e1<e2&&e1<e3) // 1s are LC
  {
   target=Repeat(i);
  }
  else if(e2<e1 && e2<e3) // 2s are LC
  {
   target=Repeat(i,2); // TB4L, jump after jump, stick after stick
  }
  else if(e3<e1 && e3<e2) // 3s are LC
  {
   target=Opposite(i);
  }
  else target=999; // no LC or all still 0, sit on your hands
 }
 return(target);
}
//=========================================================================
int Maverick2(int i) // Lazy Man's Mav: Repeat after JS or JJS trigger until lose 2-in-a-row
{ 
 if(i<3+RAModeXtra) return(999);
 
 int target;
 
 if(checkConsecLosses(i,2)) return(999); // stop after 2 consecutive losses
 
 if(net[i-1]==net[i-2]) 
 {
  if(StickTrigger(i,1)) target=Repeat(i); // not betting, waiting for trigger JS
  else target=999;
 }
 else target=Repeat(i); 
 
 return(target);
}
//=========================================================================
int Maverick1(int i) // Wait for total shoe disparity to treach a spread of 4 between RD and Anti-
{                   // Then wait for spread of R and to reach 5 to 2 in the last 7 decisions.
                    // Play F2 on that higher side until you loase AND the diaprity fell below eiter the 5 to 2 ratio and the spread of 4
                    // always stop at play 60 as soon as you lose.
 int target;
 
 if(net[i-1]>net[i-2]) // if won last decision, don't need to consider disparity
 {
  target=Fn(i,2);
 }
 else // only consider disparity if not betting or lost last decision
 {
  if(!MavDisparity(i,MavLocalDispLookback)) return(999); // no disparity
 
  Fmode=sideDisparity; // set the side to start F2 on
  target=Fn(i,2);
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
 
 if(cscount>0) // choppy conditions: use System 40
 {
  if(runlength>=eventsLC) 
  {
   if(runlength<stopbetting[eventsLC]) target=Repeat(i); // OTR if events bigger than LC, 2s: don't stop, 3s: stop after 2 (5-in-a-row), 4s: stop after 1 (5-in-a-row)
   else target=999; // stop betting OTR after a certain number
  }
  else target=Opposite(i); 
  
  modestring="Sys40";
 }
 else if(cscount<0) // streaky conditions: use RD or F
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
 else target=999; // supposed to net bet, but just stay out to mimic
 
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
void CheckTarget(int target, int i, bool flag=true)
{
 if(flag)
 {
  if(target==999) // skip
  {
   TallyWager(-1,-1,i); //transfer net score data only
   return;
  }
 
  if(value[i]==target) Score(true,target,i); // win bet 
  else                 Score(false,target,i); // lose bet 
 }
 else // Brannan separate side consideration
 {
  if(target==999) // skip
  {
   TallyWager(-1,-1,i); //transfer net score data only
   TallyPaper(target,0,i); // paper transfer   
   return;
  }
  
  if(value[i]==target) 
  {
   if(stopBetting(target)) TallyWager(-1,-1,i);
   else Score(true,target,i); // win bet
    
   TallyPaper(target,1,i); // paper win
  }
  else 
  {
   if(stopBetting(target)) TallyWager(-1,-1,i);  
   else Score(false,target,i); // lose bet 

   TallyPaper(target,-1,i); // paper loss   
  }
 }

 return;
}
//=========================================================================
void Score(bool winner, int target, int i)
{
 int wagertemp;
 
 if(flagMM[loopMM])
 {
  if(MoneyManagement(i)) return;
 }

 if(BetSelection==0) // flat bet
 {
  if(winner) 
  {
   TallyWager(target,wager,i); //record old wager
   wager=1;
  }
  else 
  {
   TallyWager(target,-wager,i); //record old wager  
   wager=1;
  }  
 }
 else if(BetSelection==1) // U1D2M2
 {
  if(winner) 
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
 }
 else if(BetSelection==2) // Martingale
 {
  if(winner) 
  {
   TallyWager(target,wager,i); //record old wager
   wager=1;
  }
  else 
  {
   TallyWager(target,-wager,i); //record old wager  
   wager*=2;
  }    
 }
 else if(BetSelection==3) // Oscar's Grind
 {
  if(winner) 
  {
   TallyWager(target,wager,i); //record old wager
   wager=NextOscarGrind(true,i);
  }
  else 
  {
   TallyWager(target,-wager,i); //record old wager  
   wager=NextOscarGrind(false,i);
  }    
 } 
 
 lastwager=wager;
 return;
}
//=========================================================================
void TallyWager(int target, int w, int i)
{
 int j;
 
 if(target==0||target==1)
 {
  bet[i,target]=w;
  totalNBets++;  

// Brannan's Ultimate  
  last2bet[target,0]=last2bet[target,1];
  last2bet[target,1]=w;  

  if(w>0) 
  {
   for(j=0;j<=2;j++)
   {
    win[j,target]++;
    winwager[j,target]+=w;

    TrackB(w,i,j); // track B wins in RA mode for proper commish

   } 
  }
  else        
  {
   for(j=0;j<=2;j++)
   {  
    loss[j,target]++;
    losswager[j,target]+=MathAbs(w);
   }
  }
 }
 else // hit stop loss, transfer data only
 {
  bet[i,0]=0;
  bet[i,1]=0;
 }

 if(i>0) 
 {
  net[i]=net[i-1]+bet[i,0]+bet[i,1]; // net overall score  
  if(net[i]>nethighscore) nethighscore=net[i]; // net highscore
  
  for(j=0;j<2;j++)
  {
   netside[i,j]=netside[i-1,j]+bet[i,j]; // net side score
   if(netside[i,j]>highscore[j]) highscore[j]=netside[i,j]; // high watermark
  }
 }
 else    
 {
  net[i]=0;
  netside[i,0]=0;
  netside[i,1]=0;    
 }
 
 return;
}
//=========================================================================
void TallyPaper(int target, int w, int i) // tally paper win & loss
{
 if(i==0)
 {
  paper[i,0]=0;
  paper[i,1]=0;
 }
 else
 {
  if(target==999) // no bet
  {
   paper[i,0]=paper[i-1,0]; // transfer info forward
   paper[i,1]=paper[i-1,1]; // transfer info forward   
  }
  else 
  {
   if(target==0) // Banker
   {
    paper[i,target]=paper[i-1,target]+w;  
    paper[i,1]=paper[i-1,1];
   }
   else if(target==1) // Player
   {
    paper[i,0]=paper[i-1,0];  
    paper[i,target]=paper[i-1,target]+w;
   }
   last2paper[target,0]=last2paper[target,1];
   last2paper[target,1]=w;
  }  
 }
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

 for(index=1;index<=j;index++)
 {
  if(bet[i-index,side]!=0) Nbet++;
 }

 if(Nbet==j) return(true);
 else return(false);
 
 return(false);
}
//=========================================================================
bool checkConsecLosses(int i, int lossN) // checks number of previous consecutive losses
{
 if(i<2+RAModeXtra) return(false);

 int index,nloss=0;
 for (index=0;index<lossN;index++)
 {
  if(net[i-1-index]<net[i-2-index]) nloss++;
 }
 
 if(nloss==lossN) return(true);
 else             return(false);
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
void DisparityAnalysis() // assigns global disparity array 
{
 disparray[0,0]=0;
 disparray[0,1]=0;

 disparray[0,value[0]]++;
  
 for(int i=1;i<n;i++) 
 {
  disparray[i,0]=disparray[i-1,0];
  disparray[i,1]=disparray[i-1,1];

  disparray[i,value[i]]++; // P or R / B or A
 }
 return;
}
//=========================================================================
void DisparityFrequency()
{
 int Pcount=0,Bcount=0,Rcount=0,Acount=0;
 for(int i=0;i<n;i++) 
 {
  if(shoe[i]==1) Pcount++; // P
  else if(shoe[i]==0) Bcount++; // B
  
  if(mav[i]==1) Rcount++; // R
  else if(mav[i]==0) Acount++; // A  
 }
 
 PFreq[0,Pcount]++;
 BFreq[0,Bcount]++;
 PBDisparityFreq[0,Pcount-Bcount+100]++; // PB Disparity

 PFreq[1,Rcount]++;
 BFreq[1,Acount]++;
 PBDisparityFreq[1,Rcount-Acount+100]++; // RA Disparity

 return;
}
//=========================================================================
bool MavDisparity(int i, int lookback) // returns whether disparity exists and which side with disparity in last lookback plays 
{
 if(i<lookback) return(false);
 
 int globaldisparity=disparray[i-1][1]-disparray[i-1][0]; // minimum global disparity condition
 if(MathAbs(globaldisparity)<MavGlobalDispMin) return(false);

 int index,left=0,right=0,localdisparity;
 for(index=0;index<lookback;index++)
 {
  if(value[i-1-index]==1) left++; // P or R
  else if(value[i-1-index]==0) right++; // B or A
 }

 localdisparity=left-right;
 
 if(MathAbs(localdisparity)<MavLocalDispMin) return(false); // no local disparity
 
 if(globaldisparity>0&&localdisparity>0) // P or R has disparity
 {
  sideDisparity=1;
 }
 else if(globaldisparity<0&&localdisparity<0) // B or A has disparity
 {
  sideDisparity=0; 
 }
 else return(false); // global & local disparities don't agree: don't bet
 
 return(true);
}
//=========================================================================
bool StickTrigger(int i, int jumpN) // jumpN=number of Jumps, e.g. JS: jumpN=1, JJS: jumpN=2, JJJS: jumpN=3
{
 if(i<jumpN+2+RAModeXtra) return(false);
 
 if(value[i-1]!=value[i-2]) return(false); // still jumping
 
 int jumps=0;
 for(int j=1;j<=jumpN;j++)
 {
  if(value[i-1-j]!=value[i-2-j]) jumps++;
 }
 
 if(jumps==jumpN) return(true);
 else return(false);
 
 return(false);
}
//=========================================================================
int F2orF3(int i) // finds F2 or F3 mode in Maverick4 (Triggers Version) based on events array 
{
 Fmode=value[i-1];
 if(eventsarray[i-1,2]==0&&eventsarray[i-1,3]==0) return(2); // F2
 else if(eventsarray[i-1,3]<eventsarray[i-1,2]&&eventsarray[i-1,3]<eventsarray[i-1,4]) return(3); // F3
 else return(2); // F2

 return(2);
}
//=========================================================================
bool no1sEvents(int i,int lookback) // returns true if no 1s in the past lookback events 
{
 if(i<2+RAModeXtra) return(false);
  
 int evnt=1;
 int run=1;
 for(int j=0;j<100;j++)
 {
  if(value[i-1-j]!=value[i-2-j]) // chop = new event
  {
   evnt++;
   if(run==1) return(false); // 1s occurred, so fail
   if(evnt>lookback) return(true); // no 1s occurred, so succeed
   run=1;
  }
  else run++;  

  if(i-2-j==0) break; // beginning of the shoe

 }

 if(run==1) return(false); // last one is a 1s
 else if(evnt<lookback) return(false); // fewer than lookback during game start
 else return(true);
}
//=========================================================================
int CheckTOT(int i, int& count[])
{
 int j;
 
 for(j=i-1;j>=MathMax(i-3,2);j--)
 {
  if(ot[j]==1) count[0]++; // OTB4L
  else         count[1]++; //  TB4L
 }
 // don't return 
}
//=========================================================================
bool stopBetting(int target)
{
 for(int j=0;j<=3;j++)
 {
  if(stopbet[target,j]) return(true);
 }
 return(false);
}
//=========================================================================
void WLIARS()
{
 int winner=0,loser=0;
 bool onewin=false; // keeps track of win, to detect 2 wins in a row
 int count=0; // count of time-before-2-wins-in-a-row
 
 if(net[0]>0) 
 {
  winner++;
  onewin=true;
  count++;
 }
 else if(net[0]<0) 
 {
  loser++;
  count++; 
 }
 
 for(int i=1;i<n;i++)
 {
  if(net[i]>net[i-1]) 
  {
   if(loser>0)
   {
    LIARS[loser]++;
    loser=0;
   }
   winner++;

   if(onewin) // track time-before-2-wins-in-a-row
   {
    TB4T[count]++;
    onewin=false;
    count=0;
   }
   else 
   {
    onewin=true;
    if(count==0) count++; // only increment count on the first win, since we progress in a parlay only on a loss thereafter
   }
  }
  else if(net[i]<net[i-1])
  {
   if(winner>0)
   {
    WIARS[winner]++;
    winner=0;
   }
   loser++;
   count++;
   onewin=false;
  }
  
  if(i==n-1) // last one
  {
   if(loser>0) LIARS[loser]++;
   else if(winner>0) WIARS[winner]++;

   if(count!=0) TB4T[count]++;
  }
 }
 return;
}
//=========================================================================
int NextOscarGrind(bool flag, int i)
{
 if(Bwin[0]%20==0&&i>0) nethighscore++; // TheArchitect's addition to Oscar's Grind to compensate for B commissions

 if(flag)
 {
  if(wager+net[i]>nethighscore) return(nethighscore-net[i]+1);
  else return(wager+1);
 }
 else
 {
  if(wager+net[i]>nethighscore) return(nethighscore-net[i]+1);
  else return(lastwager);  
 }
 return;
}
//=========================================================================
void As() // analyze Archer's As stats 
{
 int chop=0;
 for(int i=1;i<n;i++)
 {
  if(value[i]!=value[i-1]) chop++;
  else
  {
   if(chop>0)
   {
    if(chop<4) As[chop-1]++; // A1, A2, A3
    else       As[3]++;      // A3+
    
    chop=0;
   }
  }
  
  if(i==n-1) // last one
  {
   if(chop>0)
   {
    if(chop<4) As[chop-1]++; // A1, A2, A3
    else       As[3]++;      // A3+
   }   
  }
 }
 return;
}

