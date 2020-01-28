function out = zRotationMatrix(degrees)
    out = [cosd(degrees), -sind(degrees), 0;
          sind(degrees), cosd(degrees), 0;
          0, 0, 1];
end