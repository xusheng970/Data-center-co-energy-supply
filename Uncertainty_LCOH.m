% MonteCarlo_LCOH_10cases_saveArrays.m
clear; close all; clc;

% ---------------- Base inputs ----------------
total_H2_base = [912313 901788 925109 848766 889180 926942 767414 906641 790657 630508];

C_Windfarm_base = 3400;
Cycle_year_base = 100;
Year_SOEC_base = 20;
C_SOEC_base = 1192;

Year = 20;
ele_price = 0.25*1.26;
Ele_de = ele_price;

Rate = 0.03;
CRF_Wind = (Rate*(1+Rate)^Year)/((1+Rate)^Year-1);
Rate_main = 1.06;

C_Mg_char = 2500/7.1/1.5;
C_Mg_storage = 2500/7.1/1.5;
C_Mg_discha = 1800/7.1/1.5;

Wind_power = 2000.4;
P_Windfarm = Wind_power * 5;
P_SOEC = Wind_power * 5;

% ---------------- Monte Carlo settings ----------------
Nsim = 10000;
nCase = numel(total_H2_base);

delta_TH = 0.02 * 0.865;

C_Wind_min = 0.8 * C_Windfarm_base;
C_Wind_max = 1.2 * C_Windfarm_base;

C_SOEC_min = 0.8 * C_SOEC_base;
C_SOEC_max = 1.2 * C_SOEC_base;

Year_SOEC_min = max(1, floor(0.8 * Year_SOEC_base));
Year_SOEC_max = ceil(1.2 * Year_SOEC_base);

Cycle_min = max(1, floor(0.8 * Cycle_year_base));
Cycle_max = ceil(1.2 * Cycle_year_base);

LCOH_MC = zeros(Nsim, nCase);
LCOH_mean = zeros(nCase,1);
LCOH_std  = zeros(nCase,1);
LCOH_p5   = zeros(nCase,1);
LCOH_p50  = zeros(nCase,1);
LCOH_p95  = zeros(nCase,1);

rng('shuffle');

% ---------------- Monte Carlo loop ----------------
for icase = 1:nCase
    total_H20 = total_H2_base(icase);

    u = -delta_TH + (2*delta_TH).*rand(Nsim,1);
    total_H2_samps = total_H20 .* (1 + u);

    C_Wind_samps = C_Wind_min + (C_Wind_max - C_Wind_min).*rand(Nsim,1);
    C_SOEC_samps = C_SOEC_min + (C_SOEC_max - C_SOEC_min).*rand(Nsim,1);

    Cycle_year_samps = randi([Cycle_min, Cycle_max], Nsim, 1);
    Year_SOEC_samps  = randi([Year_SOEC_min, Year_SOEC_max], Nsim, 1);

    clc_Wind = Rate_main .* C_Wind_samps .* P_Windfarm .* CRF_Wind;

    CRF_SOEC_samps = (Rate.*(1+Rate).^Year_SOEC_samps) ./ ((1+Rate).^Year_SOEC_samps - 1);
    clc_SOEC = Rate_main .* C_SOEC_samps .* P_SOEC .* CRF_SOEC_samps;

    clc_charging = Ele_de .* total_H2_samps;

    clc_Mg = Rate_main .* (C_Mg_char + C_Mg_storage + C_Mg_discha) ...
             .* CRF_Wind .* total_H2_samps ./ Cycle_year_samps;

    LCOH_samps = (clc_Wind + clc_SOEC + clc_Mg + clc_charging) ./ total_H2_samps;

    LCOH_MC(:,icase) = LCOH_samps;

    LCOH_mean(icase) = mean(LCOH_samps);
    LCOH_std(icase)  = std(LCOH_samps);
    LCOH_p5(icase)   = prctile(LCOH_samps,5);
    LCOH_p50(icase)  = prctile(LCOH_samps,50);
    LCOH_p95(icase)  = prctile(LCOH_samps,95);

    fprintf('Finished case %d / %d: mean LCOH = %.6f\n', icase, nCase, LCOH_mean(icase));
end

% ---------------- Create a common xi grid and compute PDFs (ARRAYS) ----------------
Nxi = 100;  
LCOH_min = min(LCOH_MC(:));
LCOH_max = max(LCOH_MC(:));
buff = 0.02 * (LCOH_max - LCOH_min); 
xi_common = linspace(LCOH_min - buff, LCOH_max + buff, Nxi)'; 

PDF_xi = repmat(xi_common, 1, nCase);  
PDF_f  = zeros(Nxi, nCase);             

for ic = 1:nCase
    PDF_f(:, ic) = ksdensity(LCOH_MC(:,ic), xi_common);
end

% disp array of integrals (optional)
integrals = trapz(xi_common, PDF_f);  % 1 x nCase
fprintf('Integral of each PDF (should ~1):\n');
disp(integrals);

