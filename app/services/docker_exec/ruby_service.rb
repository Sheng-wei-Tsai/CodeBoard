module DockerExec
  class RubyService
    attr_reader :code, :test_code, :path, :separator, :container_id
    attr_reader :success?
    attr_reader :timeout?
  
    def initialize(code = "", test_code = [''])
      @code = code
      @test_code = test_code
      @path = file_path
      @separator = get_separator
    end
  
    def run
      if lack_args?
        # nil
        { ok: false, message: 'No Argrument!'}
      else
        create_file
        get_id
        5.times do
          if done?
            result = get_result
            remove_file_and_container
            # return result
            ok = result.is_a?(String) ? false : true
            if ok
              return { ok: true, data: result }
            else
              return { ok: false, message: result }
            end
          else
            sleep 1
          end
        end
        remove_file_and_container
        # return "Times out!"
        { ok: false, message: 'Times out!' }
      end
    end

    def run
      return { ok: false, message: 'No Argrument!'} if lack_args?

      handle_result = lambda do
        result = get_result
        remove_file_and_container
        if result.is_a?(String)
          { ok: false, message: result }
        else
          { ok: true, data: result }
        end
      end

      create_file
      get_id
      5.times do
        return handle_result.() if done?
        
        sleep 1
      end

      remove_file_and_container
      { ok: false, message: 'Times out!' }
    end
  
    private
    def lack_args?
      code.empty? || test_code.nil? || test_code.map{ |e| e.empty?}.include?(true)
    end

    def create_file
      file = File.open(path, "w") 
      contents.each { |e|
        file.write(e)
        file.write("\n")
      }
      file.close
    end
  
    def get_id
      @container_id = `docker run -d -m 128M -c 512 -v #{path}:/main.rb ruby ruby /main.rb`
    end
  
    def done?
      `docker ps --format "{{.ID}}: {{.Status}}" -f "id=#{container_id}"`.empty?
    end

    def get_result
      raw_output = `docker logs #{container_id}`
      if raw_output.empty?
        out, err = Open3.capture3("`docker logs #{container_id}`")
        err
      else
        out = JSON.parse(raw_output.split("#{separator}").pop.strip)
      end
    end
  
    def remove_file_and_container
      File.unlink(path)
      `docker rm -f #{container_id}`
    end
  
    def file_path
      tmp_file = [*"a".."z", *"A".."Z"].sample(5).join('') + ".rb"
      path = Rails.root.join('tmp', "#{tmp_file}").to_s
    end

    def get_separator
      [*"a".."z", *"A".."Z"].sample(10).join('')
    end
  
    def contents
      test_data = test_code.map{ |e| e = "result.push(#{e})" }.join("\n")
      [code, "require 'json'", "result = []", test_data, "puts \"#{separator}\"", "puts JSON.generate(result)"]
    end
  end
end