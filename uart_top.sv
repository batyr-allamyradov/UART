module uart_top(
  input  logic       clk_i           , 
  input  logic       rst_n_i         , 
  
  input  logic [7:0] tx_data_i       , 
  input  logic       tx_data_vld_i   , 
  output logic       tx_busy_o       , 
  
  output logic [7:0] rx_data_o       , 
  input  logic       rx_data_rd_en_i , 
  output logic       rx_empty_o      , 
  
  output logic       uart_tx_o       , 
  input  logic       uart_rx_i         
);


  logic [7:0] tx_fifo_data  ; 
  logic       tx_fifo_rd_en ; 
  logic       tx_fifo_empty ;
  logic [7:0] rx_fifo_data  ; 
  logic       rx_fifo_wr_en ; 
  logic       rx_fifo_full  ; 
  

  
  sync_fwft_fifo #(
    .DATA_WIDTH   (8              ),
    .ADDR_WIDTH   (3              )  
  ) tx_fifo (
    .clk_i        ( clk_i         ),     
    .rst_n_i      ( rst_n_i       ),   
    .fifo_wr_en_i ( tx_data_vld_i ), 
    .fifo_data_i  ( tx_data_i     ), 
    .fifo_full_o  ( tx_busy_o     ), 
    .fifo_rd_en_i ( tx_fifo_rd_en ), 
    .fifo_data_o  ( tx_fifo_data  ), 
    .fifo_empty_o ( tx_fifo_empty )  
  );
  
  sync_fwft_fifo #(
    .DATA_WIDTH   (8                ), 
    .ADDR_WIDTH   (3                )  
  ) rx_fifo (
    .clk_i        ( clk_i           ),     
    .rst_n_i      ( rst_n_i         ), 
    .fifo_wr_en_i ( rx_fifo_wr_en   ),  
    .fifo_data_i  ( rx_fifo_data    ),         
    .fifo_full_o  ( rx_fifo_full    ), 
    .fifo_rd_en_i ( rx_data_rd_en_i ), 
    .fifo_data_o  ( rx_data_o       ),   
    .fifo_empty_o ( rx_empty_o      )  
  );
  
endmodule