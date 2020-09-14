function [oo, ss] = performance(M, n)


for i = 1:n
   oo(i,:)= spm_vec(M(i).o')';
   ss(i,:)= spm_vec(M(i).s')';
end

return 