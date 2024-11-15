`timescale 1ns / 1ps

module uart_tx (
    input  logic       clk_i           ,
    input  logic       rst_n_i         ,
    input  logic       tx_en_i         ,
    
    input  logic [7:0] tx_fifo_data_i  ,
    input  logic       tx_fifo_empty_i ,
    output logic       tx_fifo_rd_en_o ,

    output logic       uart_tx_o
);
    
    typedef enum {S_IDLE, S_START, S_DATA, S_STOP} statetype;
    
    statetype   state     ;
    logic [2:0] bit_count ;
    logic [7:0] data_d    ;
    
    logic tx_fifo_rd_en   ;
    logic tx_fifo_rd_en_d ;
    
    assign tx_fifo_rd_en_o = (tx_fifo_rd_en & !tx_fifo_rd_en_d);
    
    always_ff @(posedge clk_i) begin
        if (!rst_n_i) begin
            state           <= S_IDLE ;
            bit_count       <= 0      ;
            data_d          <= 0      ;
            tx_fifo_rd_en   <= 0      ;
            tx_fifo_rd_en_d <= 0      ;
            uart_tx_o       <= 1      ;
        end else if (tx_en_i) begin
            case (state)
                S_IDLE: begin
                    if (!tx_fifo_empty_i) begin
                        state         <= S_START        ;
                        data_d        <= tx_fifo_data_i ;
                        tx_fifo_rd_en <= 1              ;
                    end else begin
                        state         <= S_IDLE ;
                        data_d        <= 0      ;
                        tx_fifo_rd_en <= 0      ;
                    end
                end
                
                S_START: begin
                    state         <= S_DATA ;
                    tx_fifo_rd_en <= 0      ;
                    uart_tx_o     <= 0      ;
                end
                
                S_DATA: begin
                    uart_tx_o <= data_d[bit_count] ;
                    if (bit_count == 7) begin
                        state     <= S_STOP ;
                        bit_count <= 0      ;
                    end else begin
                        state     <= S_DATA        ;
                        bit_count <= bit_count + 1 ;
                    end
                end
                
                S_STOP: begin
                    uart_tx_o         <= 1 ;
                    if (!tx_fifo_empty_i) begin
                        state         <= S_START        ;
                        data_d        <= tx_fifo_data_i ;
                        tx_fifo_rd_en <= 1              ;
                    end else begin
                        state         <= S_IDLE ;
                        data_d        <= 0      ;
                        tx_fifo_rd_en <= 0      ;
                    end
                end 
                
            endcase
        end
    end
    
    always_ff @(posedge clk_i) begin
        if (!rst_n_i) begin
            tx_fifo_rd_en_d <= 0 ;
        end else begin
            tx_fifo_rd_en_d <= tx_fifo_rd_en ;
        end
    end
    
endmodule
