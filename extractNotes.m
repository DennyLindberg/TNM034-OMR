function [noteHeads] = extractNotes(imageBW)
%     scaleFactor = size(imageBW, 2)/1024;
%     beamErode = round(12*scaleFactor);
%     beamClean = max(1, round(1*scaleFactor));
%     beamDilate = round(6*scaleFactor);
%     removeResidues = round(4*scaleFactor);
% 
%     % Get beams, so that we "backwards" can remove them
%     beams = imerode(imageBW, strel('line', beamErode, 0));
%     beams = imopen(beams, strel('disk', beamClean, 4));
%     beams = ~imdilate(beams, strel('disk', beamDilate, 4));
% 
%     % Remove the beams
%     noteHeads = beams & imageBW;
%     
%     % Remove everything that is not a note head
%     noteHeads = imopen(noteHeads, strel('disk', removeResidues, 4));




    scaleFactor = size(imageBW, 2)/1024;
    beamErode = round(14*scaleFactor);
    beamClean = max(1, round(1*scaleFactor));
    beamDilate = round(6*scaleFactor);
    removeResidues = round(4*scaleFactor);
    
    beams = imclose(imageBW, strel('line', 10, 0));
    beams = imopen(beams, strel('line', 30, 0));
    beams = imopen(beams, strel('line', 5, 90));
    
    [labels, labelCount] = bwlabel(beams);
    props = regionprops(labels, 'MajorAxisLength');
    removalLimit = 30*scaleFactor;  % TODO: Must be set per staff
    for k=1:labelCount        
        axisLength = props(k).MajorAxisLength;
        if axisLength < removalLimit
            labels(labels == k) = 0;
        end
    end
    beams = labels > 0;
    
    imageBW = imageBW & ~beams;
    
    imageBW = imopen(imageBW, strel('line', 10, 90));
    imageBW = imopen(imageBW, strel('rectangle', [8 12]));
    imageBW = imopen(imageBW, strel('disk', 8, 4));
    
    noteHeads = imageBW;
end

