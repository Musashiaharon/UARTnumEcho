/* Since we may generate characters faster than we can
 * send them over serial, CharFifo buffers them for us.
 */
module CharFifo(
    clk,
    rst,

    di,
    diValid,
    diReady,

    do,
    doValid,
    doReady
    );
    input clk, rst;

    input [7:0] di;
    input diValid;
    output diReady;

    output [7:0] do;
    output doValid;
    input doReady;


    parameter DEPTH = 1024;
    reg [7:0] fifo [DEPTH-1:0];

    reg [15:0] ra, wa;

    wire [15:0] size;
    wire full, empty;

    assign size = (wa>=ra) ? (wa-ra) : (wa-ra+DEPTH);

    assign full = size+1 == DEPTH;
    assign empty = size == 0;

    assign diReady = !full;
    assign doValid = !empty;

    assign do = fifo[ra];

    always @(posedge clk) begin
        if (rst) begin
            ra <= 0;
            wa <= 0;
        end
        else begin 
            if (diValid && diReady) begin
                fifo[wa] <= di;
                if (wa+1 >= DEPTH) wa <= 0;
                else               wa <= wa+1;
            end
            
            if (doReady && doValid) begin
                if (ra+1 >= DEPTH) ra <= 0;
                else               ra <= ra+1;
            end
        end
        
    end

endmodule
