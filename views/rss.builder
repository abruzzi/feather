xml.instruct! :xml, :version => '1.0'

xml.rss :version => '2.0' do
    xml.channel do
        @notes.each do |note|
            xml.title note.content
            xml.link "#{request.url.chomp request.path_info}/#{note.id}"
            xml.pubDate Time.parse(note.created_at.to_s).rfc822
            xml.description note.content
        end
    end
end
