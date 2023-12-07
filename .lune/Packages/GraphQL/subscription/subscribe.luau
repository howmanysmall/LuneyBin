--!native
--!optimize 2
--[[
 * Copyright (c) GraphQL Contributors
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
]]
-- ROBLOX upstream: https://github.com/graphql/graphql-js/blob/v15.5.1/src/subscription/subscribe.js
local LuauPolyfill = require("../../LuauPolyfill")
type Promise<T> = LuauPolyfill.Promise<T>

local astModule = require("../language/ast")
type DocumentNode = astModule.DocumentNode
local executeModule = require("../execution/execute")
type ExecutionResult = executeModule.ExecutionResult
type ExecutionContext = executeModule.ExecutionContext
local schemaModule = require("../type/schema")
type GraphQLSchema = schemaModule.GraphQLSchema
local definitionModule = require("../type/definition")
-- ROBLOX TODO: Luau doesn't currently support default type args, so inline any
type GraphQLFieldResolver<T, V> = definitionModule.GraphQLFieldResolver<T, V, any>

export type SubscriptionArgs = {
	schema: GraphQLSchema,
	document: DocumentNode,
	rootValue: any?,
	contextValue: any?,
	variableValues: {[string]: any},
	operationName: string?,
	fieldResolver: GraphQLFieldResolver<any, any>?,
	subscribeFieldResolver: GraphQLFieldResolver<any, any>?,
}

local function subscribe(_args: SubscriptionArgs): Promise<ExecutionResult>
	error("graphql-lua does not currently implement subscriptions")
end

local function createSourceEventStream(
	_schema: GraphQLSchema,
	_document: DocumentNode,
	_rootValue: any?,
	_contextValue: any?,
	_variableValues: {[string]: any}?,
	_operationName: string?,
	_fieldResolver: GraphQLFieldResolver<any, any>?
): Promise<ExecutionResult>
	error("graphql-lua does not currently implement subscriptions")
end

return {
	subscribe = subscribe;
	createSourceEventStream = createSourceEventStream;
}
