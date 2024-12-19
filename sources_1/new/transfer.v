module time_display (
    input [3:0] time_remaining,  // 输入剩余时间
    output reg [7:0] seg         // 七段显示器的控制信号
);

// 根据 time_remaining 显示数字
always @(*) begin
    case (time_remaining)
        4'b0000: seg = 8'b01111110; // 0
        4'b0001: seg = 8'b00110000; // 1
        4'b0010: seg = 8'b01101101; // 2
        4'b0011: seg = 8'b01111001; // 3
        4'b0100: seg = 8'b00110011; // 4
        4'b0101: seg = 8'b01011011; // 5
        4'b0110: seg = 8'b01011111; // 6
        4'b0111: seg = 8'b01110000; // 7
        4'b1000: seg = 8'b01111111; // 8
        4'b1001: seg = 8'b01111011; // 9
        default: seg = 8'b11111111; 
    endcase
end

endmodule
