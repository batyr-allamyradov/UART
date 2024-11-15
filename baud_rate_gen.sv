`timescale 1ns / 1ps

module baud_rate_gen #(
    parameter FREQUENCY = 50_000_000,
    parameter BAUD_RATE = 9600
)(
    input  logic clk_i,
    input  logic rst_n_i,
    output logic tx_en_o,
    output logic rx_en_o
);
   
    parameter RX_DIV = FREQUENCY / (BAUD_RATE * 9600);
    
    logic [8:0] rx_count;
    logic [3:0] tx_count; 
    
    
    always_ff @(posedge clk_i) begin
        if (!rst_n_i) begin
            rx_count <= 0;
            tx_count <= 0;
        end else begin
            if (rx_count == RX_DIV) begin
                rx_count <= 0;
                tx_count <= tx_count + 1;
                rx_en_o  <= 1;
                tx_en_o  <= (tx_count == 15);
            end else begin
                rx_count <= rx_count + 1;
                tx_count <= tx_count;
                rx_en_o  <= 0;
                tx_en_o  <= 0;
            end
        end
    end
    
endmodule
