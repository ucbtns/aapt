function simulation

rng('default')

% Control simulation 
control = generative_model(3,100);

for i = 1:9
    if i > 1
        control.a = a;
    end
    
    % run simulation:    
    csim= simulator(control);
    a = csim(end).a;
    [coo, css] = performance(csim,30);
    
    % store results
    if i == 1
       control_simulation = csim(:);
       control_oo = coo;
       control_ss = css;
    else
        control_simulation =  [control_simulation(:); csim(:)];
        control_oo =  [control_oo; coo];
        control_ss =  [control_ss; css];
    end
    
    clear coo css csim
end

save('~\models\control_simulation.mat', 'control_simulation');
save('~\models\control_oo.mat', 'control_oo');
save('~\models\control_ss.mat', 'control_ss');

clear; 

% Alternate antagonism with paradoxical translation:
precision_updates = [10; 10; 25; 25; 50; 50; 100; 100];
z = 0;

for i = 1:9
  
        
    if i<9
        if rem(i, 2) == 1
             z = z + 1;
             one = generative_model(1,precision_updates(z));
             
              % run simulation: 
             osim= simulator(one);
             [ooo, oss] = performance(osim,30);
               
            if i == 1
                 aapt_simulation = osim(:);
                 aapt_oo = ooo;
                 aapt_ss = oss;
            else
                aapt_simulation =  [aapt_simulation(:); osim(:)];
                aapt_oo =  [aapt_oo; ooo];
                aapt_ss =  [aapt_ss; oss];
            end
            clear ooo oss osim one
            
        else 
            z = z + 1;
            two = generative_model(2,precision_updates(z));
             % run simulation: 
            tsim= simulator(two);
            [too, tss] = performance(tsim,30);
            
            aapt_simulation =  [aapt_simulation(:); tsim(:)];
            aapt_oo =  [aapt_oo; too];
            aapt_ss =  [aapt_ss; tss];
            
            clear too tss tsim two
        end
    else
         three = generative_model(3,precision_updates(z));
         tsim= simulator(three);
         [too, tss] = performance(tsim,30);
         
         aapt_simulation =  [aapt_simulation(:); tsim(:)];
         aapt_oo =  [aapt_oo; too];
         aapt_ss =  [aapt_ss; tss];
         
         clear too tss tsim three
    end
      
end

save('~\models\aapt_simulation.mat', 'aapt_simulation');
save('~\models\aapt_oo.mat', 'aapt_oo');
save('~\models\aapt_ss.mat', 'aapt_ss');


