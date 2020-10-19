local M = {
    --框架管理器
    FishPond = {
    },

    --动作片段
    ActionDao = {
        colors = nil,--当满足这些颜色特征以后才去执行对应的操作
    --         fragment = {},--01->动作片段序列：序列的形式遍历动作参数实现链式编程
    --         afterp = nil,--在动作执行完毕以后去做一件事情
    --         beforep = nil,--在动作执行前去做一件事情
    --         uncheckp = nil,--当特征点没有找到以后去做一件事情
    },

    --颜色特征
    ColorDao = {
        name = nil,
        type = nil,
        feature = nil,
    },

    --动作参数，假设需要运行click,input,slid等方法，那么就需要最基本的参数 具体什么动作、对那几个点进行操作
    Fragment = {
        parms = nil,--用户传入的参数
    },

    --********************点击片段********************
    clickf = {},
    --********************滑动片段********************
    slidf = {},
    --********************滑动片段********************
    sleepf = {},

}


--======================================================框架控制器============================================================
--运行一个Action
function M.FishPond:runAction(a)
    a:run()
end

--运行一组Action -> jobs
function  M.FishPond:run(jobs)
    while true do
        for k,v in pairs(jobs)	do
            local isexits = v:run()		--isexit 是否退出为true退出循环
            if isexits then
                return
            end
        end
        sleep(self.s or 1000)
    end
end

--设置框架的运行频率
function M.FishPond:s(t)
    self.s = t
end

--坐标数据结构
function Point(x,y)
    return {x= x,y=y}
end


--======================================================动作片段==================================================================
--当用户调用Action时，Action给自己的动作参数fragment赋值对应的动作片段, 如果找到对应的颜色特征返回对应的坐标,Action的动作参数不为空，运行动作参数的run方法同时将找到的坐标和Action传进去
--Action的运行方法,迭代Colors,判断颜色特征是否存在，如果存在触摸点击
function M.ActionDao:run()
    local p = nil
    for k,v in ipairs(self.colors) do
        p = v:getPoints()
        if  not p then
            break
        end
    end

    --*识别图片->找到坐标->进行对应操作(用户不一定是点击，也可能是滑动，输入等····所以需要解耦)
    if p then
        for k,f in ipairs(self.fragment) do
            f:run(self,p)--02迭代动作参数
        end

        --￥beforep 在动作执行前去做一件事情
        if self.beforep then
            local isexit =self.beforep()
            return isexit
        end


        --￥如果动作参数不为空，运行动作片段的 run 方法

        if self.fragment then
            --￥after 在动作执行完毕以后去做一件事情
            local isskip,isexit= nil
            if self.afterp then
                isexit,isskip = self.afterp()
                return isexit
            end

            --￥isskip 是否跳过为false 不跳过继续执行动作片段
            if not isskip then

                for k,f in ipairs(self.fragment) do
                    f:run(self,p)--02迭代动作参数
                    logcat("02-->动作片段ActionDao:run@对应坐标为"..p.x..","..p.y)
                end
            end


            --self.fragment:run(self,p)

        end
    else
        --￥￥uncheckp 当特征点没有找到以后去做一件事情
        if self.uncheckp then
            local isexit =self.uncheckp()
            return isexit
        end

    end

end

--*****************流程控制********************
--是否退出
local isexit = function ()
    return true
end

--是否跳过	运行前执行函数
local isskip = function ()
    return false,true
end

--找不到特征点退出		找不到运行的函数
local notfind = function ()
    return true
end

--after 通过返回特定参数结束控制器中的while 循环退出任务
--after 在动作执行完毕以后去做一件事情
function M.ActionDao:after(fun)
    self.afterp = fun
    return self
end

--beforep 在动作执行前去做一件事情
function M.ActionDao:before(fun)
    self.beforep = fun
    return self
end
--uncheckp 当特征点没有找到以后去做一件事情
function M.ActionDao:uncheck(fun)
    self.uncheckp = fun
    return self
end

--创建Action对象
function Action(...)
    local a = {}
    setmetatable(a, M.ActionDao)
    M.ActionDao.__index =  M.ActionDao
    a.colors = {...}
    --***************写在new里面都是最新的
    a.fragment = {}--01->动作片段序列：序列的形式遍历动作参数实现链式编程
    a.afterp = nil--在动作执行完毕以后去做一件事情
    a.beforep = nil--在动作执行前去做一件事情
    a.uncheckp = nil--当特征点没有找到以后去做一件事情
    return a
end

--创建动作片段,给ActionDao.fragment 赋值对应的动作参数		找到坐标执行用户指定的动作
--点击动作片段
function M.ActionDao:click (...)
    self.fragment[#self.fragment + 1] = M.clickf.new(...)
    return self
end
--滑动动作片段
function M.ActionDao:slid(...)
    self.fragment[#self.fragment + 1] = M.slidf.new(...)
    return self
end
--睡眠动作片段
function M.ActionDao:sleep(times)
    self.fragment[#self.fragment + 1] = M.sleepf.new(times)
    return self
end


--======================================================动作参数===============================================================
--动作片段，假设需要运行click,input,slid等方法，那么就需要最基本的参数 具体什么动作、对那几个点进行操作
--框架调用的run方法
function  M.Fragment:run(action,point)

end

--********************点击动作参数************************
function M.clickf:run(action,point)
    if #self.param > 0 then
        --偏移点击
        if(type(self.param[1])== "number") then
            -- 坐标偏移拓展
            local px = self.param[1] or 0
            local py = self.param[2] or 0
			logcat(px..py)
			--touch.click(self.param[1],self.param[2]+py)
            touch.click(point.x+px,point.y+py)
            return
        end

        --Point点击
        for k,p in ipairs (self.param) do
            logcat("04-->click动作参数序列,点击："..p.x..","..p.y)
            touch.click(p.x, p.y)
        end

    else
        logcat("03-->click动作参数,点击："..point.x..","..point.y)
        touch.click(point.x, point.y)
    end
    --     logcat("03-->click动作参数,点击："..point.x..","..point.y)
    --     touch.click(point.x, point.y)
end

function M.clickf.new(...)
    local  c = {}
    c.param = {...}
    c.id = id
    c.pedal = pedal
    c.sync = sync
    c.xp = xp
    setmetatable(c,M.clickf)
    M.clickf.__index = M.clickf
    return c
end

--********************滑动动作参数************************
function M.slidf:run(action,point)
    if #self.param >= 2 then
        for k,p in ipairs(self.param) do
            if k == 1 then

            else
                touch.swipe(self.param[k-1].x,self.param[k-1].y,self.param[k].x, self.param[k].y,self.times or 300)
                logcat("03-->sliddon动作参数,滑动："..self.param[k-1].x..","..self.param[k-1].y.."=>"..self.param[k].x..","..self.param[k].y)
            end
        end
    end
end

function M.slidf.new(times,...)
    local  s = {}
    s.param = {...}
    s.times = times
    setmetatable(s,M.slidf)
    M.slidf.__index =M.slidf
    return s
end

--********************睡眠动作参数************************
function M.sleepf:run(action,point)
    if self.param then
        sleep(self.param)
    end
end

function M.sleepf.new(times)
    local  s = {}
    s.param = times
    setmetatable(s,M.sleepf)
    M.sleepf.__index =M.sleepf
    return s
end


--======================================================颜色特征===============================================================
--判断颜色特征是否存在
function M.ColorDao:getPoints()
    local isFound,x,y,tb = find.colors(self.feature)
    if (isFound) then
        logcat("01-->颜色特征getPoints:在x=".. x .. ",y=" .. y .. " 找到颜色")
        return Point(x,y)
    else
        logcat("未找到颜色")
    end
end

--创建Color对象
function Color(n,t,f)
    local c = {}
    setmetatable(c,M.ColorDao)
    M.ColorDao.__index = M.ColorDao
    c.name = n
    c.type = t
    c.feature = f
    return c
end

--======================================================入口函数================================================================
function M.run()
    M.FishPond:s(1000)

    c1= Color("画图",1,{0x00BFA5, {2,13,0x00BFA5}, {10,27,0x00BFA5}},60,574,1120,700,1255)
    c2 = Color("画笔",1,{0x4C4C4C, {12,-10,0xE5E5E5}, {10,-15,0x4C4C4C}},60,25,1174,120,1268)

    --     jobs = {
    --         Action(c1):click(Point(85,305)),
    --         Action(c2):slid(2000,Point(125,195),Point(360,183),Point(210,314),Point(125,195)):after(isexit),
    --         Action(c2):slid(2000,Point(173,557),Point(509,553),Point(484,833),Point(154,852),Point(173,557)),
    --     }

    --     M.FishPond:run(jobs)

    function 三角形 ()
        local jobs = {
            --214,1232
            Action(c1):click(),
            Action(c2):click(137),
            Action(c2):slid(2000,Point(125,195),Point(360,183),Point(210,314),Point(125,195)):after(isexit),
        }
        M.FishPond:run(jobs)
        toast(" 三角形已经退出了")
    end

    function 矩形 ()
        local jobs = {
            Action(c2):slid(2000,Point(173,557),Point(509,553),Point(484,833),Point(154,852),Point(173,557)):after(isexit),
        }
        M.FishPond:run(jobs)
        toast(" 矩形已经退出了")
    end

    三角形 ()
    矩形 ()
end

return M

