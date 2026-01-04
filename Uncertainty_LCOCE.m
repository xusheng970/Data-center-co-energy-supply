%% Monte Carlo LCOCE for 10 cases (case-by-case)
clear; clc;

% ---------------- Base data ----------------
total_cool_all = [ ...
    55812005 55240650.5809944 56569150 52012405 54341732 ...
    56671288 47350617 55479644 48720466 39408106 ];

Year = 20;
COP_Chiller = 6.7979;

Rate = 0.03;
CRF = (Rate*(1+Rate)^Year)/((1+Rate)^Year-1);
Rate_main = 1.06;

P_Windfarm = 2000;                     
P_ele_chiller = COP_Chiller * P_Windfarm;
C_ele_chiller = 216;                  

% Monte Carlo settings
Nsim = 10000;                           % MC samples
nCase = numel(total_cool_all);

% Sampling ranges
C_Wind_min = 3400*0.8;  C_Wind_max = 3400*1.2;
C_PCM_min  = 140*0.8;   C_PCM_max  = 140*1.2;
Cycle_min  = 80;        Cycle_max  = 120;

delta_tc = 0.02 * COP_Chiller;          

LCOCE_MC   = zeros(Nsim, nCase);
LCOCE_mean = zeros(nCase,1);
LCOCE_p5   = zeros(nCase,1);
LCOCE_p50  = zeros(nCase,1);
LCOCE_p95  = zeros(nCase,1);

rng('shuffle');

%% -------- Outer loop: 10 cases --------
for icase = 1:nCase

    total_cool_base = total_cool_all(icase);

    C_Windfarm = C_Wind_min + (C_Wind_max-C_Wind_min).*rand(Nsim,1);
    C_PCM_cool = C_PCM_min  + (C_PCM_max -C_PCM_min ).*rand(Nsim,1);
    Cycle_year = randi([Cycle_min, Cycle_max], Nsim,1);

    u = -delta_tc + 2*delta_tc.*rand(Nsim,1);
    total_cool = total_cool_base .* (1 + u);

    clc_Wind = Rate_main .* C_Windfarm .* P_Windfarm .* CRF;
    clc_chiller = Rate_main * C_ele_chiller * P_ele_chiller * CRF;
    clc_PCM = Rate_main .* C_PCM_cool .* CRF .* total_cool ./ Cycle_year;

    % --- LCOCE ---
    LCOCE = (clc_Wind + clc_chiller + clc_PCM) ./ total_cool;

    LCOCE_MC(:,icase) = LCOCE;

    
    LCOCE_mean(icase) = mean(LCOCE);
    LCOCE_p5(icase)   = prctile(LCOCE,5);
    LCOCE_p50(icase)  = prctile(LCOCE,50);
    LCOCE_p95(icase)  = prctile(LCOCE,95);

end

%% -------- Compute & save PDFs (ARRAYS) --------
Nxi = 100;  

LCOCE_min = min(LCOCE_MC(:));
LCOCE_max = max(LCOCE_MC(:));
buff = 0.02 * (LCOCE_max - LCOCE_min);

xi_common = linspace(LCOCE_min - buff, LCOCE_max + buff, Nxi)'; 

LCOCE_PDF_xi = repmat(xi_common, 1, nCase);   
LCOCE_PDF_f  = zeros(Nxi, nCase);            

for icase = 1:nCase
    LCOCE_PDF_f(:,icase) = ksdensity(LCOCE_MC(:,icase), xi_common);
end

check_int = trapz(xi_common, LCOCE_PDF_f);
disp('Integral of each LCOCE PDF (should be ~1):');
disp(check_int);

%% -------- Results table --------
CaseID = (1:nCase)';
T = table(CaseID, LCOCE_mean, LCOCE_p5, LCOCE_p50, LCOCE_p95);
disp(T);

