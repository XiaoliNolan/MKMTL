
clear
clc

load('../data/test_data21.mat');
Xtrain = Data.Xtrain;
Xtest = Data.Xtest;
Ytrain = Data.Ytrain;
Ytest = Data.Ytest;

Iters = length(Xtrain);
Tasks = size(Ytrain{1,1},2);
Dimen = size(Xtrain{1,1},2);

Ncross = 5;

C = 500;
pk = 1.5;

C_cv = 1*10.^(0:1);
p_cv = [1.01,1.5,1.99];

% Building the kernels parameters
kernelt={'gaussian'  'poly' 'jcb'};
kerneloptionvect={[0.01 0.1 1 10 100 1000] [1 2 3] [1]};
variablevec={'all' 'all' 'all'};

opts.Tasks = Tasks;
opts.Dimen = Dimen;
opts.kernelt = kernelt;
opts.kerneloptionvect = kerneloptionvect;
opts.variablevec = variablevec;

for i = 1:Iters
    fprintf('Iters,%d\n',i);
    Xtr = Xtrain{1,i};
    Xte = Xtest{1,i};
    Ytr = Ytrain{1,i};
    Yte = Ytest{1,i};
    
    RC(i,1) = C;
    RP(i,1) = pk;
    
    paras = parameters(Xtr,Ytr,Xte,Yte,opts);
    result = trainl21lq(paras,C,pk);
end


 