function [YPred] = prel21lq(beta,trInd,teInd,K)

T = size(beta,1);
k = size(beta,2);

for t=1:T
    %Compute the predictions
    YPred{t} = zeros(length(teInd),1);
    for j=1:k
        YPred{t} = YPred{t} + K(teInd,trInd,j)*beta{t,j};
    end
end

