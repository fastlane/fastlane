require 'prawn'

module Deliver
  class PdfGenerator

    # Renders all data available in the Deliverer to quickly see if everything was correctly generated.
    # @param deliverer [Deliver::Deliverer] The deliver process on which based the PDF file should be generated
    # @param export_path (String) The path to a folder where the resulting PDF file should be stored. 
    def render(deliverer, export_path = nil)
      export_path ||= '/tmp'
      
      resulting_path = "#{export_path}/#{Time.now.to_i}.pdf"
      Prawn::Document.generate(resulting_path) do

        counter = 0
        deliverer.app.metadata.information.each do |language, content|
          title = content[:title][:value] rescue ''

          Helper.log.info("[PDF] Exporting locale '#{language}' for app with title '#{title}'")

          font_size 20
          text "#{language}: #{title}"
          stroke_horizontal_rule
          font_size 14

          move_down 30

          col1 = 200
          modified_color = '0000AA'
          standard_color = '000000'

          prev_cursor = cursor.to_f
          # Description on right side
          bounding_box([col1, cursor], width: 340.0) do
            if content[:description] and content[:description][:value]
              text content[:description][:value], size: 6, color: (content[:description][:modified] ? modified_color : standard_color)
            end
            move_down 10
            stroke_horizontal_rule
            move_down 10
            text "Changelog:", size: 8
            move_down 5
            if content[:version_whats_new] and content[:version_whats_new][:value]
              text content[:version_whats_new][:value], size: 6, color: (content[:version_whats_new][:modified] ? modified_color : standard_color)
            end
          end
          title_bottom = cursor.to_f

          move_cursor_to prev_cursor

          all_keys = [:support_url, :privacy_url, :software_url, :keywords]

          all_keys.each_with_index do |key, index|
            value = content[key][:value] rescue nil
            
            color = (content[key][:modified] ? modified_color : standard_color rescue standard_color)

            bounding_box([0, cursor], width: col1) do
              key = key.to_s.gsub('_', ' ').capitalize

              width = 200
              size = 10

              if value.kind_of?Array
                # Keywords only
                text "#{key}:", color: color, width: width, size: size
                move_down 2

                keywords_padding_left = 5
                bounding_box([keywords_padding_left, cursor], width: (col1 - keywords_padding_left)) do
                  value.each do |item|
                    text "- #{item}", color: color, width: width, size: (size - 2)
                  end
                end
              else
                # Everything else
                next if value == nil or value.length == 0
                
                text "#{key}: #{value}", color: color, width: width, size: size
              end
            end
          end

          image_width = bounds.width / 6 # wide enough for 5 portrait screenshots to fit
          padding = 10
          last_size = nil
          top = [cursor, title_bottom].min - padding
          index = 0
          previous_image_height = 0
          move_cursor_to top
          
          if (content[:screenshots] || []).count > 0
            content[:screenshots].sort_by { |a| [:screen_size, :path] }.each do |screenshot|
              
              if last_size and last_size != screenshot.screen_size
                # Next row (other simulator size)
                top -= (previous_image_height + padding)
                move_cursor_to top
                
                if top < previous_image_height
                  start_new_page
                  top = cursor
                end
                
                index = 0
              end

              image screenshot.path, width: image_width, 
                                        at: [(index * (image_width + padding)), top]

              original_size = FastImage.size(screenshot.path)
              previous_image_height = (image_width.to_f / original_size[0].to_f) * original_size[1].to_f

              last_size = screenshot.screen_size
              index += 1
            end
          else
            move_cursor_to top
            text "No screenshots passed. Is this correct? They will get removed from iTunesConnect."
          end

          counter += 1
          if counter < deliverer.app.metadata.information.count
            start_new_page
          end
        end
      end

      return resulting_path
    end
  end
end