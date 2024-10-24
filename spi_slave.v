module spi_slave (
    input wire sclk,         // SPI clock
    input wire cs,           // Chip select
    input wire mosi,         // Master out slave in
    output reg miso,         // Master in slave out
    input wire [7:0] data_in,// Data to send to master
    output reg [7:0] data_out// Data received from master
);

    reg [2:0] bit_counter;
    reg [7:0] shift_reg;

    always @(negedge sclk) begin
        if (~cs) begin
            shift_reg <= {shift_reg[6:0], mosi}; // Shift in data
            bit_counter <= bit_counter + 1;
            if (bit_counter == 3'b111) begin
                data_out <= shift_reg; // Store received data
                bit_counter <= 0;
            end
        end
    end

    always @(posedge sclk) begin
        if (~cs) begin
            miso <= data_in[7 - bit_counter]; // Send MSB first
        end
    end
endmodule
