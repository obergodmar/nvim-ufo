local api = vim.api
local cmd = vim.cmd
local fn = vim.fn

local utils = require('ufo.utils')

local M = {}

function M.goPreviousStartFold()
    local function getCurLnum()
        return api.nvim_win_get_cursor(0)[1]
    end

    local cnt = vim.v.count1
    local winView = fn.winsaveview()
    local curLnum = getCurLnum()
    cmd('norm! m`')
    local previousLnum
    local previousLnumList = {}
    while cnt > 0 do
        cmd([[keepj norm! zk]])
        local tLnum = getCurLnum()
        cmd([[keepj norm! [z]])
        if tLnum == getCurLnum() then
            local foldStartLnum = utils.foldClosed(0, tLnum)
            if foldStartLnum > 0 then
                cmd(('keepj norm! %dgg'):format(foldStartLnum))
            end
        end
        local nextLnum = getCurLnum()
        while curLnum > nextLnum do
            tLnum = nextLnum
            table.insert(previousLnumList, nextLnum)
            cmd([[keepj norm! zj]])
            nextLnum = getCurLnum()
            if nextLnum == tLnum then
                break
            end
        end
        if #previousLnumList == 0 then
            break
        end
        if #previousLnumList < cnt then
            cnt = cnt - #previousLnumList
            curLnum = previousLnumList[1]
            previousLnum = curLnum
            cmd(('keepj norm! %dgg'):format(curLnum))
            previousLnumList = {}
        else
            while cnt > 0 do
                previousLnum = table.remove(previousLnumList)
                cnt = cnt - 1
            end
        end
    end
    fn.winrestview(winView)
    if previousLnum then
        cmd(('norm! %dgg_'):format(previousLnum))
    end
end

return M