//+----------------------------------------------------------------------+
//|                                             Bacc System O Tester.mq4 |
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
bool CountTies=true; // whether to include ties
bool StratO=true; // whether to use Strategy O

int shoe[]; // shoe decisions & shoe number
int score[]; // total score
int betP[],betB[]; // bets

int n; // number of decisions
int NShoe; // total number of shoes
int net=0; // score per shoe
int GrandTotal=0; // overall score
int OutputFilehandle; // handle for output file 

int target; // target 1=P, 2=B
bool bet; // whether to bet
bool wait; // whether to wait for target to recur after loss
bool wait3; // upon Tie, whether to wait for 3-in-a-row
int countTie; // countdown for decisions after a Tie before considering 3-in-a-row (to prevent 3-in-a-row before the Tie from being considered)
//=========================================================================

int init()
{
 OpenFiles();
 Input(); 
 OverallStats();
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

 NShoe=0;

// int handle=FileOpen("WoO Shoes 1-100.csv",FILE_CSV|FILE_READ,',');
 int handle=FileOpen("Zumma 600 Ties data.csv",FILE_CSV|FILE_READ,','); 
 if(handle>0)
 {
  n=0;
  while(!exit)
  {
   data=FileReadString(handle);
   if(data!="END")
   {
    if(data!="E")
    {
     IncrementShoeArray(data);
    }
    else 
    {
     if(StratO) StrategyO();
     Output();
     data=FileReadString(handle);
     n=0;
    }
   }
   else exit=true;
  }
 }

 FileClose(handle);  

 return;
}

//=========================================================================
void IncrementShoeArray(string data)
{
 n++;
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
 return;
}
//=========================================================================

void Output()
{
 string outputline,PBString,ScoreP,ScoreB;

 NShoe++;
 net=0;

 if(OutputFilehandle>0)
 { 
  outputline=StringConcatenate("\nShoe ",DoubleToStr(NShoe,0),"\n");
  FileWrite(OutputFilehandle,outputline);
    
  for(int i=0;i<n;i++)
  {

    if(shoe[i]==1) 
    {
     PBString="P,";
    }
    else if(shoe[i]==0)          
    {
     PBString=",B";    
    }
    else PBString="T,T";
   
   if(betP[i]==1) ScoreP=" 1";
   else if(betP[i]==-1) ScoreP="-1";
   else ScoreP="  ";
   
   if(betB[i]==1) ScoreB="1";
   else if(betB[i]==-1) ScoreB="-1";
   else ScoreB="  ";   
   
   net+=betP[i]+betB[i];
   
   outputline=StringConcatenate(",",PBString,",,",ScoreP,",",ScoreB);

   FileWrite(OutputFilehandle,outputline);
  }
  
  outputline=StringConcatenate("\nShoe ",DoubleToStr(NShoe,0)," Score: ",DoubleToStr(net,0));
  FileWrite(OutputFilehandle,outputline);
  GrandTotal+=net;
 }
 return;
}

//=========================================================================

void OverallStats()
{
 string filename="Overall_Stats.csv";
 string outputstring;

 int handle=FileOpen(filename,FILE_CSV|FILE_WRITE); 

 outputstring=StringConcatenate("Overall Score: ",DoubleToStr(GrandTotal,0));
 FileWrite(handle,outputstring);

 FileClose(handle);

 return;
}
//=========================================================================
void OpenFiles()
{
 string filename="Main_Output.csv";
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
void StrategyO()
{
 ArrayResize(betP,n);
 ArrayResize(betB,n); 
 
 bet=false;
 wait=false;
 wait3=false;
 
 for(int i=0;i<n;i++)
 {
  betP[i]=0;
  betB[i]=0;
   
  if(wait3) wait3=Check3InARow(i);
  if(wait3) continue;
  
  if(shoe[i]>=0) // encountered a P or B
  {

   if(wait) // lost, waiting for same target to recur
   {
    if(shoe[i]==target) 
    {
     wait=false; // target recurs, no longer wait, go back to normal chop-bet cycle
    }
    
    continue;
   }
  
   if(bet) // bet 
   {
    if(shoe[i]==target) // win bet 
    {
     Score(true,target,i);
    }
    else // lose bet                
    {
     Score(false,target,i);
     wait=true; // wait for target to recur before resuming chop-bet cycle
    }
    bet=false;
   }
   else // no-bet - waiting to see who wins for next decision
   {
    if(shoe[i]==1) target=0;
    else if(shoe[i]==0) target=1;
    bet=true; // next bet
   }
  }
  else // encountered a tie
  {
   if(bet||wait) // pretend it's a win and continue with chop-bet cycle
   {
    bet=false;  // if you get a tie and you had a bet placed, pretend that bet won and go on with strategy
    wait=false; //if you get a tie while you are waiting for either P or B to get a win(not betting), pretend who you're waiting for won
   }
   else // if not betting but waiting to see who wins, then need to wait for 3-in-a-row
   {
    countTie=2;
    wait3=true;
   }
  }
 }

 return;
}

//=========================================================================

void Score(bool win, int target, int i)
{
 int wager;
 
 if(win) wager=1;
 else wager=-1;
 
 if(target==1) betP[i]=wager;
 else if(target==0) betB[i]=wager;
 
 return;
}

//=========================================================================

bool Check3InARow(int i) // check for 3 in-a-row
{
 if(countTie>0) 
 {
  countTie--;
  return(true); // need at least 3 new decisions to start checking for 3-in-a-row
 }
 
 if(shoe[i]==shoe[i-1]&&shoe[i-1]==shoe[i-2]) 
 {
  // choose opposite as target
  if(shoe[i]==1) target=0;
  else if(shoe[i]==0) target=1;
  
  wait=true; // wait for new target to occur
  bet=false; // no betting until target occurs
  
  return(false);
 }
 else return(true);

 return(true);
}