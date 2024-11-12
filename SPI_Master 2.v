module SPI_Master(
    input wire clk,              // System Clock
    input wire reset,            // Reset Signal
    input wire start,            // Start Transaction Signal
    input wire miso,             // Master Input Slave Output
    input wire [7:0] data_in,    // Data to be sent to slave
    output reg mosi,             // Master Output Slave Input
    output reg sclk,             // Serial Clock
    output reg ss,               // Slave Select
    output reg [7:0] data_out,   // Data received from slave
    output reg done              // Transaction Complete Signal
);

    reg [2:0] bit_count = 0;
    reg [7:0] shift_reg = 8'b00000000;
    reg clk_div = 0;
    reg sclk_r = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ss <= 1;
            done <= 0;
            bit_count <= 0;
            shift_reg <= data_in;  // Load data_in into shift register
            clk_div <= 0;
            sclk_r <= 0;
            sclk <= 0;
            mosi <= 0;
            data_out <= 8'b00000000;
        end else if (start && !done) begin
            ss <= 0;  // Activate Slave Select
            clk_div <= ~clk_div;

            if (clk_div == 0) begin
                sclk_r <= ~sclk_r;  // Toggle Serial Clock
                sclk <= sclk_r;

                if (sclk_r == 1) begin
                    mosi <= shift_reg[7]; // Send MSB first
                    shift_reg <= {shift_reg[6:0], miso}; // Shift in MISO
                    bit_count <= bit_count + 1;

                    if (bit_count == 7) begin
                        ss <= 1;  // Deactivate Slave Select after 8 bits
                        done <= 1;  // Set done flag
                        data_out <= shift_reg;  // Store received data
                        bit_count <= 0;
                    end
                end
            end
        end else begin
            ss <= 1;  // Ensure Slave Select is high when idle
            done <= 0;
        end
    end
endmodule

