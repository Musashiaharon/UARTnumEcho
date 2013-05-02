module ECHO_TOP_ML505(
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

  //reg       has_char;
  //reg [7:0] char;


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


/*
  always @(posedge Clock) begin
    if (Reset) has_char <= 1'b0;
    else has_char <= has_char ? !DataInReady : DataOutValid;
  end

  always @(posedge Clock)
    if (!has_char) char <= DataOut;

  assign cf_diValid = has_char;
  assign cf_di = char;
  assign DataOutReady = !has_char;
*/
endmodule
