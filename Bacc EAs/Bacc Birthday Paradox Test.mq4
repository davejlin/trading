//+------------------------------------------------------------------+
//|                                   Bacc Birthday Paradox Test.mq4 |
//|                                   Copyright © 2010, David J. Lin |
//|                                                                  |
//| Coded by David J. Lin                                            |
//| dave.j.lin@gmail.com                                             |
//| Evanston, IL, October 17, 2010                                   |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, David J. Lin"
#property link      ""

int masterset[8]={1,2,3,4,5,6,7,8}; // master set of 8 groups of 3
int prefab[]; // prefab sets]
int OutputFilehandle;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----
 int i,j,loops,decision,total,cycles=1000000;
 double match,match2;
 string outputstring; 
 OpenFiles();
 MathSrand(0);
 
 for(i=1;i<8;i++)
 {
  ArrayResize(prefab,i); 
  match=0;  
  match2=0;
  total=0;
  for(loops=0;loops<cycles;loops++)
  {
   Shuffle();
   
   for(j=0;j<i;j++) prefab[j]=masterset[j];
   
   decision=1+random(7.999999); // pick a random object 

//   outputstring="\nprefab: ";
//   for(j=0; j<i; j++) outputstring=StringConcatenate(outputstring," ",DoubleToStr(prefab[j],0));
//   FileWrite(OutputFilehandle,outputstring);
//   outputstring=StringConcatenate("\ndecision: ",DoubleToStr(decision,0),"\n");
//   FileWrite(OutputFilehandle,outputstring);

   if(!CheckAmbiguity(i,decision)&&CheckGroup(i,decision)) // only check if not ambiguous & in same group
   {
    total++;
    for(j=0;j<i;j++) // checking for ANY match in the past i 
    {
     if(prefab[j]==decision) 
     {
      match++;
      break;
     }   
    }
   }
//   if(prefab[i-1]==decision) match2++; // checking for match in the past of "next" object 
   
  }
  double ratio=Divide(match,total);
  outputstring=StringConcatenate(DoubleToStr(i,0),",",DoubleToStr(match,0),",",DoubleToStr(ratio,4),",",DoubleToStr(total-match,0),",",DoubleToStr(1-ratio,4));
  
  ratio=Divide(total,cycles);
  outputstring=StringConcatenate(outputstring,",",DoubleToStr(total,0),",",DoubleToStr(ratio,4));
  
  FileWrite(OutputFilehandle,outputstring);
 
 }
//----
 CloseFiles();
 return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//=========================================================================
double random(double base) // base = 1.999999 returns a 0 or 1 based on random 
{                          // base = 9.999999 returns a random integer between 0 and 9
 return(MathFloor(base*MathRand()/32767.0));
}
//=========================================================================
void Shuffle() // shuffle the array of 8 groups
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

// string outputstring;
// for(int j=0; j<8; j++) outputstring=StringConcatenate(outputstring," ",DoubleToStr(masterset[j],0));
// FileWrite(OutputFilehandle,outputstring); 
 return;
}
//=========================================================================
bool CheckAmbiguity(int i, int d) // don't bet when ambiguous
{
 if(i==1) return(false); // unambiguous if only 1 set
  
 int index;
 int fullambiguity=0; // in case all are ambiguous
 int group[4]={0,0,0,0};
 for(index=0;index<i;index++)
 {
  if(prefab[index]<=2) group[0]++;
  else if(prefab[index]<=4) group[1]++;
  else if(prefab[index]<=6) group[2]++;
  else if(prefab[index]<=8) group[3]++;
 }

 for(index=0;index<i;index++)
 {
  if(group[index]==2) fullambiguity++;
 }

 if(i%2==0&&fullambiguity==i/2) return(true); // don't bet when all groups are ambiguous

 if(d<=2) group[0]++;
 else if(d<=4) group[1]++;
 else if(d<=6) group[2]++;
 else if(d<=8) group[3]++;
 
 for(index=0;index<4;index++)
 {
  if(group[index]>2) return(true); // only true if decision matched 2 in the same group: ambiguity!
 }
 
 return(false);
}
//=========================================================================
bool CheckGroup(int i, int d) // must be in same set to not blindly guess without any matching basis
{
 int index;
 for(index=0;index<i;index++)
 {
  if(checkSetsSection(prefab[index])==checkSetsSection(d)) return(true);
 }
 return(false); // decision is not in any existing set, so don't guess
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
void OpenFiles()
{
 string filename="Birthday Paradox.csv";
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
double Divide(double a, double b) // avoide divide by zero
{
 if(b==0) return(0);
 else     return(a/b);
}
//=========================================================================

