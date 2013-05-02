module Bouncy(
    input clk,
    input rst,

    output reg [7:0] x,
    output reg [7:0] y
    );

    parameter XMIN = -38;
    parameter XMAX = 38;
    parameter YMIN = -38;
    parameter YMAX = 38;

    reg [7:0] xv;
    reg [7:0] yv;

    initial begin
        xv = 1;
        yv = 2;
    
        x = 10;
        y = 12;
    end

    always @(posedge clk) begin
        if (rst) begin
            xv <= 1;
            yv <= 2;
            x  <= -10;
            y  <= 0;
        end
        else begin
            if (($signed(x+xv) > $signed(XMAX)) || ($signed(x+xv) < $signed(XMIN))) begin
                xv <= -xv;
            end
            if (($signed(y+yv) > $signed(YMAX)) || ($signed(y+yv) < $signed(YMIN))) begin
                yv <= -yv;
            end

            x <= x + xv;
            y <= y + yv;
        end
    end

endmodule
