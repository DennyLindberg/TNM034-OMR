function [staffOrigin, staffFifthLine] = getStaffSplineCoordinates(staffStruct, x)
    % If no spline is present, return the bounding box coordinate system
    if isempty(staffStruct.topSpline) || isempty(staffStruct.bottomSpline)
       staffOrigin = staffStruct.top;
       staffFifthLine = staffStruct.bottom;
    else
       staffOrigin = round(ppval(x, staffStruct.topSpline));
       staffFifthLine = round(ppval(x, staffStruct.bottomSpline));
    end
end

