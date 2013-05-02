library verilog;
use verilog.vl_types.all;
entity Bouncy is
    generic(
        XMIN            : integer := -38;
        XMAX            : integer := 38;
        YMIN            : integer := -38;
        YMAX            : integer := 38
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        x               : out    vl_logic_vector(7 downto 0);
        y               : out    vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of XMIN : constant is 1;
    attribute mti_svvh_generic_type of XMAX : constant is 1;
    attribute mti_svvh_generic_type of YMIN : constant is 1;
    attribute mti_svvh_generic_type of YMAX : constant is 1;
end Bouncy;
