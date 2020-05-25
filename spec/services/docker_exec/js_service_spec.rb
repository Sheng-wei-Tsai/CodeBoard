require 'rails_helper'

RSpec.describe DockerExec::JsService do

  describe "基本功能" do

    it "符合格式的程式碼執行" do
      code = "function iteration(list){\r\n  return list.map(x => x + 2)\r\n}"
      test_code = ["iteration([1, 2, 3, 4, 5])", "iteration([4, 5, 6, 7, 8])"]

      js = DockerExec::JsService.new(code, test_code)

      expect(js.run).to eq [[3, 4, 5, 6, 7], [6, 7, 8, 9, 10]]
    end

    it "無窮迴圈的程式碼執行" do
      code = "function circle(n){\r\n  for(let i = n; i < 10 ; i * 1){\r\n    console.log(i)\r\n  }\r\n}"
      test_code = ["circle(1)"]

      js = DockerExec::JsService.new(code, test_code)

      expect(js.run).to eq "Times out!"
    end

    it "印出 STDERR 訊息" do
      code = "function iteration(list){\r\n  return day\r\n}"
      test_code = ["iteration [1, 2, 3, 4, 5]", "iteration [4, 5, 6, 7, 8]"]

      js = DockerExec::JsService.new(code, test_code)

      expect(js.run) == 
      ["/main.js:2\n  return day\n  ^\n\nReferenceError: day is not defined\n    at iteration (/main.js:2:3)\n    at Object.<anonymous> (/main.js:7:13)\n    at Module._compile (internal/modules/cjs/loader.js:1176:30)\n    at Object.Module._extensions..js (internal/modules/cjs/loader.js:1196:10)\n    at Module.load (internal/modules/cjs/loader.js:1040:32)\n    at Function.Module._load (internal/modules/cjs/loader.js:929:14)\n    at Function.executeUserEntryPoint [as runMain] (internal/modules/run_main.js:71:12)\n    at internal/main/run_main_module.js:17:47\n"]
    end

    it "引數為 nil 的補救情況" do
      code = ""
      test_code1 = nil
      test_code2 = [""]
      test_code3 = ["", ""]

      js1 = DockerExec::JsService.new(code, test_code1)
      js2 = DockerExec::JsService.new(code, test_code2)
      js3 = DockerExec::JsService.new(code, test_code3)

      expect(js1.run).to be nil
      expect(js2.run).to be nil
      expect(js3.run).to be nil
    end

  end

end