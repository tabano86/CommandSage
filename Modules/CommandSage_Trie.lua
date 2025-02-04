-- =============================================================================
-- CommandSage_Trie.lua
-- Stores discovered commands in a Trie for efficient lookups
-- =============================================================================

CommandSage_Trie = {}

local root = {
    children = {},
    isTerminal = false,
    info = nil,  -- For storing the command metadata
}

-- Insert a slash command into the Trie
function CommandSage_Trie:InsertCommand(command, data)
    local node = root
    for i=1, #command do
        local c = command:sub(i,i)
        if not node.children[c] then
            node.children[c] = {
                children = {},
                isTerminal = false,
                info = nil,
            }
        end
        node = node.children[c]
    end
    node.isTerminal = true
    node.info = data
end

-- Helper to recursively gather all terminal nodes under a node
local function GatherAllCommands(node, prefix, results)
    if node.isTerminal and node.info then
        table.insert(results, { slash=prefix, data=node.info })
    end
    for c, child in pairs(node.children) do
        GatherAllCommands(child, prefix .. c, results)
    end
end

-- Find all completions for a given prefix
function CommandSage_Trie:FindPrefix(prefix)
    local node = root
    for i=1, #prefix do
        local c = prefix:sub(i,i)
        if not node.children[c] then
            return {} -- No matches
        end
        node = node.children[c]
    end
    local results = {}
    GatherAllCommands(node, prefix, results)
    return results
end

function CommandSage_Trie:GetRoot()
    return root
end

function CommandSage_Trie:Clear()
    wipe(root.children)
    root.isTerminal = false
    root.info = nil
end
