`timescale 1ns/1ps

module Testbench();
  // 1 / (100 MHz) = 10ns
  localparam ClockFreq      = 100_000_00;
  localparam UARTBaudRate   = 115200;

  localparam Cycle = 10;
  
  reg  Clock, Reset;
  
  reg  [7:0] DataIn;
  reg  DataInValid;
  wire DataInReady;
  wire [7:0] DataOut;
  wire DataOutValid;
  reg  DataOutReady;
  wire FPGA_SERIAL_RX;
  wire FPGA_SERIAL_TX;

  initial Clock = 1'b0;
  always #(5) Clock = ~Clock;

wire [7:0]  cf_di;
wire        cf_diValid;
wire        cf_diReady;
wire [7:0]  cf_do;
wire        cf_doValid;
wire        cf_doReady;
assign DataIn       = cf_do;
assign DataInValid  = cf_doValid;
assign cf_doReady   = DataInReady;
assign cf_di        = DataOut;
assign cf_diValid   = DataOutValid;
assign DataOutReady = cf_diReady;

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

  UART               #( .ClockFreq(       ClockFreq),
                        .BaudRate(        UARTBaudRate))
                  uart( .Clock(           Clock),
                        .Reset(           Reset),
                        .DataIn(          DataIn),
                        .DataInValid(     DataInValid),
                        .DataInReady(     DataInReady),
                        .DataOut(         ),
                        .DataOutValid(    ),
                        .DataOutReady(    ),
                        .SIn(             FPGA_SERIAL_RX),
                        .SOut(            FPGA_SERIAL_TX));

  initial begin
    // Reset
    DataInValid = 1'b0;
    DataOutReady = 1'b0;
    Reset = 1'b1;
    #(10*Cycle);
    Reset = 1'b0;
    #(Cycle);

    // Wait until DataInReady, send a character
    while (DataInReady == 1'b0) begin #(Cycle); end
    DataIn = 8'h21;
    DataInValid = 1'b1;
    #(Cycle);
    DataInValid = 1'b0;

    // Wait until it comes out the other side
    while (!DataOutValid) #(Cycle);
    if (DataOut !== 8'h21) begin
      // Wrong character came out
      $display("Simulation Failed: Got output %d", DataOut);
      $finish();
    end
    #(Cycle * 10);
    if (DataOut !== 8'h21) begin
      $display("Simulation Failed: UART did not hold DataOut until DataOutReady");
      $finish();
    end
    if (FPGA_SERIAL_TX !== 1'b1) begin
      $display("Simulation Failed: UART TX idle signal was not high");
      $finish();
    end
    DataOutReady = 1'b1;
    #(Cycle);
    if (DataOutValid) begin
      $display("Simulation Failed: UART did not clear Valid bit after Ready");
      $finish();
    end

    $display("Test Successful, got output %d", 8'h21);
    $finish();
  end



endmodule
