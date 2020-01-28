classdef Pose3D
% POSE3D represents a pose (position and orientation) in 3D space.
    properties
        translation % Translation3D object
        rotation % Rotation3D object
    end
    methods
        function self = Pose3D(translation, rotation)
            self.translation = translation;
            self.rotation = rotation;
        end
        
        % Transforms this Pose3D by another Pose3D
        function out = transformBy(self, other)
            % Transforming by another pose means first translating by
            % other.translation and then rotating by other.rotation
            out = Pose3D(self.translation.translateBy(other.translation), self.rotation.rotateBy(other.rotation));
        end
    end
end