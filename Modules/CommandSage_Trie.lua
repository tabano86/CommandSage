-- =============================================================================
-- CommandSage_Trie.lua
-- Optimized Trie for storing slash commands
-- Includes RemoveCommand() so we can unregister
-- Now includes AllCommands() for partial fallback
-- =============================================================================

CommandSage_Trie = {}

local root = {
    children = {},
    isTerminal = false,
    info = nil,
    maxDepth = 0,
}

local function updateMaxDepth(node, depth)
    if depth > (node.maxDepth or 0) then
        node.maxDepth = depth
    end
end

function CommandSage_Trie:InsertCommand(command, data)
    local node = root
    for i = 1, #command do
        local c = command:sub(i, i)
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
        table.insert(results, { slash = prefix, data = node.info })
    end
    for c, child in pairs(node.children) do
        gatherAll(child, prefix .. c, results)
    end
end

function CommandSage_Trie:FindPrefix(prefix)
    local node = root
    for i = 1, #prefix do
        local c = prefix:sub(i, i)
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

-- New: return all commands in the trie
function CommandSage_Trie:AllCommands()
    local results = {}
    gatherAll(root, "", results)
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

function CommandSage_Trie:RemoveCommand(command)
    local path = {}
    local node = root

    for i = 1, #command do
        local c = command:sub(i, i)
        if not node.children[c] then
            return
        end
        table.insert(path, { parent = node, char = c })
        node = node.children[c]
    end

    if not node.isTerminal then
        return
    end

    node.isTerminal = false
    node.info = nil

    for i = #path, 1, -1 do
        local entry = path[i]
        local parent = entry.parent
        local char = entry.char
        local child = parent.children[char]

        if child.isTerminal then
            break
        end
        if not next(child.children) then
            parent.children[char] = nil
        else
            break
        end
    end
end
