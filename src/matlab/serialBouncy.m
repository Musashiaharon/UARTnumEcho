x = -30;
y = 0;
xv = .75;
yv = 1;
s = -1;
trash = 126;
while trash == 126
    %if ((x < -38) || (x > 38)); xv = -xv; end
    %if ((y < -38) || (y > 38)); yv = -yv; end
    %x = x+xv;
    %y = y+yv;

    ser = serial('/dev/ttyS0');
    set(ser, 'BaudRate', 115200);
    fopen(ser);
    xCenter = fread(ser, 1, 'schar');
    yCenter = fread(ser, 1, 'schar');
    trash   = fread(ser, 1, 'uchar');
    
    [xCenter, yCenter]
    
    fclose(ser);
    
    clf;
    hold on;
    gpu(xCenter, yCenter);
    gpu(x, y);
    hold off;
    pause(.02);
end

delete(ser);
clear ser;
