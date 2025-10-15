clear
clc

filename = 'Data_center_energy.xlsx'; 
sheetname = 'Sheet1';

data = readtable(filename, 'Sheet', sheetname);

COP=5;
T1 = data(1:24, 1); 
P1 =data(1:24, 2);
C1 =data(1:24, 3);
T = table2array(T1);
P = table2array(P1);
C = table2array(C1);

P_Time1=sum(P(1:7,1))+sum(P(23:24,1));
P_Time2=sum(P(8:22,1));
C_Time1=sum(C(1:7,1))+sum(C(23:24,1));
C_Time2=sum(C(8:22,1));


%%
ub=[P_Time1 P_Time2 C_Time1 C_Time2 (P_Time1+P_Time2)/33.3/0.5 (C_Time1+C_Time2)];
lb=[0 0 0 0 0 0];


fun=Hydrogen_costform_wind();
rng(0);

A=[];
b=[];

Aeq=[1 1 0 0 33.3*0.5 0;...
   0 0 COP COP fun(3) COP];
beq=[sum(P) sum(C)*COP];

options=gaoptimset('UseParallel', true,'paretoFraction',0.5,'populationsize',200,'generation',300,'stallGenLimit',40,'TolFun',1e-10,'PlotFcns',@gaplotpareto);
fitnessfcn=@Data_ene_eco_system1;
nvars=6;
[x,faval]=gamultiobj(fitnessfcn,nvars,A,b,Aeq,beq,lb,ub,options);

