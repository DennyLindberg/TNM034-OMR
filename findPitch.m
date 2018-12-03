
function Pitch = findPitch(Point, Origo, y)

BoxSize = Point - Origo; 

Dist = BoxSize(1)/8;

Pitch = (y-Origo) / Dist;   

end