interface Intel8088Pins(input logic CLK, RESET);
  //* Interface ports
bit MNMX;
bit TEST;
bit READY;
bit NMI;
bit INTR;
bit HOLD;
 wire logic [7:0] AD;
 logic [19:8] A;
 logic IOM;
 logic WR;
 logic RD;
 logic SSO;
 logic INTA;
 logic ALE;
 logic DTR;
 logic DEN;
 logic HLDA;

//Intel8088 P(CLK, MNMX, TEST, RESET, READY, NMI, INTR, HOLD, AD, A, HLDA, IOM, WR, RD, SSO, INTA, ALE, DTR, DEN);

modport Processor (input CLK, MNMX, TEST, RESET, READY, NMI, INTR, HOLD,
		   inout AD,
		   output A, HLDA, IOM, WR, RD, SSO, INTA, ALE, DTR, DEN);


modport Peripheral (input CLK, RESET,
		   input ALE, IOM, RD, WR);

endinterface