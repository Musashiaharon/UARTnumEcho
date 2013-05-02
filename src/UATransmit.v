module UATransmit(
  input   Clock,
  input   Reset,

  input   [7:0] DataIn,
  input         DataInValid,
  output        DataInReady,

  output        SOut
);
  // for log2 function
  `include "util.vh"

  //--|Parameters|--------------------------------------------------------------

  parameter   ClockFreq         =   100_000_000;
  parameter   BaudRate          =   115_200;

  // See diagram in the lab guide
  localparam  SymbolEdgeTime    =   ClockFreq / BaudRate;
  localparam  ClockCounterWidth =   log2(SymbolEdgeTime);

  //--|Solution|----------------------------------------------------------------

  wire                              SymbolEdge;
  wire                              Start;
  wire                              TXRunning;

  reg       [9:0]                   TXShift;
  reg       [3:0]                   BitCounter;
  reg       [ClockCounterWidth-1:0] ClockCounter;

  // Goes high at every symbol edge
  assign SymbolEdge = (ClockCounter == SymbolEdgeTime - 1);

  // Goes high when it is time to start sending a character
  assign Start      = DataInReady && DataInValid;

  // Goes high when currently sending a character
  assign TXRunning  = BitCounter != 0;
  
  // Output
  assign DataInReady = !TXRunning;
  assign SOut = TXRunning ? TXShift[0] : 1;

  always @ (posedge Clock) begin
    if      (Start)                     TXShift <= {1'b1, DataIn[7:0], 1'b0};
    else if (SymbolEdge && TXRunning)   TXShift <= {1'b0, TXShift[9:1]};
  end

  // Counters
  always @ (posedge Clock) begin
    ClockCounter <= (Start || Reset || SymbolEdge) ? 0 : ClockCounter+1;
  end

  always @ (posedge Clock) begin
    if      (Reset)                     BitCounter <= 0;
    else if (Start)                     BitCounter <= 10;
    else if (SymbolEdge && TXRunning)   BitCounter <= BitCounter-1;
  end

endmodule
