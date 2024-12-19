module traffic_light_controller (
    input clk,              // 时钟信号
    input reset,            // 重置信号
    input manual_override,  // 外部强制控制信号
    input [1:0] manual_state, // 外部输入的手动控制状态
    output reg R,           // 红色 LED 控制
    output reg G,           // 绿色 LED 控制
    output reg [3:0] time_remaining, // 显示剩余时间
    output reg [7:0] seg,    // 七段显示器输出
    output [1:0] scan_select      // 选择七段显示器
);

assign scan_select = 2'b10;  // 选择七段显示器

// 定义状态
parameter RED_TIME = 10, YELLOW_TIME = 10, GREEN_TIME = 10;
parameter RED_STATE = 2'b00, YELLOW_STATE = 2'b01, GREEN_STATE = 2'b10;

// 状态寄存器
reg [1:0] state;          // 当前状态
reg [3:0] counter;        // 计数器（4位，足够容纳最大的计时值）

// 分频器相关变量
reg [26:0] clk_div_counter;  // 用于分频的计数器，假设输入时钟为 100 MHz
reg [26:0] clk_div_counter_400Hz;  // 用于分频的计数器
reg clk_1Hz;                  // 1Hz 输出时钟
reg clk_400Hz;               // 400Hz 输出时钟

// 时钟分频过程：将 100MHz 时钟分频为 400Hz
always @(posedge clk or posedge reset) begin
    if (reset) begin
        clk_div_counter_400Hz <= 0;
        clk_400Hz <= 0;
    end else begin
        if (clk_div_counter_400Hz == 17'd124999) begin  // 分频到 400Hz (100 MHz -> 400 Hz)
            clk_div_counter_400Hz <= 0;
            clk_400Hz <= ~clk_400Hz;  // 每 125,000 个时钟周期翻转一次
        end else begin
            clk_div_counter_400Hz <= clk_div_counter_400Hz + 1;
        end
    end
end


// 时钟分频过程：将 100MHz 时钟分频为 1Hz
always @(posedge clk or posedge reset) begin
    if (reset) begin
        clk_div_counter <= 0;
        clk_1Hz <= 0;
    end else begin
        if (clk_div_counter == 27'd99999999) begin  // 分频到 1Hz (100 MHz -> 1 Hz)
            clk_div_counter <= 0;
            clk_1Hz <= ~clk_1Hz;  // 每 100,000,000 个时钟周期翻转一次
        end else begin
            clk_div_counter <= clk_div_counter + 1;
        end
    end
end

// 时钟驱动的状态机
always @(posedge clk_1Hz or posedge reset) begin
    if (reset) begin
        state <= RED_STATE;    
        counter <= 0;        
        R <= 0;                 
        G <= 0;                 
        time_remaining <= RED_TIME;  // 初始状态下，剩余时间为红灯时间
    end else if (manual_override) begin
        // 如果外部手动控制信号被激活，使用手动控制的状态
        state <= manual_state;  // 切换到手动指定的状态
        case (manual_state)
            RED_STATE: begin
                R <= 0;        
                G <= 1;        
                time_remaining <= RED_TIME;  // 设置红灯的时间
            end
            YELLOW_STATE: begin
                R <= 1;      
                G <= 1;   
                time_remaining <= YELLOW_TIME;  // 设置黄灯的时间
            end
            GREEN_STATE: begin
                R <= 1;       
                G <= 0;        
                time_remaining <= GREEN_TIME;  // 设置绿灯的时间
            end
            default: begin
                R <= 0;        
                G <= 0;
                time_remaining <= 0;  // 非法状态，时间为0
            end
        endcase
    end else begin
        // 正常情况下，根据计时器状态自动切换
        if (counter == 0) begin
            // 根据当前状态切换到下一个状态
            case(state)
                RED_STATE: begin
                    state <= YELLOW_STATE;  // 红灯结束，进入黄灯
                    counter <= YELLOW_TIME; // 计数器设置为黄灯时间
                    R <= 1;                 
                    G <= 1;                 
                    time_remaining <= YELLOW_TIME; // 更新剩余时间
                end
                YELLOW_STATE: begin
                    state <= GREEN_STATE;   // 黄灯结束，进入绿灯
                    counter <= GREEN_TIME;  // 计数器设置为绿灯时间
                    R <= 1;                 
                    G <= 0;                 
                    time_remaining <= GREEN_TIME; // 更新剩余时间
                end
                GREEN_STATE: begin
                    state <= RED_STATE;     // 绿灯结束，进入红灯
                    counter <= RED_TIME;    // 计数器设置为红灯时间
                    R <= 0;                 
                    G <= 1;                 
                    time_remaining <= RED_TIME; // 更新剩余时间
                end
            endcase
        end else begin
            counter <= counter - 1;  // 计数器递减
            time_remaining <= counter;  // 更新剩余时间
        end
    end
end

// 七段显示器控制
always @(clk_400Hz) begin
    case (time_remaining)
        4'b0000: seg <= 8'b01111110; // 0
        4'b0001: seg <= 8'b00110000; // 1
        4'b0010: seg <= 8'b01101101; // 2
        4'b0011: seg <= 8'b01111001; // 3
        4'b0100: seg <= 8'b00110011; // 4
        4'b0101: seg <= 8'b01011011; // 5
        4'b0110: seg <= 8'b01011111; // 6
        4'b0111: seg <= 8'b01110000; // 7
        4'b1000: seg <= 8'b01111111; // 8
        4'b1001: seg <= 8'b01111011; // 9
        default: seg <= 8'b11111111; // 无效状态
    endcase
end

endmodule
