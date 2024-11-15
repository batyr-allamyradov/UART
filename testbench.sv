`timescale 1ns/1ns

module uart_tb();

  parameter CLK_P = 20; 
  
  logic        clk         ;
  logic        rst_n       ;
  logic  [7:0] tx_data     ;
  logic        tx_data_vld ;
  logic        tx_busy     ;
  logic  [7:0] rx_data     ;
  logic        rx_read_en  ;
  logic        rx_empty    ;
  logic        uart_tx_o   ;
  logic        uart_rx_i   ;
  
  uart_top DUT(
    .clk_i           ( clk         ),
    .rst_n_i         ( rst_n       ),
    .tx_data_i       ( tx_data     ),
    .tx_data_vld_i   ( tx_data_vld ),
    .tx_busy_o       ( tx_busy     ),
    .rx_data_o       ( rx_data     ), 
    .rx_data_rd_en_i ( rx_read_en  ),
    .rx_empty_o      ( rx_empty    ),
    .uart_tx_o       ( uart_tx_o   ),
    .uart_rx_i       ( uart_rx_i   )
  );

  initial begin
    clk = 0;
    forever #(CLK_P/2) clk = ~clk;
  end
    
  assign uart_rx_i = uart_tx_o;
  
  task initialize();
    {rst_n, tx_data_vld, tx_data, rx_read_en} = 0;
  endtask
  
  task reset();
    @(posedge clk)
    rst_n = 0;
    @(negedge clk)
    rst_n = 1;
  endtask
  
  task tx_fifo_write (input [7:0] data);
    @(posedge clk);
    tx_data_vld = 1    ;
    tx_data     = data ;
    @(posedge clk);
    tx_data_vld = 1;
  endtask
  
  task rx_fifo_read();
    wait(!rx_empty);
    @(posedge clk);
    rx_read_en = 1;
    @(posedge clk);
    rx_read_en = 0;
  endtask
  
  initial begin
    initialize;
	reset;
    
    tx_fifo_write (8'h24);
	#100
    tx_fifo_write (8'hAA);
    
    rx_fifo_read();
    #100
    rx_fifo_read();
    
    #1000;
    $finish;
  end

endmodule