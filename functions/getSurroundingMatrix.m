function surroundingMatrix = getSurroundingMatrix(center, gapX, gapY, gapZ)
    surroundingMatrix = np.zeros(3, 3, 3);
    for i = 1:3
        for j = 1:3
            for k = 1:3
                % Calculate the coordinates of the cell relative to the center target
                x = center(1) + (i - 2) * gapX; % Adjusted for 1-based indexing
                y = center(2) + (j - 2) * gapY; % Adjusted for 1-based indexing
                z = center(3) + (k - 2) * gapZ; % Adjusted for 1-based indexing
                
                % Assign the coordinates to the matrix
                surroundingMatrix(i, j, k) = [x, y, z];
            end
        end
    end

end