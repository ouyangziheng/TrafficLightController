`timescale 1ns / 1ps

module traffic_light_controller_tb;

// 声明测试信号
reg clk;
reg reset;
wire R;
wire G;

// 实例化被测试模块
traffic_light_controller uut (
    .clk(clk),
    .reset(reset),
    .R(R),
    .G(G)
);

// 产生时钟信号
always begin
    #5 clk = ~clk;  // 每5ns翻转一次时钟，周期为10ns
end

// 初始块，模拟测试过程
initial begin
    // 初始化信号
    clk = 0;
    reset = 0;

    // 先进行复位
    $display("开始测试...");
    reset = 1;  // 先激活复位
    #10 reset = 0;  // 释放复位，开始正常操作

    // 观察信号变化
    #100000;  // 模拟10000ns（10us）

    // 结束测试
    $finish;
end

// 监视信号变化，打印状态
initial begin
    $monitor("时间 = %0t, 复位 = %b, 红灯 = %b, 绿灯 = %b", $time, reset, R, G);
end

endmodule
