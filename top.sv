module top;
bit RESET = '0;
bit CLK = 0;
initial
begin
bus.MNMX = '1;
bus.TEST = '1;
bus.READY = '1;
bus.NMI = '0;
bus.INTR = '0;
bus.HOLD = '0;
end

logic CS;
logic [19:0] Address;
wire [7:0]  Data;
logic CS0, CS1, CS2, CS3;

Intel8088Pins bus(.CLK(CLK), .RESET(RESET));
Intel8088 P(bus.Processor);
//Intel8088 P(CLK, MNMX, TEST, RESET, READY, NMI, INTR, HOLD, AD, A, HLDA, IOM, WR, RD, SSO, INTA, ALE, DTR, DEN);

io_memory_module #(.VALID(1'b0)) MEMORY0 (
	.bus(bus.Peripheral),
        .Address(Address),
        .Data(Data),
        .CS(CS0) 
    );

io_memory_module #(.VALID(1'b0)) MEMORY1 (
	.bus(bus.Peripheral),
        .Address(Address),
        .Data(Data),
        .CS(CS1) 
	
    );

io_memory_module #(.VALID(1'b1)) IO0 (
	.bus(bus.Peripheral),
        .Address(Address),
        .Data(Data),
        .CS(CS2)
	
    );

io_memory_module #(.VALID(1'b1)) IO1 (
	.bus(bus.Peripheral),
        .Address(Address),
        .Data(Data),
        .CS(CS3)
	
    );

always_comb begin
        //CS0 = (~P.IOM) && (Address >= 20'h0 && Address <= 20'h7FFFF) ? 1'b1 : 1'b0;
        ///CS1 = (~P.IOM) && (Address >= 20'h80000 && Address <= 20'hFFFFF) ? 1'b1 : 1'b0;
        //CS2 = (P.IOM) && (Address >= 20'hFF00 && Address <= 20'hFF0F) ? 1'b1 : 1'b0; // for I/O addresses 0xFF00 to 0xFF0F
        //CS3 = (P.IOM) && (Address >= 20'h1C00 && Address <= 20'h1DFF) ? 1'b1 : 1'b0; // for I/O addresses 0x1C00 to 0x1DFF
	CS0 = (~P.IOM) && (~Address[19]) ? 1'b1 : 1'b0;
        CS1 = (~P.IOM) && (Address[19]) ? 1'b1 : 1'b0;
        CS2 = (P.IOM) && (Address[15]) ? 1'b1 : 1'b0; // for I/O addresses 0xFF00 to 0xFF0F
        CS3 = (P.IOM) && (~Address[15]) ? 1'b1 : 1'b0;    
end
// 8282 Latch to latch bus address
always_latch
begin
if (bus.ALE)
	Address <= {bus.A, bus.AD};
end

// 8286 transceiver
assign Data =  (bus.DTR & ~bus.DEN) ? bus.AD   : 'z;
assign bus.AD   = (~bus.DTR & ~bus.DEN) ? Data : 'z;


always #50 CLK = ~CLK;

initial
begin
$dumpfile("dump.vcd"); $dumpvars;
CS = 1;
repeat (2) @(posedge CLK);
RESET = '1;
repeat (5) @(posedge CLK);
RESET = '0;

repeat(10000) @(posedge CLK);
$finish();
end

endmodule
