//  ---------------------------------------------------------
//                  VERILOG DESIGN PATTERN
//  ---------------------------------------------------------

//      hsank@nospam.chipforge.org
//
//
//      April 10, 2018  @  Datengarten #87, CCCB

//  --------    principle   -------------

//          .-------.
//  input   |       | output
//  ------> |       | ------>
//          |       |
//          '-------'
//
//  what happens inside is either
//  - combinatorial         (AND, OR, + ..), or
//  - registered            (FlipFlops, Latches, RAM)
//
//  Examples:
//  - combinatorial:        Arithmetic-Logic-Unit
//  - registered:           Accumulator

//  --------    combinatorial   ---------
//
//  for combinatorial processes, you can write

    integer     a, b, c, z;

assign z = a + b + c;

    integer     a, b, c, z;

always @ (a or b)
begin
    z = a + b + c;  // What's wrong with that?
end

    integer     a;
    integer     b;
    integer     c;
    integer     z;

always @ (a or b or c)  // this is Verilog-95
// sensivity list has to be complete
begin
    z = a + b + c;
end

    wire        a;
    wire        b;
    wire        c;
    reg         z;  // result

always @*           // this is Verilog-2001
begin               // sensivity list is replaced by '*'
    z = a && b || c;
end

//  In verilog there is a flaw,
//  combinatorial signals in processes has to be defined as 'reg'

//  --------    registered  -------------

    wire        a;
    wire        b;
    wire        c;
    reg         z;      // register

always @ (posedge clk)
begin
    z <= a && b || c;     // do you see the difference??
end

//  ATTENTION:
//  Please keep an eye on
//  -   blocking '='
//  -   nonblocking '<=' assignments
//  Read the Textbooks for that!

//  --------    reset values    ----------

    wire        rst;    // (high-active) reset
    wire        clk;    // clock
    wire        a, b;   // operands
    reg         z;      // register

always @ (posedge rst or posedge clk)
begin
    if (rst)
        z <= 'h0;
    else
        z <= a + b;
end

//  Ugly, the reset value is 'hard-coded'

    localparam  z_default = 'h0;

always @ (posedge rst or posedge clk)
begin
    if (rst)
        z <= z_default;
    else
        z <= a + b;
end

//  better, with dedicated constant

//  NOTE:
//  Use constants (localparams) as often as reasonable

//  --------    for ASICs   --------------

//  you'll be killed without RESETs everywhere
//  - by your manager,
//  - by your test engineer,
//  - by the foundry

//  USE RESETS FOR ASICS!

    reg         z;

    localparam  z_default = 'h0;

always @ (posedge rst or posedge clk)
begin
    if (rst)
        z <= z_default;
    else
        z <= a + b;
end

//  NOTE:
//  I hope you got it.
//
//  Use RESET for every Latch or FlipFlop

//  --------    for FPGAs   --------------

//  RESETs will kill your maximum timing
//
//  every reset line is handled as global,
//  blocking your rare resources important stuff
//
//  Avoid RESETs for FPGAs!

    reg         z;

always @ (posedge clk)
begin
    z <= a + b;
end

//  --------    one solution    ----------

//  Often you like to try your code 1st on FPGA,
//  before going into cost-intensive ASIC production
//
//  Also, your code should run on FPGA as on ASIC..
//
//  What to do?
//
//  Use conditional compiling as you might know on C

//  put a definition into your Makefile for the FPGA target, 
//  which does not occur for the ASIC target
//
//  `define CODINGSTYLE_FPGA 1

    localparam  z_default = 'h0;

`ifdef CODINGSTYLE_FPGA
    reg         z = z_default;
`else
    reg         z;
`endif

//  Looks ugly, but it helps.
`ifdef  CODINGSTYLE_FPGA
always @ (posedge clk)
begin
`else
always @ (posedge clk or posedge rst)
begin
    if (rst)
        z <= z_default;
    else
`endif  //CODINGSTYLE_FPGA
        z <= a + b;
end

//  NOTE:
//  YES, is has to have to ugly, as long as
//  ASIC tools do not support the Initial Values.

//  ATTENTION:
//  You have to verify both pathes every time, or you get lost.

//  --------    some nameing conventions    ----

//  Someone prefers post-fix notations,
//  e.g. signal_o for outputs
//

//  This conflicts with the older naming convention to attend
//  a _n for low active signals
//
//  e.g. signal_n_o
//
//  I prefere pre-fix notations

    input       i_port,
    output      o_port,
    inout       io_port,    // bi-directional

    wire        z_signal;   // tri-state signal

    wire        w_signal;   // just combinatorial
    reg         r_signal;   // just registered

    parameter   p_param = 0;
    localparam  c_param = 0;

    unit        u_instance ();// instantiations

//  NOTE:
//  Please note, that Verilog is case-sensitive!
//  Nevertheless names should be unique,
//  while crappy tools like to "translate" names into all-BIG or all-small Capitals.

//  --------    finite state machines   ----

//  THE tool of the choice for many problems!
//
//  Please check at least Wikipedia
//  https://en.wikipedia.org/wiki/Finite-state_machine
//
//  Learn it! Use ist!

//  best practise to implement FSMs in Verilog is
//  the so-called 3-process description

//  1. combinatorial process
//  based on current state, taking the input signals,
//  calculate the next state

//  2. registered process
//  transform the next state into the current state

//  3. dependencies (combinatorial as well as registered possible)
//  drive all output signals regarding the current state

//  NOTE:
//  Moore performs better than Mealy
//  https://en.wikipedia.org/wiki/Moore_machine

//  --------    next state  ----------

//  Always use good names for the states!
//  This helps to understand and read the functionality!

//  1. version  (ugly)

`define STATE_0     0
`define STATE_1     1
`define STATE_2     2
`define STATE_3     3


//  Keep in mind
//  that in Verilog DEFINEs are valid in code until end-of-code
//  or `UNDEF

//  There could be some definitions, which using your names also.
//

//  ATTENTION:
//  Avoid defines for FSM states

//  2. version (better)

    localparam  s_IDLE  = 0;
    localparam  s_RUN   = 1;
    localparam  s_DONE  = 2;
    localparam  s_ERROR = 3;

//  you can use one-hot encoding for the states - this reduces / simplifies the state-encoding logic realy

    reg [1:0]   w_nextstate;    // (cased)
`ifdef CODINGSTYLE_FPGA
    reg [1:0]   r_currentstate = s_IDLE;
`else
    reg [1:0[   r_currentstate;
`endif

//  NOTE:
//  Next State has index as a wire, but is declared a 'reg',
//  See combinatorial in always processes above.

//  --------    next state  ----------

//  the next state process is always combinatorial

    wire    en;

always @*
case (r_currentstate)
    s_IDLE:     // wait idle
                if (en) // start condition
                    w_nextstate = s_RUN;
                else    // hold
                    w_nextstate = r_currentstate;
    s_RUN:      // run
                if (!en) // stop condition
                    w_nextstate = s_DONE;
                else    // hold
                    w_nextstate = r_currentstate;
    s_DONE:     // thanks for all the fish
                w_nextstate = s_IDLE;
    default:    // error
                w_nextstate = s_IDLE;
endcase

//  NOTE:
//  Just look at the inputs and change the state regarding the inputs.
//  That's all!

//  --------    current state  ----------

//  the current state process is even simplier

`ifdef  CODINGSTYLE_FPGA
always @ (posedge clk)
begin
`else
always @ (posedge clk or posedge rst)
begin
    if (rst)
        r_currentstate <= s_IDLE;
    else
`endif  //CODINGSTYLE_FPGA
        r_currentstate <= w_nextstate;
end

//  Take over the already prepared next state into current state.

//  Question:
//  How to deal with interrupt-like signals?

//  ugly solution:
//  just add this as an exception to every state into the next state logic

//  better solution:
//  implement this exception into the current state logic

    wire    w_interrupt;

`ifdef  CODINGSTYLE_FPGA
always @ (posedge clk)
begin
`else
always @ (posedge clk or posedge rst)
begin
    if (rst)
        r_currentstate <= s_IDLE;
    else
`endif  //CODINGSTYLE_FPGA
        if (w_interrupt)    // exceptional
            r_currentstate <= s_ERROR;
        else                // operational
            r_currentstate <= w_nextstate;
end

//  well done, nice readable code

//  --------    dependencies    ----------

//  At Moore FSMs the output depends *only* on states.
//  They could be registered, but mostly combinatorial

    wire    o_output;

always @*
case (r_currentstate)
    s_RUN:  o_output = 'd1;
    default:o_output = 'd0;
endcase

//  Got it? That's all.
//  3 processes, and you're out of trouble with
//  no latches for in-complete encoded signals

//  --------    clock domain crossing   ----
//
//  what happens here?
//
//  w_outside   .-------.           .-------.           .-------. w_inside
//  ----------> | D   Q | --------> | D   Q | --------> | D   Q | -------->
//  clk_inside  |       |           |       |           |       |
//  ----*-----> |>C     |   .-----> |>C     |   .-----> |>C     |
//      |       ._______.   |       ._______.   |       ._______.
//      .___________________|___________________|
//
//  this avoids meta-stability!

    wire    w_outside;

    parameter   p_syncin = 3;

    localparam  c_shiftreg_default = 0;
`ifdef CODINGSTYLE_FPGA
    reg [p_syncin-1:0]  r_shiftreg = c_shiftreg_default;
`else
    reg [p_syncin-1:0]  r_shiftreg;
`endif

`ifdef  CODINGSTYLE_FPGA
always @ (posedge clk_inside)
begin
`else
always @ (posedge clk_inside or posedge rst_inside)
begin
    if (rst_inside)
        r_shiftreg <= c_shiftreg_default;
    else
`endif  //CODINGSTYLE_FPGA
        r_shiftreg <= {w_outside, r_shiftreg[p_syncin-1:1]};
end

    // now @ clk_inside
    wire    w_inside;
    assign w_inside = r_shiftreg[0];

//  NOTE:
//  For low-activity signals only!
//  You can not see *every* signal change on w_outside, if the clock is to slow.
//  Inside clock has to be at least 3 times faster

//  --------    clock domain crossing   ----

//  how to handle small pulses from outside?
//
//  toggling!                                                                               .---.
//                                                                      .------------------ |XOR| w_inside
//  w_outside   .-------.   S       .-------.           .-------.       |   .-------.       |   | -------->
//  ----------> | T   Q | --S-----> | D   Q | --------> | D   Q | ------*-> | D   Q | ----- |   |
//  clk_outside |       |   S       |       |           |       |           |       |       .___.
//  ----------> |>C     |   S   .-> |>C     |   .-----> |>C     |   .-----> |>C     |
//              ._______.   S   |   ._______.   |       ._______.   |       ._______.
//                          S   |_______________|___________________|____________________clk_inside
//                          S
//                  clock boundary
//
//  w_outside    ___                                     ___
//          ____|   |___________________________________|   |_____________________________
//
//  toggle-FF        _______________________________________
//          ________|                                       |_____________________________
//
//  clk_inside   _______         _______         _______         _______         _______
//          ____||      |_______||      |_______||      |_______||      |_______||      |_
//
//  w_inside                                                       _______________
//          ______________________________________________________|               |_________

    wire    w_outside;

    localparam  c_toggleff_default = 0;
    reg     r_toggleff = c_toggleff_default;

always @ (posedge clk_outside)
begin
    r_toggleff <= (w_outside)? !r_toggleff: r_toggleff;
end

//  ATTENTION:
//  There is no RESET!  Use it for FPGAs only

//  --------    reset from both side    ----

//  Do not use reset from both side!
//  While toggle-flipflop is one,
//  and one side reset the register, 
//  => ghost pulses occures!

//  Literature
//
//  Samir Palnitkar: "Verilog HDL. A Guide to Digital Design and Synthesis."
//  1st Edition covers Verilog-95 only,
//  2nd Edition covers Verilog-2001 also.
