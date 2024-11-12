module SPI_Slave(
    input wire mosi,             // Master Output Slave Input
    input wire sclk,             // Serial Clock from Master
    input wire ss,               // Slave Select from Master
    input wire reset,            // Reset Signal
    input wire [7:0] data_in,    // Data to be sent to master
    output reg miso,             // Master Input Slave Output
    output reg [7:0] data_out    // Data received from master
);

    reg [7:0] shift_reg = 8'b00000000;
    reg [2:0] bit_count = 0;

    always @(posedge sclk or posedge reset) begin
        if (reset) begin
            bit_count <= 0;
            shift_reg <= data_in;
            data_out <= 8'b00000000;
            miso <= data_in[7]; // Initialize MISO with MSB of data_in
        end else if (!ss) begin  // Active when ss is low
            shift_reg <= {shift_reg[6:0], mosi};  // Shift in MOSI bit
            miso <= shift_reg[7]; // Send MSB on MISO
            bit_count <= bit_count + 1;

            if (bit_count == 7) begin
                data_out <= shift_reg;  // Store received data after 8 bits
                shift_reg <= data_in;   // Load data to send on MISO
                bit_count <= 0;
            end
        end
    end
endmodule

