`timescale 1ns / 1ps


module data_mem  #(parameter w = 32, d = 256, d_bit = $clog2(d))(
    input clk,
    input [31:0] data_in,
    input [31:0] addr_in,
    input we,
    input [3:0] wstrb,
    input [3:0] wstrb_load,
    output reg [31:0] data_out
    );
    
    reg [w-1:0] data_mem [0:d];
    
    genvar i;
    generate
        for (i = 0 ; i < 257 ; i = i +1) begin
            initial data_mem[i] = 32'b0;
        end
    endgenerate
    
    wire [7:0] address;
    assign address = {addr_in[9:2]};

    always @(posedge clk) begin
        if (we) begin
            if (wstrb == 4'b0001)
                data_mem[address][7:0] <= data_in[7:0]; //byte
            else if (wstrb == 4'b0011)
                data_mem[address][15:0] <= data_in[15:0]; //half
            else if (wstrb == 4'b1111)
                data_mem[address] <= data_in; //word
            else
                data_mem[address] <= data_in; 
        end
     end
       
     always @(*) begin
          if(wstrb_load == 4'b0001)
              data_out <= {{24{data_mem[address][31]}},data_mem[address][7:0]};
          if(wstrb_load == 4'b0011)
              data_out <= {{16{data_mem[address][31]}},data_mem[address][15:0]};
          if(wstrb_load == 4'b1111)
              data_out <= data_mem[address];
          if(wstrb_load == 4'b1001)
              data_out <= {24'd0,data_mem[address][7:0]};
          if(wstrb_load == 4'b1011)
              data_out <= {16'd0,data_mem[address][15:0]};
     end

endmodule


