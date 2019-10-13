classdef Rotation3D
% ROTATION3D Represents a rotation in 3D space.
% NOTE: This class should be modified to use the quaternion class for angle
% storage.
    properties
        q0
        q1
        q2
        q3
    end
    methods
        % Constructs a 3D rotation from a quaternion vector. Each column
        % represents one part of the quaternion.
        function self = Rotation3D(quaternion)
            self.q0 = quaternion(1);
            self.q1 = quaternion(2);
            self.q2 = quaternion(3);
            self.q3 = quaternion(4);
        end
        
        % Rotates this Rotatation3D by another Rotation3D.
        function out = rotateBy(self, other)
            t0 = other.q0*self.q0 - other.q1*self.q1 - other.q2*self.q2 - other.q3*self.q3;
            t1 = other.q0*self.q1 + other.q1*self.q0 - other.q2*self.q3 + other.q3*self.q2;
            t2 = other.q0*self.q2 + other.q1*self.q3 + other.q2*self.q0 - other.q3*self.q1;
            t3 = other.q0*self.q3 - other.q1*self.q2 + other.q2*self.q1 + other.q3*self.q0;
            out = Rotation3D([t0,t1,t2,t3]);
        end
    end
end