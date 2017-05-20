function newspc = getScan(spc, scanSelection)

    if(scanSelection == 0)
        scanSelection = 1:size(spc, 2);
    end

    newspc = spc(:, scanSelection);
    
    
