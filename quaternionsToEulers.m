function out = quaternionsToEulers(quaternionMatrix)
    Euler = zeros(length(quaternionMatrix),3);
    for i = 1:length(quaternionMatrix)
        q = quaternion(quaternionMatrix(i,:));
        Euler(i,:) = q.EulerAngles('123')';
        Euler(i,:) = Euler(i,:) * 180 / pi; % Convert to degrees
    end
    
    out = Euler;
end