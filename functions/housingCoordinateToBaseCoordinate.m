function housingUnitVectorsInBaseCoordinate = housingCoordinateToBaseCoordinate(topToTarget, baseToTop, t, rotation)
% all inputs in size 3 * 1

    addpath("../functions")
    
    housingUnitVectorsInHousingCoordinate = [30, 0, 0;
                                             0, 30, 0;
                                             0, 0, 30];

    %% from housing coordinate to target coordinate, it just a rotation in z axis
    housingCoordinateYInTopPlatformCoordinate = [topToTarget(1, 1); topToTarget(2, 1); 0] / norm([topToTarget(1, 1), topToTarget(2, 1), 0]);
    % disp(housingCoordinateYInTopPlatformCoordinate)
    theta = -pi/2;
    Rz = [cos(theta), -sin(theta), 0; sin(theta), cos(theta), 0; 0, 0, 1];
    housingCoordinateXInTopPlatformCoordinate = Rz * housingCoordinateYInTopPlatformCoordinate;
    % disp(housingCoordinateXInTopPlatformCoordinate)

    zRotationTargetCoordinateToHousingCoordinate = atan2(housingCoordinateXInTopPlatformCoordinate(2), housingCoordinateXInTopPlatformCoordinate(1)); 
    % disp(zRotationTargetCoordinateToHousingCoordinate)
    % disp(rad2deg(zRotationTargetCoordinateToHousingCoordinate))

    housingUnitVectorsInTargetCoordinate = convertToNewFrame(zRotationTargetCoordinateToHousingCoordinate, 0, 0, [0; 0; 0], housingUnitVectorsInHousingCoordinate);
    % disp("target coord: ")
    % disp(housingUnitVectorsInTargetCoordinate)
    
    %% from target coordinate to home target coordinate
    housingUnitVectorsInHomeTargetCoordinate = convertToNewFrame(rotation(1, 1), rotation(2, 1), rotation(3, 1), t, housingUnitVectorsInTargetCoordinate);
    % disp("home target coord: ")
    % disp(housingUnitVectorsInHomeTargetCoordinate)

    %% from home target coordinate to home platform coordinate
    housingUnitVectorsInHomePlatformCoordinate = topToTarget + housingUnitVectorsInHomeTargetCoordinate;
    % disp("home platform coord: ")
    % disp(housingUnitVectorsInHomePlatformCoordinate)

    %% from home platform coordinate to base coordinate
    housingUnitVectorsInBaseCoordinate = baseToTop + housingUnitVectorsInHomePlatformCoordinate;
    % disp("base coord: ")
    % disp(housingUnitVectorsInBaseCoordinate)
    
end