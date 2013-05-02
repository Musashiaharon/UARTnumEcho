module FPGA_TOP_ML505(
  input   GPIO_SW_C,
  input   USER_CLK,

  input   FPGA_SERIAL_RX,
  output  FPGA_SERIAL_TX
);
  //--|Parameters|--------------------------------------------------------------

  parameter   ClockFreq     =             100000000;  // 100 MHz
  parameter   UARTBaudRate  =             115200;     // 115.2 KBaud

  //--|Wires|-------------------------------------------------------------------

  wire        Clock, Reset;
  wire  [7:0] DataIn;
  wire        DataInValid;
  wire        DataInReady;
  wire  [7:0] DataOut;
  wire        DataOutValid;
  wire        DataOutReady;
  
  //--|Clock & Reset|-----------------------------------------------------------

  BUFG        clockBuf( .I(               USER_CLK),
                        .O(               Clock));

  ButtonParse        #( .Width(           1),
                        .DebWidth(        20),
                        .EdgeOutWidth(    1)) 
            resetParse( .Clock(           Clock),
                        .Reset(           1'b0),
                        .Enable(          1'b1),
                        .In(              GPIO_SW_C),
                        .Out(             Reset));

  //--|UART|--------------------------------------------------------------------
  
  UART               #( .ClockFreq(       ClockFreq),
                        .BaudRate(        UARTBaudRate))
                  uart( .Clock(           Clock),
                        .Reset(           Reset),
                        .DataIn(          DataIn),
                        .DataInValid(     DataInValid),
                        .DataInReady(     DataInReady),
                        .DataOut(         DataOut),
                        .DataOutValid(    DataOutValid),
                        .DataOutReady(    DataOutReady),
                        .SIn(             FPGA_SERIAL_RX),
                        .SOut(            FPGA_SERIAL_TX));

  //--|Echo|--------------------------------------------------------------------

parameter Delay = 5_000_000;
reg [31:0] count;

reg  [7:0]  cf_di;
reg         cf_diValid;
wire        cf_diReady;
wire [7:0]  cf_do;
wire        cf_doValid;
wire        cf_doReady;
assign DataIn       = cf_do;
assign DataInValid  = cf_doValid;
assign cf_doReady   = DataInReady;

CharFifo cf( 
    .clk(           Clock),
    .rst(           Reset),
    .di(            cf_di),
    .diValid(       cf_diValid),
    .diReady(       cf_diReady),
    .do(            cf_do),
    .doValid(       cf_doValid),
    .doReady(       cf_doReady)
);

wire [7:0] x, y;

reg bouncyClk;
Bouncy bouncy(
    .clk(       bouncyClk),
    .rst(       Reset),
    .x(         x),
    .y(         y)
);

always @(posedge Clock) begin
    if (Reset) begin
        count <= 0;
        cf_diValid <= 0;
    end
    else begin
        if (count < Delay) begin
            count <= count+1;
            bouncyClk <= 0;
        end
        else begin
            count <= 0;
            bouncyClk <= 1;
        end
    
        if (count == 1) begin
            cf_di <= x;
            cf_diValid <= 1;
        end
        else if (count == 2) begin
            cf_di <= y;
            cf_diValid <= 1;
        end
        else if (count == 3) begin
            cf_di <= 8'h7E; // "~"
            cf_diValid <= 1;
        end
        else cf_diValid <= 0;
    end
    
end

endmodule
