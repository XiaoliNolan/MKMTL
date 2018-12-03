function YPred = prelql1(trInd, teInd, alpha, lambda, gamma, utnfac, y, K)

T = size(y,1);      
k = size(K,2);       

for t=1:T
    K_comb = zeros(size(teInd,1),size(trInd,1));
    for j=1:k
        K_comb = K_comb + gamma(j)*(K{1,j}(teInd,trInd)+K{1,j}(trInd,teInd)')/(lambda(j,t)*utnfac(t,j));
    end
    YPred{t} = K_comb*alpha{t};
end

