module spi_tb;
    reg clk, rst, start;
    reg [7:0] master_data_in, slave_data_in;
    wire [7:0] master_data_out, slave_data_out;
    wire sclk, mosi, miso, cs;

    // Instantiate SPI master and slave
    spi_master master (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_in(master_data_in),
        .data_out(master_data_out),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .cs(cs)
    );

    spi_slave slave (
        .sclk(sclk),
        .cs(cs),
        .mosi(mosi),
        .miso(miso),
        .data_in(slave_data_in),
        .data_out(slave_data_out)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        start = 0;
        master_data_in = 8'b11010101;
        slave_data_in = 8'b10101010;
        #10 rst = 0;

        // Start transmission
        #10 start = 1;
        #100 start = 0; // Transmission end

        // End simulation
        #200 $finish;
    end

    initial begin
        $dumpfile("spi_tb.vcd"); // VCD file for waveform
        $dumpvars(0, spi_tb);
    end
endmodule
