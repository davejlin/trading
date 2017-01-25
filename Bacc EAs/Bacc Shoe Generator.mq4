//+----------------------------------------------------------------------+
//|                                               Bacc Shoe Generator.mq4|
//|                                                         David J. Lin |
//|                                                                      |
//|                                                                      |
//| Coded by David J. Lin                                                |
//| dave.j.lin@gmail.com                                                 |
//| Evanston, IL, September 30, 2010                                     |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2010, David J. Lin"
#property link      ""

int Ndecks=8;        // number of desired decks
int Ncardsindeck=52; // number of cards in a deck
int Ncardvalues=13;  // number of individual values in a suite
int Nshoes=10000;    // number of desired shoes to generate in a batch
int Nbatch=100;       // number of batches of shoes to generate
 
int Ncards;           // number of cards in shoe
int Nshoe=0;          // number of generated shoes (running count)
int OutputFilehandle;  // handle for hands output file 
int OutputFilehandle2; // handle for decisions output file 
int OutputFilehandle3; // handle for decisions output file for Bacc Tester
int OutputFilehandle4; // handle for total stats of all batches of shoes

bool OutputShoeDecisions=false; // true=output hands & decisions output files, false=output only decisions data-file for Bacc Tester 

bool OutputWithValues=true; // true=output data-file with values, false=output data-file without values (for Bacc System Tester)
bool OutputWithTotalsOnly=true; // true=output data-file with totals only (not full values) (for Bacc System Tester)

int shoe[];          // array of cards;
int results[90,9];   // array of decision results;

int P=0,B=0,T=0;     // tally of P, B, T wins per shoe
int GP=0,GB=0,GT=0;  // tally of P, B, T wins for all shoes
int AP=0,AB=0,AT=0; // tally of P, B, T wins for all batches of shoes 
int dec=0;           // tally of decision number

int loop;            // index for batch number to perform 
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
 for(loop=90;loop<=Nbatch;loop++)
 {
  OpenFiles();
  Initialize();
  Process();
  CloseFiles();
 }
 OutputTotal();
 return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
 return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
 return(0);
}
//=========================================================================
void Initialize()
{
 GP=0;
 GB=0;
 GT=0;
 Nshoe=0;
 return;
}
//=========================================================================
void Process()
{
 Ncards=Ndecks*Ncardsindeck;
 ArrayResize(shoe,Ncards); 
 
 for(int n=0;n<Nshoes;n++)
 {
  //MathSrand(TimeLocal()+(((loop-1)*Nshoes)+n));
  //MathSrand(0+n); // seed 0 for 100000 shoes
  MathSrand(((loop-1)*Nshoes)+n);
  Shuffle();
  Deal();
  Output();
 }
 return;
}
//=========================================================================
void Shuffle()
{
 int r,temp,value;
 P=0;B=0;T=0;
 dec=0;

 for (int i=0; i<Ncards; i++) // fill the array in order
 {
  value=(i%Ncardvalues)+1;
  if(value<10) shoe[i] = value;
  else         shoe[i] = 0; // monkey!  
 }
 
 for(i=0; i<(Ncards-1); i++) 
 {
  r = i + (MathRand() % (Ncards-i)); // Random remaining position.
  temp = shoe[i]; 
  shoe[i] = shoe[r]; 
  shoe[r] = temp;
 }
 return;
}
//=========================================================================
void Deal()
{
 int HandsP[3],HandsB[3];
 int valueP,valueB;
 bool drawB3;

 for(int i=0;i<Ncards;i++)
 {
  if(i>Ncards-6) break;
  
  HandsP[0]=shoe[i];
  HandsB[0]=shoe[i+1];
  HandsP[1]=shoe[i+2];
  HandsB[1]=shoe[i+3];  
  
  valueP=(HandsP[0]+HandsP[1])%10;
  valueB=(HandsB[0]+HandsB[1])%10;

  if(valueP>7||valueB>7) // natural, no 3rd hand 
  {
   if(valueP==valueB)      Tally(-1,valueP,valueB,HandsP[0],HandsP[1],-1,HandsB[0],HandsB[1],-1);
   else if(valueP>valueB)  Tally(1,valueP,valueB,HandsP[0],HandsP[1],-1,HandsB[0],HandsB[1],-1);
   else if(valueP<valueB)  Tally(0,valueP,valueB,HandsP[0],HandsP[1],-1,HandsB[0],HandsB[1],-1);
   i=i+3;
  }
  else if(valueP>5&&valueB>5) // no draw, no 3rd hand 
  {
   if(valueP==valueB)      Tally(-1,valueP,valueB,HandsP[0],HandsP[1],-1,HandsB[0],HandsB[1],-1);
   else if(valueP>valueB)  Tally(1,valueP,valueB,HandsP[0],HandsP[1],-1,HandsB[0],HandsB[1],-1);
   else if(valueP<valueB)  Tally(0,valueP,valueB,HandsP[0],HandsP[1],-1,HandsB[0],HandsB[1],-1);
   i=i+3;
  }
  else if(valueP>5&&valueB<=5) // only Banker draws
  {
   HandsB[2]=shoe[i+4];
   valueB=(valueB+HandsB[2])%10;
   if(valueP==valueB)      Tally(-1,valueP,valueB,HandsP[0],HandsP[1],-1,HandsB[0],HandsB[1],HandsB[2]);
   else if(valueP>valueB)  Tally(1,valueP,valueB,HandsP[0],HandsP[1],-1,HandsB[0],HandsB[1],HandsB[2]);
   else if(valueP<valueB)  Tally(0,valueP,valueB,HandsP[0],HandsP[1],-1,HandsB[0],HandsB[1],HandsB[2]);   
   i=i+4;
  }
  else if(valueP<=5&&valueB>5) // only Player draws
  {
   HandsP[2]=shoe[i+4];
   valueP=(valueP+HandsP[2])%10;
   if(valueP==valueB)      Tally(-1,valueP,valueB,HandsP[0],HandsP[1],HandsP[2],HandsB[0],HandsB[1],-1);
   else if(valueP>valueB)  Tally(1,valueP,valueB,HandsP[0],HandsP[1],HandsP[2],HandsB[0],HandsB[1],-1);
   else if(valueP<valueB)  Tally(0,valueP,valueB,HandsP[0],HandsP[1],HandsP[2],HandsB[0],HandsB[1],-1);   
   i=i+4;
  }
  else // both may draw 
  {
   HandsP[2]=shoe[i+4]; // player first
   valueP=(valueP+HandsP[2])%10;
   drawB3=CheckBankerDraw(HandsP[2],valueB);
   if(drawB3) // banker draws 3rd card
   {
    HandsB[2]=shoe[i+5];
    valueB=(valueB+HandsB[2])%10;    
    if(valueP==valueB) Tally(-1,valueP,valueB,HandsP[0],HandsP[1],HandsP[2],HandsB[0],HandsB[1],HandsB[2]);
    if(valueP>valueB)  Tally(1,valueP,valueB,HandsP[0],HandsP[1],HandsP[2],HandsB[0],HandsB[1],HandsB[2]);
    if(valueP<valueB)  Tally(0,valueP,valueB,HandsP[0],HandsP[1],HandsP[2],HandsB[0],HandsB[1],HandsB[2]);   
    i=i+5;   
   }
   else // banker stands
   {
    if(valueP==valueB) Tally(-1,valueP,valueB,HandsP[0],HandsP[1],HandsP[2],HandsB[0],HandsB[1],-1);
    if(valueP>valueB)  Tally(1,valueP,valueB,HandsP[0],HandsP[1],HandsP[2],HandsB[0],HandsB[1],-1);
    if(valueP<valueB)  Tally(0,valueP,valueB,HandsP[0],HandsP[1],HandsP[2],HandsB[0],HandsB[1],-1);   
    i=i+4;
   }
  }
 }
 
 return;
}
//=========================================================================
bool CheckBankerDraw(int p3,int b2)
{
 if((p3==9||p3<=1)&&b2<=3) return(true);
 else if(p3==8&&b2<=2) return(true);
 else if(p3==7&&b2<=6) return(true); 
 else if(p3==6&&b2<=6) return(true);
 else if(p3==5&&b2<=5) return(true); 
 else if(p3==4&&b2<=5) return(true);
 else if(p3==3&&b2<=4) return(true); 
 else if(p3==2&&b2<=4) return(true);
 else                  return(false);
 
 return(false);
}
//=========================================================================
void Tally(int result,int totalP,int totalB,int P1,int P2,int P3,int B1,int B2,int B3)
{
 results[dec,0]=result;
 results[dec,1]=totalP; 
 results[dec,2]=totalB; 
 results[dec,3]=P1;
 results[dec,4]=P2; 
 results[dec,5]=P3;
 results[dec,6]=B1;
 results[dec,7]=B2;
 results[dec,8]=B3;    
 
 if(result>0) {P++;GP++;AP++;}
 else if(result<0) {T++;GT++;AT++;}
 else {B++;GB++;AB++;}

 dec++;
 
 return;
}
//=========================================================================
void Output()
{
 Nshoe++;
 string outputstring;
 int i,j;

 if(OutputShoeDecisions)
 {
// Shoe Hands Output:
 
  outputstring=DoubleToStr(shoe[0],0);
  for(i=1;i<Ncards;i++)
  {
   outputstring=StringConcatenate(outputstring,",",DoubleToStr(shoe[i],0)); 
  }
  outputstring=StringConcatenate(outputstring,",");
  FileWrite(OutputFilehandle,outputstring);  

// Decisions Output:
 
  int shoenumber=((loop-1)*Nshoes)+Nshoe;
 
  outputstring=StringConcatenate("Shoe Number ",DoubleToStr(shoenumber,0));
  FileWrite(OutputFilehandle2,outputstring);
  FileWrite(OutputFilehandle2," ");

  for(i=0;i<dec;i++)
  { 
   outputstring=Convert(true,results[i,0]);  
   for(j=1;j<9;j++)
   {
    if(j==5||j==8)
    {
     outputstring=StringConcatenate(outputstring,",",Convert(false,results[i,j]));
    }
    else
    {
     outputstring=StringConcatenate(outputstring,",",DoubleToStr(results[i,j],0));
    }
   }
   FileWrite(OutputFilehandle2,outputstring);
  }
  FileWrite(OutputFilehandle2," "); 
  
  outputstring=StringConcatenate("Player Wins = ",DoubleToStr(P,0));
  FileWrite(OutputFilehandle2,outputstring); 

  outputstring=StringConcatenate("Banker Wins = ",DoubleToStr(B,0));
  FileWrite(OutputFilehandle2,outputstring);

  outputstring=StringConcatenate("Tie Wins = ",DoubleToStr(T,0));
  FileWrite(OutputFilehandle2,outputstring);  

  FileWrite(OutputFilehandle2," "); 

  if(Nshoe==Nshoes) // last shoe 
  {
   FileWrite(OutputFilehandle2,"Totals All Shoes");
  
   double total=GP+GB+GT;
   double percent=GP/total;
  
   outputstring=StringConcatenate("Player Wins = ",DoubleToStr(GP,0),"  ",DoubleToStr(percent,6));
   FileWrite(OutputFilehandle2,outputstring); 

   percent=GB/total;
   outputstring=StringConcatenate("Banker Wins = ",DoubleToStr(GB,0),"  ",DoubleToStr(percent,6));
   FileWrite(OutputFilehandle2,outputstring);

   percent=GT/total;  
   outputstring=StringConcatenate("Tie Wins = ",DoubleToStr(GT,0),"  ",DoubleToStr(percent,6));
   FileWrite(OutputFilehandle2,outputstring);  
  }
 }
 
// Decisions Output for Bacc Tester:

 if(OutputWithValues) // output with hand values
 {
  if(OutputWithTotalsOnly)
  {
   outputstring=StringConcatenate(DoubleToStr(Nshoe,0),",",
                                             Convert(true,results[0,0]),",",
                                              DoubleToStr(results[0,1],0),",",
                                              DoubleToStr(results[0,2],0),",");

   for(i=1;i<dec;i++)
   {
    outputstring=StringConcatenate(outputstring,DoubleToStr(Nshoe,0),",",
                                              Convert(true,results[i,0]),",",
                                               DoubleToStr(results[i,1],0),",",
                                               DoubleToStr(results[i,2],0),",");   
   }

   if(Nshoe==Nshoes) // last shoe 
   {
    outputstring=StringConcatenate(outputstring,"\n",DoubleToStr(Nshoe+1,0),",E,0,0,",
                                                    DoubleToStr(Nshoe+1,0),",END,0,0");
   }  
  }
  else
  {
   outputstring=StringConcatenate(DoubleToStr(Nshoe,0),",",
                                             Convert(true,results[0,0]),",",
                                              DoubleToStr(results[0,1],0),",",
                                              DoubleToStr(results[0,2],0),",",
                                              DoubleToStr(results[0,3],0),",",
                                              DoubleToStr(results[0,4],0),",",
                                              DoubleToStr(results[0,5],0),",",
                                              DoubleToStr(results[0,6],0),",",
                                              DoubleToStr(results[0,7],0),",",
                                              DoubleToStr(results[0,8],0),",");

   for(i=1;i<dec;i++)
   {
    outputstring=StringConcatenate(outputstring,DoubleToStr(Nshoe,0),",",
                                              Convert(true,results[i,0]),",",
                                               DoubleToStr(results[i,1],0),",",
                                               DoubleToStr(results[i,2],0),",",
                                               DoubleToStr(results[i,3],0),",",
                                               DoubleToStr(results[i,4],0),",",
                                               DoubleToStr(results[i,5],0),",",
                                               DoubleToStr(results[i,6],0),",",
                                               DoubleToStr(results[i,7],0),",",
                                               DoubleToStr(results[i,8],0),",");   
   }

   if(Nshoe==Nshoes) // last shoe 
   {
    outputstring=StringConcatenate(outputstring,"\n",DoubleToStr(Nshoe+1,0),",E,0,0,0,0,0,0,0,0,",
                                                    DoubleToStr(Nshoe+1,0),",END,0,0,0,0,0,0,0,0");
   }  
  }
 }
 else
 {
  outputstring=StringConcatenate(DoubleToStr(Nshoe,0),",",Convert(true,results[0,0]),",");

  for(i=1;i<dec;i++)
  { 
   outputstring=StringConcatenate(outputstring,DoubleToStr(Nshoe,0),",",Convert(true,results[i,0]),",");
  }

  if(Nshoe==Nshoes) // last shoe 
  {
   outputstring=StringConcatenate(outputstring,"\n",DoubleToStr(Nshoe+1,0),",E,",DoubleToStr(Nshoe+1,0),",END");
  }
 }

 FileWrite(OutputFilehandle3,outputstring);
 
 return;
}
//=========================================================================
void OutputTotal()
{
 string outputstring,filename="Final Stats.csv";
 OutputFilehandle4=FileOpen(filename,FILE_CSV|FILE_WRITE|FILE_READ);
 
 int shoenumber=Nbatch*Nshoes;

 outputstring=StringConcatenate("Total Number of Shoes: ",DoubleToStr(shoenumber,0));
 FileWrite(OutputFilehandle4,outputstring);
  
 double total=AP+AB+AT;
 double percent=AP/total;
  
 outputstring=StringConcatenate("\nPlayer Wins = ",DoubleToStr(AP,0),"  ",DoubleToStr(percent,6));
 FileWrite(OutputFilehandle4,outputstring); 

 percent=AB/total;
 outputstring=StringConcatenate("Banker Wins = ",DoubleToStr(AB,0),"  ",DoubleToStr(percent,6));
 FileWrite(OutputFilehandle4,outputstring);

 percent=AT/total;  
 outputstring=StringConcatenate("Tie Wins = ",DoubleToStr(AT,0),"  ",DoubleToStr(percent,6));
 FileWrite(OutputFilehandle4,outputstring);  

 FileClose(OutputFilehandle4);
 return;
}
//=========================================================================
void OpenFiles()
{
 string filename;
 
 if(OutputShoeDecisions)
 {
  filename=StringConcatenate(DoubleToStr(loop,0),"0000 Shoe.csv");
  OutputFilehandle=FileOpen(filename,FILE_CSV|FILE_WRITE|FILE_READ);

  filename=StringConcatenate(DoubleToStr(loop,0),"0000 Decisions.csv");
  OutputFilehandle2=FileOpen(filename,FILE_CSV|FILE_WRITE|FILE_READ); 
 }
 
 filename=StringConcatenate(DoubleToStr(loop,0)," data.csv");
 OutputFilehandle3=FileOpen(filename,FILE_CSV|FILE_WRITE|FILE_READ); 
 
 return;
}
//=========================================================================
void CloseFiles()
{
 if(OutputShoeDecisions)
 {
  FileClose(OutputFilehandle);
  FileClose(OutputFilehandle2); 
 }
 FileClose(OutputFilehandle3);  
 return;
}
//=========================================================================
string Convert(bool flag, int v)
{
 if(flag) // P/B/T decision
 {
  if(v<0) return("T");
  else if (v>0) return("P");
  else return("B");
 }
 else // 3rd draw decision
 {
  if(v<0) return("x");
  else    return(DoubleToStr(v,0));
 }
 return("X");
}
//=========================================================================

