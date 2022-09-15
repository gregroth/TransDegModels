function [t,x]=single_rna_probaribo(kon,koff,prob_delta,exportrate,initiationrate,tmax,initialcondition)
%   Gregory Roth, 2022
%   FMI, gregory.roth@fmi.ch

%% Reaction network:
%   1. export :          export    --mu--> export - 1
%   2. translation ON                 OFF     --kon--> ON
%   3. translation OFF                 ON     --koff--> OFF
%   4. initiation event     ribo --> ribo +1
%   5. degradation ON:       ON  --> deg + ON
%   6. degradation OFF:       OFF --> deg + OFF


%% Rate constants
p.kon = kon;      
p.koff = koff;                     
p.export = exportrate;
p.ini = initiationrate;

%% Initial state
tspan=[0, tmax]; 
x0=initialcondition; 

%% Specify reaction network
prop=@propensities;
stoich_matrix = [-1 1 0 0 0  %export
                 0 -1 1 0 0 %translation ON 
                 0 1 -1 0 0 %translation OFF 
                 0 0 0 1 0]; %initiation event

%% Run simulation
[t,x] = directMethod_probaribo(stoich_matrix, prop, tspan, x0, p,4,prob_delta);
end


function a = propensities(x, p)
% Return reaction propensities given current state x
nuclear_rna = x(1);
trans_off = x(2);
trans_on    = x(3);
degraded_rna= x(5);
a=[p.export*nuclear_rna.*(1-degraded_rna);       %export
     p.kon*trans_off.*(1-degraded_rna).*(1-nuclear_rna);       %translation ON 
     p.koff*trans_on.*(1-degraded_rna).*(1-nuclear_rna);       %translation OFF 
     p.ini.*trans_on.*(1-degraded_rna).*(1-nuclear_rna)];       %initiation event
end
