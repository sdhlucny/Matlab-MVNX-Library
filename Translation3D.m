classdef Translation3D
% Represents a translation (or position) in 3D space.
    properties
        x
        y
        z
    end
    methods
        % Constructs a 3D translation from a cartesian coordinate vector
        function self = Translation3D(vector)
            self.x = vector(1);
            self.y = vector(2);
            self.z = vector(3);
        end
        
        % Translates this Translation3D by another Translation3D.
        function out = translateBy(self, other)
            x = self.x + other.x;
            y = self.y + other.y;
            z = self.z + other.z;
            out = Translation3D([x y z]);
        end
    end
end
