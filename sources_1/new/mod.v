module traffic_light_controller (
    input clk,              // 时钟信号
    input reset,            // 重置信号
    output reg R,           // 红色 LED 控制
    output reg G            // 绿色 LED 控制
);

// 定义状态
parameter RED_TIME = 10, YELLOW_TIME = 10, GREEN_TIME = 10;
parameter RED_STATE = 2'b00, YELLOW_STATE = 2'b01, GREEN_STATE = 2'b10;

// 状态寄存器
reg [1:0] state;          // 当前状态
reg [3:0] counter;        // 计数器（4位，足够容纳最大的计时值）

// 时钟驱动的状态机
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= RED_STATE;     // 重置时状态设为红灯
        counter <= 0;           // 计数器清零
        R <= 0;                 // 初始化时红色LED不亮
        G <= 0;                 // 初始化时绿色LED不亮
    end
    else begin
        if (counter == 0) begin
            // 根据当前状态切换到下一个状态
            case(state)
                RED_STATE: begin
                    state <= YELLOW_STATE;  // 红灯结束，进入黄灯
                    counter <= YELLOW_TIME; // 计数器设置为黄灯时间
                    R <= 1;                 //
                    G <= 1;                 // 
                end
                YELLOW_STATE: begin
                    state <= GREEN_STATE;   // 黄灯结束，进入绿灯
                    counter <= GREEN_TIME;  // 计数器设置为绿灯时间
                    R <= 1;                 // 
                    G <= 0;                 // 
                end
                GREEN_STATE: begin
                    state <= RED_STATE;     // 绿灯结束，进入红灯
                    counter <= RED_TIME;    // 计数器设置为红灯时间
                    R <= 0;                 // 
                    G <= 1;                 // 
                end
            endcase
        end else begin
            counter <= counter - 1;  // 计数器递减
        end
    end
end

endmodule
