//+----------------------------------------------------------------------+
//|                                          Bacc System Tester Nick.mq4 |
//|                                                         David J. Lin |
//|                                                                      |
//|                                                                      |
//| Coded by David J. Lin                                                |
//| dave.j.lin@gmail.com                                                 |
//| Evanston, IL, November 3, 2010                                       |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2010, David J. Lin"
#property link      ""
//=========================================================================
bool CountTies=true; // whether to include ties (Ties are deduced from total decisions for the overall statistics)

bool flagChart=false; // whether to print out the full charts 
bool flagStats=false; // whether to print out chart stats
bool flagShoesScores=true; // whether to print out shoes vs scores stats
bool flagOverallStats=false; // whether to print out overall stats per batch of shoes
                             // note: global overall stats are always printed out
bool flagDebug=false; // whether to print out debug file

bool flagMM[2]={false,true}; // whether to use money management (stop loss, decade MM, halfwaypoint, practicalstoppoint)
bool flagDecadeMM[2]={false,true}; // whether to use decade money management (for every +10u won, trail stop by 10u) 

int StopLoss=-20;   // number of units to stop shoe & declare loss
int Nbatch=100;       // number of batches of shoes to test

int BetSelection=0; // bet selection method, 0=flat, 1=U1D2M2, 2=Martingale

int shoe[100]; // shoe decisions
int valueP[100]; // player values
int valueB[100]; // banker values

int n; // number of decisions
int totalN=0; // total number of decision (P or B) in data set 
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
int bet[][2]; // bets, 2nd index 0=Banker, 1=Player
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

int shoescoresSpacing=250; // print out shoes vs score for every number of Spacing to truncate the list for spreadsheet compatibility
int shoescorescount=0;    // count for output shoe vs score
int stop; // index to carry the stop loss paramater
int decadeMM=1;           // index to keep track of current decade in decade money management
int decadeMMless=5;       // units less than current decade in decade money management to stop out (for example, if decadeMMxtra=5, then once profit hits 10u it will stop out at 10-5=5u)
int halfwaypoint[2]={1000,40};       // decision number to check halfwaypoint score
int halfwayscore=12;       // score at halfwaypoint should be above this or else quit
int practicalstoppoint[2]={1000,60}; // decision number to stop playing (Mark's practical stop point 
string filenameMM[2]={"SS B noMM","N1b fullMM"}; // file name prefixes for MM loop

int shoe_sub[]; // keep the last Nshoe_sub decisions for varience study
int Nshoe_sub=51; // number of past decisions to keep as a running total
int Nshoe_subMO; // Nshoe_sub minus one used for array copy (calculated in initialization)
int Pdisparity_limit3a=21; // Player disparity above which to bet Banker (for setup 3a)
int Pdisparity_limit3b=28; // Player disparity above which to bet Banker (for setup 3b)
int Pdisparity_limit3c=35; // Player disparity above which to bet Banker (for setup 3c)
bool Pdisparity_trigger=false; // setup 3a bet trigger
int Pdisparity_betcount=0; // tracks number of bets for setup 3a
int Pdisparity_maxbet=50; // maximum number of times to bet for setup 3
bool Pdisparity_3btriggered=false; // whether setup 3b was triggered
//=========================================================================
 
int init()
{
 for(loopMM=0;loopMM<1;loopMM++)
 {
  GlobalOpenFiles();
  Initialize(2); // global initialize  
  for(loop=1;loop<=Nbatch;loop++)
  {
   Comment(loop);
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
  
  // setup 3:
  ArrayResize(shoe_sub,Nshoe_sub); 
  Nshoe_subMO=Nshoe_sub-1; 
  totalN=0;
  Pdisparity_trigger=false;
  Pdisparity_3btriggered=false;
  Pdisparity_betcount=0;
  Pdisparity_maxbet=50;
 }
 return;
}
//=========================================================================
void Input()
{
 string data,entry;
 bool exit=false;
 int Pvalue,Bvalue;
 int shoenum,lastshoenum=1; 
 
 string filename=StringConcatenate("with hand totals/",DoubleToStr(loop,0)," data.csv");
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
    Pvalue=StrToInteger(FileReadString(handle));   
    Bvalue=StrToInteger(FileReadString(handle));
    if(data!="END")
    {
     if(lastshoenum==shoenum)
     {
      IncrementShoeArray(data,Pvalue,Bvalue);
     }
     else 
     {
      AssignArrays();
      EventsAnalysis();
      System();
      if(flagChart) OutputCharts();
      if(flagStats) OutputStats();   
      if(flagShoesScores) OutputShoesScores();    
      if(flagDebug) OutputDebug();   
      BestWorst();
      n=0;    
      Initialize(0);
      lastshoenum=shoenum;      
      IncrementShoeArray(data,Pvalue,Bvalue);
      //if(shoenum==3) exit=true;
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
void IncrementShoeArray(string data, int p, int b) // P=1, B=0
{
 n++;
 if(data=="P") 
 {
  shoe[n-1]=1;
 }
 else if(data=="B") 
 {
  shoe[n-1]=0;  
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
 
 valueP[n-1]=p;
 valueB[n-1]=b;
 
 return;
}
//=========================================================================
void EventsAnalysis()
{
 NShoe++;
 NShoe_Global++;
// Comment(NShoe_Global);
 return;  
}
//=========================================================================
void OutputCharts()
{
 string outputline,PBString,PBvalueString;
 int i,pcount=0,bcount=0;

 string ScoreP,ScoreB,ScoreString;
 
 if(OutputFilehandle>0)
 { 
  outputline=StringConcatenate("\nShoe Number: ",DoubleToStr(NShoe,0),"\n");
  FileWrite(OutputFilehandle,outputline);

  outputline="P,B,,Pv,Bv,,PS,BS,S";
  FileWrite(OutputFilehandle,outputline);

  outputline="";
  FileWrite(OutputFilehandle,outputline);
    
  for(i=0;i<n;i++)
  {
   
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
  
   PBvalueString=StringConcatenate(DoubleToStr(valueP[i],0),",",DoubleToStr(valueB[i],0));
  
   if(bet[i,1]!=0) ScoreP=DoubleToStr(bet[i,1],0);
   else            ScoreP="";
   
   if(bet[i,0]!=0) ScoreB=DoubleToStr(bet[i,0],0);
   else            ScoreB="";     
     
   ScoreString=StringConcatenate(ScoreP,",",ScoreB,",",DoubleToStr(net[i],0));
  
   outputline=StringConcatenate(PBString,",,",PBvalueString,",,",ScoreString);
 
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
// FileWrite(OutputFilehandle7,outputstring); 

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
 
 if(flag||!flag2) FileWrite(handle,outputstring); // only print out for truncated, remove "if(!flag2)" to print out for full score vs. shoe
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

 return;
}
//=========================================================================
void System()
{
 int target;
 for(int i=0;i<n;i++)
 {
  totalN++; 
  bet[i,0]=0;
  bet[i,1]=0;
  net[i]=0;
//  TrackDisparity(i);  
  target=0;
//  target=Setup3abc(i);
//  target=Setup1bf(i);
//  target=Setup1dh(i,false);
  CheckTarget(target,i);   
 }
 return;
}
//=========================================================================
int Setup3abc(int i) // Bet B after P disparity exceeds 21 out of last 50 decisions
{
 int j,target,pcount,bcount;

 if(Pdisparity_trigger)
 {
  Pdisparity_betcount++;
  target=0;

  if(!Pdisparity_3btriggered)
  {
// setup 3b: begin
   pcount=0;bcount=0; 
   for(j=0;j<Nshoe_subMO;j++) // 3b: extra 50 if disparity exceeds Pdisparitylimit3b
   {
    if(shoe_sub[j]==1) pcount++;
    else if(shoe_sub[j]==0) bcount++;
   }
   if(pcount-bcount>=Pdisparity_limit3b) 
   {
    Pdisparity_maxbet=100-Pdisparity_betcount; // bet 50 times more for total of 100
    Pdisparity_3btriggered=true;
   }
// setup 3b: end   
  }
  else
  {
// setup 3c: begin
   pcount=0;bcount=0; 
   for(j=0;j<Nshoe_subMO;j++) // 3c: extra 50 if disparity exceeds Pdisparitylimit3c
   {
    if(shoe_sub[j]==1) pcount++;
    else if(shoe_sub[j]==0) bcount++;
   }
   if(pcount-bcount>=Pdisparity_limit3c) 
   {
    Pdisparity_maxbet=150-Pdisparity_betcount; // bet 50 times more for total of 100
   }
// setup 3c: end    
  }
  
  if(Pdisparity_betcount==Pdisparity_maxbet) 
  {
   Pdisparity_betcount=0;
   Pdisparity_trigger=false;
   Pdisparity_3btriggered=false;
  }
 }
 else
 {
  if(totalN>=Nshoe_sub)
  {
// setup 3a: begin  
   pcount=0;bcount=0; 
   for(j=0;j<Nshoe_subMO;j++) // don't look into the future! Use Nshoe_subMO, not Nshoe_sub
   {
    if(shoe_sub[j]==1) pcount++;
    else if(shoe_sub[j]==0) bcount++;
   }
   if(pcount-bcount>=Pdisparity_limit3a) 
   {
    Pdisparity_betcount=0;   
    Pdisparity_trigger=true;
    Pdisparity_maxbet=50;
    target=0;
   }
   else target=999;
// setup 3a: end    
  }
  else target=999;
 }

 return(target);
}
//=========================================================================
int Setup2a(int i) // Bet B after 2 consecutive P wins of 8 or 9, and B hands of 2 or less.
{
 if(i<2) return(999);

 if(shoe[i-1]==1&&shoe[i-2]==1)
 {
  if(valueP[i-1]>=8 && valueP[i-2]>=8)
  {
   if(valueB[i-1]>=0 && valueB[i-2]>=0)
   {
    if(valueB[i-1]<=2 && valueB[i-2]<=2) return(0); // Banker bet
   }
  }
 }
 return(999); // no bet
}
//=========================================================================
int Setup1dh(int i, bool flag=true) // Bet B after every 2 consecutive P wins of 8 or 9.  Ties kill string of setup or bet.
{                  // New rule: Wait for new 2 P win setup after a B loss.   
 if(i<3) return(999);
 
 if(flag)
 {
  if(shoe[i-1]==1&&shoe[i-2]==1&&shoe[i-3]==1)
  {
   if(valueP[i-1]>=7 && valueP[i-2]>=7 && valueP[i-3]>=7)
   {
    if(bet[i-1,0]==0&&bet[i-2,0]==0&&bet[i-3,0]==0) return(0); // Banker bet only if B didn't bet
   }
  }
 }
 else
 {
  if(shoe[i-1]==0&&shoe[i-2]==0&&shoe[i-3]==0)
  {
   if(valueB[i-1]>=7 && valueB[i-2]>=7 && valueB[i-3]>=7)
   {
    if(bet[i-1,1]==0&&bet[i-2,1]==0&&bet[i-3,1]==0) return(1); // Player bet only if P didn't bet
   }
  } 
 }
 return(999); // no bet
}
//=========================================================================
int Setup1cg(int i, bool flag=true) // Bet B/P after every 3 consecutive P/B wins of 8 or 9.  Ties kill string of setup or bet.
{  
 if(i<3) return(999);
 
 if(flag)
 {
  if(shoe[i-1]==1&&shoe[i-2]==1&&shoe[i-3]==1)
  {
   if(valueP[i-1]>=7 && valueP[i-2]>=7 && valueP[i-3]>=7) return(0); // Banker bet
  }
 }
 else
 {
  if(shoe[i-1]==0&&shoe[i-2]==0&&shoe[i-3]==0)
  {
   if(valueB[i-1]>=7 && valueB[i-2]>=7 && valueB[i-3]>=7) return(1); // Player bet
  } 
 }
 return(999); // no bet
}
//=========================================================================
int Setup1bf(int i, bool flag=true) // Bet B/P after every 2 consecutive P/B wins of 8 or 9.  Ties kill string of setup or bet.
{                  // New rule: Wait for new 2 P/B win setup after a B/P loss.   
 if(i<2) return(999);
 
 if(flag)
 { 
  if(shoe[i-1]==1&&shoe[i-2]==1)
  {
   if(valueP[i-1]>=8 && valueP[i-2]>=8) 
   {
    if(bet[i-1,0]==0&&bet[i-2,0]==0) return(0); // Banker bet only if B didn't bet
   }
  }
 }
 else
 {
  if(shoe[i-1]==0&&shoe[i-2]==0)
  {
   if(valueB[i-1]>=8 && valueB[i-2]>=8) 
   {
    if(bet[i-1,1]==0&&bet[i-2,1]==0) return(1); // Player bet only if P didn't bet
   }
  } 
 }
 return(999); // no bet
}
//=========================================================================
int Setup1ae(int i, bool flag=true) // Bet B/P after every 2 consecutive P/B wins of 8 or 9.  Ties kill string of setup or bet.
{
 if(i<2) return(999);
 
 if(flag)
 {
  if(shoe[i-1]==1&&shoe[i-2]==1)
  {
   if(valueP[i-1]>=8 && valueP[i-2]>=8) return(0); // Banker bet
  }
 }
 else
 {
  if(shoe[i-1]==0&&shoe[i-2]==0)
  {
   if(valueB[i-1]>=8 && valueB[i-2]>=8) return(1); // Player bet
  } 
 }
 return(999); // no bet
}
//=========================================================================
int Repeat(int i, int j=1) // Repeat strategy
{                          // j=1: Repeat, j=2: TB4L
 if(i<j) return(999); // need at least 2 prior for TB4L
 
 for(int index=0;index<=i-j;index++) // loop back in case of tie
 {
  if(shoe[i-j-index]<0) continue; // tie

  return(shoe[i-j-index]); // no tie
 }
 
 return(999); // tie
}
//=========================================================================
void CheckTarget(int target, int i)
{
 if(target==999) // skip
 {
  TallyWager(-1,-1,i); //transfer net score data only
  return;
 }
 else
 {
  if(shoe[i]<0)            TallyWager(-1,-1,i);   // tie: transfer net score data only
  else if(shoe[i]==target) Score(true,target,i);  // win bet 
  else                     Score(false,target,i); // lose bet 
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
 return;
}
//=========================================================================
void TallyWager(int target, int w, int i)
{
 int j;
 
 if(target==0||target==1)
 {
  bet[i,target]=w;


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
 }
 else    
 {
  net[i]=0;    
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
void TrackDisparity(int i)
{
 if(totalN<=Nshoe_sub) shoe_sub[totalN-1]=shoe[i];
 else
 {
  ArrayCopy(shoe_sub,shoe_sub,0,1,Nshoe_subMO); // bump one down
  shoe_sub[Nshoe_subMO]=shoe[i];
//  string outputstring=DoubleToStr(totalN,0);
//  for(int i=0;i<Nshoe_sub;i++) outputstring=StringConcatenate(outputstring,",",shoe_sub[i]);
//  FileWrite(OutputFilehandle7,outputstring); 
 }
 return;
}