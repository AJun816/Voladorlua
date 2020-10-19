
# Voladorlua

Voladorlua 是一款用lua语言实现的链式编程框架，可以方便的进行自动化测试。

> 触动、XS、节点、AS······，所有基于lua语言开发的IDE均可使用。

# 示例

```lua
function M.run()
    M.FishPond:s(1000)

    c1= Color("画图",1,{0x00BFA5, {2,13,0x00BFA5}, {10,27,0x00BFA5}},60,574,1120,700,1255)
    c2 = Color("画笔",1,{0x4C4C4C, {12,-10,0xE5E5E5}, {10,-15,0x4C4C4C}},60,25,1174,120,1268)

    function  Triangle ()
        local jobs = {
            --214,1232
            Action(c1):click(),

            Action(c2):slid(2000,Point(125,195),Point(360,183),Point(210,314),Point(125,195)):after(isexit),
        }
        M.FishPond:run(jobs)
        toast(" Triangle已经退出了")
    end

    function  Rectangle ()
        local jobs = {
            Action(c2):slid(2000,Point(173,557),Point(509,553),Point(484,833),Point(154,852),Point(173,557)):after(isexit),
        }
        M.FishPond:run(jobs)
        toast(" Rectangle已经退出了")
    end

    Triangle ()
    Rectangle ()
end
```

