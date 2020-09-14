function M = simulator(mdp)

mdp.s(2,1)= 1;
mdp.s(4,1) = 1; % naming + french
mdp_run(1:5) = deal(mdp);

mdp.s(2,1)= 2;
mdp.s(4,1) = 1;% repeat + french
mdp_run(6:10) = deal(mdp);

mdp.s(2,1)= 3;
mdp.s(4,1) = 1; % tran + french
mdp_run(11:15) = deal(mdp);

mdp.s(2,1)= 1;
mdp.s(4,1) = 2; % naming + english
mdp_run(16:20) = deal(mdp);

mdp.s(2,1)= 2;
mdp.s(4,1) = 2; % repeat + english
mdp_run(21:25) = deal(mdp);

mdp.s(2,1)= 3;
mdp.s(4,1) = 2; % tran + english
mdp_run(26:30) = deal(mdp);

M = spm_MDP_VB_X(mdp_run);
return 