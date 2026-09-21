---@class (exact) TreeNode<B, L>
---@field value B
---@field children TreeNode<B, L>[]
---@field leaves L[]

---@class (exact) Tree<B, L>
---@field nodes TreeNode<B, L>[]
---@field source B[]
---@field query string
---@field children_fn fun(node: B): B[]
---@field leaves_fn fun(node: B): L[]
---@field filter_fn (fun(node: B): string)?
---@field filter_leaf_fn (fun(leaf: L): string)?

---@class (exact) TreeOptionalArgs<B, L>
---@field filter_fn (fun(node: B): string)?
---@field filter_leaf_fn (fun(leaf: L): string)?

---@class Tree
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@generic B, L
---@param source B[]
---@param children_fn fun(node: B): B[]
---@param leaves_fn fun(node: B): L[]
---@param optional_args TreeOptionalArgs<B, L>?
---@return Tree<B, L>
function this:new(source, children_fn, leaves_fn, optional_args)
    optional_args = optional_args or {}

    local o = {
        nodes = {},
        source = source,
        query = "",
        children_fn = children_fn,
        leaves_fn = leaves_fn,
        filter_fn = optional_args.filter_fn,
        filter_leaf_fn = optional_args.filter_leaf_fn,
    }

    setmetatable(o, self)
    ---@cast o Tree

    o:_rebuild()

    return o
end

---@param source B[]
function this:swap(source)
    self.source = source
    self:_rebuild()
end

---@param query string
function this:filter(query)
    if not self.filter_fn and not self.filter_leaf_fn then
        return
    end

    query = query:lower()

    if self.query == query then
        return
    end

    self.query = query
    self:_rebuild()
end

---@return boolean
function this:empty()
    return #self.nodes == 0
end

---@return integer
function this:size()
    return #self.nodes
end

---@return TreeNode<B, L>[]
function this:get()
    return self.nodes
end

---@param value string
---@return boolean
function this:_matches(value)
    return value:lower():find(self.query, 1, true) ~= nil
end

---@param node B
---@param ancestor_matches boolean?
---@return TreeNode<B, L>?
function this:_filter_node(node, ancestor_matches)
    local node_matches = self.query == ""
        or not self.filter_fn
        or self:_matches(self.filter_fn(node))

    local subtree_matches = ancestor_matches or node_matches
    ---@type TreeNode<B, L>[]
    local children = {}
    for _, child in ipairs(self.children_fn(node)) do
        local filtered = self:_filter_node(child, subtree_matches)
        if filtered then
            table.insert(children, filtered)
        end
    end

    ---@type L[]
    local leaves = {}
    ---@diagnostic disable-next-line: no-unknown
    for _, leaf in ipairs(self.leaves_fn(node)) do
        if
            subtree_matches
            or not self.filter_leaf_fn
            or self:_matches(self.filter_leaf_fn(leaf))
        then
            table.insert(leaves, leaf)
        end
    end

    if not subtree_matches and #children == 0 and #leaves == 0 then
        return nil
    end

    return {
        value = node,
        children = children,
        leaves = leaves,
    }
end

function this:_rebuild()
    self.nodes = {}
    ---@diagnostic disable-next-line: no-unknown
    for _, node in ipairs(self.source) do
        local filtered = self:_filter_node(node)

        if filtered then
            table.insert(self.nodes, filtered)
        end
    end
end

return this
