function out = xRotationMatrix(degrees)
    out = [1, 0, 0;
          0, cosd(degrees), -sind(degrees);
          0, sind(degrees), cosd(degrees)];
end