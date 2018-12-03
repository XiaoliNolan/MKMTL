function [alpha, lambda, gamma, obj, utnfac, countInv] = trainlql1(trInd,C,p,y,K)

lastwarn('');
ITER_MAX = 200; 
myEps = 10e-4;  
myTol = 10e-8;
T = size(y,1);        
k = size(K,2);        
utnfac = zeros(T,k);
for t=1:T   
    m(t) = size(trInd,1);    
    for j=1:k
        utnfac(t,j) = trace(K{1,j}(trInd,trInd));
    end
end
if(p<2)
    fprintf('Invalid value of p\n');
    return;
elseif(p==2)
    q = inf;
elseif(p==inf)
    q = 1;
else
    q = p/(p-2);
end
gamma = 1/k*ones(k,1);          %Initialize gamma


if(p~=2)
    lambda = 1/T^(1/q)*ones(k,T);             %Initialize lambda
else
    lambda = ones(k,T);
end
sumQuaTerm = zeros(k,1);
quaTerms = zeros(k,T);

%Loop for gamma
countInv = 0;%Pratik

min_obj = 1.7977e+300;
min_alpha = [];
min_gamma = gamma;
min_lambda = lambda;
obj_gloop = -1.7977e+300;
for iter_gamma = 1:ITER_MAX

    %Solve for alpha, lambda; given gamma
    obj_inner_old = -1.7977e+300;
    for iter_inner = 1:ITER_MAX

        %Update alphas by building T SVMs
        sumLinTerm = 0;
        for t=1:T

            K_comb = sparse(zeros(m(t)));
            for j=1:k
                K_comb = K_comb + (gamma(j)/(lambda(j,t)*utnfac(t,j)))*K{1,j}(trInd,trInd);
            end
            K_comb = K_comb + K_comb' - diag(diag(K_comb)) + 1/C*eye(m(t));

            alpha{t} = K_comb\y{t}(trInd);
            [msgstr,msgid] = lastwarn;
            if ~isempty(msgstr)
                break;
            end
            sumLinTerm = sumLinTerm + y{t}(trInd)'*alpha{t}-(1/(2*C))*alpha{t}'*alpha{t};
            for j=1:k
                quaTerms(j,t) = (alpha{t}'*K{1,j}(trInd,trInd)*alpha{t}-0.5*alpha{t}'*(diag(K{1,j}(trInd,trInd)).*alpha{t}))/utnfac(t,j);
            end
        end
        countInv = countInv + 1;
        %Update lambdas; given alphas and gamma
        if(p~=2)
            for j=1:k
                lambda(j,:) = quaTerms(j,:).^(1/(q+1))/((sum(quaTerms(j,:).^(q/(q+1))))^(1/q));
            end
        end
        if(T~=1)
            sumQuaTerm=-sum((quaTerms./lambda)')';
        else
            sumQuaTerm=-quaTerms./lambda;
        end
        obj_inner = sumLinTerm + gamma'*sumQuaTerm;
        if(p==2)
            break;
        end
        if(obj_inner_old > obj_inner)
            fprintf('This is bad! obj_gloop=%f, obj_inner=%f\n',obj_gloop, obj_inner);
            break;
        elseif((obj_inner-obj_inner_old)/abs(obj_inner_old)<myEps)
            break;
        end
        obj_inner_old = obj_inner;
        if ~isempty(msgstr)
            break;
        end
    end
    if(min_obj > obj_inner)
        min_obj = obj_inner;
        min_alpha = alpha;
        min_lambda = lambda;
        min_gamma = gamma;
    end
    if((obj_inner-obj_gloop)/abs(obj_gloop)<myEps)
        break;
    end
    %Gradient computation
    warning off
    pvec = sumQuaTerm.*sqrt(log(k))./(sqrt(iter_gamma)*norm(sumQuaTerm,inf))-1-log(gamma);
    warning on
    gamma = exp(-pvec); gamma = gamma/sum(gamma); gamma(find(gamma<myTol)) = 0;
    %Calculate obj and check for convergence
    obj_gloop = sumLinTerm + gamma'*sumQuaTerm;
    if ~isempty(msgstr)
        break;
    end
end
obj = min_obj;
gamma = min_gamma;
lambda = min_lambda;
alpha = min_alpha;
