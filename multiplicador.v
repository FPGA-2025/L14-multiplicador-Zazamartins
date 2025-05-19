module Multiplier #(
    parameter N = 4
) (
    input wire clk,
    input wire rst_n,

    input wire start,
    output reg ready,

    input wire   [N-1:0] multiplier,
    input wire   [N-1:0] multiplicand,
    output reg [2*N-1:0] product
);

    localparam IDLE = 1'b0;
    localparam RUNNING = 1'b1;

    reg state;
    reg [2*N-1:0] A_reg; // Registro do multiplicando (2N bits)
    reg [N-1:0] B_reg;    // Registro do multiplicador (N bits)
    reg [$clog2(N)-1:0] count; // Contador para rastrear os ciclos

    always @(posedge clk) begin
        if (~rst_n) begin
            state <= IDLE;
            ready <= 0;
            product <= 0;
            A_reg <= 0;
            B_reg <= 0;
            count <= 0;
        end else begin
            case (state)
                IDLE: begin
                    ready <= 0;
                    if (start) begin
                        A_reg <= {{N{1'b0}}, multiplicand}; // Inicializa com multiplicando nos bits inferiores
                        B_reg <= multiplier;
                        product <= 0;
                        count <= 0;
                        state <= RUNNING;
                    end
                end
                RUNNING: begin
                    // Se o bit menos significativo de B_reg for 1, adiciona A_reg ao produto
                    if (B_reg[0]) begin
                        product <= product + A_reg;
                    end
                    // Desloca A_reg para a esquerda e B_reg para a direita
                    A_reg <= A_reg << 1;
                    B_reg <= B_reg >> 1;
                    count <= count + 1;

                    // Verifica se todos os bits foram processados
                    if (count == (N-1)) begin
                        state <= IDLE;
                        ready <= 1;
                    end else begin
                        ready <= 0;
                    end
                end
            endcase
        end
    end

endmodule