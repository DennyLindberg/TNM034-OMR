
function [Pitch] = findPitch(centroidArray)

Point = [x2;y2];

BoxSize = Point - Origo; 

Dist = BoxSize(1)/8;
Pitch = zero(length(centroidArray),1);


% f�ljande for-loop kanske ska skrivas som en liten separat funktion i
% rapport syfte som f�rklaras lite mer utf�rligt och sedan n�mna att vi g�r
% detta f�r alla ceteroider. 
for  i = 1 : length(centroidArray) 
    distfromorigo = centroidArray(i) - Origo(2);
    Pitch(i) = distfromorigo / Dist;   
    % origo(2) + error; %n�n form av detta kan beh�vas n�nstans i loopen 
end 
