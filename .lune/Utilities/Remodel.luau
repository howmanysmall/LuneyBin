--!native
--!optimize 2
--!strict

local fs = require("@lune/fs")
local net = require("@lune/net")
local process = require("@lune/process")
local roblox = require("@lune/roblox")
local serde = require("@lune/serde")

export type LuneDataModel = roblox.DataModel
export type LuneInstance = roblox.Instance

local function GetAuthCookieWithFallbacks()
	local Cookie = roblox.getAuthCookie()
	if Cookie then
		return Cookie
	end

	local CookieFromEnv = process.env.REMODEL_AUTH
	if CookieFromEnv and #CookieFromEnv > 0 then
		return `.ROBLOSECURITY={CookieFromEnv}`
	end

	for Index, Argument in process.args do
		if Argument == "--auth" then
			local CookieFromArgs = process.args[Index + 1]
			if CookieFromArgs and #CookieFromArgs > 0 then
				return `.ROBLOSECURITY={CookieFromArgs}`
			end

			break
		end
	end

	error([[
		Failed to find ROBLOSECURITY cookie for authentication!
		Make sure you have logged into studio, or set the ROBLOSECURITY environment variable.
	]])
end

local function DownloadAssetId(AssetId: number)
	-- 1. Try to find the auth cookie for the current user
	local Cookie = GetAuthCookieWithFallbacks()

	-- 2. Send a request to the asset delivery API,
	--    which will respond with cdn download link(s)
	local AssetApiResponse = net.request({
		headers = {
			Accept = "application/json";
			Cookie = Cookie;
		};
		url = `https://assetdelivery.roblox.com/v2/assetId/{AssetId}`;
	})

	if not AssetApiResponse.ok then
		error(
			string.format(
				"Failed to fetch asset download link for asset id %*!\n%* (%*)\n%*",
				tostring(AssetId),
				tostring(AssetApiResponse.statusCode),
				tostring(AssetApiResponse.statusMessage),
				tostring(AssetApiResponse.body)
			)
		)
	end

	-- 3. Make sure we got a valid response body
	local AssetApiBody = serde.decode("json", AssetApiResponse.body)
	if type(AssetApiBody) ~= "table" or type(AssetApiBody.locations) ~= "table" then
		error(string.format("Asset delivery API returned an invalid response body!\n%*", AssetApiResponse.body))
	end

	-- 4. Grab the first asset download location - we only
	--    requested one in our query, so this will be correct
	local FirstLocation = AssetApiBody.locations[1]
	if type(FirstLocation) ~= "table" then
		error(string.format("Asset delivery API returned no download locations!\n%*", AssetApiResponse.body))
	elseif type(FirstLocation.location) ~= "string" then
		error(string.format("Asset delivery API returned no valid download locations!\n%*", AssetApiResponse.body))
	end

	-- 5. Fetch the place contents from the cdn
	local CdnResponse = net.request({
		headers = {Cookie = Cookie};
		url = FirstLocation.location;
	})

	if not CdnResponse.ok then
		error(
			string.format(
				"Failed to download asset with id %* from the Roblox cdn!\n%* (%*)\n%*",
				tostring(AssetId),
				tostring(CdnResponse.statusCode),
				tostring(CdnResponse.statusMessage),
				tostring(CdnResponse.body)
			)
		)
	end

	-- 6. The response body should now be the contents of the asset file
	return CdnResponse.body
end

local function UploadAssetId(AssetId: number, Contents: string)
	-- 1. Try to find the auth cookie for the current user
	local Cookie = GetAuthCookieWithFallbacks()

	-- 2. Use a different endpoint to fetch a valid CSRF token
	local CsrfResponse = net.request({
		body = Contents;
		headers = {
			Accept = "application/json";
			Cookie = Cookie;
			["User-Agent"] = "Roblox/WinInet";
		};
		method = "POST";
		url = `https://auth.roblox.com/`;
	})

	local CsrfToken = CsrfResponse.headers["x-csrf-token"]
	if CsrfToken == nil then
		error("Failed to fetch CSRF token.")
	end

	-- 3. Upload the asset to Roblox
	local UploadResponse = net.request({
		body = Contents;
		headers = {
			Accept = "application/json";
			["Content-Type"] = "application/octet-stream";
			Cookie = Cookie;
			["User-Agent"] = "Roblox/WinInet";
			["X-CSRF-Token"] = CsrfToken;
		};
		method = "POST";
		url = `https://data.roblox.com/Data/Upload.ashx?assetid={AssetId}`;
	})

	-- 4. Make sure it uploaded properly
	if not UploadResponse.ok then
		error(
			string.format(
				"Failed to upload asset with id %* to Roblox!\n%* (%*)\n%*",
				tostring(AssetId),
				tostring(UploadResponse.statusCode),
				tostring(UploadResponse.statusMessage),
				tostring(UploadResponse.body)
			)
		)
	end
end

local Remodel = {}

--[=[
	Load an `rbxl` or `rbxlx` file from the filesystem.

	Returns a `DataModel` instance, equivalent to `game` from within Roblox.
]=]
function Remodel.readPlaceFile(FilePath: string)
	return roblox.deserializePlace(fs.readFile(FilePath))
end

--[=[
	Load an `rbxm` or `rbxmx` file from the filesystem.

	Note that this function returns a **list of instances** instead of a single instance!
	This is because models can contain mutliple top-level instances.
]=]
function Remodel.readModelFile(FilePath: string)
	return roblox.deserializeModel(fs.readFile(FilePath))
end

--[=[
	Reads a place asset from Roblox, equivalent to `remodel.readPlaceFile`.

	***NOTE:** This function requires authentication using a ROBLOSECURITY cookie!*
]=]
function Remodel.readPlaceAsset(AssetId: number)
	return roblox.deserializePlace(DownloadAssetId(AssetId))
end

--[=[
	Reads a model asset from Roblox, equivalent to `remodel.readModelFile`.

	***NOTE:** This function requires authentication using a ROBLOSECURITY cookie!*
]=]
function Remodel.readModelAsset(AssetId: number)
	return roblox.deserializeModel(DownloadAssetId(AssetId))
end

--[=[
	Saves an `rbxl` or `rbxlx` file out of the given `DataModel` instance.

	If the instance is not a `DataModel`, this function will throw.
	Models should be saved with `writeModelFile` instead.
]=]
function Remodel.writePlaceFile(FilePath: string, DataModel: LuneDataModel)
	local AsXml = string.sub(FilePath, -6) == ".rbxlx"
	assert(string.sub(FilePath, -5) == ".rbxl" or AsXml, "File path must have .rbxl or .rbxlx extension")
	fs.writeFile(FilePath, roblox.serializePlace(DataModel, AsXml))
end

--[=[
	Saves an `rbxm` or `rbxmx` file out of the given `Instance`.

	If the instance is a `DataModel`, this function will throw.
	Places should be saved with `writePlaceFile` instead.
]=]
function Remodel.writeModelFile(FilePath: string, Instance: LuneInstance)
	local AsXml = string.sub(FilePath, -6) == ".rbxmx"
	assert(string.sub(FilePath, -5) == ".rbxm" or AsXml, "File path must have .rbxm or .rbxmx extension")
	fs.writeFile(FilePath, roblox.serializeModel({Instance}, AsXml))
end

--[=[
	Uploads the given `DataModel` instance to Roblox, overwriting an existing place.

	If the instance is not a `DataModel`, this function will throw.
	Models should be uploaded with `writeExistingModelAsset` instead.

	***NOTE:** This function requires authentication using a ROBLOSECURITY cookie!*
]=]
function Remodel.writeExistingPlaceAsset(DataModel: LuneDataModel, AssetId: number)
	UploadAssetId(AssetId, roblox.serializePlace(DataModel))
end

--[=[
	Uploads the given instance to Roblox, overwriting an existing model.

	If the instance is a `DataModel`, this function will throw.
	Places should be uploaded with `writeExistingPlaceAsset` instead.

	***NOTE:** This function requires authentication using a ROBLOSECURITY cookie!*
]=]
function Remodel.writeExistingModelAsset(Instance: LuneInstance, AssetId: number)
	UploadAssetId(AssetId, roblox.serializeModel({Instance}))
end

Remodel.readFile = fs.readFile
Remodel.readDir = fs.readDir
Remodel.writeFile = fs.writeFile
Remodel.createDirAll = fs.writeDir
Remodel.removeFile = fs.removeFile
Remodel.removeDir = fs.removeDir
Remodel.isFile = fs.isFile
Remodel.isDir = fs.isDir

return table.freeze(Remodel)
