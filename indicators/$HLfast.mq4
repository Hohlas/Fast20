// Вот теперь может и сбудется...
#property copyright "Hohla"
#property link      "hohla@mail.ru"
#property strict // Указание компилятору на применение особого строгого режима проверки ошибок
#property description "Встроена функция R/W для ускорения оптимизации. При первом вызове создается файл со значениями индикатора, при последующих вызовах из него считываются посчитанные значения. Не дает никакого преимущества в скорости"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 clrBlue // iHI
#property indicator_color2 clrBlue // iLO
#property indicator_color3 clrGainsboro // MaxHI
#property indicator_color4 clrGainsboro // MinLO

extern char Mod=0;// 0..1 
extern char HL=1; // 1..9 Type
extern char HLk=8;// 1..8 Period
double iHI[], iLO[], iMaxHI[], iMinLO[]; 

#define MAX_EXPERTS_AMOUNT 10
float Real, atr,ATR, Lim, Present, S=1;
short FastAtrPer=15, SlowAtrPer=222, AtrLim;

string Company="Alp", SYMBOL=Symbol();
double Magic=555;

#include <INDICATORS.mqh>
#include <iGRAPH.mqh>
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
int OnInit(void){
   
   //if (!IND_INIT(Name)) return (INIT_FAILED);
   IndicatorBuffers(4);
   SetIndexStyle(0,DRAW_LINE);   SetIndexBuffer(0,iHI);     SetIndexLabel(0,"iHI");
   SetIndexStyle(1,DRAW_LINE);   SetIndexBuffer(1,iLO);     SetIndexLabel(1,"iLO");
   SetIndexStyle(2,DRAW_LINE);   SetIndexBuffer(2,iMaxHI);  SetIndexLabel(2,"MaxHI");
   SetIndexStyle(3,DRAW_LINE);   SetIndexBuffer(3,iMinLO);  SetIndexLabel(3,"MinLO");
   if (HL<0 || HL>9){//--- check for input parameter
      Print("Wrong input parameter HL=",HL);
      return(INIT_FAILED);
      }
   BarsInDay=short(24*60/Period());
   if (Mod==0) LimitBars=1000;         // предел поиска HI LO 
   else        LimitBars=BarsInDay*25;
   string Name="$HLfast."+DoubleToStr(HL,0)+"."+DoubleToStr(HLk,0);
   IndicatorShortName(Name);
   return (INIT_SUCCEEDED); // "0"-Успешная инициализация.
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
int bar;         
int start(){ 
   int CountBars=Bars-IndicatorCounted()-1; // IndicatorCounted() меньше на 1 чем prev_calculated в новом типе индикаторов  
   for (bar=CountBars; bar>0; bar--){    // Print("bar=",bar,"  ",TimeToStr(Time[bar],TIME_DATE | TIME_MINUTES));
      //ATR=float(iATR(NULL,0,100,bar));
      iHL(bar);
      iHI[bar]=HI;  
      iLO[bar]=LO;  
      //iMaxHI[bar]=MaxHI;
      //iMinLO[bar]=MinLO;
      }   
   return(0);
   }
short FIBO(int Val){  
   if (Mod==0) return(short(Val));
   short sign=1;
   if (Val<0) sign=-1;
   switch(MathAbs(Val)){
      case 1: return(sign/2); 
      case 2: return(sign*1);   
      case 3: return(sign*2);   
      case 4: return(sign*3);   
      case 5: return(sign*5);   
      case 6: return(sign*8);   
      case 7: return(sign*13);  
      case 8: return(sign*21);  
      case 9: return(sign*34);  
      case 10:return(sign*55);  
      default:return (0);
   }  }
void REPORT(string txt){Print(txt);}
void OnDeinit(const int reason){
   switch (reason){ // вместо reason можно использовать UninitializeReason()
      //case 0: str="Эксперт самостоятельно завершил свою работу"; break;
      case 1: REPORT("Program  removed from chart"); break;
      case 2: REPORT("Program  recompile"); break;
      case 3: REPORT("Symbol or Period was CHANGED!"); break;
      case 4: REPORT("Chart closed!"); break;
      case 5: REPORT("Input Parameters Changed!"); break;
      case 6: REPORT("Another Account Activate!"); break; 
      case 9: REPORT("Terminal closed!"); break;   
      }
   CLEAR_CHART();
   }