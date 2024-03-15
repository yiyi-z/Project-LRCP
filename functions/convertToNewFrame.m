function vectorArrayNewFrame = convertToNewFrame(psi, theta, phi, t, vectorArray)
% Convert vectors in old coordinate frame to a new coordinate frame. 
% inputs:
%   psi: yaw, rotation around z-axis, respect to new frame.
%   theta: pitch, rotation around y-axis, respect to new frame.
%   phi: row, rotation around x-axis, respect to new frame.
%   t: translation from new frame origin to old fram origin, 3 * 1.
%   vectorArray: vectors in old frame, size 3 * n, n is the number of 
%       vectors.

% return vectorArray in new frame, size 3 * n.

    rotationMatrixZ = [cos(psi), -sin(psi), 0; ...
                       sin(psi), cos(psi), 0; ...
                       0, 0, 1];
    rotationMatrixY = [cos(theta), 0, sin(theta); ...
                       0, 1, 0; ...
                       -sin(theta), 0, cos(theta)];
    rotationMatrixX = [1, 0, 0; ...
                       0, cos(phi), -sin(phi); ...
                       0, sin(phi), cos(phi)];
    rotationMatrix = rotationMatrixZ * rotationMatrixY * rotationMatrixX;
    % display(rotationMatrix)
    % display(vectorArray)
    vectorArrayNewFrame = t + rotationMatrix * vectorArray;
end
