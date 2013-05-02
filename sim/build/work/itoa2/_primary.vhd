library verilog;
use verilog.vl_types.all;
entity itoa2 is
    generic(
        SIZE            : integer := 64
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        num0            : in     vl_logic_vector;
        num1            : in     vl_logic_vector;
        diValid         : in     vl_logic;
        diReady         : out    vl_logic;
        do              : out    vl_logic_vector(7 downto 0);
        doValid         : out    vl_logic;
        doReady         : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of SIZE : constant is 1;
end itoa2;
