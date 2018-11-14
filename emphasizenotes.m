function [result] = emphasizenotes(photograyscale)
    weakenedNotes = imdilate(photograyscale, strel('Disk',4,8));
    strengthenedNotes = imerode(photograyscale, strel('Disk',1,8));
    extractedNotes = imsubtract(weakenedNotes, strengthenedNotes);
    
    originalPrepared = prepareforsegmentation(photograyscale, 64, 0.5);
    result = (extractedNotes+originalPrepared) .* extractedNotes;
end

