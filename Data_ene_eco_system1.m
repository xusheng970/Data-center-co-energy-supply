function Fun=Data_ene_eco_system1(xx) 

ele_offpeak=0.133*1.25*0.6;
ele_peak=0.305*1.25*0.6;

filename = 'Data_center_energy.xlsx'; 
sheetname = 'Sheet1';

data = readtable(filename, 'Sheet', sheetname);
COP_Chiller=5;

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
P_FC_1=(P_Time1-xx(1))/9;
P_FC_2=(P_Time2-xx(2))/15;
P_Chiller_1=(xx(3))/9;
P_Chiller_2=(xx(4))/15;

P_FC=max(P_FC_1,P_FC_2);
P_Chiller=max(P_Chiller_1,P_Chiller_2);
Eff_PEMFC=0.5;
day=330;

Power_grid=xx(1)+xx(2);
Cool_P_grid=xx(3)+xx(4);
Hydrogen_offshore=xx(5);
Cool_offshore=xx(6);

Cost_Hydrogen=Hydrogen_costform_wind();
Cost_cool=Cooling_costfrom_wind();

Cost_Cooling_SOEC_liBr=xx(5)*Cost_Hydrogen(2)*Cost_Hydrogen(3);


Year=20;
Rate=0.03;
CRF=(Rate*(1+Rate)^Year)/((1+Rate)^Year-1);
Rate_main=1.06;

C_PEMFC=650;
clc_PEMFC=(Rate_main*C_PEMFC*P_PEMFC*CRF)/day; 

C_ele_chiller=216;
clc_chiller=(Rate_main*C_ele_chiller*P_Chiller*CRF*COP_Chiller)/day; 

Energy_consumption=Power_grid+Cool_P_grid;
Peak_price_off=(xx(1)+xx(3))*ele_offpeak;
Peak_price=(xx(2)+xx(4))*ele_peak;


Cost=Peak_price_off+Peak_price+Hydrogen_offshore*Cost_Hydrogen(1)+Cool_offshore*COP_Chiller*Cost_cool(1)+clc_chiller+clc_PEMFC+Cost_Cooling_SOEC_liBr;

Fun=[Energy_consumption, Cost];

end
