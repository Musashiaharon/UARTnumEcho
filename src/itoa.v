/* Converts integers to ASCII representation, and streams them out with a 
 * ready-valid interface.
 */
module itoa(
    clk,
    rst,

    di, 
    diValid,
    diReady,

    do,
    doValid,
    doReady
    );
    `include "util.vh"

    parameter SIZE = 64;

    input               clk, rst;

    input [SIZE-1:0]    di;
    input               diValid;
    output              diReady;

    output reg [7:0]    do;
    output reg          doValid;
    input               doReady;

    localparam Idle     = 0;
    localparam Classify = 1; // Is negative? Is 0?
    localparam Push     = 2; // Calculate and push chars onto a stack
    localparam Pop      = 3; // Pop them off the stack, reversing digits

    reg     [3:0]           state;
    wire                    busy;
    wire                    start;

    reg     [SIZE-1:0]      theNum;
    wire                    negative;
    wire    [SIZE-1:0]      posNum;

    // For converting to BCD
    reg     [log2(SIZE):0]  digitCounter;
    reg     [7:0]           digitStack [log2(SIZE):0];
    
    assign negative = theNum[SIZE-1];
    assign posNum = negative? -theNum : theNum;

    assign busy    = state != Idle;
    assign diReady = state == Idle;
    assign start   = diReady && diValid;
    
    always @ (posedge clk) begin
        if (rst) begin
            state <= Idle;
        end
        else case(state)
            Idle: begin
                doValid <= 0;
                
                if (start) begin
                    theNum <= di;
                    digitCounter <= 0;

                    state <= Classify;
                end
            end // Idle:

            Classify: begin
                if (negative) begin
                    do <= 8'h2D; // "-"
                    doValid <= 1;
                    if (doReady) begin
                        theNum <= posNum;

                        state <= Push;
                    end
                end // if (negative)
                else if (theNum == 0) begin
                    do <= 8'h30; // "0"
                    doValid <= 1;
                   
                    if (doReady) state <= Idle;
                end // if (theNum == 0)
                else begin
                    doValid <= 0;
                    
                    state <= Push;
                end
            end // Classify:

            Push: begin
                doValid <= 0;

                // converts to ASCII here; "0" = 8'h30
                digitStack[digitCounter] <= 4'h30 + (theNum%10);
                theNum <= theNum/10;

                if (theNum/10 != 0) digitCounter <= digitCounter+1;
                else                state <= Pop;
            end // Push:

            Pop: begin
                do <= digitStack[digitCounter];
                doValid <= 1;

                if (doReady) begin
                    if (digitCounter != 0) begin
                        digitCounter <= digitCounter-1;
                    end // if (digitCounter != 0)
                    else state <= Idle;
                end // if (doReady)
            end // Pop:
            default: state <= Idle;
        endcase
    end // always @(posedge clk)

endmodule
