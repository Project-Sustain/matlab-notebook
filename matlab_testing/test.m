function [] = test()

    % Declare two matrices a and b
    a = [1 4 5 9; 2 3 7 1;];
    b = [1 5; 2 4; 7 7; 1 3;];

    % Multiply them together into c
    c = a * b;

    % Write matrix to output file
    writematrix(c,'output.csv')

end
