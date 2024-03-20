module io_memory_module (
    Intel8088Pins.Peripheral bus,                 
    input logic [19:0] Address,     
    inout logic [7:0] Data,
    input logic CS         
);
    parameter VALID = 1'b0;
    parameter INIT_FILE = "memory_init.txt";
    // State definitions for the FSM
    typedef enum logic [2:0] {
        T1  = 3'b001,
        T2  = 3'b010,
        T3R = 3'b011,
        T3W = 3'b100,
        T4  = 3'b101
    } state_t;

    // Internal signals
    state_t current_state, next_state;
    logic OE;
    logic LoadAddress;
    logic Write;
    logic [19:0] RegisteredAddress;
    logic [7:0] InternalData; // Buffer for the data to be read or written
    logic [7:0] memory_array[(2**20)-1:0]; // Memory array 2^20-1 deep and 8 bits wide

    // Tri-state buffer control
    assign Data = (OE) ? InternalData : 8'bz;

    // FSM Logic
    always_ff @(posedge bus.CLK or posedge bus.RESET) begin
        if (bus.RESET) begin
            current_state <= T1;
        end else begin
            current_state <= next_state;
        end
    end

    // Next State Logic
    always_comb begin
	{LoadAddress, Write, OE} = '0;
       // LoadAddress = 0;
        //Write = 0;
	//OE = 0;
        next_state = current_state;

        case (current_state)
            T1: if (CS && bus.ALE && (bus.IOM == VALID)) next_state = T2;
            T2: begin
                LoadAddress = 1;
                if (!bus.RD) next_state = T3R;
                else if (!bus.WR) next_state = T3W;
            end
            T3R: begin
		OE = 1;
		InternalData <= memory_array[RegisteredAddress];
                next_state = T4;
            end
            T3W: begin
                Write = 1;
		memory_array[RegisteredAddress] <= Data;
                next_state = T4;
            end
            T4: begin
                next_state = T1;
            end
            default: next_state = T1;
        endcase
    end

    initial begin
        $readmemh(INIT_FILE, memory_array);
    end

    // Address register logic
    always_ff @(posedge bus.CLK) begin
        if (LoadAddress) RegisteredAddress <= Address;
    end

    // Read and Write Operations
    //always_ff @(posedge bus.CLK) begin
    //    if (Write) begin
    //        memory_array[RegisteredAddress] <= Data;
    //    end else if (!bus.RD) begin
    //        InternalData <= memory_array[RegisteredAddress];
    //    end
 //   end

endmodule

