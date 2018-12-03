function Pitch = findPitch(Point, Origo, y)

fourths = [G1 A1 B1 C2 D2 E2 F2 G2 A2 B2 C3 D3 E3 F3 G3 A3 B3 C4 D4 E4];

eights = [g1 a1 b1 c2 d2 e2 f2 g2 a2 b2 c3 d3 e3 f3 g3 a3 b3 c4 d4 e4];

BoxSize = Point - Origo; 

Dist = BoxSize(1)/8;

Pitch = (y-Origo) / Dist;   

end