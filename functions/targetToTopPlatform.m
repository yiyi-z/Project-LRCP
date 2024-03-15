% given data of target translation and rotation respect to
% home target coordinate, calculate the translation and 
% rotation of center of top platform respect to home top platform
% coordinate

function [topTranslation, topRotation] = targetToTopPlatform(translation, rotation, topToTarget)
% rotation: target rotation respect to home target coordinate, 3 * 1
% translation: target translation respect to home target coordinate, 3 * 1
% topToTarget: from center of the top platform to target respect to 
% home top platform coordinate, 3 * 1

% returns rotation (3 * 1) and translation (3 * 1) for center of top platform that
% that would generate this motion for target
    addpath("../functions")

    % notice that the rotation is the same
    topRotation = rotation;
    
    topToTargetHomeTargetCoordinate = convertToNewFrame(rotation(1, :), ...
        rotation(2, :), rotation(3, :), zeros(3, 1), topToTarget); % 3 * 1
    topTranslation = translation - topToTargetHomeTargetCoordinate + topToTarget;
    threshold = 1e-6; 
    topTranslation(abs(topTranslation) < threshold) = 0;
    
    
    % display(translation)
    % display(topToTargetHomeTargetCoordinate)
    % display(topToTarget)
    % 
    % display(topRotation)
    % display(topTranslation)
end
