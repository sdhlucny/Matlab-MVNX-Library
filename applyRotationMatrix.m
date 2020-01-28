function out = applyRotationMatrix(eulerVector, rotation)
    temp = rotation * eulerVector';
    out = temp';