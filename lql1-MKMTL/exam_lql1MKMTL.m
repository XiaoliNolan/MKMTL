
clear
clc

load('../data/test_data.mat');
Xtrain = Data.Xtrain;
Xtest = Data.Xtest;
Ytrain = Data.Ytrain;
Ytest = Data.Ytest;

Iters = length(Xtrain);
Tasks = size(Ytrain{1,1},2);
Dimen = size(Xtrain{1,1},2);

Ncross = 5;
C = 1000;
p = 4;

% % Building the kernels parameters
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
        
    YPred = lql1MKMTL(Xtr,Ytr,Xte,Yte,C,p,opts);
end
 