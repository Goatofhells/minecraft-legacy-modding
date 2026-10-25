---@meta

---@class modplr
---@field x number
---@field y number
---@field z number
---@field health number
---@field dim integer
---@field flight boolean

---@class modslot
---@field id integer
---@field count integer
---@field aux integer

---@class moditem
---@field id integer
---@field stack integer

---@class modblock
---@field dim integer
---@field x integer
---@field y integer
---@field z integer
---@field id integer
---@field aux integer
---@field face integer

---@class modapi
---@field api integer
---@field id string
---@field on fun(event: 'load'|'unload'|'tick'|'join'|'leave'|'chat'|'break'|'use', cb: function)
---@field command fun(name: string, cb: fun(name: string, args: string))
---@field players fun(): string[]
---@field player fun(name: string): modplr?, string?
---@field inventory fun(name: string): table<integer, modslot>?, string?
---@field item fun(id: integer): moditem?
---@field message fun(name: string, text: string): boolean
---@field give fun(name: string, id: integer, count?: integer, aux?: integer): integer?, integer|string?
---@field take fun(name: string, id: integer, count?: integer, aux?: integer): integer?, string?
---@field heal fun(name: string): boolean?, string?
---@field teleport fun(name: string, x: number, y: number, z: number): boolean?, string?
---@field flight fun(name: string, enabled: boolean): boolean?, string?
---@field block fun(dim: integer, x: integer, y: integer, z: integer): integer?, integer|string?
---@field setblock fun(dim: integer, x: integer, y: integer, z: integer, id: integer, aux?: integer): boolean?, string?
---@field time fun(dim: integer, ticks?: integer): integer?, string?
---@field weather fun(dim: integer, state: 'clear'|'rain'|'storm'): boolean?, string?
---@field get fun(key: string): string|number|boolean|nil
---@field set fun(key: string, val: string|number|boolean|nil)
---@field log fun(text: string)

---@type modapi
legacy = legacy
