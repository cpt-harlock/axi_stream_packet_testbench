//import axi_vip_pkg::*;
//import axi_vip_0_pkg::*;

module top_sim;

bit clk             ; 
bit rst             ; 
bit rst_fill        ;
bit rstn            ;

logic [511:0]   S0_AXIS_TDATA       ;
logic [31:0]    S0_AXIS_TUSER       ;
logic           S0_AXIS_TVALID  = 0 ;
logic           S0_AXIS_TREADY      ;
logic [63:0]    S0_AXIS_TKEEP       ;
logic           S0_AXIS_TLAST       ; 

logic  [511:0]   M0_AXIS_TDATA         ;
logic            M0_AXIS_TUSER         ;
logic            M0_AXIS_TVALID  = 0   ;
logic            M0_AXIS_TREADY        ;
logic  [63:0]    M0_AXIS_TKEEP         ;
logic            M0_AXIS_TLAST         ;

logic           S_AXI_ACLK     = 0   ;
logic           S_AXI_ARESETN  = 0   ;
logic [31:0]    S_AXI_AWADDR   = 0   ;
logic           S_AXI_AWVALID  = 0   ;
logic [31:0]    S_AXI_WDATA    = 0   ;
logic [3:0]     S_AXI_WSTRB    = 0   ;
logic           S_AXI_WVALID   = 0   ;
logic           S_AXI_BREADY   = 0   ;
logic [31:0]    S_AXI_ARADDR   = 0   ;
logic           S_AXI_ARVALID  = 0   ;
logic           S_AXI_RREADY      ;
logic           S_AXI_ARREADY     ;
logic [31:0]    S_AXI_RDATA       ;
logic [1:0]     S_AXI_RRESP       ;
logic           S_AXI_RVALID      ;
logic           S_AXI_WREADY      ;
logic [1:0]     S_AXI_BRESP       ;
logic           S_AXI_BVALID      ;
logic           S_AXI_AWREADY     ;


logic [15:0]    tx_pktcount_1 ;
logic           pcapfinished_1 ;

//logic           eos_1 ;
logic [7:0]     rx_pktcount_1 ;

parameter CLK_PERIOD = 4.0;

//xil_axi_resp_t  resp;
bit[31:0]  addr, data, base_addr = 32'h4400_0000;


initial begin
    rst = 1'b1;
    rstn = 1'b0;
    #(100 * CLK_PERIOD);
    rst = 1'b0;
    rstn = 1'b1;
    $display("Reset Deasserted");
   end


//Clock generation
   initial begin
      clk = 1'b0;
      #(CLK_PERIOD/2);
      forever
         #(CLK_PERIOD/2) clk = ~clk;
   end

//https://support.xilinx.com/s/article/1058302?language=en_US
//Axilite transactions
// create_ip -name axi_vip -vendor xilinx.com -library ip -version 1.1 -module_name axi_vip_0

//axi_vip_0 AXI_Sim(
//  .aclk(clk),
//  .aresetn(rstn),
//  .m_axi_awaddr(S_AXI_AWADDR),
//  .m_axi_awprot(), //out
//  .m_axi_awvalid(S_AXI_AWVALID),
//  .m_axi_awready(S_AXI_AWREADY),
//  .m_axi_wdata(S_AXI_WDATA),
//  .m_axi_wstrb(S_AXI_WSTRB),
//  .m_axi_wvalid(S_AXI_WVALID),
//  .m_axi_wready(S_AXI_WREADY),
//  .m_axi_bresp(S_AXI_BRESP),
//  .m_axi_bvalid(S_AXI_BVALID),
//  .m_axi_bready(S_AXI_BREADY),
//  .m_axi_araddr(S_AXI_ARADDR),
//  .m_axi_arprot(), //out
//  .m_axi_arvalid(S_AXI_ARVALID),
//  .m_axi_arready(S_AXI_ARREADY),
//  .m_axi_rdata(S_AXI_RDATA),
//  .m_axi_rresp(S_AXI_RRESP),
//  .m_axi_rvalid(S_AXI_RVALID),
//  .m_axi_rready(S_AXI_RREADY)
//);

//initial begin
//    // Step 3 - Declare the agent for the master VIP
//    axi_vip_0_mst_t      master_agent;
    
//    // Step 4 - Create a new agent
//    master_agent = new("master vip agent",top_sim.AXI_Sim.inst.IF);
    
//    // Step 5 - Start the agent
//    master_agent.start_master();
    
//    //Send 0x1 to the AXI GPIO Data register 1
//    #500ns
//    addr = 0;
//    data = 1;
//    master_agent.AXI4LITE_WRITE_BURST(base_addr + addr,0,data,resp);
    
//    // Read the AXI GPIO Data register 2
//    #200ns
//    addr = 8;
//    master_agent.AXI4LITE_READ_BURST(base_addr + addr,0,data,resp);    
//end 

    task axi_write;
        input [31:0] awaddr;
        input [31:0] wdata; 
        begin
            // *** Write address ***
            S_AXI_AWADDR = awaddr;
            S_AXI_AWVALID = 1;
            S_AXI_WDATA = wdata;
            S_AXI_WSTRB = 4'hf;
            S_AXI_WVALID = 1; 
            wait(S_AXI_AWREADY);
            wait(S_AXI_WREADY);
            @ (posedge clk);
            S_AXI_AWVALID = 0;
            S_AXI_WVALID = 0;
            // TBD: should wait bresp             
        end
    endtask
    
    task axi_read;
        input [31:0] araddr;
        output [31:0] rdata;
        begin
            // *** Read address ***
            S_AXI_ARADDR = araddr;
            S_AXI_ARVALID = 1;
            S_AXI_RREADY = 1;
            @ (posedge clk);
            wait(S_AXI_ARREADY);
            wait(S_AXI_RVALID);
            rdata=S_AXI_RDATA;
            S_AXI_ARVALID = 0;
            S_AXI_RREADY = 0;        
        end
    endtask

initial begin
    // Read from AXI4-lite  
    #900ns
    addr =32'h10;
    axi_read(addr,data);
    $display("data is %d",data);

    // Read from AXI4-lite  
    #400ns
    addr =32'h10;
    axi_read(addr,data);
    $display("data is %d",data);

    // Write and re-read from AXI4-lite
    addr =32'h20;
    axi_write(addr,100);
    axi_read(addr,data);
    $display("data is %d",data);
        
end 

   
pcap_parse
#(
    .pcap_filename  ("/home/sal/vitis/flowid/test.pcap")
)
AXIS_STIM_hXDP
(
    .pause          (rst        	                                                               ),
    .data           (S0_AXIS_TDATA                                                                 ),
    .strb           (S0_AXIS_TKEEP                                                                 ),
    .ready          (S0_AXIS_TREADY                                                                ),
    .valid          (S0_AXIS_TVALID                                                                ),
    .eop            (S0_AXIS_TLAST                                                                 ),
    .clk            (clk         	                                                               ),
    .pktcount       (tx_pktcount_1                                                                 ),
    .pcapfinished   (pcapfinished_1	                                                               ) 

);
assign S0_AXIS_TUSER=32'b0;
 
tcp_chksum_0 dut_i  (        
  .s_axi_control_AWADDR(S_AXI_AWADDR),
  .s_axi_control_AWVALID(S_AXI_AWVALID),
  .s_axi_control_AWREADY(S_AXI_AWREADY),
  .s_axi_control_WDATA(S_AXI_WDATA),
  .s_axi_control_WSTRB(S_AXI_WSTRB),
  .s_axi_control_WVALID(S_AXI_WVALID),
  .s_axi_control_WREADY(S_AXI_WREADY),
  .s_axi_control_BRESP(S_AXI_BRESP),
  .s_axi_control_BVALID(S_AXI_BVALID),
  .s_axi_control_BREADY(S_AXI_BREADY),
  .s_axi_control_ARADDR(S_AXI_ARADDR),
  .s_axi_control_ARVALID(S_AXI_ARVALID),
  .s_axi_control_ARREADY(S_AXI_ARREADY),
  .s_axi_control_RDATA(S_AXI_RDATA),
  .s_axi_control_RRESP(S_AXI_RRESP),
  .s_axi_control_RVALID(S_AXI_RVALID),
  .s_axi_control_RREADY(S_AXI_RREADY),
  .ap_clk(clk),
  .ap_rst_n(rstn),
  .dataIn_TVALID(S0_AXIS_TVALID),
  .dataIn_TREADY(S0_AXIS_TREADY),
  .dataIn_TDATA(S0_AXIS_TDATA),
  .dataIn_TKEEP(S0_AXIS_TKEEP),
  .dataIn_TSTRB(S0_AXIS_TKEEP),
  .dataIn_TLAST(S0_AXIS_TLAST),
  .dataOut_TVALID(M0_AXIS_TVALID),
  .dataOut_TREADY(M0_AXIS_TREADY),
  .dataOut_TDATA(M0_AXIS_TDATA),
  .dataOut_TKEEP(M0_AXIS_TKEEP),
  .dataOut_TSTRB(M0_AXIS_TKEEP),
  .dataOut_TLAST(M0_AXIS_TLAST)
);
assign M0_AXIS_TUSER =1'b0;


pcap_dumper
#(
    .pcap_filename 	( "sink_pcie.pcap")
)
AXIS_SINK_PCIE
(
    .rst_n       	( rstn ),
    .tdata        	(    M0_AXIS_TDATA ),
    .tstrb        	(    M0_AXIS_TKEEP ),
    .tready       	(    M0_AXIS_TREADY),
    .tvalid       	(    M0_AXIS_TVALID),
    .tlast         	(    M0_AXIS_TLAST),
    .clk         	( clk ),
    .eos    	(  1'b0),
    .pktcount	(  rx_pktcount_1)
);


    endmodule;
