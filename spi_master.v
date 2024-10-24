module spi_master (
    input wire clk,          // System clock
    input wire rst,          // Reset signal
    input wire start,        // Start transmission
    input wire [7:0] data_in,// Data to be sent to slave
    output reg [7:0] data_out,// Data received from slave
    output reg sclk,         // SPI clock
    output reg mosi,         // Master out slave in
    input wire miso,         // Master in slave out
    output reg cs            // Chip select
);

    reg [2:0] bit_counter;
    reg [7:0] shift_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sclk <= 0;
            mosi <= 0;
            cs <= 1;
            bit_counter <= 3'b000;
            data_out <= 8'b0;
        end else if (start) begin
            cs <= 0;
            sclk <= ~sclk; // Toggle clock
            if (sclk) begin
                mosi <= shift_reg[7]; // Send MSB first
                shift_reg <= {shift_reg[6:0], miso}; // Shift data
                bit_counter <= bit_counter + 1;
                if (bit_counter == 3'b111) begin
                    cs <= 1; // End transmission
                    data_out <= shift_reg; // Store received data
                end
            end
        end
    end

    always @(posedge start) begin
        shift_reg <= data_in; // Load data to be sent
        bit_counter <= 0;
    end
endmodule
