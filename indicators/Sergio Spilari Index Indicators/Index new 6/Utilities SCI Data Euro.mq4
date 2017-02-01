//+----------------------------------------------------------------------+
//|                                    Stochastic Channel Index Data.mq4 |
//|                                                         David J. Lin |
//| Stochastic Channel Index Data                                        |
//|                                                                      |
//| Coded for Sérgio Spilari Filho <sergio@ssfconsultoriafinanceira.com> |
//| Coded by David J. Lin (dave.j.lin@gmail.com)                         |
//| Evanston, IL, May 26, 2013                                           |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2013,  Sérgio Spilari Filho and David J. Lin"

#include "Utilities SCI/SCI Data Header.mqh"

int numPairs=7;
string symbols[] = {"EURUSD","EURJPY","EURGBP","EURAUD","EURCHF","EURCAD","EURNZD"};
double pows[]    = {0.100,0.100,0.100,0.100,0.100,0.100,0.100};

#include "Utilities SCI/SCI Data Body.mqh"