function updateStewartPlatformPlot(t, pArray, bArray, betaArray, servoAngleArray, a)
    % We will plot
    % originBase: origin of Base frame, 
    % originPlatform: origin of Platform frame (translations),
    % p1, ..., p6: the points of the joint between supporting rod and the top platform (P_b_arr), 
    % a1, ..., a6: the joint between rotation arm and the rod,
    % b1, ..., b6: the center of the rotation for the motor (B_arr).
    
    originBase = [0, 0, 0];
    originPlatform = t;

    p1 = transpose(pArray(:, 1));
    p2 = transpose(pArray(:, 2));
    p3 = transpose(pArray(:, 3));
    p4 = transpose(pArray(:, 4));
    p5 = transpose(pArray(:, 5));
    p6 = transpose(pArray(:, 6));

    b1 = transpose(bArray(:, 1));
    b2 = transpose(bArray(:, 2));
    b3 = transpose(bArray(:, 3));
    b4 = transpose(bArray(:, 4));
    b5 = transpose(bArray(:, 5));
    b6 = transpose(bArray(:, 6));

    a1 = [a * cos(servoAngleArray(1)) * cos(betaArray(1)), ...
           a * cos(servoAngleArray(1)) * sin(betaArray(1)), ...
           a * sin(servoAngleArray(1))] ...
           + b1;
    a2 = [a * cos(servoAngleArray(2)) * cos(betaArray(2)), ...
           a * cos(servoAngleArray(2)) * sin(betaArray(2)), ...
           a * sin(servoAngleArray(2))] ...
           + b2;
    a3 = [a * cos(servoAngleArray(3)) * cos(betaArray(3)), ...
           a * cos(servoAngleArray(3)) * sin(betaArray(3)), ...
           a * sin(servoAngleArray(3))] ...
           + b3;
    a4 = [a * cos(servoAngleArray(4)) * cos(betaArray(4)), ...
           a * cos(servoAngleArray(4)) * sin(betaArray(4)), ...
           a * sin(servoAngleArray(4))] ...
           + b4;
    a5 = [a * cos(servoAngleArray(5)) * cos(betaArray(5)), ...
           a * cos(servoAngleArray(5)) * sin(betaArray(5)), ...
           a * sin(servoAngleArray(5))] ...
           + b5;
    a6 = [a * cos(servoAngleArray(6)) * cos(betaArray(6)), ...
           a * cos(servoAngleArray(6)) * sin(betaArray(6)), ...
           a * sin(servoAngleArray(6))] ...
           + b6;

    points = {originBase, originPlatform, p1, p2, p3, p4, p5, p6, ...
        b1, b2, b3, b4, b5, b6, a1, a2, a3, a4, a5, a6};
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
    % pi together as a hexogon
    % bi together as a hexogon
    % bi to ai as rotation arm
    % ai to pi as supporting rod
    % OriginBase to OriginPlatform showing translations

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

    axis([-100, 100, -100, 100, 0, 120])
    
end






