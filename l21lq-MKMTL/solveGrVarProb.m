function [lambda,obj] = solveGrVarProb(mu,groups,qbar)

myTol = 1e-8;
myEps = 1e-8;
totd = size(mu,1);
k = size(groups,1);
delta = myEps/k;
if(totd~=sum(groups))
    fprintf('Invalid input\n');
end


for j=1:k
    muj = mu(sum(groups(1:j-1))+1:sum(groups(1:j-1))+groups(j));
    mubar{j} = exp(-muj);
    mubar{j} = mubar{j}/sum(mubar{j});
    ind = find(mubar{j});
    f(j,1) = mubar{j}'*muj+(mubar{j}(ind))'*log(mubar{j}(ind));
end

if(k==1)
    rho = 1;
    obj = 0;
else
    cvx_begin
        cvx_quiet(true);
        variable rho(k);
        minimize(f'*rho-sum(entr(rho+delta)));
        subject to
        rho >= 0;
        norm(rho,qbar) <= 1;
    cvx_end
    obj = cvx_optval;
end

lambda = [];
for j=1:k
    lambda=[lambda;rho(j)*mubar{j}];
end

return
