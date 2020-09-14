function plots

clear;clc;
rng('default')

addpath ~/spm/toolbox/DEM/
addpath ~/spm/
addpath 'D:/PhD/Draft Papers/Current/language_forgetting/car'

load('~\models\aapt_oo.mat', 'aapt_oo');
load('~\models\control_oo.mat', 'control_oo');


aapt = aapt_oo(:,8);
control = control_oo(:,8);

aapt(aapt~=1) = 0;
control(control~=1) = 0;

tt = 9;
n = 0;
for i = 1:tt
    picture_naming(1+(n*5):5+(n*5),3) = aapt(1+(n*30):5+(n*30));
    picture_naming(1+(n*5):5+(n*5),4) = aapt(16+(n*30):20+(n*30));
    picture_naming(1+(n*5):5+(n*5),1) = control(1+(n*30):5+(n*30));
    picture_naming(1+(n*5):5+(n*5),2) = control(16+(n*30):20+(n*30));
    
    word_repetition(1+(n*5):5+(n*5),3) = aapt(6+(n*30):10+(n*30));
    word_repetition(1+(n*5):5+(n*5),4) = aapt(21+(n*30):25+(n*30));
    word_repetition(1+(n*5):5+(n*5),1) = control(6+(n*30):10+(n*30));
    word_repetition(1+(n*5):5+(n*5),2) = control(21+(n*30):25+(n*30));
    
    word_translation(1+(n*5):5+(n*5),3) = aapt(11+(n*30):15+(n*30));
    word_translation(1+(n*5):5+(n*5),4) = aapt(26+(n*30):30+(n*30));
    word_translation(1+(n*5):5+(n*5),1) = control(11+(n*30):15+(n*30));
    word_translation(1+(n*5):5+(n*5),2) = control(26+(n*30):30+(n*30));
    n = n + 1;
end

for i = 1:4
    swt(:,i) = sum(reshape(word_translation(:,i), 5,tt))';
    spn(:,i) = sum(reshape(picture_naming(:,i), 5,tt))';
    swr(:,i) = sum(reshape(word_repetition(:,i), 5,tt))';
end

names= {'Picture naming' 'Word repetition' 'Word translation'};

% Behavioural performance plot:
% -----------------------------------
for i = 1:3
    subplot(3,1,i)
    %colormap gray
    if i == 3
        data = swt; 
    elseif i == 1; data=spn;   
    else; data=swr; end
    bar(data, 'hist');
    if i == 3;  xlabel('(simulated) day number',  'FontSize', 12);
        legend({'#1-L1' '#1-L2' '#2-L1' '#2-L2'},...
                'Orientation','horizontal',...
                'Location', 'best',...
            'FontSize', 12)
    end
    ylim([0,6]);
    ylabel('# correct responses',  'FontSize', 12);
    title(names{i},  'FontSize', 14);
end

clear;

load('~\models\aapt_simulation.mat', 'aapt_simulation');
load('~\models\control_simulation.mat', 'control_simulation');


[Fa,Fua,Fsa,Fqa,Fga,Faa]  =spm_MDP_F(aapt_simulation);
[Fc,Fuc,Fsc,Fqc,Fgc,Fac]   = spm_MDP_F(control_simulation);

n = 0;
for i = 1:9
    fpn(1+(n*5):5+(n*5),3) = Fa(1+(n*30):5+(n*30));
    fpn(1+(n*5):5+(n*5),4) = Fa(16+(n*30):20+(n*30));
    fpn(1+(n*5):5+(n*5),1) = Fc(1+(n*30):5+(n*30));
    fpn(1+(n*5):5+(n*5),2) = Fc(16+(n*30):20+(n*30))-0.5;
    
    fwr(1+(n*5):5+(n*5),3) = Fa(6+(n*30):10+(n*30));
    fwr(1+(n*5):5+(n*5),4) = Fa(21+(n*30):25+(n*30));
    fwr(1+(n*5):5+(n*5),1) = Fc(6+(n*30):10+(n*30));
    fwr(1+(n*5):5+(n*5),2) = Fc(21+(n*30):25+(n*30))-0.5;
    
    fwt(1+(n*5):5+(n*5),3) = Fa(11+(n*30):15+(n*30));
    fwt(1+(n*5):5+(n*5),4) = Fa(26+(n*30):30+(n*30));
    fwt(1+(n*5):5+(n*5),1) = Fc(11+(n*30):15+(n*30));
    fwt(1+(n*5):5+(n*5),2) = Fc(26+(n*30):30+(n*30))-0.5;
    n = n + 1;
end


% Free energy plot:
%--------------------
names= {'Picture naming' 'Word repetition' 'Word translation'};

for i = 1:3
    subplot(3,1,i)
   % colormap gray
    if i == 3
        data(:,1) = sum(fwt(:,1:2),2);
        data(:,2) = sum(fwt(:,3:4),2);
    elseif i == 1
        data(:,1) = sum(fpn(:,1:2),2);
        data(:,2) = sum(fpn(:,3:4),2);
    else
        data(:,1) = sum(fwr(:,1:2),2);
        data(:,2) = sum(fwr(:,3:4),2);
    end
    plot(data, 'LineWidth', 2);
    if i == 3;  xlabel('Trial number',  'FontSize', 12);end
    legend({'#1' '#2' },...
                'Orientation','horizontal',...
                'Location', 'best',...
            'FontSize', 12)
  
    ylim([0,85]);
    ylabel('Free energy (nats)',  'FontSize', 12);
    title(names{i},  'FontSize', 14);
end


% Belief updating plots: 
%------------------------
colormap gray

subplot(2,1,1)
spm_MDP_VB_LFPn(control_simulation,[],5);
title('Model #1', 'FontSize', 16)
subplot(2,1,2)
spm_MDP_VB_LFPn(aapt_simulation,[],5);
title('Model #2', 'FontSize', 16)
xlabel('time (sec)','FontSize',12)


% 61 picture naming
n = 61;
colormap gray
subplot(2,2,1)
spm_MDP_VB_LFPn(control_simulation(n),[],5);
title('Model #1', 'FontSize', 16)
subplot(2,2,2)
spm_MDP_VB_LFPn(aapt_simulation(n),[],5);
title('Model #2', 'FontSize', 16)
xlabel('time (sec)','FontSize',12)
subplot(2,2,3)
spm_MDP_VB_LFPn(control_simulation(n),[],4);
title('Model #1', 'FontSize', 16)
subplot(2,2,4)
spm_MDP_VB_LFPn(aapt_simulation(n),[],4);
title('Model #2', 'FontSize', 16)
xlabel('time (sec)','FontSize',12)

n = 75; % or 86 
colormap gray
subplot(2,2,1)
spm_MDP_VB_LFPn(control_simulation(n),[],5);
title('Model #1', 'FontSize', 16)
subplot(2,2,2)
spm_MDP_VB_LFPn(aapt_simulation(n),[],5);
title('Model #2', 'FontSize', 16)
xlabel('time (sec)','FontSize',12)
subplot(2,2,3)
spm_MDP_VB_LFPn(control_simulation(n),[],4);
title('Model #1', 'FontSize', 16)
subplot(2,2,4)
spm_MDP_VB_LFPn(aapt_simulation(n),[],4);
title('Model #2', 'FontSize', 16)
xlabel('time (sec)','FontSize',12)


n = 66;
colormap gray
subplot(2,2,1)
spm_MDP_VB_LFPn(control_simulation(n),[],5);
title('Model #1', 'FontSize', 16)
subplot(2,2,2)
spm_MDP_VB_LFPn(aapt_simulation(n),[],5);
title('Model #2', 'FontSize', 16)
xlabel('time (sec)','FontSize',12)
subplot(2,2,3)
spm_MDP_VB_LFPn(control_simulation(n),[],4);
title('Model #1', 'FontSize', 16)
subplot(2,2,4)
spm_MDP_VB_LFPn(aapt_simulation(n),[],4);
title('Model #2', 'FontSize', 16)
xlabel('time (sec)','FontSize',12)





