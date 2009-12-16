module Coloration
  class JEditTheme < Theme
    def self.editor_name
      "JEdit"
    end
    
    def self.parse(text)
      raise RuntimeError.new("Not implemented yet")
    end

    def escape(value)
      value.gsub(':', '\:').gsub('#', '\#').strip
    end

    def format_ui(name, value)
      case value
      when Color::RGB
        value = value.html
      else
        value = value.to_s
      end
      "#{name}=#{escape(value)}"
    end
    
    def format_item(name, style)
      raise RuntimeError.new("Style for #{name} is missing!") if style.nil?
      "#{name}=#{format_style(style)}"
    end
    
    def format_style(style)
      s = ""
      s << " color:#{style.foreground.html}" if style.foreground
      s << " bgColor:#{style.background.html}" if style.background
      if s.size > 0
        s << " style:"
        s << "b" if style.bold
        s << "u" if style.underline
        s << "i" if style.italic
      end
      escape(s)
    end
    
    def format_comment(text)
      "\# #{text}"
    end
    
    def build
      ui = {
        "scheme.name"             => @name,
        "view.fgColor"            => @ui[:foreground],
        "view.bgColor"            => @ui[:background],
        "view.caretColor"         => @ui[:caret],
        "view.selectionColor"     => @ui[:selection],
        "view.eolMarkerColor"     => @ui[:invisibles],
        "view.lineHighlightColor" => @ui[:line_highlight],
      }

      ui.keys.each do |key|
        add_line(format_ui(key, ui[key]))
      end

      items = {
        "view.style.comment1"     => @items[:comment], # #foo
        "view.style.literal1"     => @items[:string], # "foo"
        "view.style.label"        => @items["constant.other.symbol"], # :foo
        "view.style.digit"        => @items["constant.numeric"], # 123
        "view.style.keyword1"     => @items["keyword.control"], # class, def, if, end
        "view.style.keyword2"     => @items["support.function"], # require, include
        "view.style.keyword3"     => @items["constant.language"], # true, false, nil
        "view.style.keyword4"     => @items["variable.other"], # @foo
        "view.style.operator"     => @items["keyword.operator"], # = < + -
        "view.style.function"     => @items["entity.name.function"], # def foo
        "view.style.literal3"     => @items["string.regexp"], # /jola/
#         "view.style.invalid"      => @items["invalid"], # errors etc
        #"view.style.literal4" => :constant # MyClass, USER_SPACE
        "view.style.markup"       => @items["meta.tag"] || @items["entity.name.tag"] # <div>
        #TODO: gutter etc
      }
      
      default_style = Style.new
      default_style.foreground = @ui[:foreground]
      items.keys.each do |key|
        add_line(format_item(key, items[key] || default_style))
      end
    end
  end
end