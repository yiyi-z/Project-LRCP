% All measurements in mm.

% Sample input values
translations = [0, 0, 100];  % Replace with user input translation values
rotations = [0, 0, 0];  % Replace with user input rotation values

% Arguments that depend on the configurations of the model
B_arr = [90.53, 49.00, -46.66, -89.04, -41.28, 42.62; ...
         0, 74.28, 74.28, 0, -81.72, -82.72; ...
         0, 0, 0, 0, 0, 0]; % 3 * 6
P_arr = 0.6 * B_arr; % 3 * 6
s = 100;
a = 25;
beta_arr = deg2rad([120, 120, 240, 240, 360, 360]); % 1 * 6

% Call the StewartPlatformIK function
servoAngle_arr = StewartPlatformIK(translations, rotations, P_arr, B_arr, s, a, beta_arr);

% Display the result
disp('Servo Angles (in radians):');
disp(servoAngle_arr);

% Convert servo angles from radians to degrees
angles = rad2deg(servoAngle_arr);
disp('Servo Angles (in degrees):');
disp(angles);


%% Added code to send angles to arduino//////////////////
% Connect to Arduino
arduinoObj = serialport("COM7", 9600); % Update COM3 to your Arduino's port

% Give the Arduino time to reset
pause(2);

% Define an array of numbers
numbers = [0, 0, 0, 0, 0, 0];
%numbers = [0,20];
% Convert the array to a string format: "12,34"
numbersString = strjoin(string(numbers), ",");

% Send the string to Arduino
writeline(arduinoObj, numbersString);

% Wait and read confirmation from Arduino
confirmation = readline(arduinoObj);

% Display the confirmation
disp(['Confirmation from Arduino: ', confirmation]);

% Clean up
clear arduinoObj

%% Inverse Kinematics (6 servoAngles)
function servoAngle_arr = StewartPlatformIK(translations, rotations, P_arr, B_arr, s, a ,beta_arr)
    % Inverse Kinematics for 6-DOF Stewart Platform with 6 rotational servo.
    % Reference: 
    %   https://cdn.instructables.com/ORIG/FFI/8ZXW/I55MMY14/FFI8ZXWI55MMY14.pdf
    %   We follow this article closely and also keep their variable naming decision.
    % Assumptions:
    %   1. The center of rotation of the servo arm is at the x-y plane of the Base frame (can achieve by
    %      defining the Base frame at the same plane of the center of rotations)
    % Inputs:
    %   translations: origin of the platform frame, expressed in the Base frame.
    %   rotations: three angular displacements that defines the orientation of the platform, expressed in the Platform frame.
    %   P_arr: 3 * 6 array of coordinate of the 6 P points. P is the point of the joint between the rod i and the top platform, expressed in the Platform frame.
    %   B_arr: 3 * 6 array of coordinate of the 6 B points. B is the point of rotation of the servo arm for servo motor i, expressed in the Base frame.
    %   s: length of the operating leg.
    %   a: length of the servo operating arm.
    %   beta_arr: 1 * 6 array of 6 beta angles. beta is the angle of the servo arm plane relative to the x-axis of Base frame.
    % Output:
    %   servoAngle_arr: 1 * 6 array of 6 servo angle, the servo angle is the of servo operating arm from horizontal (which is defined by x-y plane of Base frame).

    % Task 1: Process inputs.

    % Get translation column vector T based on the input 'translations'
    T = [translations(1); translations(2); translations(3)]; % 3 * 1 matrix
    % Extract rotation components
    psi = rotations(1);  % Yaw
    theta = rotations(2);  % Pitch
    phi = rotations(3);  % Roll
    

    % Task 2: Calculate l_i. l_i is the length from B_i to P_i. (Consider that if we're using linear servos,
    % this will be the output for length of those linear servos. This helps us to set the fundations for the
    % further calculation for rotational servos.)

    % define the rotation matrix R_pb of the Platform relative to the Base. (R_x, R_y, R_z is the rotation around each axis)
    R_z = [cos(psi), -sin(psi), 0; ...
           sin(psi), cos(psi), 0; ...
           0, 0, 1];
    R_y = [cos(theta), 0, sin(theta); ...
           0, 1, 0; ...
           -sin(theta), 0, cos(theta)];
    R_x = [1, 0, 0; ...
           0, cos(phi), -sin(phi); ...
           0, sin(phi), cos(phi)];
    R_pb = R_z * R_y * R_x; % 3 * 3 matrix

    % calculate L_arr, L as the vector points from B to P, expressed in the Base frame.
    L_arr = T + (R_pb * P_arr) - B_arr; % 3 * 6 matrix

    % calculate l_arr, l is the length from B to P.
    l_arr = zeros(1, 6); % 1 * 6 matrix
    for i = 1:6
        l_arr(i) = sqrt(L_arr(1, i)^2 + L_arr(2, i)^2 + L_arr(3, i)^2);
    end


    % Task 3: Calculate the servoAngle. From our reference article, the alpha will be our servoAngle, please refer our 
    % variable naming there.
    % calculate P_b_arr, P_b is point P in the Base frame
    P_b_arr = T + R_pb * P_arr;
    % refer L, M, B in the reference article
    L = l_arr.^2 - (s^2 - a^2);
    M = 2 * a * (P_b_arr(3, :) - B_arr(3, :)); % 1 * 6
    N = 2 * a * (cos(beta_arr) .* (P_b_arr(1, :) - B_arr(1, :)) + ...
                 sin(beta_arr) .* (P_b_arr(2, :) - B_arr(2, :))); % 1 * 6
    servoAngle_arr = asin(L ./ sqrt(M.^2 + N.^2)) - ...
                     atan(N ./ M); % 1 * 6

    % Task 4: Plot result (in base frame)
    % We will plot
    % O_b: origin of Base frame, 
    % O_p: origin of Platform frame (translations),
    % P_1, ..., P_6: the points of the joint between supporting rod and the top platform (P_b_arr), 
    % A_1, ..., A_6: the joint between rotation arm and the rod,
    % B_1, ..., B_6: the center of the rotation for the motor (B_arr).
    O_b = [0, 0, 0];
    O_p = translations;

    P_1 = transpose(P_b_arr(:, 1));
    P_2 = transpose(P_b_arr(:, 2));
    P_3 = transpose(P_b_arr(:, 3));
    P_4 = transpose(P_b_arr(:, 4));
    P_5 = transpose(P_b_arr(:, 5));
    P_6 = transpose(P_b_arr(:, 6));

    B_1 = transpose(B_arr(:, 1));
    B_2 = transpose(B_arr(:, 2));
    B_3 = transpose(B_arr(:, 3));
    B_4 = transpose(B_arr(:, 4));
    B_5 = transpose(B_arr(:, 5));
    B_6 = transpose(B_arr(:, 6));

    A_1 = [a * cos(servoAngle_arr(1)) * cos(beta_arr(1)), ...
           a * cos(servoAngle_arr(1)) * sin(beta_arr(1)), ...
           a * sin(servoAngle_arr(1))] ...
           + B_1;
    A_2 = [a * cos(servoAngle_arr(2)) * cos(beta_arr(2)), ...
           a * cos(servoAngle_arr(2)) * sin(beta_arr(2)), ...
           a * sin(servoAngle_arr(2))] ...
           + B_2;
    A_3 = [a * cos(servoAngle_arr(3)) * cos(beta_arr(3)), ...
           a * cos(servoAngle_arr(3)) * sin(beta_arr(3)), ...
           a * sin(servoAngle_arr(3))] ...
           + B_3;
    A_4 = [a * cos(servoAngle_arr(4)) * cos(beta_arr(4)), ...
           a * cos(servoAngle_arr(4)) * sin(beta_arr(4)), ...
           a * sin(servoAngle_arr(4))] ...
           + B_4;
    A_5 = [a * cos(servoAngle_arr(5)) * cos(beta_arr(5)), ...
           a * cos(servoAngle_arr(5)) * sin(beta_arr(5)), ...
           a * sin(servoAngle_arr(5))] ...
           + B_5;
    A_6 = [a * cos(servoAngle_arr(6)) * cos(beta_arr(6)), ...
           a * cos(servoAngle_arr(6)) * sin(beta_arr(6)), ...
           a * sin(servoAngle_arr(6))] ...
           + B_6;

    points = {O_b, O_p, P_1, P_2, P_3, P_4, P_5, P_6, B_1, B_2, B_3, B_4, B_5, B_6, A_1, A_2, A_3, A_4, A_5, A_6};
    x = zeros(1, numel(points));
    y = zeros(1, numel(points));
    z = zeros(1, numel(points));
    for i = 1:numel(points)
        x(i) = points{i}(1);
        y(i) = points{i}(2);
        z(i) = points{i}(3);
    end
    scatter3(x, y, z, 'o', 'MarkerFaceColor', 'r');
    

    % connect points for better visualization
    % We will connect:
    % P_i together as a hexogon
    % B_i together as a hexogon
    % B_i to A_i as rotation arm
    % A_i to P_i as supporting rod
    % O_b to O_p showing translations

    line([x(3), x(4)], [y(3), y(4)], [z(3), z(4)], 'Color', 'b', 'LineStyle', '-'); 
    line([x(4), x(5)], [y(4), y(5)], [z(4), z(5)], 'Color', 'b', 'LineStyle', '-'); 
    line([x(5), x(6)], [y(5), y(6)], [z(5), z(6)], 'Color', 'b', 'LineStyle', '-'); 
    line([x(6), x(7)], [y(6), y(7)], [z(6), z(7)], 'Color', 'b', 'LineStyle', '-'); 
    line([x(7), x(8)], [y(7), y(8)], [z(7), z(8)], 'Color', 'b', 'LineStyle', '-'); 
    line([x(8), x(3)], [y(8), y(3)], [z(8), z(3)], 'Color', 'b', 'LineStyle', '-'); 

    line([x(9), x(10)], [y(9), y(10)], [z(9), z(10)], 'Color', 'b', 'LineStyle', '-'); 
    line([x(10), x(11)], [y(10), y(11)], [z(10), z(11)], 'Color', 'b', 'LineStyle', '-'); 
    line([x(11), x(12)], [y(11), y(12)], [z(11), z(12)], 'Color', 'b', 'LineStyle', '-'); 
    line([x(12), x(13)], [y(12), y(13)], [z(12), z(13)], 'Color', 'b', 'LineStyle', '-'); 
    line([x(13), x(14)], [y(13), y(14)], [z(13), z(14)], 'Color', 'b', 'LineStyle', '-'); 
    line([x(14), x(9)], [y(14), y(9)], [z(14), z(9)], 'Color', 'b', 'LineStyle', '-'); 

    line([x(9), x(15)], [y(9), y(15)], [z(9), z(15)], 'Color', 'r', 'LineStyle', '-'); 
    line([x(10), x(16)], [y(10), y(16)], [z(10), z(16)], 'Color', 'r', 'LineStyle', '-'); 
    line([x(11), x(17)], [y(11), y(17)], [z(11), z(17)], 'Color', 'r', 'LineStyle', '-'); 
    line([x(12), x(18)], [y(12), y(18)], [z(12), z(18)], 'Color', 'r', 'LineStyle', '-'); 
    line([x(13), x(19)], [y(13), y(19)], [z(13), z(19)], 'Color', 'r', 'LineStyle', '-'); 
    line([x(14), x(20)], [y(14), y(20)], [z(14), z(20)], 'Color', 'r', 'LineStyle', '-');

    line([x(3), x(15)], [y(3), y(15)], [z(3), z(15)], 'Color', 'r', 'LineStyle', '-'); 
    line([x(4), x(16)], [y(4), y(16)], [z(4), z(16)], 'Color', 'r', 'LineStyle', '-'); 
    line([x(5), x(17)], [y(5), y(17)], [z(5), z(17)], 'Color', 'r', 'LineStyle', '-'); 
    line([x(6), x(18)], [y(6), y(18)], [z(6), z(18)], 'Color', 'r', 'LineStyle', '-'); 
    line([x(7), x(19)], [y(7), y(19)], [z(7), z(19)], 'Color', 'r', 'LineStyle', '-'); 
    line([x(8), x(20)], [y(8), y(20)], [z(8), z(20)], 'Color', 'r', 'LineStyle', '-');

    line([x(1), x(2)], [y(1), y(2)], [z(1), z(2)], 'Color', 'b', 'LineStyle', '-'); 

    % label
    labels = {'O_b', 'O_p', 'P_1', 'P_2', 'P_3', 'P_4', 'P_5', 'P_6', 'B_1', 'B_2', 'B_3', 'B_4', 'B_5', 'B_6', 'A_1', 'A_2', 'A_3', 'A_4', 'A_5', 'A_6'};
    for i = 1:numel(x)
        text(x(i), y(i), z(i), labels{i}, 'FontSize', 8, 'FontWeight', 'bold');
    end
    daspect([1 1 1]); 
    
end




