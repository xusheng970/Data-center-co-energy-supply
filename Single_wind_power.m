function Power=Single_wind_power(V_wind)
density_air=1225; %kg/m3
Pe_rate=2000;%kW
V_rate=14;%m/s
a=125077;b=0.234403;c=-2.92941;
efficiency_0=((a*b)^(V_wind/V_rate))*(V_wind/V_rate)^c;
A_rotor=Pe_rate/efficiency_0/0.5/density_air/(V_rate)^3;
Pw_wind=0.5*density_air*A_rotor*V_wind^3;
V_cutin=4;% m/s
V_cutout=25;

if V_wind<V_cutin || V_wind>=V_cutout
    Pe_wind=0;% Pe_wind is Wind turbine power

elseif V_wind>=V_cutin && V_wind<V_rate
    Pe_wind=efficiency_0*Pw_wind;

else
    Pe_wind=Pe_rate;

end
Power=Pe_wind;


