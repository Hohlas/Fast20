void COUNT_OLD(){
   if (Mod>0){ // Mod=1
      Present=ATR*FIBO(Oprf); // 0 0.5 1 2 3 5 
   }else{            // Mod=0
      if (Oprf==0)   Present=-999999;   // пороговая прибыль, 
      else           Present=float(Oprf*Oprf*ATR/10);  // без которой не хочется закрываться  0.1  0.4  0.9  1.6
   }  }
   
   // INPUT
void SET_BUY_OLD(){
   if (S>0)    setBUY.Stp=setBUY.Val-ATR*FIBO(S);   
   else{       for (int b=bar; b<Bars; b++)  if (FIND_LO(bar,b,-S, setBUY.Stp, setBUY.Val-Low[b]>ATR*FIBO(-S)))  {A("stpBUY ",setBUY.Stp,b,clrRed); break;}  setBUY.Stp-=ATR/2;}
   if (P==0)   setBUY.Prf =0;                      else
   if (P>0)    setBUY.Prf=setBUY.Val+ATR*FIBO(P);  else
   if (P<0)    setBUY.Prf=setBUY.Val-(setBUY.Val-setBUY.Stp)/2*P; 
   }
void SET_SEL_OLD(){
   if (S>0)    setSEL.Stp=setSEL.Val+ATR*FIBO(S);  
   else{       for (int b=bar; b<Bars; b++)  if (FIND_HI(bar,b,-S, setSEL.Stp, High[b]-setSEL.Val>ATR*FIBO(-S))) {V("stpSEL ",setSEL.Stp,b,clrRed); break;}    setSEL.Stp+=ATR/2;}
   if (P==0)   setSEL.Prf =0;                      else
   if (P>0)    setSEL.Prf=setSEL.Val-ATR*FIBO(P);  else
   if (P<0)    setSEL.Prf=setSEL.Val+(setSEL.Stp-setSEL.Val)/2*P; 
   }   
   
   // OUTPUT
void TRAILING_OLD(float& TrlBuy, float& TrlSel){
   if (Tk>0){  TrlBuy=H-ATR*FIBO(Tk);                 TrlSel=L+ATR*FIBO(Tk);}
   if (Tk==1){ TrlBuy=LO-ATR/2;                       TrlSel=HI+ATR/2;}
   if (Tk<0){  TrlBuy=PIC_LO(bar,-Tk,H+Tk*ATR)-ATR/2; TrlSel=PIC_HI(bar,-Tk,L-Tk*ATR)+ATR/2;}
   }      