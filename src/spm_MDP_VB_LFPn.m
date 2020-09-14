function [u,v] = spm_MDP_VB_LFPn(MDP,UNITS,f,SPECTRAL)
% auxiliary routine for plotting simulated electrophysiological responses
% FORMAT [u,v] = spm_MDP_VB_LFP(MDP,UNITS,FACTOR,SPECTRAL)
%
% MDP        - structure (see spm_MDP_VB_X.m)
%  .xn       - neuronal firing
%  .dn       - phasic dopamine responses
%
% UNITS(1,j) - hidden state                           [default: all]
% UNITS(2,j) - time step
%
% FACTOR     - hidden factor to plot                  [default: 1]
% SPECTRAL   - replace raster with spectral responses [default: 0]
%
% u - selected unit rate of change of firing (simulated voltage)
% v - selected unit responses {number of trials, number of units}
%
% This routine plots simulated electrophysiological responses. Graphics are
% provided in terms of simulated spike rates (posterior expectations).
%
% see also: spm_MDP_VB_ERP (for hierarchical belief updating)
%__________________________________________________________________________
% Copyright (C) 2005 Wellcome Trust Centre for Neuroimaging
 
% Karl Friston
% $Id: spm_MDP_VB_LFP.m 7653 2019-08-09 09:56:25Z karl $
 
 
% defaults
%==========================================================================
try, f;          catch, f        = 1;  end
try, UNITS;      catch, UNITS    = []; end
try, SPECTRAL;   catch, SPECTRAL = 0;  end
try, MDP = spm_MDP_check(MDP);         end

% dimensions
%--------------------------------------------------------------------------
Nt     = length(MDP);               % number of trials
try
    Ne = size(MDP(1).xn{f},4);      % number of epochs
    Nx = size(MDP(1).B{f}, 1);      % number of states
    Nb = size(MDP(1).xn{f},1);      % number of time bins per epochs
catch
    Ne = size(MDP(1).xn,4);         % number of epochs
    Nx = size(MDP(1).A, 2);         % number of states
    Nb = size(MDP(1).xn,1);         % number of time bins per epochs
end

% units to plot
%--------------------------------------------------------------------------
ALL   = [];
for i = 1:Ne
    for j = 1:Nx
        ALL(:,end + 1) = [j;i];
    end
end
if isempty(UNITS)
    UNITS = ALL;
end
    
% summary statistics
%==========================================================================
for i = 1:Nt
    
    % all units
    %----------------------------------------------------------------------
    str    = {};
    try
        xn = MDP(i).xn{f};
    catch
        xn = MDP(i).xn;
    end
    for j = 1:size(ALL,2)
        for k = 1:Ne
            zj{k,j} = xn(:,ALL(1,j),ALL(2,j),k);
            xj{k,j} = gradient(zj{k,j}')';
        end
        str{j} = sprintf('%s: t=%i',MDP(1).label.name{f}{ALL(1,j)},ALL(2,j));
    end
    z{i,1} = zj;
    x{i,1} = xj;
    
    % selected units
    %----------------------------------------------------------------------
    for j = 1:size(UNITS,2)
        for k = 1:Ne
            vj{k,j} = xn(:,UNITS(1,j),UNITS(2,j),k);
            uj{k,j} = gradient(vj{k,j}')';
        end
    end
    v{i,1} = vj;
    u{i,1} = uj;
    
    % dopamine or changes in precision
    %----------------------------------------------------------------------
    %if size(mean(MDP(i).dn,2),1) == 32
        dn(:,i) = mean(MDP(i).dn,2);
    %else
       % dn(:,i) = ones(32,1)*0.125;
    % end

end

if nargout, return, end
 
% phase amplitude coupling
%==========================================================================
dt  = 1/64;                              % time bin (seconds)
t   = (1:(Nb*Ne*Nt))*dt;                 % time (seconds)
Hz  = 4:32;                              % frequency range
n   = 1/(4*dt);                          % window length
w   = Hz*(dt*n);                         % cycles per window
 
% simulated firing rates and local field potential
%--------------------------------------------------------------------------

image(t,1:(Nx*Ne),64*(1 - spm_cat(z)'))

if numel(str) < 16
   grid on, set(gca,'YTick',1:(Ne*Nx))
   set(gca,'YTickLabel',str)
end
grid on, set(gca,'XTick',(1:(Ne*Nt))*Nb*dt)
if Ne*Nt > 32, set(gca,'XTickLabel',{}), end
if Nt == 1,    axis square,              end
 
 return
