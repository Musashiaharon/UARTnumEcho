/* This module takes two integers and converts them to
 * a string of ASCII characters, in this format:
 *  num0\tnum2\n
 * Note that they are separated by a tab character.
 * 
 * This module should be connected to a CharFifo.
 */
module itoa2(
    clk,
    rst,

    num0,
    num1,
    diValid,
    diReady,

    do,
    doValid,
    doReady
    );

    parameter SIZE = 64;

    input               clk, rst;

    input [SIZE-1:0]    num0, num1;
    input               diValid;
    output              diReady;

    output reg [7:0]    do;
    output reg          doValid;
    input               doReady;

    
    localparam Idle     = 0;
    localparam Convert  = 1;
    localparam Wait     = 2;
    localparam Output   = 3;
    reg [3:0] state;

    reg            ws; // Select which input we are processing
    reg [SIZE-1:0] num [1:0];

    reg [SIZE-1:0]  itoa_di;
    reg             itoa_diValid;
    wire            itoa_diReady;
    wire [7:0]      itoa_do;
    wire            itoa_doValid;
    reg             itoa_doReady;

    itoa itoa(
        .clk(       clk),
        .rst(       rst),

        .di(        itoa_di),
        .diValid(   itoa_diValid),
        .diReady(   itoa_diReady),

        .do(        itoa_do),
        .doValid(   itoa_doValid),
        .doReady(   itoa_doReady)
    );

    assign diReady = state == Idle;
   

    wire start;
    assign start = diReady && diValid;

    always @(posedge clk) begin
        if (rst) begin
            state <= Idle;
        end
        else case (state)
            Idle: begin
                ws <= 0;
                itoa_doReady <= 0;
                itoa_diValid <= 0;

                if (start) begin
                    num[0] <= num0;
                    num[1] <= num1;
                    state <= Convert;
                end
            end

            Convert: begin
                if (itoa_diReady) begin
                    itoa_di <= num[ws];
                    itoa_diValid <= 1;

                    itoa_doReady <= 1;
                    state <= Wait;
                end
            end
            
            Wait: begin
                if (itoa_doValid) begin
                    if (doReady) begin
                        do <= itoa_do;
                        doValid <= 1;

                        state <= Output;
                    end
                end
            end

            Output: begin
                itoa_diValid <= 0;

                do <= itoa_do;
                doValid <= 1;
            end

            default: begin
                state <= Idle;
                ws    <= 0;
            end
        endcase
    end

endmodule
