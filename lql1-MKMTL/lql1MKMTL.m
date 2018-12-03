function YPred = lql1MKMTL(Xtrain,Ytrain,Xtest,Ytest,C,p,opts)

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
        YTotk{k,1} = YTot(:,k);
    end

    [kernel,kerneloptionvec,variableveccell]=CreateKernelListWithVariable(variablevec,dim,kernelt,kerneloptionvect);
    [Weight,InfoKernel]=UnitTraceNormalization(XTot,kernel,kerneloptionvec,variableveccell);
    K=mklkernel(XTot,InfoKernel,Weight,IndTot);
    
    [alpha, lambda, gamma, obj, utnfac, countInv] = trainlql1(trInd,C,p, YTotk,K);
    YPred = prelql1(trInd, teInd, alpha, lambda, gamma, utnfac,YTotk,K);    
   


