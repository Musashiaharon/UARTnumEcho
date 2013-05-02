`timescale 1ns/1ps

module EchoTestbench();

reg Clock, Reset;
wire FPGA_SERIAL_RX, FPGA_SERIAL_TX;

wire  [7:0] DataIn;
wire        DataInValid;
wire        DataInReady;
wire  [7:0] DataOut;
wire        DataOutValid;
reg         DataOutReady;

parameter HalfCycle = 5;
parameter Cycle = 2*HalfCycle;
parameter ClockFreq = 100_000_000;

initial Clock = 0;
always #(HalfCycle) Clock <= ~Clock;

FPGA_TOP_ML505    #(  .ClockFreq(     ClockFreq))
                top(  .GPIO_SW_C(     Reset),
                      .USER_CLK(      Clock),
                      .FPGA_SERIAL_RX(FPGA_SERIAL_RX),
                      .FPGA_SERIAL_TX(FPGA_SERIAL_TX));

UART               #( .ClockFreq(       ClockFreq))
                  uart( .Clock(           Clock),
                        .Reset(           Reset),
                        .DataIn(          DataIn),
                        .DataInValid(     DataInValid),
                        .DataInReady(     DataInReady),
                        .DataOut(         DataOut),
                        .DataOutValid(    DataOutValid),
                        .DataOutReady(    DataOutReady),
                        .SIn(             FPGA_SERIAL_TX),
                        .SOut(            FPGA_SERIAL_RX));

reg [7:0]   cf_di;
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



initial begin
  // Reset. Has to be long enough to not be eaten by the debouncer.
  Reset = 0;
  cf_di = 8'h21;
  cf_diValid = 0;
  DataOutReady = 0;
  #(10*Cycle)

  Reset = 1;
  #(30*Cycle)
  Reset = 0;

  // Wait until transmit is ready
  while (!cf_diReady) #(Cycle);
  cf_diValid = 1;
  #(Cycle)
  cf_diValid = 0;

  // Wait for something to come back
  while (!DataOutValid) #(Cycle);
  $display("Got %d", DataOut);
  $finish();
end

endmodule
