void INPUT(){ // Ф И Л Ь Т Р Ы    В Х О Д А    ///////////////////////////////////////////////////////
   setBUY.Val=0; setBUY.Stp=0; setBUY.Prf=0; 
   setSEL.Val=0; setSEL.Stp=0; setSEL.Prf=0; 
   bool SigUp=(InUp && TrUp && !BUY.Val && (!memBUY.Val || Mod>0)); // 
   bool SigDn=(InDn && TrDn && !SEL.Val && (!memSEL.Val || Mod>0)); //   
   if (!SigUp && !SigDn) return; // Print(" Up=",Up," Dn=",Dn);   
   float Delta =ATR*D/2;   // 0 .. 2.5 
   if (Mod>0) Delta=ATR*FIBO(D); // 0, 0.5, 1, 2, 3, 5
   //Print("ATR=",ATR," Delta=",Delta," FIBO=",FIBO(D));    
   switch (Iprice){  // расчет цены входов:         
      case 1:  // по рынку + ATR          
         setBUY.Val=float(Open[0])+Spred+Delta;     // ask и bid формируем из Open[0],
         setSEL.Val=float(Open[0])-Delta;          // чтоб отложники не зависели от шустрых движух   
      break;
      case 2:  // HI / LO
         setBUY.Val=HI+Delta;    
         setSEL.Val=LO-Delta;    
      break; 
      case 3: // по ФИБО уровням       
         setBUY.Val=FIBO_LEVELS( D);       
         setSEL.Val=FIBO_LEVELS(-D); 
           
      break;
      case 4:  // LO / HI (was Not used in previous release)
         setBUY.Val = LO+Delta;     
         setSEL.Val = HI-Delta;     
      break;
      }    
   if (SigUp){  // 
      if (!BrkBck) SET_BUY_STOP(); // ставим стоп, если не включен режим "виртуальных" ордеров
      if (Del==1){      // удаление старого ордера при появлении нового сигнала  
         if (BUYSTP     && MathAbs(setBUY.Val-BUYSTP)>ATR/2)      {X("ReSet Order",BUYSTP,bar,clrRed);     BUYSTP=0;}     // если старый ордер далеко от нового
         if (memBUY.Val && MathAbs(setBUY.Val-memBUY.Val)>ATR/2)  {X("ReSet Order",memBUY.Val,bar,clrRed); memBUY.Val=0;}
         if (BUYLIM     && MathAbs(setBUY.Val-BUYLIM)>ATR/2)      {X("ReSet Order",BUYLIM,bar,clrRed);     BUYLIM=0;}     // то удаляем его
         }
      if (Del==2) CLOSE_SEL(float(Ask),Present,"LongSignal");   // при появлении нового сигнала удаляем противоположный или если ордер остался один;
      }    
   if (SigDn){  // 
      if (!BrkBck) SET_SEL_STOP();
      if (Del==1){
         if (SELSTP     && MathAbs(setSEL.Val-SELSTP)>ATR/2)      {X("ReSet Order",SELSTP,bar,clrRed);     SELSTP=0;} 
         if (memSEL.Val && MathAbs(setSEL.Val-memSEL.Val)>ATR/2)  {X("ReSet Order",memSEL.Val,bar,clrRed); memSEL.Val=0;} 
         if (SELLIM     && MathAbs(setSEL.Val-SELLIM)>ATR/2)      {X("ReSet Order",SELLIM,bar,clrRed);     SELLIM=0;}  
         }
      if (Del==2) CLOSE_BUY(float(Bid),Present,"ShortSignal");   
      }    
   if (!SigUp || BUYSTP || BUYLIM || memBUY.Val) setBUY.Val=0;  // если остались старые ордера,
   if (!SigDn || SELSTP || SELLIM || memSEL.Val) setSEL.Val=0;  // новые не выставляем 
   ERROR_CHECK(__FUNCTION__);
   }
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void SET_BUY_STOP(){// стопы в отдельную ф., чтобы использовать в откатах VIRTUAL_ORDERS() 
   if (Mod==0)    SET_BUY_OLD();
   else{
      if (S>0)    setBUY.Stp=setBUY.Val-ATR*FIBO(S);   
      else        setBUY.Stp=PIC_LO(bar,-S,setBUY.Val-ATR*FIBO(-S));   
      if (P==0)   setBUY.Prf =0;                      else
      if (P>0)    setBUY.Prf=setBUY.Val+ATR*FIBO(P);  else
      if (P<0)    setBUY.Prf=setBUY.Val-(setBUY.Val-setBUY.Stp)/2*P;    
      if (Iprice==3){  // вход и стоп по фибам
         setBUY.Stp=FIBO_LEVELS( D-S);  
         setBUY.Prf=FIBO_LEVELS( D+P);
   }  }  }   
void SET_SEL_STOP(){
   if (Mod==0)    SET_SEL_OLD();    
   else{
      if (S>0)    setSEL.Stp=setSEL.Val+ATR*FIBO(S);  
      else        setSEL.Stp=PIC_HI(bar,-S,setSEL.Val+ATR*FIBO(-S));    
      if (P==0)   setSEL.Prf =0;                      else
      if (P>0)    setSEL.Prf=setSEL.Val-ATR*FIBO(P);  else
      if (P<0)    setSEL.Prf=setSEL.Val+(setSEL.Stp-setSEL.Val)/2*P;   
      if (setSEL.Prf<0) setSEL.Prf=0;
      if (Iprice==3){  // вход и стоп по фибам
         setSEL.Stp=FIBO_LEVELS(-D+S);  
         setSEL.Prf=FIBO_LEVELS(-D-P);  
   }  }  }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void VIRTUAL_ORDERS(){ // виртуальные ордера для откатов после пробоя
   if (BrkBck==0) {memBUY.Val=0; memSEL.Val=0; return;}  
   if (setBUY.Val){  // выставлен/обновлен лонг                              L O N G
      memBUY=setBUY; // запоминаем его параметры в виртуальник
      setBUY.Val=0;  // и удаляем сам ордер
      V("memBUY "+S4(memBUY.Val),memBUY.Val,bar,clrBlue);
      }
   if (ExpirBars && memBUY.Val && Time[0]>memBUY.Exp){ // Экспирация виртуального ордера проверяется вручную
      X("BUY_Expiration",memBUY.Val,bar,clrBlue);
      memBUY.Val=0;                     // удаляем виртуальник
      }
   float delta=ATR*BrkBck;   
   if (Mod>0) delta=ATR*BrkBck/2;
   if (memBUY.Val){ // стоит виртуальник (стоп либо лимит)
      int B=bar;
      if (High[1]>memBUY.Val && High[2]<memBUY.Val){ // пересечение стоп-ордера снизу вверх, стваим лимитник ниже
         if (BrkBck==-1)   for (B=bar+1; B<Bars-2; B++)  if (High[B]<High[B+1]) break; // ближайшая впадина
         if (BrkBck<=-2)   for (B=bar+1; B<Bars-2; B++)  if (High[B]>High[B+1] && High[B]>High[B-1] && High[B]<memBUY.Val-(ATR*FIBO(-BrkBck-2))) break; // ближайший пик
         if (BrkBck>0)     setBUY.Val=memBUY.Val-delta;   // откат ниже пробитого уровня
         else{ 
            if (B<Bars-3)  setBUY.Val=(float)High[B];
         }  }
      if (Low[1]<memBUY.Val && Low[2]>memBUY.Val){ // пересечение лимитника сверху вниз, ставим стоп ордер выше
         if (BrkBck==-1)   for (B=bar+1; B<Bars-2; B++)  if (Low[B]>Low[B+1] && Low[B]>memBUY.Val) break;
         if (BrkBck<=-2)   for (B=bar+1; B<Bars-2; B++)  if (Low[B]<Low[B+1] && Low[B]<Low[B-1] && Low[B]>memBUY.Val+(ATR*FIBO(-BrkBck-2))) break;
         if (BrkBck>0)     setBUY.Val=memBUY.Val+delta;
         else{  
            if (B<Bars-3)  setBUY.Val=(float)Low[B]; 
         }  }
      if (setBUY.Val){  // если виртуальник зацепило, т.е. выставлен реальный ордер  
         SET_BUY_STOP();// ставим к нему стоп
         V("BUY "+S4(setBUY.Val),memBUY.Val,bar,clrBlue);
         memBUY.Val=0; // удаляем виртуальник
      }  }          
   if (setSEL.Val){ //                                                        S H O R T        
      memSEL=setSEL;
      setSEL.Val=0;
      A("memSEL "+S4(memSEL.Val),memSEL.Val,bar,clrGreen);
      }
   if (ExpirBars && memSEL.Val && Time[0]>memSEL.Exp){
      X("SEL_Expiration",memSEL.Val,bar,clrGreen);
      memSEL.Val=0;
      }
   if (memSEL.Val){
      int B=bar;
      if (Low[1]<memSEL.Val && Low[2]>memSEL.Val){
         if (BrkBck==-1)   for (B=bar+1; B<Bars-2; B++)  if (Low[B]>Low[B+1]) break;
         if (BrkBck<=-2)   for (B=bar+1; B<Bars-2; B++)  if (Low[B]<Low[B+1] && Low[B]<Low[B-1] && Low[B]>memSEL.Val+(ATR*FIBO(-BrkBck-2))) break;
         if (BrkBck>0)     setSEL.Val=memSEL.Val+delta;  
         else{             
            if (B<Bars-3)  setSEL.Val=(float)Low[B]; 
         }  }
      if (High[1]>memSEL.Val && High[2]<memSEL.Val){
         if (BrkBck==-1)   for (B=bar+1; B<Bars-2; B++)  if (High[B]<High[B+1] && High[B]<memSEL.Val) break; // ближайшая впадина 
         if (BrkBck<=-2)   for (B=bar+1; B<Bars-2; B++)  if (High[B]>High[B+1] && High[B]>High[B-1] && High[B]<memSEL.Val-(ATR*FIBO(-BrkBck-2))) break;   // ближайший пик
         if (BrkBck>0)     setSEL.Val=memSEL.Val-delta;
         else{              
            if (B<Bars-3)  setSEL.Val=(float)High[B];  
         }  }
      if (setSEL.Val){   
         SET_SEL_STOP();
         A("SEL "+S4(setSEL.Val),memSEL.Val,bar,clrGreen);
         memSEL.Val=0;   
   }  }  } 
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
float FIBO(int Val){  
   if (Mod==0) return(short(Val));
   float sign=1;
   if (Val<0) sign=-1;
   switch(MathAbs(Val)){
      case 1: if (Mod<2) return(0); else return(sign/2); 
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
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
float FIBO_LEVELS(int FiboLevel){ // Считаем ФИБУ:  Разбиваем диапазон HL   0   11.8   23.6   38.2  50  61.8   76.4  88.2   100 
   double Fib=0;
   switch(FiboLevel){
      case 16: Fib= (HI-LO)*2.500; break;
      case 15: Fib= (HI-LO)*2.382; break;
      case 14: Fib= (HI-LO)*2.236; break;
      case 13: Fib= (HI-LO)*2.118; break;
      case 12: Fib= (HI-LO)*2.000; break;
      case 11: Fib= (HI-LO)*1.882; break;
      case 10: Fib= (HI-LO)*1.764; break;
      case  9: Fib= (HI-LO)*1.618; break;
      case  8: Fib= (HI-LO)*1.500; break;
      case  7: Fib= (HI-LO)*1.382; break;
      case  6: Fib= (HI-LO)*1.236; break;
      case  5: Fib= (HI-LO)*1.118; break;
      case  4: Fib= (HI-LO)*1.000; break; // Hi
      case  3: Fib= (HI-LO)*0.882; break;
      case  2: Fib= (HI-LO)*0.764; break; 
      case  1: Fib= (HI-LO)*0.618; break; // Золотое сечение
      case  0: Fib= (HI-LO)*0.500; break; 
      case -1: Fib= (HI-LO)*0.382; break; // Золотое сечение 
      case -2: Fib= (HI-LO)*0.236; break;
      case -3: Fib= (HI-LO)*0.118; break; 
      case -4: Fib= (HI-LO)*0;     break; // Lo   
      case -5: Fib=-(HI-LO)*0.118; break; 
      case -6: Fib=-(HI-LO)*0.236; break;
      case -7: Fib=-(HI-LO)*0.382; break; 
      case -8: Fib=-(HI-LO)*0.500; break; 
      case -9: Fib=-(HI-LO)*0.618; break; 
      case-10: Fib=-(HI-LO)*0.764; break;
      case-11: Fib=-(HI-LO)*0.882; break;
      case-12: Fib=-(HI-LO)*1.000; break;
      case-13: Fib=-(HI-LO)*1.118; break;
      case-14: Fib=-(HI-LO)*1.236; break;
      case-15: Fib=-(HI-LO)*1.382; break;
      case-16: Fib=-(HI-LO)*1.500; break;
      } //Print("FIBO: HI=",S4(HI)," LO=",S4(LO));
   return(N5(LO+Fib));
   }


   
   
         
         
         
         
         
         
         
         
      

