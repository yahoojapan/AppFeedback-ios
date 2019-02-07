
license = <<EOL
//
//  <File>
//  <Class>
//
//  Copyright (c) 2018 Yahoo Japan Corporation.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
EOL

Dir.glob("**/*.{h,m,swift}").each do |file|
  content = File.read(file)
  
  # 既存の先頭のライセンス削除

  lines = content.lines

  while lines[0].start_with?("//") || lines[0] =~ /^\s+$/
    lines.shift
  end

  file_name = File.basename(file)
  class_name = File.basename(file, '.*')

  file_license = license.sub('<File>', file_name).sub('<Class>', class_name)

  File.write(file, file_license + "\n\n" + lines.join)
end
