function servoAngleArray = computeServoAngleArray(pArray, bArray, s, a, betaArray) 
% inputs:
% (all coordinate-related inputs are in base frame)
%   t: the translation vector, i.e., the origin of the Platform frame 
%       expressed in Base frame, size 3 * 1.
%   pArray: p is the point of the joint between the supporting rod and the 
%       top platform, size 3 * 6.
%   bArray: b is the point of rotation of the servo arm for a servo motor, 
%       size 3 * 6.
%   s: length of the supporting leg.
%   a: length of the servo operating arm.
%   betaArray: beta is the angle of the servo arm plane relative to the 
%       x-axis of Base frame, size 1 * 6.
% ouput:
%   servoAngleArray: 6 servo angles that are computed by inverse kinematics 
%       given the inputs, size 1 * 6.
% reference: 
%   https://cdn.instructables.com/ORIG/FFI/8ZXW/I55MMY14/FFI8ZXWI55MMY14.pdf
%   We follow this article closely and also keep their variable naming 
%   decision.
    
    % Step 1: compute lLengthArray, l as the vector points from b to p, 
    % expressed in Base frame.
    lArray = pArray - bArray;
    lLengthArray = zeros(1, 6); % 1 * 6 matrix
    for i = 1:6
        lLengthArray(i) = sqrt(lArray(1, i)^2 + lArray(2, i)^2 + ...
            lArray(3, i)^2);
    end

    % Step 2: compute servoAngleArray.
    % refer L, M, B in the reference article
    L = lLengthArray.^2 - (s^2 - a^2);
    M = 2 * a * (pArray(3, :) - bArray(3, :)); % 1 * 6
    N = 2 * a * (cos(betaArray) .* (pArray(1, :) - bArray(1, :)) + ...
        sin(betaArray) .* (pArray(2, :) - bArray(2, :))); % 1 * 6
    servoAngleArray = asin(L ./ sqrt(M.^2 + N.^2)) - ...
        atan(N ./ M); % 1 * 6

    % Step 3: check out-of-range error. If the input is output range, i.e., 
    % there is an imaginary part for the computed angle, we will output an
    % error.
    hasImaginary = any(imag(servoAngleArray(:)) ~= 0);
    if hasImaginary
        error('Out of range.');
    end
end