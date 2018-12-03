function [paras] = parameters(Xtrain,Ytrain,Xtest,Ytest,opts)

    Tasks = opts.Tasks;
    dim = opts.Dimen;
    kernelt = opts.kernelt;
    kerneloptionvect = opts.kerneloptionvect;
    variablevec = opts.variablevec;

    XTot = cat(1,Xtest,Xtrain);
    YTot = cat(1,Ytest,Ytrain);
    teInd = [1:size(Xtest,1)]';
    trInd = [size(Xtest,1)+1:size(Xtest,1)+size(Xtrain,1)]';
    IndTot = [teInd;trInd]; 

    for k = 1:Tasks
        Ytestk{k,1} = Ytest(:,k);
        YTotk{k,1} = YTot(:,k);
    end

    [kernel,kerneloptionvec,variableveccell]=CreateKernelListWithVariable(variablevec,dim,kernelt,kerneloptionvect);
    [Weight,InfoKernel]=UnitTraceNormalization(XTot,kernel,kerneloptionvec,variableveccell);
    K=mklkernel(XTot,InfoKernel,Weight,IndTot);
    
    T = size(YTot,1);
    totTrInd = [];
    totTrInd = [totTrInd;trInd];
    m = length(totTrInd);
    k = size(K,3);
    M = cell(T,k);
    %Kernelization tricks
    for j=1:k
        [U{j},D] = eig((K(totTrInd,totTrInd,j)+K(totTrInd,totTrInd,j)')/2);
        rankQ(j,1) = rank(D);
        tmpnzpo = m-rankQ(j)+1;
        U{j} = D(tmpnzpo:m,tmpnzpo:m)^(-0.5)*U{j}(:,tmpnzpo:m)';
        for t=1:T
            M{t,j} = U{j}*K(totTrInd,trInd,j);
        end
    end
    
    paras.Tasks = Tasks;
    paras.trInd = trInd;
    paras.teInd = teInd;
    paras.YTotk = YTotk;
    paras.Ytestk = Ytestk;
    paras.K = K;
    paras.rankQ = rankQ;
    paras.M = M;
    paras.U = U;


