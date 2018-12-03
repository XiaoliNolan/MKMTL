function result = trainl21lq(paras,C,pk)

    trInd = paras.trInd;
    teInd = paras.teInd;
    YTotk = paras.YTotk;
    K = paras.K;
    rankQ = paras.rankQ;
    M = paras.M;
    U = paras.U;

    [beta, obj] = l21lq(trInd,C,pk,YTotk,K,rankQ,M,U);
    YPred = prel21lq(beta,trInd,teInd,K);
    
    result.YPred = YPred;
    result.beta = beta;
    result.obj = obj;
    


