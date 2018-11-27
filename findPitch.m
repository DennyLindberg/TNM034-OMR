
function [Pitch] = findPitch(centroidArray)

Point = [x2;y2];

BoxSize = Point - Origo; 

Dist = BoxSize(1)/8;
Pitch = zero(length(centroidArray),1);


% följande for-loop kanske ska skrivas som en liten separat funktion i
% rapport syfte som förklaras lite mer utförligt och sedan nämna att vi gör
% detta för alla ceteroider. 
for  i = 1 : length(centroidArray) 
    distfromorigo = centroidArray(i) - Origo(2);
    Pitch(i) = distfromorigo / Dist;   
    % origo(2) + error; %nån form av detta kan behövas nånstans i loopen 
end 
