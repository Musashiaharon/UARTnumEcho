xCenter = -40;
yCenter = -40;
while true 
    xCenter = xCenter + 1;
    yCenter = yCenter + 1;
    center = [xCenter, yCenter];
    dlmwrite('inputs.txt', center, 'Delimiter', '');
    pause(2);
end

