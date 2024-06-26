addpath("../functions")

translation = transpose([0.9, 3, 4]);
rotation = transpose([0, 0, 0]);
topToTarget = transpose([0, -10, 5]);

[result1, result2] = targetToTopPlatform(translation, rotation, topToTarget);
display(result1)
display(result2)

oldTop = transpose([0, 0, 0]);
oldTarget = topToTarget;
newTop = result1;
newTarget = oldTarget + translation;
points = [oldTop, oldTarget, newTop, newTarget];

disp(norm(oldTarget - oldTop))
disp(norm(newTarget - newTop))

x = points(1, :); % Extracts the first column (x-coordinates)
y = points(2, :); % Extracts the second column (y-coordinates)
z = points(3, :); % Extracts the third column (z-coordinates)


display(points)
plot3(x, y, z, 'o');
hold on;
% display(x)
plot3(x(1: 2), y(1: 2), z(1: 2));
plot3(x(3: 4), y(3: 4), z(3: 4));
hold off;


