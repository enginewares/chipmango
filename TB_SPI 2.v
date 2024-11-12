module TB_SPI();

    // Testbench Signals
    reg clk = 0;
    reg reset = 0;
    reg start = 0;
    reg [7:0] data_in_master = 8'b10101010;  // Initial data to transmit from Master
    reg [7:0] data_in_slave = 8'b11001100;   // Initial data to transmit from Slave
    wire mosi, miso, sclk, ss, done;
    wire [7:0] data_out_master, data_out_slave;

    // Generate a clock with a 20ns period
    always #10 clk = ~clk;

    // Instantiate Master
    SPI_Master master(
        .clk(clk),
        .reset(reset),
        .start(start),
        .miso(miso),
        .data_in(data_in_master),
        .mosi(mosi),
        .sclk(sclk),
        .ss(ss),
        .data_out(data_out_master),
        .done(done)
    );

    // Instantiate Slave
    SPI_Slave slave(
        .mosi(mosi),
        .sclk(sclk),
        .ss(ss),
        .reset(reset),
        .data_in(data_in_slave),
        .miso(miso),
        .data_out(data_out_slave)
    );

    // Test Sequence
    initial begin
        // Apply reset
        reset = 1;
        #20;
        reset = 0;

        // Initial delay
        #20;
        
        // Start the SPI transaction
        start = 1;
        #320;  // Allow sufficient time for the 8-bit transmission based on sclk timing
        start = 0;
        
        // Monitor signals for debugging
        $monitor("Time=%0t | mosi=%b | miso=%b | data_out_master=%b | data_out_slave=%b",
                 $time, mosi, miso, data_out_master, data_out_slave);

        // Wait for transaction to complete
        #40;  // Buffer time to observe completion
        if (done) begin
            $display("Transaction Complete");
            $display("Master received: %b", data_out_master);
            $display("Slave received: %b", data_out_slave);

            // Verify transmitted data
            if (data_out_master === data_in_slave)
                $display("SUCCESS: Master received correct data from Slave.");
            else
                $display("ERROR: Master received incorrect data from Slave!");

            if (data_out_slave === data_in_master)
                $display("SUCCESS: Slave received correct data from Master.");
            else
                $display("ERROR: Slave received incorrect data from Master!");
        end else begin
            $display("Transaction failed to complete properly.");
        end

        // Stop the simulation after the transaction completes
        #20;
        $stop;
    end
endmodule

