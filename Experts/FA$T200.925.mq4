#define NAME  "FA$T"  
#define VER   "200.925"
#define MAX_RISK  10
#property version    VER // yym.mdd
#property copyright  "Hohla"
#property link       "hohla.ru"
#property strict // Указание компилятору на применение особого строгого режима проверки ошибок 

extern short   BackTest=0;
extern short   Opt_Trades=5;  // Opt_Trades Влияет только на оптимизацию, остальные параметры и на опт ина бэктест
extern float   RF_=0;         // RF_ При оптимизациях отбрасываем
extern float   PF_=1;         // PF_ резы с худшими показателями
extern float   MO_=0;         // MO_ множитель спреда, т.е. MO=MO_ * Spred
extern float   Risk=1;        // Risk процент депо в сделке (на реале задается в файле #.csv) Если в настройках выставить Risk>0, то риск, считанный из #.csv будет увеличен в данное количество раз
extern char    MM=1;          // MM 1..4 см. ММ: 
extern bool    Real=false;    // Real
extern char    CustMax=0;     // 0-Bal, 1-RF, 2-iRF, 3-MO/SD - максимизируемый при оптимизации параметр
extern string  SkipPer="";    // пропустить период при оптимизации
extern char    Mod=2;         // Mod=2.. Modification

extern string z1=" -  S I G N A L S  - ";  
extern char  HL=1;    // HL=1..6  расчет экстремумов HL 
extern char  HLk=1;   // HLk=1..8 переменная для расчета HL
extern char  TR=1;    // TR=-8..8 расчет направления тренда 
extern char  TRk=1;   // TRk=1..9 переменная для расчета тренда
extern char  IN=1;    // IN=-8..8 виды входных фильтров 
extern char  Ik=1;    // Ik=1..9  переменная для фильтра входа 
extern string z2=" -  I N P U T S  - ";  
extern char  Del=1;   // Del=0..2 удаление отложников 0=не трогаем;  1=при появлении нового сигнала удаляем; 2=при появлении нового сигнала удаляем противоположный или если ордер остался один;
extern char  BrkBck=0;// BrkBck=-5..5 откат после пробоя
extern char  Inv=0;   // Inv=0..1 инвертирование тренда Up=!Up Dn=!Dn 
extern char  D=-2;    // D=-5..5  дельта к ценам входа
extern char  Iprice=1;// Iprice=1..4  цена входа 0-LO/HI, 1-Рынок, 2-HI/LO, 3-FIBO
extern char  S=6;     // S=-4..6  S*ATR либо за пик на S*ATR
extern char  P=5;     // P=-6..8   P=(P+1)^2/10*ATR, при Р==0 без таргета
extern string z3=" -  O U T P U T S  - ";  
extern char  PM1=2;   // PM1=-3..3 приближение профита при каждом откате. <0~не ближе MaxFromBuy
extern char  PM2=3;   // PM2=0..4  если цена провалится от максимальнодостигнутого на xATR, выставляется тейк на максимальнодостигнутый уровень
extern char  Tk=1;    // Tk=-4..4  -1~STOP, 1~HI/LO, >1~H-Tk*ATR, <-1~пик дальше ATR*Tk   
extern char  TS=0;    // TS=0..1   0~трал со стопа, 1~от входа    
extern char  Out=0;   // Out=0..1  появление противоположного сигнала
extern char  OTr=0;   // OTr=-1..1  пропадание сигнала тренда / появление противоположного
extern char  Oprc=1;  // Oprc=1..3  цена выхода 1-ask, 2-MaxFromBuy, 3-HI
extern char  OD=1;    // OD=0..3    OD*ATR/2 прибавка к цене выхода
extern char  Oprf= 2; // Oprf=-3..3 тейк не ближе FIBO(Oprf)  0 0.5 1 2 3 5
extern char  Wknd=0;  // Wknd=0..2 закрытие поз 1-FOMC, 2-Weekend 
extern string z4=" -  A T R  - ";  
extern char  A=15;    // A=7..28 (7)  кол-во баров  для долгосрочной ATR (49,196,784 баров) 
extern char  a=5;     // a=3..6  (1)  кол-во баров для краткосрочной atr
extern char  AtrLim=0;// AtrLim=0..30 (10) %ATR прибавляемый к уровням стопов
extern string z5=" -  T I M E  - ";  
extern char  tk=0;    // tk=0..3  (1)  (0..6 для 30минуток) 0-без временного фильтра,  >0-разрешена торговля с Tin=(tk-1)*8+T0 до Tin+T1, потом все позы херятся. Каждая единица прибавляет 8 часов к времени Т0  
extern char  T0=7;    // T0=1..8  (1)  при tk=0 определяет GTC: 1,2,3,5,8,13,21 бесконечно. При tk>0 время входа Tin=((8*(tk-1)+T0-1). Все в БАРАХ
extern char  T1=8;    // T1=1..8  (1)  при tk=0 определяет скока баров держать открытую позу: 1,3,5,8,16,24,36,бесконечно. При tk>0 количество баров в течении которых разрешена работа  с момента T0. При T1=0 || T1=8 ограничения по времени не работают  
extern char  tp=1;    // tp=0..3 (1) 

datetime BarTime, TestEndTime;
bool     InUp, InDn, TrUp, TrDn;
short    ExpirBars, Per, Tout, Tin, Tper,  LotDigits, DIGITS, Exp, ExpTotal, FastAtrPer, SlowAtrPer, HistDD,  LastTestDD, SkipFrom=0, SkipTo=0;
int      bar=1, Magic, Today, TesterFile;
float    PS[20], ch[6], Present, MaxSpred, Lot, Aggress, CurDD,
         ATR, atr, ASK, BID, StopLevel, Spred, MaxRisk,  MaxMargin=float(0.7),  // максимальный суммарный риск всех позиций в одну сторону (все лонги или все шорты), максимальная загрузка маржи    
         InitDeposit, DayMinEquity, DrawDown, MaxEquity, MinEquity, Equity;  
string   ChartHistory="", SYMBOL, Hist, filename, ID, Company,
         Prm1,Prm2,Prm3,Prm4,Prm5,Prm6,Prm7,Prm8,Prm9,Prm10,Prm11,Prm12,Prm13, OptPeriod,
         Str1,Str2,Str3,Str4,Str5,Str6,Str7,Str8,Str9,Str10,Str11,Str12,Str13; 
ulong    MagicLong;
struct PICS{ // структура  PICS для совместимости с $o$imple в файле ORDERS.mqh 
   float P;       // price
   datetime T;       // время формирования пика 
   } F[1]; 
   
#include <stdlib.mqh> 
#include <stderror.mqh> 
#include <StdLibErr.mqh> 
#include <iGRAPH.mqh>
#include <SERVICE.mqh>       // сохранение/восстановление параметров, отчеты и др. заморочки
#include <ERRORS.mqh>    // проверка исполнения
#include <MM.mqh> 
#include <OLD_FUNCTIONS.mqh>
#include <ORDERS.mqh>
#include <INPUT.mqh>
#include <OUTPUT.mqh>
#include <SIGNAL.mqh>
#include <INDICATORS.mqh>
#include <COUNT.mqh>


 
double HH,LL;
void OnTick(){
   if (Real && float(Ask-Bid)>MaxSpred) MaxSpred=float(Ask-Bid);
   if (Time[0]==BarTime){
      CHECK_OUT(); 
      return;}  // Сравниваем время открытия текущего(0) бара 
   DAY_STATISTIC(); // расчет параметров DD, Trades, массив с резами сделок
   if (TimeYear(Time[bar])>=SkipFrom && TimeYear(Time[bar])<SkipTo){
      ORDER_CHECK(); 
      ORDERS_CLOSE(0); 
      return;}
   for (Exp=0; Exp<ExpTotal; Exp++){// осуществление перебора всех строк с входными параметрами за один тик (только для реала) 
      if (!EXPERT_SET()) continue; // выбор параметров эксперта из строки Exp массива CSV, сформированного из файла #.csv
      ORDER_CHECK();  // подробности открытых и отложенных поз  Print("SELLSTOP=",SELLSTOP," BUYSTOP=",BUYSTOP);
      TIMER(); // может пора закрыть открытые позы?
      PENDING_ORDERS_DEL(); // удаление отложника, если остался один (при Del=2)
      if (!COUNT() || !CAN_TRADE()){// не торгуем и закрываем все позы в период запрета торговли
         AFTER(); 
         continue;}  
      if (BUY.Val>0 || SEL.Val>0){
         TRAILING_STOP();
         TRAILING_PROFIT();
         OUTPUT();   
         }
      INPUT();    
      VIRTUAL_ORDERS();  // виртуальные ордера для отрaботки откатов 
      MODIFY();  
      if (setBUY.Val!=0 || setSEL.Val!=0){ 
         if (Real)   ORDERS_COLLECT();
         else{   
            if (Risk==0)   Lot=float(0.1);
            else           Lot=MM(MathMax(setBUY.Val-setBUY.Stp, setSEL.Stp-setSEL.Val), Risk, SYMBOL); Print("Lot=",Lot);
            ORDERS_SET();
         }  }    
      AFTER(); // сохранение на каждом баре переменных HI,LO,DM,DayBar... и значений индикаторов Real/Test 
      }  
   END(); // отчет о проведенных операциях, сохранение текущих параметров       
   BarTime=Time[0];  
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
bool CAN_TRADE(){// удаление всех поз в период запрета торговли
   if (!FINE_TIME()                                                  // временной фильтр
   || (Wknd==1 && TimeDayOfWeek(TimeCurrent())==5 && TimeDay(TimeCurrent())>22)  // FOMC
   || (Wknd==2 && TimeDayOfWeek(TimeCurrent())==5 && TimeHour(TimeCurrent())>21)){// Weekend
      ORDERS_CLOSE(0); // все закрываем и удаляем
      MODIFY();   
      return (false);
      }
   return (true);
   }
void ORDERS_CLOSE(uchar Position){ // удаление открытых и отложенных поз: 1~BUY, -1~SEL, 0~обе
   float MinProfit=float(tp*tp*ATR/10);  //  0.1 0.4 0.9 
   if (tp==0) MinProfit=-999999;
   if (Position>=0)  CLOSE_BUY(float(Bid),MinProfit,"TimeOver");// Выходим из длинной  
   if (Position<=0)  CLOSE_SEL(float(Ask),MinProfit,"TimeOver");// Выходим из короткой  
   }        
     
      
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  
void PENDING_ORDERS_DEL(){// УДАЛЕНИЕ ОТЛОЖНИКА, ЕСЛИ ОСТАЛСЯ ОДИН  
   if (Del!=2)  return;
   if (BUY.Val>0){ 
      if (SELSTP!=0 && SELSTP!=memSEL.Val)   SELSTP=0;   
      if (SELLIM!=0)                         SELLIM=0;  
      }
   if (SEL.Val>0){
      if (BUYSTP!=0 && BUYSTP!=memBUY.Val)   BUYSTP=0;    
      if (BUYLIM!=0)                         BUYLIM=0;   
   }  }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void TIMER(){   // ВРЕМЯ УДЕРЖАНИ ОТКРЫТЫХ ПОЗ (В Барах)  
   if (!Tper) return;
   if (BUY.Val>0 && (Time[0]-BUY.T)/60/Period()>=Tper) ORDERS_CLOSE( 1);
   if (SEL.Val>0 && (Time[0]-SEL.T)/60/Period()>=Tper) ORDERS_CLOSE(-1);
   }  
