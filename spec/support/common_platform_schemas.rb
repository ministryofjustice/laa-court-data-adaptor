require "sinatra/base"

class CommonPlatformSchemas < Sinatra::Base
  get "/" do
    "fake common platform running"
  end

  get "/core/courts/:directory/:file_name" do
    json_response(200, "/global/", params[:file_name])
  end

  get "/core/courts/:file_name" do
    json_response(200, "/global/", params[:file_name])
  end

  get "/core/external/:directory/:file_name" do
    json_response(200, "/global/", params[:file_name])
  end

  get "/core/courts/search/external/:file_name" do
    json_response(200, "/global/search/", params[:file_name])
  end

  get "/core/external/global/search/:file_name" do
    json_response(200, "/global/search/", params[:file_name])
  end

  get "/core/external/global/:directory/:file_name" do
    json_response(200, "/global/", params[:file_name])
  end

  get "/results/external/:directory/:file_name" do
    json_response(200, "/global/", params[:file_name])
  end

  get "/hearing/external/:directory/:file_name" do
    json_response(200, "/global/", params[:file_name])
  end

  get "/core/courts/:directory/search/:file_name" do
    json_response(200, "/global/search/", params[:file_name])
  end

  get "/core/courts/search/public/:file_name" do
    json_response(200, "/global/search/", params[:file_name])
  end

  get "/unified_search_query/global/search/:file_name" do
    json_response(200, "/global/search/", params[:file_name])
  end

  get "/unified_search_query/external/global/search/:file_name" do
    json_response(200, "/global/search/", params[:file_name])
  end

  get "/unified_search_query/external/global/:file_name" do
    json_response(200, "/global/", params[:file_name])
  end

  get "/results/global/:file_name" do
    json_response(200, "/global/", params[:file_name])
  end

private

  def json_response(response_code, file_path, file_name)
    content_type :json
    status response_code

    file_name = normalise_file_name(file_name)

    file_contents = JSON.parse(Rails.root.join("lib/schemas/#{file_path}/#{file_name}").read)

    # We need to rewrite /core/courts/search/public/whatever
    # to match /core/courts/search/global/whatever
    # depending on the location that the schema is referenced from.
    # This is particularly important for courtsDefinitions.json which could
    # be referenced from both urls. The easiest way to do this is by
    # rewriting the path in the "id" attribute
    # for the schema based on the requested path
    file_contents["id"] = url
    file_contents.to_json
  end

  def normalise_file_name(name)
    name = "api#{name}" unless name.starts_with? "api"

    # apicourtsDefinitions.json => apiCourtsDefinitions.json
    name.chars.map.with_index { |x, i| (x.upcase if i == 3) || x }.join
  end
end
