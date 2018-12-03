function [kernelcellaux,kerneloptioncellaux,variablecellaux]=CreateKernelListWithVariable(variablecell,dim,kernelcell,kerneloptioncell)

j=1;
for i=1:length(variablecell)
    switch variablecell{i}
        case 'all'
            kernelcellaux{j}=kernelcell{i};
            kerneloptioncellaux{j}=kerneloptioncell{i};
            variablecellaux{j}=1:dim;
            j=j+1;    
        case 'single'
            for k=1:dim
                kernelcellaux{j}=kernelcell{i};
                kerneloptioncellaux{j}=kerneloptioncell{i};
                variablecellaux{j}=k;
                j=j+1;
            end
    end
end
