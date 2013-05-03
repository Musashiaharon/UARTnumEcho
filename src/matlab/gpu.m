function gpu(xCenter,yCenter)

    theta = 0 : 0.2 : 2*pi;
    radius = 2;
    x = radius * cos(theta) + xCenter;
    y = radius * sin(theta) + yCenter;
    plot(x, y);
    axis square;
    xlim([-40 40]);
    ylim([-40 40]);
    grid on;
    grid MINOR;
end