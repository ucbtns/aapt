function mdp =  generative_model(lesion,w)

rng('default')
% Three Tasks
% ------------------------------------------------
% Picture Naming (task 1):
% Epoch 1. Subject is presented with a visual stimuli 
% Epoch 2. Subject has to identify the object in  
% the picture (visual stimuli).'

% Translation (task 2):
% Epoch 1. Subject is presented with a auditory 
% stimuli in French/English
% Epoch 2. Subject has to translate the word to
% the English/French
 
% Repetition (task 3):
% Epoch 1. Subject is presented with a auditory 
% stimuli in French/English
% Epoch 2. Subject has to repeat the word
% ------------------------------------------------

t= 3;
n_words = 12;
n_languages = 2;
word = {'girl' 'man' 'baby' 'cat' 'dog' 'parrot' 'ring' 'scarf' 'hat' 'leaflet' 'book' 'newspaper'};

language = {'french', 'english'};

combined = {n_words*n_languages};
n = 1;
for i = 1:numel(language)
    for j = 1:numel(word)
        combined{n}  = strcat(word{j},'_',language{i});
        n = n+1;
    end
end

label.factor{1}  = 'Word';  label.name{1}  =word; 
label.factor{2} = 'Context'; label.name{2} = {'naming', 'repetition', 'translation'};
label.factor{3} = 'Epoch'; label.name{3} = {'1', '2', '3'};
label.factor{4} = 'Heard Language'; label.name{4} = {'French', 'English'};
label.factor{5} = 'Target Language'; label.name{5} = {'French', 'English'};

combined{(n_words*n_languages)+1} = {'blank'}; % added
combined     = ([combined{:}]);

% prior beliefs about initial states :
%--------------------------------------------------------------------------
for i = 1:numel(label.factor)
    n    = numel(label.name{i});
    D{i} = ones(n,1)/n;
end

% known initial states
%--------------------------------------------------------------------------
D{3}(1)  = exp(8);
D{2}(1) = 8;

% probabilistic mapping from hidden states to outcomes
%--------------------------------------------------------------------------
Nf    = numel(D);
Ng = 5;
for f = 1:Nf
    Ns(f) = numel(D{f}); 
end

label.modality{1} = 'Task';   label.outcome{1}  =  {'Picture Naming', 'Translation', 'Repetition'};
label.modality{2} = 'Audition';   label.outcome{2}  =  combined;
word{13} = 'N/A';
label.modality{3} = 'Visual'; label.outcome{3} =  word;
label.modality{4} = 'Feedback'; label.outcome{4} =  {'Correct', 'Wrong', 'N/A'};
label.modality{5} = 'Language'; label.outcome{5} = {'French','English','Unknown'};

% Likelihood mappings:
for f = 1:Ng
    No(f) = numel(label.outcome{f});   
end

for g = 1:Ng
    A{g} = zeros([No(g),Ns]); 
end


% Specifying the distribution: 
for f1 = 1:Ns(1) 
    for f2 = 1:Ns(2)  
        for f3 = 1:Ns(3)  
            for f4 = 1:Ns(4)    
                for f5 = 1:Ns(5)
                    
                        % Task modality - what is the task in play:
                        % determined by the context factor
                        % ===================
                        A{1}(f2,:,f2,:,:) = 1;  
                        
                        % Audition:
                        % ===================                       
                        % E1: 
                        A{2}(f1,f1,2:3,1,1,:) = 1; % French                   
                        A{2}(f1+n_words,f1,2:3,1,2,:) = 1; % English                        
                        A{2}((n_words*n_languages)+1,:,1,1,:,:) = 1;
               
                        % E2: Naming / Repetition:
                        A{2}(f1,f1,1:2,2,1,1) = 1; % French to French                    
                        A{2}(f1+n_words,f1,1:2,2,2,2) = 1;  % English to English 
                        
                        if f4 ~= f5
                        A{2}(:,:,1:2,2,f4,f5) = 1;
                        end
       
                        % Translation:
                        A{2}(f1,f1,3,2,2,1) = 1;  % English switch to French
                        A{2}(f1+n_words,f1,3,2,1,2) = 1;  % French switch to English
                        A{2}(:,:,3,2,f4,f4) = 1;
                                        
                        A{2}((n_words*n_languages)+1,:,:,3,:,:) = 1;
            
                        % Visual:
                        % ===================     
                        % E1 - context has to be visual
                        % and mapped to target
                        % if audition then blank.
                        A{3}(f1, f1,1,1,:,:) = 1;
                        A{3}((n_words)+1, :,2:3,1,:,:) = 1;

                        % E2/3 we don't see anything:          
                        A{3}(n_words+1,:,:,2:3,:,:) = 1;
                        
                        % Feedback
                        %===================
                        A{4}(3,:,:,1,:,:) =1;
                        A{4}(1, :,1:2,2:3,f4,f4) = 1;
                        A{4}(2, :,3,2:3,f4,f4) = 1;
                        
                        if f4 ~= f5
                        A{4}(2, :,1:2,2:3,f4,f5) = 1;
                        A{4}(1, :,3,2:3,f4,f5) = 1;
                        end
                    
                        % Language
                        % ===================
                        A{5}(f4,:,:,[1 3],f4,:) = 1;                           
                        A{5}(f5,:,:,2,:,f5) = 1;   
                        
                end        
            end
        end
    end
end           


for g = 1:Ng
    a{g} = A{g};
end

if lesion == 1
    a{2}(:,:,:,:,2,:)=spm_softmax(w*log(A{2}(:,:,:,:,2,:) + 0.1)); 
    a{2}(:,:,2,:,1,:) =spm_softmax(w*log(A{2}(:,:,2,:,1,:) + 0.1));   
elseif lesion == 2
    a{2}(:,:,:,:,1,:)=spm_softmax(w*log(A{2}(:,:,:,:,1,:) + 0.1));   
    a{2}(:,:,2,:,2,:) =spm_softmax(w*log(A{2}(:,:,2,:,2,:) + 0.1));   
elseif lesion == 3
    a{2}(:,:,:,:,2,:)=spm_softmax(w*log(A{2}(:,:,:,:,2,:) + 0.1)); 
    a{2}(:,:,:,:,1,:)=spm_softmax(w*log(A{2}(:,:,:,:,1,:) + 0.1)); 
end


% Transition:
%---------------------------------------------------------------------- 
e= 0;
for f = 1:Nf
        B{f} = e*ones(Ns(f));
end

% Target determined by the environmnet:
B{1} = eye(Ns(1));

% Context determined by the environmnet:
B{2} = eye(Ns(2));

% Epoch: controlled by the environment
B{3} = circshift( eye(Ns(3)),1);
B{3}(:,3) = circshift(B{3}(:,3),2); 

B{4} = eye(Ns(4));

 for i = 1:2
    B{5}(i,:,i) = 1;
 end 

x = 2;
tt= 1;

% Policies (1-step policy):
U(:,:,1) = ones(tt,x);
U(:,:,2) =ones(tt,x);
U(:,:,3) = ones(tt,x);
U(:,:,4) = ones(tt,x);
U(:,:,5) = [tt x];
            
% Preferences over outcomes: 
for g = 1:Ng
            C{g}  = ones(No(g),t)*1e-6;
end
    
if lesion == 0
    C{4}(1,2:t) = 1;  
    C{4}(2,2:t) = -1;  
end

% Aggregate 1st level model parameters :
mdp.label = label;       % names of factors and outcomes
mdp.T = 3;                    % stimuli, response, feedback 
mdp.V = U;                  % allowable policies
mdp.A = A;                   % Likelihood (Process)
mdp.a = a;
mdp.B = B;                    % Transition (Process)     
mdp.D = D;                   % Initial State (Process)
mdp.C = C;

mdp       = spm_MDP_check(mdp);

return 
