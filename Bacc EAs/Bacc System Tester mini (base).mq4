//+----------------------------------------------------------------------+
//|                                          Bacc System Tester mini.mq4 |
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
bool CountTies=false; // whether to include ties (Ties are deduced from total decisions for the overall statistics)

bool flagChart=false; // whether to print out the full charts 
bool flagStats=false; // whether to print out chart stats
bool flagShoesScores=true; // whether to print out shoes vs scores stats
bool flagOverallStats=false; // whether to print out overall stats per batch of shoes
                             // note: global overall stats are always printed out
bool flagDebug=false; // whether to print out debug file

bool flagMM[2]={false,true}; // whether to use money management (stop loss, decade MM, halfwaypoint, practicalstoppoint)
bool flagDecadeMM[2]={false,true}; // whether to use decade money management (for every +10u won, trail stop by 10u) 

int StopLoss=-20;   // number of units to stop shoe & declare loss
int Nbatch=13;       // number of batches of shoes to test

int BetSelection=1; // bet selection method, 0=flat, 1=U1D2M2, 2=Martingale

int shoe[100]; // shoe decisions & shoe number
int sap[1,5]; // SAP arrays

int ot[]; // P/B OTB4L vs TB4L array
int cs[]; // P/B chop vs streak (opposites vs. repeats) array

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

int shoescoresSpacing=25; // print out shoes vs score for every number of Spacing to truncate the list for spreadsheet compatibility
int shoescorescount=0;    // count for output shoe vs score
int stop; // index to carry the stop loss paramater
int decadeMM=1;           // index to keep track of current decade in decade money management
int decadeMMless=5;       // units less than current decade in decade money management to stop out (for example, if decadeMMxtra=5, then once profit hits 10u it will stop out at 10-5=5u)
int halfwaypoint[2]={1000,40};       // decision number to check halfwaypoint score
int halfwayscore=12;       // score at halfwaypoint should be above this or else quit
int practicalstoppoint[2]={1000,60}; // decision number to stop playing (Mark's practical stop point 
string filenameMM[2]={"PB Repeat noMM","PB Repeat fullMM"}; // file name prefixes for MM loop

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
 n++;
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
 return;
}
//=========================================================================
void EventsAnalysis()
{
 int SAPCount=1,SAPCurrent; // inter-shoe SAP and FOE global counts

 // sap and foe are the intra-shoe SAP and FOE arrays 
    
 ArrayResize(sap,n);
 ArrayResize(cs,n); 
 ArrayResize(ot,n);
 
 SAPCurrent=shoe[0];
 
 for(int j=0;j<5;j++) // initialize SAP and FOE 1st element
 {
  sap[0,j]=0;
 }

 for(int i=1;i<n;i++)
 {  
  sap[i,0]=0; // reset 
  cs[i]=0;
  ot[i]=0;  
  
  for(j=1;j<5;j++) // transfer all intra-shoe SAP and FOE arrays forward 
  {
   sap[i,j]=sap[i-1,j];
  }
 
  if(SAPCurrent==shoe[i])
  {
   SAPCount++;
  }
  else
  {
   EventsCounter(i,SAPCount);

   SAPCount=1; 
   SAPCurrent=shoe[i];
  }   
  
  if(i>0)
  {
   if(shoe[i]==shoe[i-1]) cs[i]=-1; // PB streak
   else                   cs[i]=1; // PB chop
   
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
void EventsCounter(int i, int count)
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
 return;
}
//=========================================================================
void OutputCharts()
{
 string outputline,PBString,SAPString,OTString,CSString;
 int i,pcount=0,bcount=0,ocount=0,tcount=0,ccount=0,scount=0;

 string ScoreP,ScoreB,ScoreString;
 
 if(OutputFilehandle>0)
 { 
  outputline=StringConcatenate("\nShoe Number: ",DoubleToStr(NShoe,0),"\n");
  FileWrite(OutputFilehandle,outputline);

  outputline=",,,,,,,,,,,F,O,E,,,S,A,P";
  FileWrite(OutputFilehandle,outputline);
  
  outputline="P,B,,PS,BS,S,,I,II,III,IV,,O,T,,C,S";
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
  
   outputline=StringConcatenate(PBString,",,",",,",ScoreString,",,",SAPString,",,",OTString,",,",CSString);
 
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
  outputstring="";
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

 return;
}
//=========================================================================
void System()
{
 int target; // target 1=P, 0=B
 
 for(int i=1;i<n;i++)
 {
  bet[i,0]=0;
  bet[i,1]=0;
  net[i]=0; 
  target=Repeat(i);
  CheckTarget(target,i);   
 }
 return;
}
//=========================================================================
int Repeat(int i, int j=1) // Repeat strategy
{                          // j=1: Repeat, j=2: TB4L
 if(i<j) return(999); // need at least 2 prior for TB4L
 
 int target=shoe[i-j];  
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

 if(shoe[i]==target) Score(true,target,i); // win bet 
 else                 Score(false,target,i); // lose bet 

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

