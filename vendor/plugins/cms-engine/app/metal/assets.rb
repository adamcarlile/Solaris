# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)

class Assets
  def self.call(env)
    if env["PATH_INFO"] =~ /^\/assets\/([^\/]+)\/(.+)/
      @type, @id = $1, $2
      @id,@version = @id.split('-')

      if @type == 'images'
        @asset_class = Image
        @content_disposition = 'inline'
      elsif @type == 'files'
        @asset_class = FileUpload
        @content_disposition = 'attachment'
      else
        return not_found        
      end

      begin
        @asset = @asset_class.find(@id)
      rescue
        return not_found
      end

      @file_data = File.open(@asset.file.path(@version)).read
      @filename = @asset.file_file_name
      @headers = {
        "Content-Type"        => @asset.file_content_type, 
        "Content-disposition" => "#{@content_disposition}; filename=\"#{@filename}\""
      }
      [200, @headers, [@file_data]]
    else
      not_found
    end
  end

  def self.not_found
    [404, {"Content-Type" => "text/html"}, ["Not Found"]]
  end

end
