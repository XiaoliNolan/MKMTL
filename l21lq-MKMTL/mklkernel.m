function K=mklkernel(xapp,InfoKernel,Weight,IndTot)


    xsup=xapp;

    for k=1:length(Weight) 

        Kr=svmkernel(xapp(:,InfoKernel(k).variable),InfoKernel(k).kernel,InfoKernel(k).kerneloption, xsup(:,InfoKernel(k).variable));  %????????????????????????

        Kr=Kr*Weight(k);

        K(IndTot,IndTot,k)=Kr;  
    end