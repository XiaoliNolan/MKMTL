function [beta, obj] = l21lq(trInd,C,pk,y,K,rankQ,M,U)

fprintf('trrg_mkmtfl_md is being called\n');

myEps = 10e-5;
ITER_MAX = 2;
T = size(y,1);

k = size(K,3);
delta = (1e-8)/k;
isConv = 0;
qbar = pk/(2-pk);

%Initialization of Q{j} 
for j=1:k
    L_Q{j} = eye(rankQ(j));
    lambda_Q{j} = 1/(k^(1/qbar)*rankQ(j))*ones(rankQ(j),1);
end
%%SOLVER%%
obj = realmax;
%Start of Mirror Descent
for iter = 1:ITER_MAX
    fprintf('.');
    obj_old = obj;
    %Compute gradient g_g{j} by solving T SVRs with current Q{j}
    obj=0;
    %computing Q{j} (aliased by g_g{j})
    for j=1:k
        g_g{j} = L_Q{j}*diag(lambda_Q{j})*L_Q{j}';
    end
    %For each task solve SVR
    for t=1:T
        %Compute temp. kernel
        tmpKern = 1/(2*C)*eye(length(trInd));
        for j=1:k
            tmpKern = tmpKern + M{t,j}'*g_g{j}*M{t,j};
        end
        alpha{t} = tmpKern\y{t}(trInd);
        obj = obj + 0.5*y{t}(trInd)'*alpha{t};
    end
    %Check for convergence of md

    if(obj_old < obj)
        fprintf('Something wrong with convergence! obj_old=%f, obj=%f\n',obj_old,obj);
    elseif((obj_old-obj)/obj_old < myEps)
        isConv=1;
        break;
    end    
    if(iter == ITER_MAX)
        break;
    end
    %Prepare gradient g_g
    for j=1:k
        g_g{j} = zeros(rankQ(j));
        for t=1:T
            tmpVec = M{t,j}*alpha{t};
            g_g{j} = g_g{j} + tmpVec*tmpVec';
        end
        g_g{j} = -0.5*g_g{j};
    end
    %End of computing gradient g_g{j} by solving T SVRs
    %Compute P{j} matrices (aliased by g_g{j} itself)
    %00-scatten norm for step-size computation
    eigsopts.disp = 0;
    for j=1:k
        g_ginf(j) = abs(eigs((g_g{j}+g_g{j}')/2,1,'lm',eigsopts));
    end
    s_g = sqrt(log(sum(rankQ))/iter)/max(g_ginf);                     %%%%%%%%%Can be avoided if expensive
    mu=[];
    for j=1:k
        g_g{j} = s_g*g_g{j}-(L_Q{j}*diag(log(lambda_Q{j}+delta)+1)*L_Q{j}');
        [L_Q{j},g_g{j}] = eig((g_g{j}+g_g{j}')/2);g_g{j} = diag(g_g{j});
        mu = [mu;g_g{j}];
    end
    lambda = solveGrVarProb(mu,rankQ,qbar);
    for j=1:k
        lambda_Q{j} = lambda(sum(rankQ(1:j-1))+1:sum(rankQ(1:j-1))+rankQ(j));
    end
end
%End of Mirror Descent
%%END OF SOLVER%%
%Update beta
for j=1:k
    g_g{j} = U{j}'*L_Q{j}*diag(lambda_Q{j})*L_Q{j}';
    for t=1:T
        beta{t,j} = g_g{j}*M{t,j}*alpha{t};
    end
end
if(isConv==1)
    fprintf('Successfull convergence\n');
else
    fprintf('Convergence premature\n');
end

