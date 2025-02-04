-- =============================================================================
-- CommandSage_PersistentTrie.lua
-- Saves and loads the Trie to reduce startup scans
-- =============================================================================

CommandSage_PersistentTrie = {}

local TRIE_DB_KEY = "cachedTrie"

local function SerializeTrieNode(node)
    local result = {
        isTerminal = node.isTerminal,
        info = node.info,
        children = {},
    }
    for c, child in pairs(node.children) do
        result.children[c] = SerializeTrieNode(child)
    end
    return result
end

local function DeserializeTrieNode(data)
    local node = {
        children = {},
        isTerminal = data.isTerminal,
        info = data.info,
    }
    for c, childData in pairs(data.children) do
        node.children[c] = DeserializeTrieNode(childData)
    end
    return node
end

function CommandSage_PersistentTrie:SaveTrie()
    local root = CommandSage_Trie:GetRoot()
    local serialized = SerializeTrieNode(root)
    CommandSageDB[TRIE_DB_KEY] = serialized
end

function CommandSage_PersistentTrie:LoadTrie()
    local cached = CommandSageDB[TRIE_DB_KEY]
    if cached then
        CommandSage_Trie:Clear()
        local root = CommandSage_Trie:GetRoot()
        local loadedRoot = DeserializeTrieNode(cached)
        root.children = loadedRoot.children
        root.isTerminal = loadedRoot.isTerminal
        root.info = loadedRoot.info
    end
end
