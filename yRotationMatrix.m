function out = yRotationMatrix(degrees)
    out = [cosd(degrees), 0, sind(degrees);
          0, 1, 0;
          -sind(degrees), 0, cosd(degrees)];
end