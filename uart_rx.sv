`timescale 1ns / 1ps

    module uart_rx(
    input  logic         clk_i           ,
    input  logic         rst_n_i         ,
    input  logic         rx_en_i         ,
    
    output logic [7:0]   rx_fifo_data_o  ,
    input  logic         rx_fifo_full_i  ,
    output logic         rx_fifo_wr_en_o ,
    
    input  logic         uart_rx_i
);

    typedef enum {S_IDLE, S_START, S_DATA, S_STOP} statetype ;
    
    statetype   state     ;
    logic [3:0] tik_count ;
    logic [2:0] bit_count ;
    logic [7:0] data_d    ;
    
    logic rx_fifo_wr_en   ;
    logic rx_fifo_wr_en_d ; 
    
    assign rx_fifo_wr_en_o = (rx_fifo_wr_en & !rx_fifo_wr_en_d) ;
    
    always_ff @(posedge clk_i) begin
        if (!rst_n_i) begin
            state         <= S_IDLE ;
            tik_count     <= 0      ;
            bit_count     <= 0      ;
            data_d        <= 0      ;
            rx_fifo_wr_en <= 0      ;
            rx_fifo_wr_en <= 0      ;
        end else if (rx_en_i & !rx_fifo_full_i) begin
            case (state)
                S_IDLE:  begin
                    rx_fifo_data_o <= 0 ;
                    rx_fifo_wr_en  <= 0 ;
                    if (!uart_rx_i) begin
                        state <= S_START ;
                    end else begin
                        state <= S_IDLE  ;
                    end
                end
                
                S_START: begin 
                    if (tik_count == 7) begin
                        state     <= S_DATA ;
                        tik_count <= 0      ;
                    end else begin
                        state     <= S_START       ;
                        tik_count <= tik_count + 1 ;
                    end
                end
                
                S_DATA:  begin 
                    if (tik_count == 15) begin
                        data_d    <= {uart_rx_i, data_d[7:1]} ;
                        tik_count <= 0                        ;
                        
                        if (bit_count == 7) begin
                            state <= S_STOP ;
                        end else begin
                            state <= S_DATA ;
                        end
                                                
                        bit_count <= bit_count + 1 ;
                    end else begin
                        data_d    <= data_d        ;
                        state     <= S_DATA        ;
                        bit_count <= bit_count     ;
                        tik_count <= tik_count + 1 ;
                    end
                end
                
                S_STOP:  begin 
                        if (tik_count == 15) begin
                            state          <= S_IDLE ;
                            rx_fifo_data_o <= data_d ;
                            rx_fifo_wr_en  <= 1      ;
                            tik_count      <= 0      ;
                        end else begin
                            state          <= S_STOP         ;
                            rx_fifo_data_o <= 0              ;
                            rx_fifo_wr_en  <= 0              ;
                            tik_count      <= tik_count + 1  ;
                        end
                end
            endcase
        end
    end
    
    always_ff @(posedge clk_i) begin
        if (!rst_n_i) begin
            rx_fifo_wr_en_d <= 0 ;
        end else begin
            rx_fifo_wr_en_d <= rx_fifo_wr_en ;
        end
    end
    
endmodule
