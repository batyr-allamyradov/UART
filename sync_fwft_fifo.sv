`timescale 1ns / 1ps

module sync_fwft_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 16
)(
    input logic clk_i   ,
    input logic rst_n_i ,
    
    input  logic                  fifo_wr_en_i ,
    input  logic [DATA_WIDTH-1:0] fifo_data_i  ,
    output logic                  fifo_full_o  ,
    
    input  logic                  fifo_rd_en_i ,
    output logic [DATA_WIDTH-1:0] fifo_data_o  ,
    output logic                  fifo_empty_o
);

    logic [DATA_WIDTH-1:0] fifo[ADDR_WIDTH**2] = '{default:0};
    logic [ADDR_WIDTH:0]   wr_ptr;
    logic [ADDR_WIDTH:0]   rd_ptr;
    logic [ADDR_WIDTH-1:0] rd_ptr_nxt;
    
    logic                  write_en;
    logic                  read_en;
    
    assign write_en     = (fifo_wr_en_i & !fifo_full_o);
    assign read_en      = (fifo_rd_en_i & !fifo_empty_o);
    
    assign rd_ptr_nxt   = rd_ptr[ADDR_WIDTH-1:0] + 1;
    
    assign fifo_empty_o = (wr_ptr == rd_ptr);
    assign fifo_full_o  = (wr_ptr == {~rd_ptr[ADDR_WIDTH], rd_ptr[ADDR_WIDTH-1:0]});
    
    always_ff @(posedge clk_i) begin
        if (!rst_n_i) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
        end else begin
            if (write_en) begin
                wr_ptr                       <= wr_ptr + 1;
                fifo[wr_ptr[ADDR_WIDTH-1:0]] <= fifo_data_i;     
            end
            
            if (read_en) begin
                rd_ptr                       <= rd_ptr + 1;
            end
        end
    end
    
    always_ff @(posedge clk_i) begin
        fifo_data_o <= read_en ? fifo[rd_ptr_nxt] : fifo[rd_ptr[ADDR_WIDTH-1:0]]; 
    end
    
endmodule
