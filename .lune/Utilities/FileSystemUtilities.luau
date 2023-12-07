--!native
--!optimize 2
--!strict

local Promise = require("../Packages/PromiseTyped")
local fs = require("@lune/fs")
local serde = require("@lune/serde")

--[=[
	Utilities for working with the file system.
	@class FileSystemUtilities
]=]
local FileSystemUtilities = {}
FileSystemUtilities.Promise = Promise

export type Promise<T...> = Promise.TypedPromise<T...>

function FileSystemUtilities.PromiseReadFile(FilePath: string): Promise<string>
	return Promise.new(function(Resolve, Reject)
		local Success, Value = pcall(fs.readFile, FilePath)
		if Success then
			Resolve(Value)
		else
			Reject(Value)
		end
	end)
end

function FileSystemUtilities.PromiseWriteFile(FilePath: string, FileContents: string): Promise<nil>
	return Promise.new(function(Resolve, Reject)
		local Success, Exception = pcall(fs.writeFile, FilePath, FileContents)
		if Success then
			Resolve()
		else
			Reject(Exception)
		end
	end)
end

function FileSystemUtilities.PromiseReadDir(FilePath: string): Promise<{string}>
	return Promise.new(function(Resolve, Reject)
		local Success, Value = pcall(fs.readDir, FilePath)
		if Success then
			Resolve(Value)
		else
			Reject(Value)
		end
	end)
end

function FileSystemUtilities.PromiseWriteDir(FilePath: string): Promise<nil>
	return Promise.new(function(Resolve, Reject)
		local Success, Exception = pcall(fs.writeDir, FilePath)
		if Success then
			Resolve()
		else
			Reject(Exception)
		end
	end)
end

function FileSystemUtilities.PromiseSafeWriteFile(FilePath: string, FileContents: string): Promise<nil>
	return Promise.new(function(Resolve, Reject)
		local Success, Exception =
			pcall(FileSystemUtilities.SafeWriteFile :: (string, string) -> nil, FilePath, FileContents)
		if Success then
			Resolve()
		else
			Reject(Exception)
		end
	end)
end

--[=[
	Gets the file extension of the file at the path.
	@param FilePath string -- The path to the file.
	@return string? -- The file extension.
]=]
function FileSystemUtilities.GetFileExtension(FilePath: string, SkipAfterNoExtension: boolean?): string?
	local NoExtensionCheck = string.match(FilePath, "[^/\\]+%.(%w+)$")
	if NoExtensionCheck then
		return NoExtensionCheck
	end

	return if SkipAfterNoExtension
		then nil
		else string.match(FilePath, "%.([^%.]+)$") or string.match(FilePath, "%.(%a+)$")
end

local EXTENSION_TO_XCODE: {[string]: serde.EncodeDecodeFormat} = {
	json = "json";
	toml = "toml";
	yaml = "yaml";
	yml = "yaml";
}

function FileSystemUtilities.GetEncodeDecodeType(FilePath: string): serde.EncodeDecodeFormat?
	local FileExtension = FileSystemUtilities.GetFileExtension(FilePath)
	return if FileExtension then EXTENSION_TO_XCODE[FileExtension] else nil
end

--[=[
	Gets the name of the file.
	@param FilePath string -- The path to the file.
	@return string? -- The name of the file.
]=]
function FileSystemUtilities.GetFileName(FilePath: string)
	return string.match(FilePath, "([^/\\]+)$") or FilePath
end

function FileSystemUtilities.GetFileNameWithoutExtension(FilePath: string)
	return string.match(FilePath, "([^/\\]+)%.%w+$") or string.match(FilePath, "([^/\\]+)$") or FilePath
end

function FileSystemUtilities.CreateDirectory(FilePath: string)
	if not fs.isDir(FilePath) then
		fs.writeDir(FilePath)
	end
end

function FileSystemUtilities.SafeWriteFile(FilePath: string, FileContents: string)
	if not fs.isFile(FilePath) then
		fs.writeFile(FilePath, FileContents)
	else
		local FileName = FileSystemUtilities.GetFileNameWithoutExtension(FilePath)
		local FileExtension = FileSystemUtilities.GetFileExtension(FilePath)
		local BasePath = string.gsub(FilePath, FileSystemUtilities.GetFileName(FilePath), "")
		local Index = 1

		while fs.isFile(`{BasePath}{FileName} ({Index}).{FileExtension}`) do
			Index += 1
		end

		fs.writeFile(`{BasePath}{FileName} ({Index}).{FileExtension}`, FileContents)
	end
end

return table.freeze(FileSystemUtilities)
