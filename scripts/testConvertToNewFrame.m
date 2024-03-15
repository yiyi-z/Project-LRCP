psi = 0.5 * pi;
theta = 0.2 * pi;
phi = 0.1 * pi;
t = 3;
vector = [1; 2; 3];

vectorNewFrame = convertToNewFrame(psi, theta, phi, t, vector);
disp(norm(vector))
disp(norm(vectorNewFrame - t))