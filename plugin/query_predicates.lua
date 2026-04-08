local query = vim.treesitter.query

--- Normalize match value to a list of nodes.
--- In Neovim 0.12+, match[id] returns a list of TSNode.
--- Guard against older behavior where a single node may be returned.
---@param val TSNode[]|TSNode|nil
---@return TSNode[]
local function normalize_nodes(val)
  if not val then
    return {}
  end
  if type(val) == 'table' and val[1] then
    return val
  end
  -- single node (userdata) or unexpected shape - wrap in a list
  if type(val) == 'userdata' then
    return { val }
  end
  return {}
end

local predicates = {
  ---@param match table<integer,TSNode[]>
  ---@param pred any[]
  ---@param any boolean
  ---@return boolean
  ['kind-eq'] = function(match, pred, any)
    local nodes = normalize_nodes(match[pred[2]])
    if #nodes == 0 then
      return true
    end

    local types = { unpack(pred, 3) }
    for _, node in ipairs(nodes) do
      local res = vim.list_contains(types, node:type())
      if any and res then
        return true
      elseif not any and not res then
        return false
      end
    end
    return not any
  end,
}

-- register custom predicates (overwrite existing; needed for CI)

---@param match table<integer,TSNode[]>
---@param pred any[]
---@return boolean
query.add_predicate('kind-eq?', function(match, _, _, pred, _metadata)
  return predicates['kind-eq'](match, pred, false)
end, { force = true })

---@param match table<integer,TSNode[]>
---@param pred any[]
---@return boolean
query.add_predicate('any-kind-eq?', function(match, _, _, pred, _metadata)
  return predicates['kind-eq'](match, pred, true)
end, { force = true })
