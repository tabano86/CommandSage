-- =============================================================================
-- CommandSage_Trie.lua
-- Optimized Trie for storing slash commands
-- =============================================================================

CommandSage_Trie = {}

local root = {
    children = {},
    isTerminal = false,
    info = nil,
    maxDepth = 0, -- optional optimization
}

local function updateMaxDepth(node, depth)
    if depth > (node.maxDepth or 0) then
        node.maxDepth = depth
    end
end

function CommandSage_Trie:InsertCommand(command, data)
    local node = root
    for i=1, #command do
        local c = command:sub(i,i)
        if not node.children[c] then
            node.children[c] = {
                children = {},
                isTerminal = false,
                info = nil,
                maxDepth = 0,
            }
        end
        node = node.children[c]
        updateMaxDepth(node, #command - i)
    end
    node.isTerminal = true
    node.info = data
end

local function gatherAll(node, prefix, results)
    if node.isTerminal and node.info then
        table.insert(results, { slash=prefix, data=node.info })
    end
    for c, child in pairs(node.children) do
        gatherAll(child, prefix..c, results)
    end
end

function CommandSage_Trie:FindPrefix(prefix)
    local node = root
    for i=1,#prefix do
        local c = prefix:sub(i,i)
        local child = node.children[c]
        if not child then
            return {}
        end
        node = child
    end
    local results = {}
    gatherAll(node, prefix, results)
    return results
end

function CommandSage_Trie:GetRoot()
    return root
end

function CommandSage_Trie:Clear()
    wipe(root.children)
    root.isTerminal = false
    root.info = nil
    root.maxDepth = 0
end
