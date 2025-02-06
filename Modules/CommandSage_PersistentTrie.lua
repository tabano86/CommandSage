CommandSage_PersistentTrie = {}
local KEY = "cachedTrie"
local function serializeNode(node)
    local data = {
        isTerminal = node.isTerminal,
        info = node.info,
        children = {},
        maxDepth = node.maxDepth or 0
    }
    for c, child in pairs(node.children) do
        data.children[c] = serializeNode(child)
    end
    return data
end
local function deserializeNode(data)
    local node = {
        children = {},
        isTerminal = data.isTerminal,
        info = data.info,
        maxDepth = data.maxDepth
    }
    for c, childData in pairs(data.children) do
        node.children[c] = deserializeNode(childData)
    end
    return node
end
function CommandSage_PersistentTrie:SaveTrie()
    local r = CommandSage_Trie:GetRoot()
    local s = serializeNode(r)
    CommandSageDB[KEY] = s
end
function CommandSage_PersistentTrie:LoadTrie()
    local s = CommandSageDB[KEY]
    if s then
        CommandSage_Trie:Clear()
        local loaded = deserializeNode(s)
        local r = CommandSage_Trie:GetRoot()
        r.children = loaded.children
        r.isTerminal = loaded.isTerminal
        r.info = loaded.info
        r.maxDepth = loaded.maxDepth
    end
end
function CommandSage_PersistentTrie:ClearCachedTrie()
    CommandSageDB[KEY] = nil
    print("CommandSage: Persistent trie data cleared.")
end
