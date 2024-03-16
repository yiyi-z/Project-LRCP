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

    rotationMatrix = [cos(psi) * cos(theta), ...
        -sin(psi) * cos(phi) + cos(psi) * sin(theta) * sin(phi),...
        sin(psi) * sin(phi) + cos(psi) * sin(theta) * cos(phi);
        ...
        sin(psi) * cos(theta),...
        cos(psi) * cos(phi) + sin(psi) * sin(theta) * sin(phi),...
        -cos(psi) * sin(phi) + sin(psi) * sin(theta) * cos(phi);
        ...
        -sin(theta),...
        cos(theta) * sin(phi),...
        cos(theta) * cos(phi)];

    vectorArrayNewFrame = t + rotationMatrix * vectorArray;
end
